#### {% title "Wyszukiwanie ElasticSearch" %}

<blockquote>
 {%= image_tag "/images/john_cage.jpg", :alt => "[John Cage]" %}
 <p>I can't understand why people are frightened of new ideas.
    I'm frightened of the old ones.
 </p>
 <p class="author">— John Cage (1912–1992)</p>
</blockquote>

[What's Wrong with SQL search](http://philip.greenspun.com/seia/search).

Strona domowa ElasticSearch, dokumentacja:

* [You know, for Search](http://www.elasticsearch.org/)
* [Guides](http://www.elasticsearch.org/guide/):
  - [Setup](http://www.elasticsearch.org/guide/reference/setup/)
  - [API](http://www.elasticsearch.org/guide/reference/api/)
  - [Query](http://www.elasticsearch.org/guide/reference/query-dsl/)
  - [Mapping](http://www.elasticsearch.org/guide/reference/mapping/)
  - [Facets](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html)
* [Setting up ElasticSearch ](http://www.elasticsearch.org/tutorials/2010/07/01/setting-up-elasticsearch.html)

ElasticSearch driver dla języka Ruby:

* Karel Minarik.
  [Tire](https://github.com/karmi/tire) – a rich Ruby API and DSL for the ElasticSearch search engine/database

Fedora:

* [Elasticsearch RPMs](https://github.com/tavisto/elasticsearch-rpms)

Różne:

* Karel Minarik
  - [Data Visualization with ElasticSearch and Protovis](http://www.elasticsearch.org/blog/2011/05/13/data-visualization-with-elasticsearch-and-protovis.html)
  - [Your Data, Your Search, ElasticSearch (EURUKO 2011)](http://www.slideshare.net/karmi/your-data-your-search-elasticsearch-euruko-2011)
  - [Reversed or “Real Time” Search in ElasticSearch](http://karmi.github.com/tire/play/percolated-twitter.html) –
  czyli „percolated twitter”
  - [Route requests to ElasticSearch to authenticated user's own index](https://gist.github.com/986390) (wersja dla Nginx)
* Clinton Gormley.
  [Terms of endearment – the ElasticSearch Query DSL explained](http://www.elasticsearch.org/tutorials/2011/08/28/query-dsl-explained.html)

Przykładowe aplikacje:

* Karel Minarik.
  [Search Your Gmail Messages with ElasticSearch and Ruby](http://ephemera.karmi.cz/)
  (Sinatra)


## Instalacja ze źródeł

Rozpakowujemy archiwum z ostatnią wersją
[ElasticSearch](http://www.elasticsearch.org/download/) (ok. 16 MB):

    unzip elasticsearch-0.18.6.zip

Uruchamiamy *elasticsearch*:

    cd elasticsearch-0.18.6
    bin/elasticsearch -f

I już! Domyślnie ElasticSearch nasłuchuje na porcie 9200.


<blockquote>
 <p>The usual purpose of a full-text search engine is to return
  <b>a small number</b> of documents matching your query.
</blockquote>

## Your data, Your search

Kilka, nieco zmienionych, przykładów z tej strony
[Your Data, Your Search](http://www.elasticsearch.org/blog/2010/02/12/yourdatayoursearch.html).

**Interpretacja uri w zapytaniach kierowanych do ElasticSearch:**

<pre>http://localhost:9200/<b>⟨index⟩</b>/<b>⟨type⟩</b>/...
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

    :::bash
    curl -XPUT http://localhost:9200/amazon/books/0812504321 -d @book.json
      {"ok":true,"_index":"amazon","_type":"books","_id":"0812504321","_version":1}

Przykładowe zapytanie (w **query string**):

    :::bash
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

    :::bash
    curl -XPUT http://localhost:9200/amazon/cds/B00192IV0O -d @cd.json
      {"ok":true,"_index":"amazon","_type":"cds","_id":"B00192IV0O","_version":1}

Przykładowe zapytanie:

    :::bash
    curl 'http://localhost:9200/amazon/cds/_search?pretty=true&q=label:Interscope'

Wyszukiwanie po kilku typach:

    :::bash
    curl 'http://localhost:9200/amazon/books,cds/_search?pretty=true&q=name:energy'

Wyszukiwanie po wszystkich typach:

    :::bash
    curl 'http://localhost:9200/amazon/_search?pretty=true&q=name:energy'

Na koniec, zapytanie o zdrowie:

    :::bash
    curl -XGET 'http://127.0.0.1:9200/_cluster/health?pretty=true'


## Korzystamy z JSON Query Language

Użyjemy programu *curl* do zapisania danych w ElasticSearch:

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


### Odpytywanie ElasticSearch

Po umieszczeniu danych w ElasticSearch spróbujemy zadać
kilka zapytań, korzystających z **JSON query language**.

Dla przypomnienia, interpretacja uri w zapytaniach do ElasticSearch:

<pre>http://localhost:9200/_search?...
http://localhost:9200/<b>⟨index⟩</b>/_search?...
http://localhost:9200/<b>⟨index⟩</b>/<b>⟨type⟩</b>/_search?...
</pre>


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

Wyciągamy wszystkie dokumenty z ElasticSearch:

    :::bash
    curl -XGET 'http://localhost:9200/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'

A teraz – wszystkie dokumenty z indeksu *twitter*:

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

*Tenant* to najemca, dzierżawca. *Multi tenant* – jak to przetłumaczyć?
Co to może oznaczać?

*Przykład.* Zaczynamy od zapisania takich danych w ElasticSearch:

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


<blockquote>
 {%= image_tag "/images/daniel_kahneman.jpg", :alt => "[Daniel Kahneman]" %}
 <p><b>The hallo effect</b> helps keep explanatory narratives
  simple and coherent by exaggerating the consistency
  of evaluations: good people do only good things
  and bad people are all bad.
 </p>
 <p class="author">— Daniel Kahneman</p>
</blockquote>

## ElasticSearch & Rails

Przykłady w których sami zapisujemy dane w ElasticSearch,
po to aby je zaraz odszukać pozwalają na sprawdzić czy
poprawnie zainstalowaliśmy program oraz czy rozumiemy
rest API. Dalsze tego typu eksperymenty są nużące.

Dlatego, do następnych eksperymentów użyjemy rzeczywistych
danych. Pobierzemy dużo interesujących nas statusów z Twittera.
Do przeszukiwania statusów, napiszemy prostą aplikację Rails.
(Ponieważ Twitter & Rails są *cool*, więc efekt halo powinnien
przenieść *coolines* na ten przykład.)

Do pobierania statusów skorzystamy ze [stream API](https://dev.twitter.com/docs/streaming-api).
Pierwsza wersja skryptu, którego użyjemy do filtrowania,
ma działać. *Pre-launch Checklist* zajmiemy się później.

Za pomocą programu curl:

    :::bash
    curl -X POST -uAnyTwitterUser:Password \
      https://stream.twitter.com/1/statuses/filter.json -d @tracking

Interesujące nas statusy odfiltrujemy zapisując w pliku *tracking*
po `track=` interesujące nas słowa kluczowe.

Do słów kluczowych dopiszemy jeszcze **wow**. Słówko to pojawia się
w wielu statusach, a pozostałe słowa występują z rzadka. Po dodaniu
**wow** nowe statusy będą się pojawiać co chwila. Wow!

    :::tracking
    track=wow,rails,mongodb,couchdb,redis,elasticsearch,neo4j

Statusy zawierają wiele pól. Tylko niektóre z nich nas będą nas interesować:

    id
    text
    created_at
    screen_name

Trudno by było wyciąć na konsoli te pola ze statusów.
Dlatego „czyszczenie” statusów zaprogamujemy w języku Ruby.
Skorzystamy z kilku gemów:

   gem install eventmachine em-http-request tweetstream yajl-ruby

Linki do dokumentacji:

* [eventmachine](https://github.com/eventmachine/eventmachine)
* [em-http-request](https://github.com/igrigorik/em-http-request)
* [tweetstream](https://github.com/intridea/tweetstream)
* [yajl-ruby](https://github.com/brianmario/yajl-ruby)

<blockquote>
<p>
  <h2><a href="https://dev.twitter.com/docs/streaming-api/concepts#access-rate-limiting">Important note</a></h2>
  <p>Each account may create only one standing connection to the
  Streaming API. Subsequent connections from the same account may
  cause previously established connections to be
  disconnected. Excessive connection attempts, regardless of success,
  will result in an automatic ban of the client's IP
  address. Continually failing connections will result in your IP
  address being blacklisted from all Twitter access.
</p>
</blockquote>

{%= image_tag "/images/twitter_elasticsearch.jpeg", :alt => "[Twitter -> ElasticSearch]" %}

Oto ten skrypt:

    :::ruby nosql-twitter-stream.rb
    # encoding: utf-8

    require 'yajl/json_gem'
    require 'tweetstream'

    user, password = ARGV

    unless (user && password)
      puts "Usage: #{__FILE__} <user> <password>"
      exit(1)
    en

    TweetStream.configure do |config|
      config.username = username
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


Zobacz też:

* [Consuming the Twitter Streaming API](http://adam.heroku.com/past/2010/3/19/consuming_the_twitter_streaming_api/)
  prościej, bez *TweetStream*
* [Gmail & ES](http://ephemera.karmi.cz/post/5510326335/gmail-elasticsearch-ruby)


# Wtyczki

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
      "_type" : "my_twitter_river",
      "_id" : "_status",
      "_version" : 5,
      "exists" : true,
      "_source" : {"ok":true,
         "node":{"id":"aUJLtb_KSZibfW3IG9P8yQ","name":"Nobilus","transport_address":"inet[/192.168.4.4:9300]"}}

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

Sprawdzamy mapping:

    :::bash
    curl ‐X GET "http://localhost:9200/tweets/_mapping?pretty=true"

Oto mapowanie:

    :::json
    {
      "tweets" : {
        "nosql" : {
          "properties" : {
            "text" : {
              "type" : "string"
            },
            "source" : {
              "type" : "string"
            },
            "location" : {
              "type" : "geo_point"
            },
            "link" : {
              "dynamic" : "true",
              "properties" : {
                "start" : {
                  "type" : "long"
                },
                "expand_url" : {
                  "type" : "string"
                },
                "display_url" : {
                  "type" : "string"
                },
                "url" : {
                  "type" : "string"
                },
                "end" : {
                  "type" : "long"
                }
              }
            },
            "hashtag" : {
              "dynamic" : "true",
              "properties" : {
                "text" : {
                  "type" : "string"
                },
                "start" : {
                  "type" : "long"
                },
                "end" : {
                  "type" : "long"
                }
              }
            },
            "retweet_count" : {
              "type" : "long"
            },
            "created_at" : {
              "format" : "dateOptionalTime",
              "type" : "date"
            },
            "mention" : {
              "properties" : {
                "id" : {
                  "type" : "long"
                },
                "start" : {
                  "type" : "long"
                },
                "name" : {
                  "type" : "string"
                },
                "screen_name" : {
                  "index" : "not_analyzed",
                  "type" : "string"
                },
                "end" : {
                  "type" : "long"
                }
              }
            },
            "in_reply" : {
              "properties" : {
                "user_screen_name" : {
                  "index" : "not_analyzed",
                  "type" : "string"
                },
                "status" : {
                  "type" : "long"
                },
                "user_id" : {
                  "type" : "long"
                }
              }
            },
            "truncated" : {
              "type" : "boolean"
            },
            "place" : {
              "dynamic" : "true",
              "properties" : {
                "id" : {
                  "type" : "string"
                },
                "name" : {
                  "type" : "string"
                },
                "type" : {
                  "type" : "string"
                },
                "country_code" : {
                  "type" : "string"
                },
                "url" : {
                  "type" : "string"
                },
                "full_name" : {
                  "type" : "string"
                },
                "country" : {
                  "type" : "string"
                }
              }
            },
            "user" : {
              "properties" : {
                "id" : {
                  "type" : "long"
                },
                "location" : {
                  "type" : "string"
                },
                "description" : {
                  "type" : "string"
                },
                "name" : {
                  "type" : "string"
                },
                "screen_name" : {
                  "index" : "not_analyzed",
                  "type" : "string"
                }
              }
            }
          }
        }
      }


# Rails Along The River

Rails — Tire & ElasticSearch

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
