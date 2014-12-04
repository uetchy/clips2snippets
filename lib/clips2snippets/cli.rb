# coding: utf-8

require 'clips2snippets'
require 'tmpdir'
require 'plist'
require 'thor'

module Clips2Snippets
  class CLI < Thor
    desc 'gen FILE', 'Convert Coda Clips to Sublime Text Snippets'
    def gen(srcfile)

      unless srcfile
        puts 'Usage: clips2snippets [filename.clips]'
        exit
      end

      Dir.mktmpdir do |tmpdir|
        clipsfile = File.join(tmpdir, 'clips')
        system "plutil -convert xml1 '#{File.expand_path(srcfile)}' -o '#{clipsfile}'"
        plist = Plist::parse_xml(clipsfile)

        objects = plist['$objects']
        clips_title = objects[2]

        indexes = []
        objects.each_with_index do |e, n|
          if e.class == Hash && e.keys.include?('title')
            indexes << n
          end
        end

        indexes.each_with_index do |index, n|
          eor = (indexes[n+1])? indexes[n+1].to_i - 3 : objects.size

          title = objects[index+1]
          code = objects[index+2]
          trigger = objects[index+3]
          puts "Found Clip: #{title}"

          # Check for existence of placeholders
          ranges = []
          placeholders = objects[index+4, eor]
          placeholders.each_with_index do |ph, i|
            if ph.class == Hash && ph.has_key?('range')
              range = placeholders[i+1].scan(/\{(\d+), (\d+)\}/)[0].map{|s| s.to_i}
              ranges << [range, ph['type']]
            end
          end

          # Replace placeholders
          curr = ranges.size
          ranges.reverse.each do |range, type|
            # 1 => Created at
            # 2 => Filename(*)
            # 3 => Parent folder
            # 4 => Website name
            # 5 => Local url
            # 6 => Remote url
            # 7 => Author(*)
            # 8 => SCM Revision
            # 9 => Insert locator(*)
            # 10 => Selection(*)
            # 11 => Text behind it
            # 12 => Custom(*)
            # 13 => Clipboard

            case type
            when 2
              code[range[0], range[1]] = "${#{curr}:$TM_FILENAME}"
            when 7
              code[range[0], range[1]] = "${#{curr}:$TM_FULLNAME}"
            when 10
              code[range[0], range[1]] = "${#{curr}:$SELECTION}"
            when 12
              code[range[0], range[1]] = "${#{curr}:#{code[range[0], range[1]]}}"
            else
              code[range[0], range[1]] = "${#{curr}}"
            end

            curr -= 1
          end

          # Convert into ST2 Snippet
          save_dir = "Snippets - #{clips_title}"
          Dir.mkdir save_dir unless FileTest.exists? save_dir
          st2_snippet = "<snippet>\n  <content><![CDATA[\n%s\n]]></content>\n  <tabTrigger>%s</tabTrigger>\n  <description>%s</description>\n  <!-- <scope>[add here]</scope> -->\n</snippet>"
          snippet = st2_snippet % [code, trigger, title]
          open(File.join(save_dir, "#{title}.sublime-snippet"), "w").puts snippet
        end
      end

      say "Finished converting all of Clips!", :green
    end
  end
end
