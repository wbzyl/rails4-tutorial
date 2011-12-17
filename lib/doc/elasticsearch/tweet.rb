# -*- coding: utf-8 -*-

require 'tire'
require 'yajl/json_gem'

Tire.configure do
  # By default, at the _info_ level, only the `curl`-format of request and
  # basic information about the response will be logged:
  #
  # # 2011-04-24 11:34:01:150 [CREATE] ("tweets")
  # #
  # curl -X POST "http://localhost:9200/tweets"
  #
  # # 2011-04-24 11:34:01:152 [200]
  #
  # logger 'elasticsearch.log'
  #
  # For debugging, we can switch to the _debug_ level, which will log the complete JSON responses.
  #
  # That's very convenient if we want to post a recreation of some problem or solution
  # to the mailing list, IRC channel, etc.
  #
  # logger 'elasticsearch.log', :level => 'debug'
  # Note that we can pass any [`IO`](http://www.ruby-doc.org/core/classes/IO.html)-compatible Ruby object as a logging device.
  #
  # logger STDERR, :level => 'debug'
end

#### Simple Query String Searches

# We can do simple searches, like searching for tweets containing “One” in their title.
#
s = Tire.search('tweets') do
  query do
    string "text:Holmgreen"
  end
end

s.results.each do |document|
  #puts document.inspect
  puts "* id: #{ document.id }"
  puts "* text: #{ document.text }"
  puts "* score: #{ document._score }"
  puts "* index: #{ document._index }"
  puts "* type: #{ document._type }"
  puts "* source: #{ document.source }"
  puts "* highlight: #{ document.highlight }"
  puts "* sort: #{ document.sort }"
  puts "* created_at: #{ document.created_at }"
  #puts "* user: #{ document.user.inspect }"
  puts "* user.id: #{ document.user.id }"
  puts "* user.name: #{ document.user.name }"
  puts "* user.screen_name: #{ document.user.screen_name }"
end

puts "= Searching for tweets published 2011-12-16 between 22:00-23:00"

s = Tire.search('tweets') do
  query do
    string "created_at:[2011-12-16T20:00:00 TO 2011-12-16T23:00:00]"
  end
end

s.results.each do |document|
  puts "* #{ document.text[0..40] } [created at: #{document.created_at}]"
end

# Notice, that we can access local variables from the _enclosing scope_.
# (Of course, we may write the blocks in shorter notation.)

# We will define the query in a local variable named `q`...
#
q = "text:Rails*"
# ... and we can use it inside the `query` block.
#
s = Tire.search('tweets', type: 'www') do
  size 2
  from 2
  query do
    string q
  end
end

s.results.each do |document|
  puts "* #{ document.text[0..77] + "..." }"
end

puts "", "Query:", "-"*80
puts s.to_json

puts "", "Try the query in Curl:", "-"*80
puts s.to_curl

class Tweet
  def self.search(params, options = {})
    Tire.search("#{self.name.downcase + "s"}", type: 'nosql') do
      if options[:per_page]
        size options[:per_page]
      end
      if options[:page]
        from options[:page]
      end
      query do
        string params['q']
      end
    end.results
  end
end

params = { }
params['q'] = "Rails*"
r = Tweet.search params, per_page: 2, page: 1

r.each do |document|
  puts "* #{ document.text[0..77] + "..." }"
end
