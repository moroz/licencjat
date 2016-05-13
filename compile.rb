#!/usr/bin/env ruby

def read_patterns(filename)
  hash = {}
  File.open(filename).each_line do |line|
    array = line.chomp.split(/\t+|\s{3,}/)
    if array.length == 1
      hash.merge!(Hash[array[0],array[0]])
    else
      hash.merge!(Hash[*array])
    end
  end
  hash
end

def read_paragraphs(*filenames)
  array = filenames.map do |file|
    File.read(file).split(/\n{2,}/)
  end
  array.flatten
end

def search_pattern(text)
  Regexp.new('(?<=\\\\textit\{|[^\{])(' + text + ')(?!\\\\index\\{)')
end

def sub_pattern(text)
  '\1\index{' + text + '}'
end

def remove_comment_blocks(str)
  str.gsub(/\\if 0.+\\fi/m, '')
end

default_files = %w( introduction.tex chapter_one.tex chapter_two.tex chapter_three.tex )
input_files = ARGV.empty? ? default_files : ARGV
paragraphs = read_paragraphs(*input_files)
patterns = read_patterns("patterns.txt")

# p patterns
patterns.each do |key,val|
  paragraphs = paragraphs.map do |par|
    par.sub search_pattern(key), sub_pattern(val)
  end
end
File.write "output_with_index.tex", paragraphs.join("\n\n")
revision = `git rev-parse HEAD`
File.write "revision.tex", revision
system "xelatex praca"
system "xelatex praca_with_index"
system "makeindex praca_with_index.idx"
system "xelatex praca_with_index"
system "xelatex praca_with_index"

File.delete(*Dir['./*.log', '*_with_index.aux', './*.ilg', './*.idx', './*.ind'])
# puts paragraphs.join("\n\n")
