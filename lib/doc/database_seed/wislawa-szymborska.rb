# -*- coding: utf-8 -*-
#
# A. Bikont, J. Szczęsna.
# Pamiątkowe rupiecie. Biografia Wisławy Szymborskiej.
# strony 350, 352

require 'faker'

#platitudes = File.readlines('trawestowanie-sloganu.u8', "\n%\n")
platitudes = File.readlines('menu.u8', "\n%\n")

platitudes.map do |p|
  reg = /(.+?)\n(?:\s+--\s(.+)\n)?%/m
  m = p.match(reg)

  # puts m.inspect

  if m
    quotation = m[1]
    if m[2]
      source = m[2]
    else
      source = Faker::Name.name
    end

    puts "#{quotation}\n\t#{source}"
    # Fortune.create quotation: quotation, source: source
  end

end
