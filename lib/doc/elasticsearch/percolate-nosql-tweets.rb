# encoding: utf-8

require 'yaml'
require 'yajl/json_gem'
require 'tweetstream'
require 'tire'

require 'ansi/code'
include ANSI::Code

# To access the streaming API methods the authentication
# with OAuth or HTTP Basic Authentication is required.
# We use Basic Authentication.

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

# user, password = ARGV

# unless (user && password)
#   puts "\nUsage:\n\t#{__FILE__} <AnyTwitterUser> <Password>\n\n"
#   exit(1)
# end

# TweetStream.configure do |config|
#   config.username = user
#   config.password = password
#   config.auth_method = :basic
#   config.parser = :yajl
# end

# Tire part.

# Let's define a class to hold our data in *ElasticSearch*.

class Status
  include Tire::Model::Persistence

  property :id
  property :text
  property :screen_name
  property :created_at
  property :entities

  # Let's define callback for percolation.
  # Whenewer a new document is saved in the index, this block will be executed,
  # and we will have access to matching queries in the `Status#matches` property.
  #
  # In our case, we will just print the list of matching queries.

  on_percolate do
    puts green { "'#{text}' from @#{bold { screen_name }}" } unless matches.empty?
  end
end

# First, let's define the query_string queries.

# TODO: add check if already defined.

# q = {}
# q[:rails] = 'rails'
# q[:mongodb] = 'mongodb'
# q[:redis] = 'redis'
# q[:couchdb] = 'couchdb'
# q[:neo4j] = 'neo4j'
# q[:elasticsearch] = 'elasticsearch'

# Status.index.register_percolator_query('rails') { |query| query.string q[:rails] }
# Status.index.register_percolator_query('mongodb') { |query| query.string q[:mongodb] }
# Status.index.register_percolator_query('redis') { |query| query.string q[:redis] }
# Status.index.register_percolator_query('couchdb') { |query| query.string q[:couchdb] }
# Status.index.register_percolator_query('neo4j') { |query| query.string q[:neo4j] }
# Status.index.register_percolator_query('elasticsearch') { |query| query.string q[:elasticsearch] }

# Refresh the `_percolator` index for immediate access.

Tire.index('_percolator').refresh

puts magenta { "\nYou can check out the the documents in your index with curl:\n" }
puts yellow  { "  curl 'http://localhost:9200/statuses/_search?q=*&sort=created_at:desc&size=4&pretty=true'\n" }

# Strip off fields we are not interested in.

def handle_tweet(s)
  h = Status.new :id => s[:id],
    :text => s[:text],
    :screen_name => s[:user][:screen_name],
    :entities => s[:entities],
    :created_at => Time.parse(s[:created_at])

  types = h.percolate
  puts cyan { "matched queries: #{types}" }

  types.to_a.each do |type|
    Status.document_type type
    h.save
  end
end

# Tweetstream part.

# Get statuses from Twitter.

client = TweetStream::Client.new

client.on_error do |message|
  puts red { message }
end

client.on_delete do |status_id, user_id|
  Status.delete(status_id)
end

client.track('rails', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
  handle_tweet(status)
end
