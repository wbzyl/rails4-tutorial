# This code uses the Faker library.
# Please, add the 'faker' gem to Gemfile.

# $ locate platitudes.u8
#   /usr/share/games/fortune/platitudes.u8
# Brakuje pliku platitudes.u8
# $ sudo yum install fortune-mod  # Fedora

platitudes = File.readlines('/usr/share/games/fortune/platitudes.u8', "\n%\n")
# platitudes = File.readlines(Rails.root.join('db', 'platitudes.u8'), "\n%\n")

platitudes.map do |p|
  reg = /\t?(.+)\n\t\t--\s*(.*)\n%\n/m
  m = p.match(reg)
  if m
    Fortune.create :quotation => m[1], :source => m[2]
  else
    Fortune.create :quotation => p[0..-4], :source => Faker::Name.name
  end
end
