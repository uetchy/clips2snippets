#!/usr/bin/env ruby
# coding: utf-8

require "tmpdir"
require "plist"

srcfile = ARGV.first

unless srcfile
  puts "Usage: clips2snippets [filename.clips]"
  exit
end

Dir.mktmpdir do |tmpdir|
  clipsfile = File.join(tmpdir, 'clips')
  system "plutil -convert xml1 '#{File.expand_path(srcfile)}' -o '#{clipsfile}'"
  plist = Plist::parse_xml(clipsfile)
  
  objects = plist["$objects"]
  indexes = []
  objects.each_with_index do |e, n|
    if e.class == Hash && e.keys.include?("title")
      indexes << n
    end
  end
  
  indexes.each_with_index do |index, n|
    puts "this is hash"
    eor = (indexes[n+1])? indexes[n+1].to_i : objects.size
    #placeholders = objects[index+4, eor]
    #placeholders.pop
    title = objects[index+1]
    code = objects[index+2]
    trigger = objects[index+3]
    
    # ST2 Snippet
    st2_snippet = "<snippet>\n  <content><![CDATA[\n%s\n]]></content>\n  <tabTrigger>%s</tabTrigger>\n  <description>%s</description>\n  <!-- <scope>[add here]</scope> -->\n</snippet>"
    snippet = st2_snippet % [code, trigger, title]
    open("#{title}.sublime-snippet", "w").puts snippet
  end
end