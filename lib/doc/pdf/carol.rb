require "prawn"
require "open-uri"
require "iconv"

start_time = Time.now

Prawn::Document.generate("carol.pdf") do
  source = open("http://www.gutenberg.org/files/46/46-8.txt").read
  book = Iconv.conv("UTF-8", "ISO-8859-1", source)
  text(book)
end

puts "took #{Time.now - start_time} seconds to generate."
