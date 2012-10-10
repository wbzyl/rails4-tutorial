# -*- coding: utf-8 -*-

# Emacs: Ctrl+u M-|
#   shell-command-on-region and insert the output in the current buffer

require "prawn"

require "csv"
require "pp"

Prawn::Document.generate("lista.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  font_size 10

  if ARGV.length == 0
    puts "Usage: ruby lista.rb NAME.CSV"
    exit
  else
    # csv_file = "asi2011.csv"
    csv_file = ARGV[0]
  end

  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

  csv_data = open(csv_file).readlines
  body = CSV.parse(csv_data.join)

  nazwisko = make_cell :content => "nazwisko"
  imie = make_cell :content => "imię"
  repo_url = make_cell :content => "url repo na github.com"

  index = 0
  counted = body.map do |row|
    # row: Bzyl,Włodzimierz,wbzyl,rails4-tutorial,pon12
    index += 1
    [index.to_s, row[0], row[1], "#{row[2]}/#{row[3]}", row[4]]
  end
  # counted.unshift ["0", "Bzyl", "Włodzimierz", "wbzyl/trekking", ""]

  counted.unshift ["", nazwisko, imie, repo_url, "lab"]

  table(counted, :header => true,
     :width => 540,
     :column_widths => {0 => 32},
     :cell_style => {:height => 36, :padding => [12, 6, 12, 6], :overflow => :shrink_to_fit}
  )

end

puts "--> lista.pdf"
