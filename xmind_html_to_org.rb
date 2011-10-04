#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'

def traverse(doc)
  buf = ""
  doc.each do |elem|
    h1 = Hpricot(elem.to_html).search("h1")
    if h1.length > 0
      buf += "\n"
      buf += "* " + clean(h1) + "\n"
      buf += "\n"
    end
    
    h2 = Hpricot(elem.to_html).search("h2")
    if h2.length > 0
      buf += "\n"
      buf += "** " + clean(h2) + "\n"
      buf += "\n"
    end

    h3 = Hpricot(elem.to_html).search("h3")
    if h3.length > 0
      buf += "*** " + clean(h3)
      buf += "\n"
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


