# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# $ locate platitudes.u8
#   /usr/share/games/fortune/platitudes.u8

platitudes = File.readlines('/usr/share/games/fortune/platitudes.u8', "\n%\n")
platitudes.map do |p|
  reg = /\t?(.+)\n\t\t--\s*(.*)\n%\n/m
  m = p.match(reg)
  if m
    Fortune.create :quotation => m[1], :source => m[2]
  else
    Fortune.create :quotation => p[0..-4], :source => Faker::Name.name
  end
end
