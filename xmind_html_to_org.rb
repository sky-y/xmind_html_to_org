#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
$KCODE = 'UTF8'

require 'rubygems'
require 'nokogiri'
require 'URI'


class XMindHTMLToOrg
  def initialize(autoIndent = true)
    # @traversed_header = {'text' => "", 'tag' => "" }
    @traversed_img = ""
    @h3_queue = []
    @autoIndent = autoIndent
  end
  
  def traverse(doc)
    buf = ""

    doc.search("body/*").each do |elem|
      #puts "elem: " + URI.decode(elem.to_s)
      
      #e.to_html
      #e = elem
      #puts e.to_s

      buf += get_new_text(elem)
    end
    
    buf += put_header(@h3_queue.shift, @traversed_img)

    return buf
  end

  
  def get_new_text(elem = nil)
    if elem != nil
      e = Nokogiri.parse(elem.to_html, nil, "utf-8")
    else
      e = nil
      h = []
      div = []
      img = []
    end
    
    text = ""
    new_header = {'text' => "", 'tag' => "" }

    ## h1
    h = e.search("h1") if e != nil
    if h.length > 0
      if @h3_queue.length > 0
        text = put_header(@h3_queue.shift, @traversed_img)
      end

      new_header = { "text" => clean(h[0]), "tag" => "h1" }
      @h3_queue.push(new_header)

      return text
      
    end

    ## h2
    h = e.search("h2") if e != nil
    if h.length > 0
      if @h3_queue.length > 0
        text = put_header(@h3_queue.shift, @traversed_img)
      end
      
      new_header = { "text" => clean(h[0]), "tag" => "h2" }
      @h3_queue.push(new_header)
      
      return text
    end

    ## h3
    h = e.search("h3") if e != nil
    if h.length > 0
      if @h3_queue.length > 0
        text = put_header(@h3_queue.shift, @traversed_img)
      end

      new_header = { "text" => clean(h[0]), "tag" => "h3" }
      @h3_queue.push(new_header)

      return text
    end    

    ## div/img
    if @autoIndent
      div = e.search("div") if e != nil
      if div.length > 0
        if div.attr('class').to_s =~ /.*[Oo]verview/
          #puts "div.class: " + div.attr('class')
          
          img = e.search("img") if e != nil
          
          if img.length > 0 
            URI.decode(img.attr('src').to_s) =~ /(.*)\/images\/(.*)\.jpg/
            @traversed_img = $2
            #puts "@traversed_img: " + @traversed_img
          end

          if @h3_queue.length > 0
            text = put_header(@h3_queue.shift, @traversed_img)
          end
          
        end
      end
    end
    


    return text
    
  end

  def put_header(traversed_header, traversed_img = "")
    buf = ""

    #print "put_header("+traversed_header['text']+","+traversed_img+"):"
    
    if traversed_header['text'].length > 0
      
      if traversed_header['tag'] == 'h1'
        buf += "\n"
        buf += "* " + traversed_header['text'] + "\n"
        buf += "\n"
      elsif traversed_header['tag'] == 'h2'
        buf += "\n"
        buf += "** " + traversed_header['text'] + "\n"
        buf += "\n"
      elsif traversed_header['tag'] == 'h3'
        if traversed_header['text'] == traversed_img 
          buf += "*** " + traversed_header['text'] + "\n"
        else 
          if @autoIndent
            buf += "**** " + traversed_header['text'] + "\n"
          else
            buf += "*** " + traversed_header['text'] + "\n"
          end
        end
      end
    end
    
    #puts buf
    return buf
end

  
  def clean(doc)
    return "" if doc == nil
      
    buf = ""
    #doc.to_html
    
    doc.traverse do |elem|
      #print "traverse: "+elem.to_html; puts
      elem.to_html # needed

      if elem.children.length > 0 
        next
      else # elem is a leaf node
        t = elem.to_s
        buf += t.chomp if t != nil
      end
    end

    return buf
  end
  
end

def change_ext(filename, ext)
  filename.gsub(/\.[^.]+$/, ext)
end


# main
if __FILE__ == $PROGRAM_NAME
  html_file = ARGV[0]
  if ['','0','false','f','no','n'].include?(ARGV[1])
    html2org = XMindHTMLToOrg.new(false)
  else
    html2org = XMindHTMLToOrg.new(true)
  end
  
  
  doc = Nokogiri(open(html_file))
  if ARGV.length <= 1
    org_file = change_ext(html_file, ".org")
  else
    org_file = ARGV[1]
  end
  
  File::open(org_file, "w") do |f|
    f.print html2org.traverse(doc.search("html/body"))
  end
  
end


