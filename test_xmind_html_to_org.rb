#!/usr/bin/env ruby 
# -*- coding: utf-8 -*-
$KCODE = 'UTF8'

require 'test/unit'
require 'xmind_html_to_org.rb'

class TestXMindHTMLToOrg < Test::Unit::TestCase
  def setup
    @html2org = XMindHTMLToOrg.new
    @html2org_no_autoindent = XMindHTMLToOrg.new(false)
    @test_html = open("test.html").read
    @doc = Nokogiri::HTML.parse(@test_html,
                               nil, "utf-8")
    @file_test_org = open("test_true.org")
    @file_test_org_no_autoindent = open("test_true_no_autoindent.org")
  end


  def test_clean
    
    # No.1
    elem = Nokogiri::XML('<a name="1f207dbj9otvbsfjfu9042km0a">PDCAの習慣を付ける</a>',
                         nil, "utf-8") # , Nokogiri::XML::ParseOptions::STRICT
    assert_equal('PDCAの習慣を付ける', URI.decode(@html2org.clean(elem)), "No.1 failed")
    
    # No.2
    elem = Nokogiri::XML('<html><head></head><body><div><a name="1f207dbj9otvbsfjfu9042km0a">PDCAの習慣を付ける</a></div></body></html>',
                         nil, "utf-8")
    assert_equal('PDCAの習慣を付ける', URI.decode(@html2org.clean(elem)), "No.2 failed")

    # No.3
    elem = Nokogiri::HTML("<h1 align=\"center\" class=\"root\">\n<a name=\"1eqj8jeavqttrm82rbn6ndnfol\">てすと</a>\n</h1>",
                         nil, "utf-8")
    assert_equal('てすと', URI.decode(@html2org.clean(elem)), "No.3 failed")    
    
  end

  def test_traverse
    html = @html2org.traverse(@doc.search("/html/body"))
    assert_equal(@file_test_org.read, html, "#1: auto indent")

    html_no_autoindent = @html2org_no_autoindent.traverse(@doc.search("/html/body"))
    assert_equal(@file_test_org_no_autoindent.read, html, "#2: no auto indent")

  end

  def test_put_header
    assert_equal("\n* ほげ\n\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h1'},"ほげ"), "#1")
    assert_equal("\n* ほげ\n\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h1'},"ふが"), "#1")
    assert_equal("\n** ほげ\n\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h2'},"ほげ"), "#2")
    assert_equal("\n** ほげ\n\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h2'},"ふが"), "#2")
    assert_equal("*** ほげ\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h3'},"ほげ"), "#3")
    assert_equal("**** ほげ\n", @html2org.put_header({'text' => "ほげ", 'tag' => 'h3'},"ふが"), "#4")
    assert_equal("", @html2org.put_header({'text' => "", 'tag' => 'h3'},"ふが"), "#5")
    assert_equal("", @html2org.put_header({'text' => "", 'tag' => 'h3'},""), "#6")
    
  end
end
