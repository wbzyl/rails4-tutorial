# encoding: utf-8

require 'yajl/json_gem'
require 'tweetstream'

require 'ansi/code'
include ANSI::Code

user, password = ARGV

unless (user && password)
  puts "\nUsage:\n\t#{__FILE__} <user> <password>\n\n"
  exit(1)
end

TweetStream.configure do |config|
  config.username = user
  config.password = password
  config.auth_method = :basic
  config.parser = :yajl
end

def handle_tweet(s)
  return unless s.text
  # puts "#{JSON.pretty_generate(s)}"
  puts green { "\t#{s.user.screen_name} (#{s.id}):" }
  puts "#{s.text}"
end

# ----

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

#client.track('wow', 'lol') do |status|
client.track('rails', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
  handle_tweet status
end
