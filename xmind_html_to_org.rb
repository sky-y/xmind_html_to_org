#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'
require 'URI'

def traverse(doc)
  buf = ""
  traversed_text = ""
  doc.each do |elem|
    e = Hpricot(elem.to_html)
    h1 = e.search("h1")
    if h1.length > 0
      buf += "\n"
      buf += "* " + clean(h1) + "\n"
      buf += "\n"
    end
    
    h2 = e.search("h2")
    if h2.length > 0
      buf += "\n"
      buf += "** " + clean(h2) + "\n"
      buf += "\n"
    end

    div = e.search("div")
    if div != nil
      if div.attr('class') =~ /overview/
        img_src = e.search("img")
        if img_src.length > 0 
          URI.decode(img_src.attr('src')) =~ /(.*)\/images\/(.*)\.jpg/
          puts $2
          buf += "*** " + $2
          buf += "\n"
          traversed_text = ""
        end
      end
    end

    h3 = e.search("h3")
    if h3.length > 0
      if traversed_text == clean(h3)
        traversed_text = ""
        ## skip
      else
        buf += "*** " + clean(h3)
        buf += "\n"
      end
    end
  end

  return buf
end


def clean(doc)
  return "" if doc == nil
  
  buf = ""
  Hpricot(doc.inner_html).traverse_text{|elem| buf += elem.to_s.chomp}

  return buf
end

def change_ext(filename, ext)
  filename.gsub(/\.[^.]+$/, ext)
end


# main
if __FILE__ == $PROGRAM_NAME
  html_file = ARGV[0]
  
  doc = Hpricot(open(html_file))
  if ARGV.length <= 1
    org_file = change_ext(html_file, ".org")
  else
    org_file = ARGV[1]
  end
  
  File::open(org_file, "w") do |f|
    f.print traverse(doc.search("/html/body/"))
  end
  
end


