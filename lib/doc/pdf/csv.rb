require "open-uri"

require "prawn"

require "csv"
require "pp"


# link do manuala:
#  https://github.com/sandal/prawn/wiki/

start_time = Time.now

Prawn::Document.generate("currency.pdf", :page_layout => :landscape) do
  market_url = "http://bankofcanada.ca/en/markets/csv/exchange_eng.csv"
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

  csv_data = open(market_url).readlines

  # skip comments
  headers = CSV.parse(csv_data[6])
  # pp headers

  # data starts at 8th line
  body = CSV.parse(csv_data[7..-1].join)
  table body, :header => headers.first
end

puts "took #{Time.now - start_time} seconds to generate."
