# encoding: utf-8

require 'yajl/json_gem'
require 'tweetstream'

require 'tire'

class Status
  include Tire::Model::Persistence

  property :id
  property :text
  property :screen_name
  property :created_at
  property :entities

  property :user
end

#puts Status.methods

s = Status.first
puts s.to_json

# puts s.methods

s.destroy

Tire.index('statuses').refresh

s = Status.first

puts s.to_json

s.update_attributes text: "[Censored]"

puts s.to_json

#puts Status.first.to_json

# puts Status.find("157236146202624000").inspect

# puts Status.all.inspect

__END__

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

# http://www.elasticsearch.org/guide/reference/mapping/date-format.html
# http://joda-time.sourceforge.net/api-release/org/joda/time/format/ISODateTimeFormat.html#dateOptionalTimeParser%28%29

s = Tire.search('statuses') do
  query do
    string "created_at:[2012-01-12T14:00:00 TO 2012-01-12T14:24:00]"
  end
  size 4  # return that many statuses
  from 2  # offset
end

puts JSON.pretty_generate(s.to_hash)
#puts s.to_curl

s.results.each do |document|
  puts "#{magenta { document.created_at }}: #{document.text}"
end

# include Tire::Persistence::Pagination
# size per_page

s = Tire.search('statuses', per_page: 10, page: 3) do
  query { string 'mongo*' }
  # query { all }
  #filter :range, created_at: {to: Time.now.iso8601, from: (Time.now - 3600).iso8601}
  filter :range, created_at: {to: "2012-01-13T18:00:00", from: "2012-01-13T16:00:00"}
  sort { by :created_at, 'desc' }
  size options[:per_page]
  from (options[:page] - 1) * options[:per_page]

  highlight :text, :options => { :tag => '<strong class="highlight">' }
end

puts JSON.pretty_generate(s.to_hash)
#puts s.to_curl

puts cyan {"\nHighligted:\n"}
s.results.each do |document|
  puts "#{magenta { document.created_at }}: #{document.text}"
end

puts cyan {"\nFaceted search:\n"}

# s = Tire.search 'statuses', type: 'rails' do
s = Tire.search 'statuses' do
  # query { all } # this is the default value
  # filter :range, created_at: {to: "2012-01-13", from: "2012-01-12"}

  # and retrieve the counts “bucketed” by `entities.hashtags.text`.
  facet('hashtags') { terms 'entities.hashtags.text', size: 16 }
  facet('timeline') { date  :created_at, interval: 'day' }
end

#puts "Found #{s.results.count} statuses" # s.results.map(&:text).join("\n")

puts JSON.pretty_generate(s.to_hash)
#puts s.to_curl

puts cyan {"\nCounts by hashtags:\n"}
s.results.facets['hashtags']['terms'].each do |facet|
  puts "#{facet['term'].ljust(16)} #{facet['count']}"
end
puts cyan {"\nTimeline: \#statuses per day:\n"}
s.results.facets['timeline']['entries'].each do |facet|
  puts "#{Time.at(facet['time']/1000).utc} #{facet['count']}"
end

puts ""
