#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'hpricot'

def traverse(doc)
  doc.each do |elem|
    h1 = Hpricot(elem.to_html).search("h1")
    if h1.length > 0
      puts
      print "*" + clean(h1); puts
      puts
    end
    
    h2 = Hpricot(elem.to_html).search("h2")
    if h2.length > 0
      puts
      print "**" + clean(h2); puts
      puts
    end

    h3 = Hpricot(elem.to_html).search("h3")
    if h3.length > 0
      print "***" + clean(h3)
      puts
    end
  end
  
end


def clean(doc)
  return "" if doc == nil
  
  buf = ""
  Hpricot(doc.inner_html).traverse_text{|elem| buf += elem.to_s.chomp}

  return buf
end


file = ARGV[0]
doc = Hpricot(open(file))


traverse(doc.search("/html/body/"))

