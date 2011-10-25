# -*- coding: utf-8 -*-

require "prawn"
require "prawn/layout"

require 'pp'

# fonty: /home/wbzyl/.rvm/gems/ruby-1.9.2-p290/gems/prawn-0.12.0/data/fonts/

Prawn::Document.generate("tables.pdf") do
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  text "Default font: #{font.inspect}"
  font_size 10
  text "Set to 10 points: #{font.inspect}"

  move_down 18

  table([
         ["krótki", "krótki", "dłuuuuuuuuuuuuuuuuuugi"],
         ["krótki", "dłuuuuuuuuuuuuuuuuuugi", "krótki"],
         ["krótki", "krótki", "dłuuuuuuuuuuuuuuuuuugi"]
  ])

  move_down 72

  t = make_table([
         ["pierwszy wiersz"],
         ["drugi wiersz"]
  ])
  t.draw

  move_down 36

  nazwisko = make_cell :content => "Nazwisko"
  imie = make_cell :content => "Imię"
  repo = make_cell :content => "url repozytorium na github.com"

  kowalski = make_cell :content => "Kowalski"
  jan = make_cell :content => "Jan"
  trekking = make_cell :content => "git://github.com/darkwader/trekking.git"

  data = [
     [" ", nazwisko, imie, repo, "==> Uwagi <=="],
     ["1", "Bzyl", "Włodzimierz", "git://github.com/wbzyl/trekking.git", ""]
  ]
  data += [["", "", "", "", ""]] * 2

  table(data, :header => true,
        :width => 540,
        :column_widths => {0 => 32},
        :cell_style => {:height => 36, :padding => [12, 6, 12, 6], :overflow => :shrink_to_fit}
  )

  # defined in example_helper.rb
  # stroke_axis

end
