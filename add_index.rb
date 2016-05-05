#!/usr/bin/env ruby

def read_patterns(filename)
  hash = {}
  File.open(filename).each_line do |line|
    array = line.chomp.split(/\t+|\s{3,}/)
    if array.length == 1
      hash.merge Hash[array[0],array[0]]
    else
      hash.merge Hash[*array]
    end
  end
end

def read_paragraphs(*filenames)
  array = filenames.map do |file|
    str = remove_comment_blocks(File.read(file))
    paragraphs = str.split(/\n{2,}/)
  end
  array.flatten
end

def search_pattern(text)
  Regexp.new('(?<=\\\\textit\{|[^\{])(' + text + ')(?!\\\\index\{|\\})')
end

def sub_pattern(text)
  '\1\index{' + text + '}'
end

def remove_comment_blocks(str)
  str.gsub(/\\if 0.+\\fi/m, '')
end

input_files = ARGV.empty? ? "sample.txt" : ARGV
paragraphs = read_paragraphs(input_files)
patterns = read_patterns("patterns.txt")

patterns.each do |key,val|
  paragraphs = paragraphs.map do |par|
    par.sub search_pattern(key), sub_pattern(val)
  end
end
puts paragraphs.join("\n\n")
