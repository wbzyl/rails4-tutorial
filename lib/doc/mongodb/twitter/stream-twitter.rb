require "bundler/setup"

# Collects user tweets and saves them to a mongodb

require 'yaml'

require 'yajl/json_gem'
require 'tweetstream'

require 'mongo'


Bundler.require

# We use the TweetStream gem to access Twitter's Streaming API.
# https://github.com/intridea/tweetstream

TweetStream.configure do |config|
  # settings = YAML.load_file File.dirname(__FILE__) + '/twitter.yml'
  settings = YAML.load_file File.join(ENV['HOME'], '.credentials', '/twitter.yml')

  config.consumer_key       = settings['consumer_key']
  config.consumer_secret    = settings['consumer_secret']
  config.oauth_token        = settings['oauth_token']
  config.oauth_token_secret = settings['oauth_token_secret']

  config.auth_method        = :oauth
  config.parser             = :yajl
end

# https://github.com/intridea/tweetstream

#TweetStream::Client.new.track('wow') do |status|
#  puts "#{status.text}"
#end

# TweetStream::Daemon.new('tracker').track('wow') do |status|
#   # do something in the background
# end

# TODO:
#   http://gregmoreno.wordpress.com/2012/09/05/mining-twitter-data-with-ruby-mongodb-and-map-reduce/


db = Mongo::Connection.new['nosql']
coll = db['test']

stream = TweetStream::Client.new

stream.on_error do |msg|
  puts msg
end

# stream.track('wow') do |status|
#   puts "#{status.text}"
# end

# puts "There are #{coll.count} records."
# coll.find.each { |doc| puts doc.inspect }
# coll.remove

stream.track('rails', 'mongodb', 'elasticsearch', 'meteorjs', 'backbone.js', 'd3.js') do |status|

  # puts "#{status.id.class}" # Fixnum
  puts "#{status.id.to_s}"

  puts "#{status.text}"
  # puts status.methods
  # puts status.to_hash

  # puts "#{status.created_at}"

  # puts "="*72
  # puts "user screen_name: #{status.user.screen_name}"
  # puts "user name: #{status.user.name}"

  # puts "="*72
  # puts "hashtags: #{status.hashtags.class}"
  # puts "-"*72
  # status.hashtags.each { |hashtag| puts hashtag.text }  # ex. trabajo a nie #trabajo
  # puts "-"*72

  # puts "="*72
  # puts "urls: #{status.urls.class}"
  # puts "-"*72
  # status.urls.each { |url| puts url.expanded_url  }
  # puts "-"*72

  # puts "="*72
  # puts "user_mentions: #{status.user_mentions.class}" # @jordiromero
  # puts "-"*72
  # status.user_mentions.each { |user| puts user.screen_name }
  # puts "-"*72

  urls = status.urls.to_a.map { |o| o["expanded_url"] }
  hashtags = status.hashtags.to_a.map { |o| o["text"] }
  user_mentions = status.user_mentions.to_a.map { |o| o["screen_name"] }

  # puts urls
  # puts hashtags
  # puts user_mentions

  doc = Hash.new _id: status.id.to_s, text: status.text

  puts doc

  # coll.insert status
end
