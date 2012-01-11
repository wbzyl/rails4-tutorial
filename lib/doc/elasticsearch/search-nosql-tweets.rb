# encoding: utf-8

require 'yajl/json_gem'
require 'tweetstream'

require 'tire'

require 'ansi/code'
include ANSI::Code

# s = Tire.search('statuses') do
#   query do
#     string "elasticsearch"
#   end
# end

# s.results.each do |document|
#   puts "#{document.text}"
# end

# s = Tire.search('statuses', type: 'couchdb') do
#   query do
#     string "elasticsearch"
#   end
# end

# s.results.each do |document|
#   puts "#{document.text}"
# end

s = Tire.search('statuses') do
  query do
    string "created_at:[2011-01-11T21:17:00 TO 2012-01-11T21:20:00]"
  end
end

s.results.each do |document|
  puts "#{yellow { document.created_at }}: #{document.text} matched #{document.inspect}"
  puts "----"
  puts "#{document.inspect}"
  puts "===="end
