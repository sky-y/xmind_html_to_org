#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
$KCODE = 'UTF8'


require 'rubygems'
require 'nokogiri'
require 'URI'


class XMindHTMLToOrg
  ## autoIndent: enable "sloopy" auto indent or not
  ## latexHeader: enable a header for LaTeX
  def initialize(autoIndent = true, latexHeader = true)
    @traversed_img = ""
    @h_queue = []
    @autoIndent = autoIndent
    @latexHeader = latexHeader
  end

  ## traverse HTML document
  ##
  ## return: formatted Org text
  def traverse(doc)
    buf = ""

    doc.search("body/*").each do |elem|
      buf += get_new_text(elem)
    end
    
    buf += put_header(@h_queue.shift, @traversed_img)

    return buf
  end

  ## parse HTML element and get a formatted line
  ## (NOTICE: evaluation of h1-h3 is delayed for auto indent
  ##          because the div/img block needs to be evaluated
  ##          before evaluation of h1-h3.)
  ## 
  ## elem: part of Nokogiri::XML::Node
  ## return: a formatted line (indented with '*')
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
      if @h_queue.length > 0
        text = put_header(@h_queue.shift, @traversed_img)
      end

      new_header = { "text" => clean(h[0]), "tag" => "h1" }
      @h_queue.push(new_header)

      return text
    end

    ## h2
    h = e.search("h2") if e != nil
    if h.length > 0
      if @h_queue.length > 0
        text = put_header(@h_queue.shift, @traversed_img)
      end
      
      new_header = { "text" => clean(h[0]), "tag" => "h2" }
      @h_queue.push(new_header)
      
      return text
    end

    ## h3
    h = e.search("h3") if e != nil
    if h.length > 0
      if @h_queue.length > 0
        text = put_header(@h_queue.shift, @traversed_img)
      end

      new_header = { "text" => clean(h[0]), "tag" => "h3" }
      @h_queue.push(new_header)

      return text
    end    

    ## div/img
    if @autoIndent
      div = e.search("div") if e != nil
      if div.length > 0
        if div.attr('class').to_s =~ /.*[Oo]verview/
          img = e.search("img") if e != nil
          
          if img.length > 0 
            URI.decode(img.attr('src').to_s) =~ /(.*)\/images\/(.*)\.jpg/
            @traversed_img = $2
          end

          if @h_queue.length > 0
            text = put_header(@h_queue.shift, @traversed_img)
          end
        end
      end
    end

    return text
  end

  ## get formatted line (with '*')
  def put_header(traversed_header, traversed_img = "")
    buf = ""

    #print "put_header("+traversed_header['text']+","+traversed_img+"):"
    
    if traversed_header['text'].length > 0
      
      if traversed_header['tag'] == 'h1'
        ## put header for LaTeX
        if @latexHeader
          buf += <<"DOC"
#+TITLE: #{traversed_header['text']}
#+AUTHOR: Author
#+DATE: \\today
#+LATEX_CLASS: jsarticle
#+OPTIONS: toc:nil


DOC
        end

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
    
    return buf
  end

  ## remove all tags and leave inner text
  ##
  ## doc: XML document (Nokogiri::XML::Node)
  def clean(doc)
    return "" if doc == nil
      
    buf = ""
    
    doc.traverse do |elem|
      elem.to_html # needed, but I don't know why...

      if elem.children.length > 0 
        next
      else # when elem is a leaf node
        t = elem.to_s
        buf += t.chomp if t != nil
      end
    end

    return buf
  end
  
end

## changes extension of the filename
## example: filename="foo.html", ext=".org" => foo.org
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


