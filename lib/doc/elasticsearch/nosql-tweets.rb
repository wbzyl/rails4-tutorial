# encoding: utf-8

require 'yaml'
require 'yajl/json_gem'
require 'tweetstream'

# services.yml
# ---
# twitter:
#   login: AnyTwitterUser
#   password: Password

# Twitter Stream API configuration

begin
  raw_config = File.read("#{ENV['HOME']}/.credentials/services.yml")
  twitter = YAML.load(raw_config)['twitter']
rescue
  puts red { "\n\tError: problems with #{ENV['HOME']}/.credentials/services.yml\n" }
  exit(1)
end

TweetStream.configure do |config|
  config.username = twitter['login']
  config.password = twitter['password']
  config.auth_method = :basic
  config.parser = :yajl
end

# def handle_tweet(s)
#   puts "#{JSON.pretty_generate(s)}"
# end

def handle_tweet(s)
  h = { }
  h[:id] = s[:id]
  h[:text] =  s[:text]
  h[:screen_name] = s[:user][:screen_name]
  h[:entities] = s[:entities]
  h[:created_at] = Time.parse(s[:created_at])
  puts "#{JSON.pretty_generate(h)}"
end

client = TweetStream::Client.new

client.on_error do |message|
  puts message
end

client.track('rails', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
  handle_tweet status
end
