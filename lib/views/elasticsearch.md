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

Driver do Ruby:

* Karel Minarik.
  [Tire](https://github.com/karmi/tire) – a rich Ruby API and DSL for the ElasticSearch search engine/database

Różne:

* Karel Minarik.
  [Data Visualization with ElasticSearch and Protovis](http://www.elasticsearch.org/blog/2011/05/13/data-visualization-with-elasticsearch-and-protovis.html)


## Instalacja

Rozpakowujemy archiwum z ostatnią wersją
[ElasticSearch](http://www.elasticsearch.org/download/) (ok. 16 MB):

    unzip elasticsearch-0.18.5.zip

Uruchamiamy *elasticsearch*:

    cd elasticsearch-0.18.5
    bin/elasticsearch -f

Korzystamy z domyślnych ustawień — *http://localhost:9200*


## Zapisujemy dane w ElasticSearch

Składnia zapytań:

<pre>http://localhost:9200/<b> index </b>/<b> type </b>/...
</pre>

Dane zapiszemy w ElasticSearch za pomocą programu *curl*:

    :::bash
    curl -XPUT 'http://localhost:9200/twitter/user/kimchy' -d '
    {
       "name" : "Shay Banon"
    }'

    curl -XPUT 'http://localhost:9200/twitter/tweet/1' -d '
    {
       "user": "kimchy",
       "postDate": "2009-11-15T13:12:00",
       "message": "Trying out Elastic Search, so far so good?"
    }'

    curl -XPUT 'http://localhost:9200/twitter/tweet/2' -d '
    {
       "user": "kimchy",
       "postDate": "2009-11-15T14:12:12",
       "message": "Another tweet, will it be indexed?"
    }'

Sprawdzamy, co zostało dodane:

Now, lets see if the information was added by GETting it:

    :::bash
    curl -XGET 'http://localhost:9200/twitter/user/kimchy?pretty=true'
    curl -XGET 'http://localhost:9200/twitter/tweet/1?pretty=true'
    curl -XGET 'http://localhost:9200/twitter/tweet/2?pretty=true'


## Wyszukiwanie – pierwsze koty za płoty

Składnia zapytań:

<pre>http://localhost:9200/_search?...
http://localhost:9200/<b> index </b>/_search?...
http://localhost:9200/<b> index </b>/<b> type </b>/_search?...
</pre>

Standardowe zapytanie (w *query string*):

    :::bash
    curl -XGET 'http://localhost:9200/twitter/tweet/_search?q=user:kimchy&pretty=true'

Zapytanie z JSON (korzystamy z *JSON query language*):

    :::bash
    curl -XGET 'http://localhost:9200/twitter/tweet/_search?pretty=true' -d '
    {
       "query" : {
          "text" : { "user": "kimchy" }
       }
    }'

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
    curl -XGET 'http://localhost:9200/twitter/user/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'


## Multi Tenant – indeksy i typy

*Tenant* to najemca, dzierżawca. *Multi tenant* oznacza — …?

*Przykład.* Zapisujemy następujące dane w ElasticSearch:

    :::bash
    curl -XPUT 'http://localhost:9200/bilbo/info/1' -d '{ "name" : "Bilbo Baggins" }'
    curl -XPUT 'http://localhost:9200/frodo/info/1' -d '{ "name" : "Frodo Baggins" }'

    curl -XPUT 'http://localhost:9200/bilbo/tweet/1' -d '
    {
        "user": "bilbo",
        "postDate": "2009-11-15T13:12:00",
        "message": "Trying out Elastic Search, so far so good?"
    }'
    curl -XPUT 'http://localhost:9200/frodo/tweet/1' -d '
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


## Nie działa: Twitter Rivers

Przykład tzw. *filtered stream*:

    :::bash
    curl -XPUT localhost:9200/_river/my_twitter_river/_meta -d '
    {
        "type" : "twitter",
        "twitter" : {
            "user" : "twitter_user",
            "password" : "twitter_password",
            "filter": {
               "tracks": ["elasticsearch", "mongodb", "couchdb", "rails"]
            }
        },
        "index" : {
            "index" : "wlodek",
            "type" : "nosql",
            "bulk_size" : 10
        }
    }
    '

Ale można też tak:

    :::bash
    curl -XPUT localhost:9200/_river/my_twitter_river/_meta -d @wlodek-nosql-tweets.json

gdzie powyższy JSON zapisaliśmy w pliku *wlodek-nosql-tweets.json*.
