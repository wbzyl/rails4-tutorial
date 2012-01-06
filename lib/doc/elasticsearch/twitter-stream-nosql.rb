# http://adam.heroku.com/past/2010/3/19/consuming_the_twitter_streaming_api/
# https://github.com/igrigorik/em-http-request

# gem install em-http-request

require 'eventmachine'
require 'em-http'
require 'json'

usage = "#{$0} <user> <password>"
abort usage unless user = ARGV.shift
abort usage unless password = ARGV.shift

#url = 'https://stream.twitter.com/1/statuses/sample.json'
#url = 'https://stream.twitter.com/1/statuses/filter.json?track=wow,ruby,rails,mongodb,couchdb,redis,neo4j,elasticsearch'

url = 'https://stream.twitter.com/1/statuses/filter.json?track=ruby,rails,mongodb,couchdb,redis,neo4j,elasticsearch'

def handle_tweet(tweet)
  return unless tweet['text']
  puts "#{tweet['user']['screen_name']}: #{tweet['text']}"
end

EventMachine.run do
  http = EventMachine::HttpRequest.new(url).get :head => { 'Authorization' => [ user, password ] }

  buffer = ""

  http.stream do |chunk|
    buffer += chunk
    while line = buffer.slice!(/.+\r?\n/)
      handle_tweet JSON.parse(line)
    end
  end
end
