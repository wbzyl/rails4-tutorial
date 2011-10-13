# -*- coding: utf-8 -*-

require "prawn"
#require "iconv"

start_time = Time.now

# fonty: /home/wbzyl/.rvm/gems/ruby-1.9.2-p290/gems/prawn-0.12.0/data/fonts/

Prawn::Document.generate("utf8.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "ZAŻŁÓĆ GĘŚŁĄ JAŹŃ zażłóć gęśłą jaźń"
end

puts "took #{Time.now - start_time} seconds to generate."
