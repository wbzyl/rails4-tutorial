# -*- coding: utf-8 -*-

require 'tire'
require 'yajl/json_gem'

fortunes = [
  { id: 1, type: 'quotes', text: "Jedną z cech głupstwa jest logika.", tags: ["logika", "głupstwo", "nauka"] },
  { id: 2, type: 'quotes', text: "Znasz hasło do swojego wnętrza?", tags: ["hasło", "głupstwo", "czas"] },
  { id: 3, type: 'quotes', text: "Miał lwi pazur, ale brudny.", tags: ["lew", "pazur", "nauka"] },
  { id: 4, type: 'quotes', text: "Unikaj skarżącego się na brak czasu, chce ci zabrać twój.", tags: ["nauka", "czas"] }
]

# fields *id* and *type* are required.

Tire.index 'fortunes' do
  delete
  import fortunes
  refresh
end

puts "Searching for 'text:hasło'"

s = Tire.search('fortunes') do
  query do
    string 'text:hasło'
  end
end

s.results.each do |document|
  puts "* #{ document.text } [tags: #{document.tags.join(', ')}]"
end

puts "Searching for :tags, ['hasło', 'lew'] (_or_)"

s = Tire.search('fortunes') do
  # Let's suppose we want to search for articles with specific _tags_, in our case “hasło” _or_ “lew”.
  #
  query do
    # That's a great excuse to use a [_terms_](http://elasticsearch.org/guide/reference/query-dsl/terms-query.html) query.
    #
    terms :tags, ['hasło', 'lew']
  end
end

s.results.each do |document|
  puts "* #{ document.text } [tags: #{document.tags.join(', ')}]"
end

puts "Searching for 'text:l*'"

q = "text:l*"

s = Tire.search('fortunes') { query { string q } }

s.results.each do |document|
  puts "* #{ document.text } [tags: #{document.tags.join(', ')}]"
end

# Let's assume we have a plain Ruby class, named `Article`.
#
class Fortune
  # We will define the query in a class method...
  #
  def self.q
    "text:s*"
  end
  # ... and wrap the _Tire_ search method in another one.
  def self.search
    # Notice how we pass the `search` object around as a block argument.
    #
    Tire.search('fortunes') do |search|
      # And we pass the query object in a similar matter.
      #
      search.query do |query|
        # Which means we can access the `q` class method.
        #
        query.string self.q
      end
    end.results
  end
end

puts "Searching for 'text:s*'"
s = Fortune.search
s.results.each do |document|
  puts "* #{ document.text } [tags: #{document.tags.join(', ')}]"
end

# Faceted Search

# _ElasticSearch_ makes it trivial to retrieve complex aggregated data from our index/database,
# so called [_facets_](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html).

# Let's say we want to display article counts for every tag in the database.
# For that, we'll use a _terms_ facet.

# Scoped and global counts

s = Tire.search 'fortunes' do
  query { string 'text:s*' }
  #
  # retrieve the counts “bucketed” by `tags`.
  #
  facet 'scoped tags counts' do
    terms :tags
  end

  facet 'global tags counts' do
    terms :tags, global: true
  end
end

puts "Found #{s.results.count} fortunes matching 'text:s*':\n#{s.results.map(&:text).join("\n")}"

puts "\nScoped counts by tag:", "-"*25
s.results.facets['scoped tags counts']['terms'].each do |f|
  puts "#{f['term'].ljust(10)} #{f['count']}"
end

puts "\nGlobal counts by tag:", "-"*25
s.results.facets['global tags counts']['terms'].each do |f|
  puts "#{f['term'].ljust(10)} #{f['count']}"
end


# Filtered Search

s = Tire.search 'fortunes' do
  query { string 'text:s*' }

  filter :terms, tags: ['głupstwo']
end

puts "\nFiltered search: 'text:s*', filter: tags: ['głupstwo']", "-"*25
s.results.each do |document|
  puts "* #{ document.text } [tags: #{document.tags.join(', ')}]"
end


# Sortowanie

s = Tire.search 'fortunes' do
  query { all }

  # sort do
  #   by :text, 'desc'
  # end
end

puts "\nSorted desc: (nie działa)", "-"*25
s.results.each do |document|
  puts "* #{ document.text }"
end


# Highlighting

s = Tire.search 'fortunes' do
  query { string 'text:hasło' }

  highlight :text
end

puts "\nHighlighting:", "-"*25
s.results.each do |document|
  puts "* #{document.highlight.text}"
end
