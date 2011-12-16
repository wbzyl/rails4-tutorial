# -*- coding: utf-8 -*-

require 'tire'
require 'yajl/json_gem'

# Let's initialize an index named “articles”.
#
Tire.index 'articles' do
  # To make sure it's fresh, let's delete any existing index with the same name.
  #
  delete
  # And then, let's create it.
  #
  create

  # We want to store and index some articles with `title`, `tags` and `published_on` properties.
  # Simple Hashes are OK.
  # The default _type_ is „document”.
  #
  store :title => 'One', :tags => ['ruby'], :published_on => '2011-01-01'
  store :title => 'Two', :tags => ['ruby', 'python'], :published_on => '2011-01-02'

  # We usually want to set a specific _type_ for the document in _ElasticSearch_.
  # Simply setting a `type` property is OK.
  #
  store :type => 'article',
        :title => 'Three', :tags => ['java'], :published_on => '2011-01-02'
end

# We may want to wrap your data in a Ruby class, and use it when storing data.
# The **contract** required of such a class is very simple.
#
class Article
  attr_reader :title, :tags, :published_on

  def initialize(attributes={})
    @attributes = attributes
    @attributes.each_pair { |name,value| instance_variable_set :"@#{name}", value }
  end

  # It must provide a `type`, `_type` or `document_type` method for propper mapping.
  #
  def type
    'article'
  end

  # And it must provide a `to_indexed_json` method for conversion to JSON.
  #
  def to_indexed_json
    @attributes.to_json
  end
end

Tire.index 'articles' do
  # Note: Since our class takes a Hash of attributes on initialization, we may even
  # wrap the results in instances of this class; we'll see how to do that further below.
  #
  article = Article.new :title => 'Four', :tags => ['ruby', 'javascript'], :published_on => '2011-01-03'

  # Let's store the `article`, now.
  #
  store article

  # And let's „force refresh“ the index, so we can query it immediately.
  #
  refresh
end
