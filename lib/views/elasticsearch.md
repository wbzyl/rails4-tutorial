#### {% title "Wyszukiwanie ElasticSearch" %}

<blockquote>
 {%= image_tag "/images/john_cage.jpg", :alt => "[John Cage]" %}
 <p>I can't understand why people are frightened of new ideas.
    I'm frightened of the old ones.
 </p>
 <p class="author">— John Cage (1912–1992)</p>
</blockquote>

Strona domowa, dokumentacja:

* [You know, for Search](http://www.elasticsearch.org/)
* [Guides](http://www.elasticsearch.org/guide/):
  - [Setup](http://www.elasticsearch.org/guide/reference/setup/)
  - [API](http://www.elasticsearch.org/guide/reference/api/)
  - [Query](http://www.elasticsearch.org/guide/reference/query-dsl/)
  - [Mapping](http://www.elasticsearch.org/guide/reference/mapping/)
  - [Facets](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html)
* [Setting up elasticsearch ](http://www.elasticsearch.org/tutorials/2010/07/01/setting-up-elasticsearch.html)

Driver do Ruby:

* Karel Minarik.
  [Tire](https://github.com/karmi/tire) – a rich Ruby API and DSL for the ElasticSearch search engine/database

Fedora:

* [Elasticsearch RPMs](https://github.com/tavisto/elasticsearch-rpms)

Różne:

* Karel Minarik.
  [Data Visualization with ElasticSearch and Protovis](http://www.elasticsearch.org/blog/2011/05/13/data-visualization-with-elasticsearch-and-protovis.html)
* Clinton Gormley.
  [Terms of endearment – the ElasticSearch Query DSL explained](http://www.elasticsearch.org/tutorials/2011/08/28/query-dsl-explained.html)


## Instalacja ze źródeł

Rozpakowujemy archiwum z ostatnią wersją
[ElasticSearch](http://www.elasticsearch.org/download/) (ok. 16 MB):

    unzip elasticsearch-0.18.5.zip

Uruchamiamy *elasticsearch*:

    cd elasticsearch-0.18.5
    bin/elasticsearch -f

Korzystamy z domyślnych ustawień — *http://localhost:9200*


<blockquote>
 <p>The usual purpose of a full-text search engine is to return
  <b>a small number</b> of documents matching your query.
</blockquote>

## Your data, Your search

Nieco zmienione przykłady
z [Your Data, Your Search](http://www.elasticsearch.org/blog/2010/02/12/yourdatayoursearch.html).

Składnia zapytań:

<pre>http://localhost:9200/<b> index </b>/<b> type </b>/...
</pre>

<blockquote>
 <p>Field names with the <b>same name</b> across types are highly
 recommended to have the <b>same type</b> and same mapping characteristics
 (analysis settings for example).
</blockquote>

Książka:

    :::json book.json
    {
      "isbn" : "0812504321",
      "name" : "Call of the Wild",
      "author" : {
         "first_name" : "Jack",
         "last_name" : "London"
       },
       "pages" : 128,
       "tags" : ["fiction", "children"]
    }

Dodajemy książkę:

    curl -XPUT http://localhost:9200/amazon/books/0812504321 -d @book.json
      {"ok":true,"_index":"amazon","_type":"books","_id":"0812504321","_version":1}

Przykładowe zapytanie (w **query string**):

    curl 'http://localhost:9200/amazon/books/_search?pretty=true&q=author.first_name:Jack'

CD:

    :::json cd.json
    {
       "asin" : "B00192IV0O",
       "name" : "THE E.N.D. (Energy Never Dies)",
       "artist" : "Black Eyed Peas",
       "label" : "Interscope",
       "release_date": "2009-06-09",
       "tags" : ["hip-hop", "pop-rap"]
    }

Dodajemy CD:

    curl -XPUT http://localhost:9200/amazon/cds/B00192IV0O -d @cd.json
      {"ok":true,"_index":"amazon","_type":"cds","_id":"B00192IV0O","_version":1}

Przykładowe zapytanie:

    curl 'http://localhost:9200/amazon/cds/_search?pretty=true&q=label:Interscope'

Wyszukiwanie po kilku typach:

    curl 'http://localhost:9200/amazon/books,cds/_search?pretty=true&q=name:energy'

Wyszukiwanie po wszystkich typach:

    curl 'http://localhost:9200/amazon/_search?pretty=true&q=name:energy'


## Korzystamy z JSON Query Language

Dane zapiszemy w ElasticSearch kozystając z programu *curl*:

    :::bash
    curl -XPUT 'http://localhost:9200/twitter/users/kimchy' -d '
    {
       "name" : "Shay Banon"
    }'

    curl -XPUT 'http://localhost:9200/twitter/tweets/1' -d '
    {
       "user": "kimchy",
       "postDate": "2009-11-15T13:12:00",
       "message": "Trying out Elastic Search, so far so good?"
    }'

    curl -XPUT 'http://localhost:9200/twitter/tweets/2' -d '
    {
       "user": "kimchy",
       "postDate": "2009-11-15T14:12:12",
       "message": "Another tweet, will it be indexed?"
    }'

Sprawdzamy, co zostało dodane:

    :::bash
    curl -XGET 'http://localhost:9200/twitter/users/kimchy?pretty=true'
    curl       'http://localhost:9200/twitter/tweets/1?pretty=true'
    curl       'http://localhost:9200/twitter/tweets/2?pretty=true'


## Wyszukiwanie – pierwsze koty za płoty

Składnia zapytań:

<pre>http://localhost:9200/_search?...
http://localhost:9200/<b> index </b>/_search?...
http://localhost:9200/<b> index </b>/<b> type </b>/_search?...
</pre>

Przykładowe zapytanie (korzystamy z **JSON query language**):

    :::bash
    curl -XGET 'http://localhost:9200/twitter/tweets/_search?pretty=true' -d '
    {
       "query" : {
          "text" : { "user": "kimchy" }
       }
    }'
    curl -XGET 'http://localhost:9200/twitter/tweets/_search?pretty=true' -d '
    {
       "query" : {
          "term" : { "user": "kimchy" }
       }
    }'

Jaka jest różnica między wyszukiwaniem z **text** a **term**?

Wszystkie dokumenty:

    :::bash
    curl -XGET 'http://localhost:9200/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'

Wszystkie dokumenty z indeksu *twitter*:

    :::bash
    curl -XGET 'http://localhost:9200/twitter/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'

Wszystkie dokumenty typu *user* z indeksu *twitter*:

    :::bash
    curl -XGET 'http://localhost:9200/twitter/users/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'


## Multi Tenant – indeksy i typy

*Tenant* to najemca, dzierżawca.
*Multi tenant* – jak to przetłumaczyć?
Co to może oznaczać?

*Przykład.* Zapisujemy następujące dane w ElasticSearch:

    :::bash
    curl -XPUT 'http://localhost:9200/bilbo/info/1' -d '{ "name" : "Bilbo Baggins" }'
    curl -XPUT 'http://localhost:9200/frodo/info/1' -d '{ "name" : "Frodo Baggins" }'

    curl -XPUT 'http://localhost:9200/bilbo/tweets/1' -d '
    {
        "user": "bilbo",
        "postDate": "2009-11-15T13:12:00",
        "message": "Trying out Elastic Search, so far so good?"
    }'
    curl -XPUT 'http://localhost:9200/frodo/tweets/1' -d '
    {
        "user": "frodo",
        "postDate": "2009-11-15T14:12:12",
        "message": "Another tweet, will it be indexed?"
    }'

Wyszukiwanie po kilku indeksach:

    :::bash
    curl -XGET 'http://localhost:9200/bilbo,frodo/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'


## Wtyczki

Zaczynamy od instalacji [wtyczek](https://github.com/elasticsearch).

Rivers allows to index streams:

    :::bash
    bin/plugin -install river-twitter
      -> Installing river-twitter...
      Trying http://elasticsearch.googlecode.com/svn/plugins/river-twitter/elasticsearch-river-twitter-0.18.5.zip...
      ...
    bin/plugin -install river-couchdb
      -> Installing river-couchdb...
      Trying http://elasticsearch.googlecode.com/svn/plugins/river-couchdb/elasticsearch-river-couchdb-0.18.5.zip...
      Downloading ...DONE
      Installed river-couchdb
    bin/plugin -install river-wikipedia
      -> Installing river-wikipedia...
      Trying http://elasticsearch.googlecode.com/svn/plugins/river-wikipedia/elasticsearch-river-wikipedia-0.18.5.zip...
      Downloading ......DONE
      Installed river-wikipedia

Allows to have JavaScript as the language of scripts to execute:

    :::bash
    bin/plugin -install lang-javascript
      -> Installing lang-javascript...
      Trying http://elasticsearch.googlecode.com/svn/plugins/lang-javascript/elasticsearch-lang-javascript-0.18.5.zip...

**Uwaga**: Elasticsearch must be restarted after the installation of a plugin.


### River Twitter

Usuwanie swoich rivers, na przykład:

    :::bash
    curl -XDELETE http://localhost:9200/_river/my_twitter_river

Przykład tzw. *filtered stream*:

    :::bash
    curl -XPUT localhost:9200/_river/my_twitter_river/_meta -d @tweets-nosql.json

gdzie w pliku *nosql-tweets.json* wpisałem:

    :::json tweets-nosql.json
    {
        "type" : "twitter",
        "twitter" : {
            "user" : "wbzyl",
            "password" : "sekret",
            "filter": {
               "tracks": ["elasticsearch", "mongodb", "couchdb", "rails"]
            }
        },
        "index" : {
            "index": "tweets",
            "type" : "nosql",
            "bulk_size" : 10
        }
    }

Sprawdzanie statusu:

    :::bash
    curl -XGET http://localhost:9200/_river/my_twitter_river/_status?pretty=true
    {
      "_index" : "_river",
      "_type" : "my_rivers",
      "_id" : "_status",
      "_version" : 1,
      "exists" : true, "_source" : {
         "ok":true,"node": {
            "id":"Q6rFvYZfTKClSCa4HyWxvA","name":"Hazard","transport_address":"inet[/192.168.32.64:9300]"}}

A tak raportowane jest pobranie paczki z 10 tweets na konsoli:

    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Establishing connection.
    [2011-12-16 12:54][INFO ][cluster.metadata           ] [Hazard] [_river] update_mapping [my_rivers] (dynamic)
    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Connection established.
    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Receiving status stream.
    [2011-12-16 12:57][INFO ][cluster.metadata           ] [Hazard] [tweets] update_mapping [nosql] (dynamic)

Wyszukiwanie:

    :::bash
    curl -XGET 'http://localhost:9200/tweets/nosql/_search?q=text:mongodb&fields=user.name,text&pretty=true'
    curl -XGET 'http://localhost:9200/tweets/nosql/_search?pretty=true' -d '
    {
        "query" : {
            "match_all" : { }
        }
    }'


# Rails — Tire & ElasticSearch

* Rails application template.
* Dodać klasę *Tweet* i podłączyć ją do Twitter River.

JSON:

    :::json tweets-nosql.json
    {
        "type" : "twitter",
        "twitter" : {
            "user" : "me",
            "password" : "secret",
            "filter": {
               "tracks": ["elasticsearch", "mongodb", "couchdb", "rails"]
            }
        },
        "index" : {
            "index": "tweets",
            "type" : "nosql",
            "bulk_size" : 20
        }
    }

Twitter River:

    curl -XPUT localhost:9200/_river/my_twitter_river/_meta -d @tweets-nosql.json

Routing:

    :::ruby config/routes.rb
    # get "tweets/index"
    match '/tweets' => 'tweets#index', :as => :tweets

Model:

    :::ruby app/models/tweet.rb
    class Tweet
      def self.search(params)
        Tire.search('tweets', type: 'nosql') do
          size 6
          if params[:page].present?
            from ((params[:page].to_i - 1) * 6)
          end
          query do
            boolean do
              must { string params[:q] } if params[:q].present?
            end
          end
        end.results
      end
    end

Kontroler:

    :::ruby app/controllers/tweets_controller.rb
    class TweetsController < ApplicationController
      def index
        @tweets = Tweet.search(params)
      end
    end

Widok:

    :::rhtml app/views/tweets/index.html.erb
    <h1>Listing tweets</h1>

    <%= form_tag tweets_path, method: :get do %>
      <p>
        <%= text_field_tag :q, params[:q] %>
        <%= submit_tag 'Search', name: nil %>
      </p>
    <% end %>

    <%= will_paginate @tweets %>

    <% @tweets.each do |tweet| %>
    <p><%= tweet.text %>
    <% end %>


# Ruby — Tire + ElasticSearch

Instalujemy gemy – *tire* i *yajl-ruby*:

    gem install tire
    gem install yajl-ruby

Hurtowe indeksowanie (*bulk indexing*):

    :::ruby quotes.rb
    require 'tire'
    fortunes = [
      { id: 1, type: 'quotes', text: "Jedną z cech głupstwa jest logika.", tags: ["logika", "głupstwo", "nauka"] },
      { id: 2, type: 'quotes', text: "Znasz hasło do swojego wnętrza?", tags: ["hasło", "głupstwo", "czas"] },
      { id: 3, type: 'quotes', text: "Miał lwi pazur, ale brudny.", tags: ["lew", "pazur", "nauka"] },
      { id: 4, type: 'quotes', text: "Unikaj skarżącego się na brak czasu, chce ci zabrać twój.", tags: ["nauka", "czas"] }
    ]
    Tire.index 'fortunes' do
      delete
      import fortunes
      refresh
    end

*Uwaga:* pola *id* oraz *type* są obowiązkowe.

**TODO**: doc/elasticsearch/Tire.md


# Zadania

1\. Zainstalować wtyczkę *Wikipedia River*. Wyszukiwanie?

2\. Przeczytać [Creating a pluggable REST endpoint](http://www.elasticsearch.org/tutorials/2011/09/14/creating-pluggable-rest-endpoints.html).

* Zainstalować wtyczkę [hello world](https://github.com/brusic/elasticsearch-hello-world-plugin/).
* Napisać swoją wtyczkę.
