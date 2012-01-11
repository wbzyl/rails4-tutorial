# encoding: utf-8

require 'yajl/json_gem'
require 'tweetstream'

require 'tire'

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
  puts cyan { s.text }
  h = Status.new :id => s[:id],
    :text => s[:text],
    :screen_name => s[:user][:screen_name],
    :entities => s[:entities],
    :created_at => Time.parse(s[:created_at])

  types = h.percolate
  puts magenta { types }

  # types.each do |type|
  #   Status.document_type type
  #   h.save
  # end
end

# ----

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
  #
  on_percolate do
    puts green { "'#{text}' from @#{bold { screen_name }} matches queries: #{bold { matches.inspect }}" } unless matches.empty?
  end
end

# First, let's define the query_string queries.
#
q = {}
q[:rails] = 'rails'
q[:mongodb] = 'mongodb'
q[:redis] = 'redis'
q[:couchdb] = 'couchdb'
q[:neo4j] = 'neo4j'
q[:elasticsearch] = 'elasticsearch'

Status.index.register_percolator_query('rails') { |query| query.string q[:rails] }
Status.index.register_percolator_query('mongodb') { |query| query.string q[:mongodb] }
Status.index.register_percolator_query('redis') { |query| query.string q[:redis] }
Status.index.register_percolator_query('couchdb') { |query| query.string q[:couchdb] }
Status.index.register_percolator_query('neo4j') { |query| query.string q[:neo4j] }
Status.index.register_percolator_query('elasticsearch') { |query| query.string q[:elasticsearch] }

# ----

client = TweetStream::Client.new

client.on_error do |message|
  puts red { message }
end

client.track('rails', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
  handle_tweet status
end

# client.on_delete do |status_id, user_id|
#   Tweet.delete(status_id)
# end

# You can check out the the documents in your index with `curl` or your browser.
#
# puts "curl 'http://localhost:9200/statuses/_search?q=*&sort=created_at:desc&size=4&pretty=true'", ""
