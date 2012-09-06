# collects tweets and saves them to a mongodb database: nosql/statuses

require "bundler/setup"

require 'yaml'
# require 'yajl/json_gem'
require 'tweetstream'
require 'mongo'


Bundler.require


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

# TODO:
# TweetStream::Daemon.new('tracker').track('wow') do |status|
#   # do something in the background
# end

# TODO: MapReduce
#   http://gregmoreno.wordpress.com/2012/09/05/mining-twitter-data-with-ruby-mongodb-and-map-reduce/

db = Mongo::Connection.new['nosql']
coll = db['statuses']

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
  # puts status.methods
  # puts status.to_hash
  puts "#{status.text}"

  # puts "#{status.id.class}" # Fixnum
  # puts "#{status.id.to_s}"

  # puts "#{status.created_at.class}"
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

  doc = {
    _id: status.id.to_s,
    created_at: status.created_at,
    text: status.text,
    screen_name: status.user.screen_name,
    urls: urls,
    hashtags: hashtags,
    user_mentions: user_mentions
  }
  # puts doc

  coll.insert doc
end
