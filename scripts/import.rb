#!/usr/bin/env ruby
require 'yaml'

Encoding.default_external = 'iso-8859-1'

def parse_file path, &block
  puts "\nParsing #{path} "
  File.readlines(path).each_with_index do |line, i|
    next if i == 0

    line.to_s.match(%r|<b>(.*)\s</b>(.*)|i) do |matches|
      word, definition = matches[1..2].map { |s| s.encode('utf-8', 'iso-8859-1') }
      block.call word, definition, i
      print "." if i % 10 == 0
    end
  end
end

`rm db/development.sqlite`
require File.expand_path("./lib/environment")

parse_file "assets/dansk-engelsk.html" do |word, definition, i|
  Word.create word: word, definition: definition, lang: 'da'
end

parse_file "assets/engelsk-dansk.html" do |word, definition, i|
  Word.create word: word, definition: definition, lang: 'en'
end
