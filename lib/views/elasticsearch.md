#### {% title "Wyszukiwanie z ElasticSearch" %}

<blockquote>
 {%= image_tag "/images/john_cage.jpg", :alt => "[John Cage]" %}
 <p>I can't understand why people are frightened of new ideas.
    I'm frightened of the old ones.
 </p>
 <p class="author">— John Cage (1912–1992)</p>
</blockquote>

Zaczynamy od lektury [What's Wrong with SQL search](http://philip.greenspun.com/seia/search).

Teraz pora, na przyjrzenie się zawartości strony domowej *ElasticSearch*:

* [You know, for Search](http://www.elasticsearch.org/)
* [Guides](http://www.elasticsearch.org/guide/):
  - [Setup](http://www.elasticsearch.org/guide/reference/setup/)
  - [API](http://www.elasticsearch.org/guide/reference/api/)
  - [Query](http://www.elasticsearch.org/guide/reference/query-dsl/)
  - [Mapping](http://www.elasticsearch.org/guide/reference/mapping/)
  - [Facets](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html)
* [Setting up ElasticSearch ](http://www.elasticsearch.org/tutorials/2010/07/01/setting-up-elasticsearch.html)

Kiedyś trzeba będzie zainstalować tę wtyczkę
[A web front end for an ElasticSearch cluster](https://github.com/Aconex/elasticsearch-head)

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

    :::bash
    unzip elasticsearch-0.19.1.zip

A tak uruchamiamy *elasticsearch*:

    :::bash
    elasticsearch-0.19.1/bin/elasticsearch -f

I już! Domyślnie ElasticSearch nasłuchuje na porcie 9200:

    :::bash
    xdg-open http://localhost:9200

ElasticSearch zwraca wynik wyszukiwania w formacie JSON.
Jeśli preferujemy pracę w przeglądarce, to użyteczny
może być dodatek do Firefoks o nazwie
[JSONView](http://jsonview.com/) – that helps you view JSON documents
in the browser.

Warto też od razu zainstalować i uruchomić interfejs webowy do
ElasticSearch:

    :::bash
    elasticsearch-0.19.1/bin/plugin -install Aconex/elasticsearch-head
    xdg-open http://localhost:9200/_plugin/head/

### Krótka ściąga z Elasticsearch Head

W zakładce *Structured Query* warto wstawić „✔” przy *Show query source*.

W zakładce *Any Request* zmieniamy **POST** na **GET**.

Następnie dopisujemy do *Query* ścieżkę *_search*:

    http://localhost:9200/_search

W okienku *Validate JSON* wpisujemy, na przykład:

    :::json
    {"query":{"query_string":{"query":"mongo*"}}}

W *Result Transformer*, podmieniamy instrukcję z *return*
na przykład na:

    :::js
    return root.hits.hits;


<blockquote>
 <p>The usual purpose of a full-text search engine is to return
  <b>a small number</b> of documents matching your query.
</blockquote>

## Your data, Your search

Kilka, nieco zmienionych przykładów ze strony
[Your Data, Your Search](http://www.elasticsearch.org/blog/2010/02/12/yourdatayoursearch.html).

Czy *elasticsearch* ma REST API?
[REST API & JSON & Elasticsearch](http://www.elasticsearch.org/guide/reference/api/).

Podstawowa terminologia: indeks i jego typ.<br>
**Interpretacja URI w zapytaniach kierowanych do ElasticSearch:**

<pre>http://localhost:9200/<b>⟨index⟩</b>/<b>⟨type⟩</b>/...
</pre>

**Składnia zapytań** – [Lucene Query Parser Syntax](http://lucene.apache.org/java/2_9_1/queryparsersyntax.html).


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

Dodajemy książkę do indeksu *amazon*:

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

Dodajemy CD do indeksu *amazon*:

    :::bash
    curl -XPUT http://localhost:9200/amazon/cds/B00192IV0O -d @cd.json
      {"ok":true,"_index":"amazon","_type":"cds","_id":"B00192IV0O","_version":1}

Przykładowe zapytanie:

    :::bash
    curl 'http://localhost:9200/_search?pretty=true&q=label:Interscope'

Wyszukiwanie po wszystkich typach w indeksie *amazon*:

    :::bash
    curl 'http://localhost:9200/amazon/_search?pretty=true&q=name:energy'

Wyszukiwanie po kilku typach:

    :::bash
    curl 'http://localhost:9200/amazon/books,cds/_search?pretty=true&q=name:energy'

Teraz pora na posprzątanie po sobie. Usuwamy indeks **amazon**:

    :::bash
    curl -XDELETE 'http://localhost:9200/amazon'

albo, za jednym razem usuwamy **wszystkie** indeksy
(zalecana ostrożność):

    :::bash
    curl -XDELETE 'http://localhost:9200/_all'

Na koniec, zapytanie o zdrowie klastra ElasticSearch:

    :::bash
    curl 'http://localhost:9200/_cluster/health?pretty=true'


### Zapytania, korzystające z JSON Query Language

Zaczynamy od zapisania kilku dokumentów w ElasticSearch:

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
    curl 'http://localhost:9200/twitter/users/kimchy?pretty=true'
    curl 'http://localhost:9200/twitter/tweets/1?pretty=true'
    curl 'http://localhost:9200/twitter/tweets/2?pretty=true'

Dla przypomnienia, interpretacja uri w zapytaniach do ElasticSearch:

<pre>http://localhost:9200/<b>⟨index⟩</b>/_search?...
http://localhost:9200/<b>⟨index⟩</b>/<b>⟨type⟩</b>/_search?...
</pre>

Teraz odpytamy indeks *twitter* korzystając
z ElasticSearch *JSON query language*:

    :::bash
    curl 'http://localhost:9200/twitter/tweets/_search?pretty=true' -d '
    {
       "query" : {
          "text" : { "user": "kimchy" }
       }
    }'
    curl 'http://localhost:9200/twitter/tweets/_search?pretty=true' -d '
    {
       "query" : {
          "term" : { "user": "kimchy" }
       }
    }'

Jaka jest różnica między wyszukiwaniem z **text** a **term**?

Sprawdzamy ile jest dokumentów w indeksie *twitter*:

    :::bash
    curl 'http://localhost:9200/twitter/_count

Wyciągamy wszystkie dokumenty z indeksu *twitter*:

    :::bash
    curl 'http://localhost:9200/twitter/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'

Albo – dokumenty typu *users* z indeksu *twitter*:

    :::bash
    curl -XGET 'http://localhost:9200/twitter/users/_search?pretty=true' -d '
    {
        "query" : {
            "matchAll" : {}
        }
    }'


## Indeksy i typy *Multi Tenant*

*Tenant* to najemca, dzierżawca. *Multi tenant* – jak to przetłumaczyć?
Czy poniższy przykład coś wyjaśnia?

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

Wyszukiwanie „multi”, po kilku indeksach:

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

# ElasticSearch & Ruby + Tire

Takie eksperymentowanie z ElasticSearch rest API pozwala sprawdzić,
czy dobrze je rozumiemy oraz czy poprawnie zainstalowaliśmy sam program.
Dalsze takie próby są nużące i wyniki nie są są zajmujące.

Dlatego, do następnych prób użyjemy większej liczby rzeczywistych
(i dlatego zajmujących) danych. Naszymi danymi będą statusy z Twittera.
Dodatkowo do odfiltrowania interesujących nas statusów
skorzystamy z [stream API](https://dev.twitter.com/docs/streaming-api):

    :::ruby tracking
    track=rails,mongodb,couchdb,redis,elasticsearch,neo4j

(Dlaczego filtrujemy? Co sekundę wysyłanych jest do Twittera ok. 1000
nowych statusów. Większość z nich nie ma dla nas żadnego znaczenia.)

Więcej tweetów: jeśli dopiszemy słowo **wow** wpisywane w wielu
statusach, zostaniemy zalani tweetami – **wow!**

Najprościej będzie zacząć od pobrania statusów za pomocą programu *curl*:

    :::bash
    curl -X POST https://stream.twitter.com/1/statuses/filter.json -d @tracking \
      -uAnyTwitterUser:Password

Jak widać statusy zawierają wiele pól i tylko kilka z nich zawiera
interesujące dane. Niestety, na konsoli trudno jest czytać interesujące nas fragmenty.
Są one wymieszane z jakimiś technicznymi rzeczami, np.
*profile_sidebar_fill_color*, *profile_use_background_image* itp.

Dlatego, przed wypisaniem statusu na ekran, powinniśmy go „oczyścić”
ze zbędnych rzeczy. Zrobimy to za pomocą skryptu w Ruby. W skrypcie
skorzystamy z następujących gemów:

    gem install tweetstream yajl-ruby tire ansi

{%= image_tag "/images/twitter_elasticsearch.jpeg", :alt => "[Twitter -> ElasticSearch]" %}

Zaczniemy od skryptu działającego podobnie do polecenia z *curl* powyżej.

Aby uzyskać dostęp do stream API wymagana jest weryfikacja<br>
(opcja *-uAnyTwitterUser:Password* w poleceniu *curl* powyżej).

    :::ruby nosql-tweets.rb
    # encoding: utf-8

    require 'yajl/json_gem'
    require 'tweetstream'

    user, password = ARGV

    unless (user && password)
      puts "\nUsage:\n\t#{__FILE__} <AnyTwitterUser> <Password>\n\n"
      exit(1)
    end

    TweetStream.configure do |config|
      config.username = user
      config.password = password
      config.auth_method = :basic  # OAuth or HTTP Basic Authentication is required
      config.parser = :yajl
    end

    def handle_tweet(s)
      puts "#{JSON.pretty_generate(s)}"
    end

    client = TweetStream::Client.new

    client.on_error do |message|
      puts message
    end

    client.track('rails', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
      handle_tweet status
    end


W skrypcie {%= link_to "nosql-tweets.rb", "/elasticsearch/nosql-tweets.rb" %},
który zostanie wykorzystany na wykładzie, inaczej rozwiązano
podawanie swoich danych. Dlaczego tak?


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

Skrypt ten uruchamiamy na konsoli w następujący sposób:

    :::bash
    ruby nosql-tweets.rb MyTwitterUserName MyPassword

Wpatrując się w ekran przez jakiś czas zaczynamy
dostrzegać pole zawierające interesujące dane:

    id
    text
    created_at
    user:
      screen_name
    entities:      # tylko trzy tablice?
      urls (url)
      user_mentions (id_str, name, screen_name)
      hashtags (text)

Czyszczenie statusów, to zadanie dla metody *handle_tweet*:

    :::ruby
    def handle_tweet(s)
      h = { }
      h[:id] = s[:id]
      h[:text] =  s[:text]
      h[:screen_name] = s[:user][:screen_name]
      h[:entities] = s[:entities]
      h[:created_at] = Time.parse(s[:created_at])
      puts "#{JSON.pretty_generate(h)}"
    end

Po wymianie na nowy kodu *handle_tweet* i ponownym uruchomieniu skryptu
widzimy efekty. To się da czytać!


## Twitter Stream ⟿ ElasticSearch

Teraz zabierzemy się za zapisywanie oczyszczonych statusów
w ElasticSearch.  W tym celu napiszemy skrypt w Ruby i skorzystamy
z wygodnego DSL dla ElasticSearch oferowanego przez gem Tire.

Z Twitterem możemy zestawić tylko jeden strumień (co można wyczytać
w dokumentacji do API Twittera).
Dlatego zbierzemy wszystkie statusy z interesujących nas kategorii – rails,
mongodb itd. do jednego strumienia.
Rozdzielimy je na typy, na chwilę przed zapisaniem w bazie.
Wykorzystamy w tym celu mechanizm perkolacji.

Co oznacza *percolation*? przenikanie, przefiltrowanie, perkolacja?
„Let's define callback for percolation.
Whenewer a new document is saved in the index, this block will be executed,
and we will have access to matching queries in the `NosqlTweet#matches` property.”

Przy okazji zdefinujemy *mapping* dla statusów zapisywanych w bazie ElasticSearch.

Co to jest *mapping*?
„Mapping is the process of defining how a document should be mapped to
the Search Engine, including its searchable characteristics such as
which fields are searchable and if/how they are tokenized.”

    :::ruby create-index-percolate_nosql_tweets.rb
    # encoding: utf-8
    require 'tire'

    nosql_tweets_mapping =  {
      :properties => {
        :text          => { :type => 'string', :boost => 2.0,            :analyzer => 'snowball'       },
        :screen_name   => { :type => 'string', :index => 'not_analyzed',                               },
        :created_at    => { :type => 'date',                                                           },
        :hashtags      => { :type => 'string', :index => 'not_analyzed', :index_name => 'hashtag'      },
        :urls          => { :type => 'string', :index => 'not_analyzed', :index_name => 'url'          },
        :user_mentions => { :type => 'string', :index => 'not_analyzed', :index_name => 'user_mention' }
      }
    }

    mappings = { }

    %w{rails jquery mongodb couchdb redis neo4j elasticsearch}.each do |keyword|
      mappings[keyword.to_sym] = nosql_tweets_mapping
    end

    Tire.index('nosql_tweets') do
      delete
      create :mappings => mappings
    end

    Tire.index('nosql_tweets').refresh

    # Register several queries for percolation against the nosql_tweets index.

    Tire.index('nosql_tweets') do
      %w{rails jquery mongodb redis couchdb neo4j elasticsearch}.each do |keyword|
        register_percolator_query(keyword) { string keyword }
      end
    end

    # Refresh the `_percolator` index for immediate access.

    Tire.index('_percolator').refresh

Uuruchamiamy ten skrypt i sprawdzamy czy *mapping* zostało zapisane w bazie:

    :::bash
    ruby create-index-percolate_nosql_tweets.rb
    curl 'http://localhost:9200/nosql_tweets/_mapping?pretty=true'

Cały skrypt można obejrzeć na GitHubie –
[create-index-percolate_nosql_tweets.rb](https://github.com/wbzyl/est/blob/master/create-index-percolate_nosql_tweets.rb).

Dopiero po tych wstępnych robótkach ręcznych, zabierzemy się za
skrypt zapisujący statusy indeksie *nosql_tweets* i w typach
o nazwach takich samych jak słowa kluczowe.

    :::ruby fetch-nosql_tweets.rb
    # Let's define a class to hold our data in ElasticSearch.

    class NosqlTweet
      include Tire::Model::Persistence

      property :text
      property :screen_name
      property :created_at
      property :hashtags
      property :urls
      property :user_mentions

      # Let's define callback for percolation.
      # Whenewer a new document is saved in the index, this block will be executed,
      # and we will have access to matching queries in the `NosqlTweet#matches` property.
      #
      # Below, we will just print the text field of matching query.
      on_percolate do
        if matches.empty?
          puts bold { "'#{text}' from @#{bold { screen_name }}" }
        else
          puts green { "'#{text}' from @#{bold { screen_name }}" }
        end
      end
    end

    def handle_tweet(s)
      ... ✂ ...

      types = h.percolate
      puts "matched queries: #{types}"

      types.to_a.each do |type|
        NosqlTweet.document_type type
        h.save
      end
    end

    # TweetStream part.

    client = TweetStream::Client.new

    client.on_error do |message|
      puts red { message }
    end

    # Fetch statuses from Twitter and write them to ElasticSearch.
    client.track('rails', 'jquery', 'mongodb', 'couchdb', 'redis', 'neo4j', 'elasticsearch') do |status|
      handle_tweet(status)
    end

Cały skrypt *fetch-nosql_tweets-cli.rb* można podejrzeć
[tutaj](https://github.com/wbzyl/est/blob/master/fetch-nosql_tweets-cli.rb).

Po uruchmieniu skryptu:

    :::bash fetch-nosql_tweets-cli.rb
    ruby fetch-nosql_tweets-cli.rb

i odczekaniu kilku minut, aż kilka statusów zostanie zapisanych w bazie,
wykonujemy kilka prostych testów:

    :::bash
    curl 'http://localhost:9200/nosql_tweets/_count'
    curl 'http://localhost:9200/nosql_tweets/rails/_count'
    curl 'http://localhost:9200/nosql_tweets/_search?q=*&sort=created_at:desc&size=2&pretty=true'
    curl 'http://localhost:9200/nosql_tweets/_search?size=2&sort=created_at:desc&pretty=true'
    curl 'http://localhost:9200/nosql_tweets/_search?_all&sort=created_at:desc&pretty=true'

Oczywiście można też podejrzeć statusy
korzystając z aplikacji webowej [Elasticsearch Head](https://github.com/Aconex/elasticsearch-head).


## Faceted search, czyli wyszukiwanie fasetowe

[Co to jest?](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html)
„Facets provide aggregated data based on a search query. In the
simplest case, a terms facet can return facet counts for various facet
values for a specific field. ElasticSearch supports more facet
implementations, such as statistical or date histogram facets.”

**Uwaga:** Pole wykorzystywane do obliczeń fasetowych musi być typu:

* *numeric*
* *date* lub *time*
* *be analyzed as a single token*

Przykłady:

    :::bash
    curl -X POST "http://localhost:9200/nosql_tweets/_count?q=couchdb&pretty=true"
    curl -X POST "http://localhost:9200/nosql_tweets/_search?pretty=true" -d '
    {
      "query" : { "query_string" : {"query" : "couchdb"} },
      "sort" : { "created_at" : { "order" : "desc" } }
    }'
    curl -X POST "http://localhost:9200/nosql_tweets/_search?pretty=true" -d '
    {
      "query" : { "query_string" : {"query" : "couchdb"} },
      "sort" : { "created_at" : { "order" : "desc" } },
      "facets" : { "hashtags" : { "terms" :  { "field" : "hashtags" } } }
    }'
    curl -X POST "http://localhost:9200/nosql_tweets/_search?pretty=true" -d '
    {
      "query" : { "match_all" : {} },
      "sort" : { "created_at" : { "order" : "desc" } },
      "facets" : { "hashtags" : { "terms" :  { "field" : "hashtags" } } }
    }'
    curl -X POST "http://localhost:9200/nosql_tweets/_search?size=0&pretty=true" -d '
    {
      "facets" : { "hashtags" : { "terms" :  { "field" : "hashtags" } } }
    }'

A tak wygląda „fasetowy” JSON:

    :::json
    "facets" : {
       "hashtags" : {
         "_type" : "terms",
         "missing" : 3240,
         "total" : 2099,
         "other" : 1279,
         "terms" : [ {
           "term" : "mongodb",
           "count" : 198
         }, {
           "term" : "rails",
           "count" : 141
         }, {
           "term" : "nosql",
           "count" : 80
         }, {
           "term" : "job",
           "count" : 80
         } ]
       }
     }


[Search API – Facets](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html):
The facet also returns the number of documents which have no value for
the field (*missing*), the number of facet values not included in the
returned facets (*other*), and the total number of tokens in the facet
(*total*).

Jeszcze jeden przykład:

    :::bash
    curl -X POST "http://localhost:9200/nosql_tweets/_search?pretty=true" -d '
       {
         "query" : { "query_string" : {"query" : "couchdb"} },
         "sort" : { "created_at" : { "order" : "desc" } },
         "facets" : { "hashtags" : { "terms" :  { "field" : "hashtags", size: 3 }, "global": true } }
       }'

A teraz inny facet:

    :::bash
    curl -X POST "http://localhost:9200/nosql_tweets/_search?pretty=true" -d '
    {
      "query" : { "match_all" : {} },
      "sort" : { "created_at" : { "order" : "desc" } },
      "facets" : { "statuses_per_day" : { "date_histogram" :  { "field" : "created_at", "interval": "day" } } }
    }'

Tak wygląda *date_histogram* facet:

    :::json
    "facets" : {
      "statuses_per_day" : {
        "_type" : "date_histogram",
        "entries" : [ {
          "time" : 1332201600000,
          "count" : 2834
        }, {
          "time" : 1332288000000,
          "count" : 384
        } ]
      }
    }

Co to są za liczby przy *time*:

    :::js
    new Date(1332201600000);                  // Tue, 20 Mar 2012 00:00:00 GMT
    new Date(1332288000000);                  // Wed, 21 Mar 2012 00:00:00 GMT
    (new Date(1332288000000)).getFullYear();  // 2012


### Krótka ściąga z obiektu Date

Inicjalizacja:

    :::javascript
    new Date();
    new Date(milliseconds);
    new Date(dateString);
    new Date(year, month, day, hours, minutes, seconds, milliseconds);
    // parsing
    ms = Date.parse('2011-01-31T12:00:00.016');
    new Date(ms); // Mon, 31 Jan 2011 12:00:00 GMT

Metody:

    :::js
    d = new Date(1332288000000);
    d.getTime();         // 1332288000000
    d.getFullYear();     // 2011
    d.getMonth();        //    0    (0-11)
    d.getDate();         //   31    zwraca dzień miesiąca!
    d.getHours();
    d.getMinutes();
    d.getSeconds();
    d.getMilliseconds();

Konwersja na napis:

    d.toString();        // 'Mon Jan 31 2011 01:00:00 GMT+0100 (CET)'
    d.toLocaleString();  // 'Wed Mar 21 2012 01:00:00 GMT+0100 (CET)'
    d.toGMTString();     // 'Wed, 21 Mar 2012 00:00:00 GMT'

Zobacz też [Epoch & Unix Timestamp Conversion Tools](http://www.epochconverter.com/).


## Trochę linków

Linki do dokumentacji:

* [eventmachine](https://github.com/eventmachine/eventmachine)
* [em-http-request](https://github.com/igrigorik/em-http-request)
* [tweetstream](https://github.com/intridea/tweetstream)
* [yajl-ruby](https://github.com/brianmario/yajl-ruby)

Zobacz też:

* Adam Wiggins.
  [Consuming the Twitter Streaming API](http://adam.heroku.com/past/2010/3/19/consuming_the_twitter_streaming_api/) –
  prościej, bez *TweetStream*
* Karel Minarik.
  [Gmail & ES](http://ephemera.karmi.cz/post/5510326335/gmail-elasticsearch-ruby)
* Mirko Froehlich.
  [Building a Twitter Filter With Sinatra, Redis, and TweetStream](http://www.digitalhobbit.com/2009/11/08/building-a-twitter-filter-with-sinatra-redis-and-tweetstream/)


# Aplikacja EST

Śledząc spływające statusy na konsoli i analizując
wyniki wyszukiwania fasetowego dla hashtagów,
wkrótce zaczynamy orientować się co się dzieje w świecie
rails, mongodb, couchdb, redis, elasticsearch, neo4j.

Napiszemy prostą aplikację Rails umożliwiającą nam przeglądanie
statusów, które zostały zapisane w bazie, w czasie kiedy nie
śledziliśmy statusów na konsoli.

Aplikacja będzie składała się z jednego modelu *NosqlTweet*,
kontroler będzie miał jedną metodę *index*.

Na stronie indeksowej umieścimy formularz wyszukiwania statusów,
zwracane statusy będą stronicowane (skorzystamy z gemu
*will_paginate*).

Po wejściu na stronę główną, aplikacja wyświetli stronę z ostatnio
pobranymi statusami.

Dlaczego korzystamy z gemu Tire? Czy jest jakaś alternatywa dla Tire?


## Generujemy rusztowanie aplikacji

Aplikację nazwiemy krótko **EST** (*ElasticSearch Statuses*):

    :::bash
    rails new est --skip-active-record --skip-test-unit --skip-bundle
    rm est/public/index.html

Następnie instalujemy gemy, generujemy kontroler:

    cd est
    bundle install --path=$HOME/.gems --binstubs
    rails generate controller nosql_tweets index

i zmieniamy routing:

    :::ruby config/routes.rb
    match '/nosql_tweets' => 'nosql_tweets#index', as: :nosql_tweets
    root to: 'nosql_tweets#index'

Po tej zmianie, polecenie

    :::bash
    rake routes

powinno wypisać taki routing:

    :::json
    nosql_tweets  /nosql_tweets(.:format) {:controller=>"nosql_tweets", :action=>"index"}
            root  /                       {:controller=>"nosql_tweets", :action=>"index"}


<blockquote>
 {%= image_tag "/images/mark-otto.jpg", :alt => "[Mark Otto]" %}
 <p>Bootstrap is a toolkit from Twitter designed to kickstart
 development of webapps and sites.  It includes base CSS and HTML for
 typography, forms, buttons, tables, grids, navigation, and more.<p>
 <p class="author">— Mark Otto</p>
</blockquote>

### Korzystamy z frameworka Twitter Bootstrap

Dlaczego będziemy korzystać z [Twitter Bootstrap](http://twitter.github.com/bootstrap/)?

Jest kilka gemów ułatwiajacych instalację tego frameworka w Rails.
My skorzystamy z gemu [Bootstrap Sass](https://github.com/thomas-mcdonald/bootstrap-sass).

Dopisujemy go, i przy okazji gemy [Will Paginate](https://github.com/mislav/will_paginate)
oraz [Tire](https://github.com/karmi/tire) do *Gemfile*:

    :::ruby Gemfile
    gem 'bootstrap-sass', group: :assets
    gem 'will_paginate'
    gem 'tire'

i instalujemy oba gemy i gemy od nich zależne:

    :::bash
    bundle install

Zmienne, mixiny, makra i pozostałe rzeczy zdefiniowane w *Bootstrap*
znajdziemy tutaj:

    :::bash
    bundle show bootstrap-sass
      $HOME/.gems/ruby/1.9.1/gems/bootstrap-sass-1.4.4
    cd $HOME/.gems/ruby/1.9.1/gems/bootstrap-sass-1.4.4/vendor/assets/stylesheets
    tree
    .
    ├── bootstrap
    │   ├── forms.css.scss
    │   ├── mixins.css.scss
    │   ├── patterns.css.scss
    │   ├── reset.css.scss
    │   ├── scaffolding.css.scss
    │   ├── tables.css.scss
    │   ├── type.css.scss
    │   └── variables.css.scss
    └── bootstrap.css.scss

Ja zmienię wielkość fontu, kolorystykę i dodam brakujący odstęp pod paskiem
u góry strony:

    :::css app/assets/stylesheets/nosql_tweets.css.scss
    $basefont: 16px;
    $baseline: 24px;

    @import 'bootstrap';

    article {
      clear: both;
    }

    body {
      padding-top: 60px;
    }

    // patterns.css.scss:
    // 0 -- opaque
    // 1 -- transparent
    .topbar-inner, .topbar .fill {
      background-color: rgb(164, 5, 15);
      @include vertical-gradient(#A4050F, #A40200);
      $shadow: 0 0 3px rgba(164, 5, 15, .25), inset 0 -1px 0 rgba(164, 5, 15, .1);
      @include box-shadow($shadow);
    }

    $headerColor: #300800;
    $headerColorLight: lighten($headerColor, 25%);

    // type.css.scss
    h1, h2, h3, h4, h5, h6 {
      font-weight: bold;
      color: $headerColor;
      small {
        color: $headerColorLight;
      }
    }

    // statuses: datetime
    .date {
      float: right;
      font-style: italic;
      font-size: 90%;
    }
    a.entities {
      margin-left: .5em;
    }

Pozostaje zmienić layout (użyjemy gotowego szablonu o nazwie
[ContainerApp](http://twitter.github.com/bootstrap/examples/container-app.html)),
dodać kilka widoków częściowych i pierwsza wersja rusztowania
aplikacji będzie gotowa.

Wszystkie użyte pliki są w repozytorium [EST](https://github.com/wbzyl/est):

* [application.html.erb](https://github.com/wbzyl/est/blob/master/app/views/layouts/application.html.erb) –
  szablon [ContainerApp](http://twitter.github.com/bootstrap/examples/container-app.html) dostosowany do Rails 3.1
* szablony częściowe:
  * [_menu.html.erb](https://github.com/wbzyl/est/blob/master/app/views/common/_menu.html.erb)
  * [_header.html.erb](https://github.com/wbzyl/est/blob/master/app/views/common/_header.html.erb)
  * [_footer.html.erb](https://github.com/wbzyl/est/blob/master/app/views/common/_footer.html.erb)

Powyżej skorzystałem z palety:

* pomarańczowy: \#A4050F
* brązowy: \#300800
* khaki: \#61673C (ciemny), \#B2AF6A (jaśniejszy), \#F6E6AF (jasny)

Użyteczne linki:

* [Twitter Bootstrap on Rails](http://lucapette.com/rails/twitter-bootstrap-on-rails/)
* [Too good to be true! Twitter Bootstrap meets Formtastic and Tabulous](http://rubysource.com/too-good-to-be-true-twitter-bootstrap-meets-formtastic-and-tabulous/)
* [How to Customize Twitter Bootstrap’s Design in a Rails app](http://rubysource.com/how-to-customize-twitter-bootstrap%E2%80%99s-design-in-a-rails-app/)
* [jQuery Datepicker](http://keith-wood.name/datepick.html)
* [jQuery-UI Datepicker](http://jqueryui.com/demos/datepicker/)


## Dodajemy pozostałe elementy MVC

Kontroler:

    :::ruby app/controllers/nosql_tweets_controller.rb
    class NosqlTweetsController < ApplicationController
      def index
        @nosql_tweets = NosqlTweet.search(params)
      end
    end

Formularz:

    :::rhtml app/views/nosql_tweets/index.html.erb
    <%= form_tag nosql_tweets_path, method: :get do %>
    <p>
      <%= text_field_tag :q, params[:q] %>
      <%= submit_tag 'Search', name: nil %>
    </p>
    <% end %>

Paginacja:

    :::rhtml app/views/nosql_tweets/index.html.erb
    <div class="digg_pagination">
      <div clas="page_info">
        <%= page_entries_info @nosql_tweets.results %>
      </div>
      <%= will_paginate @nosql_tweets.results %>
    </div>


Pozostała część widoku *index* (*TODO:* napisać kilka metod pomocniczych):

    :::rhtml app/views/nosql_tweets/index.html.erb
    <% @nosql_tweets.results.each do |tweet| %>
    <article>
    <p>
     <% text = (tweet.highlight && tweet.highlight.text) ? tweet.highlight.text.first : tweet.text %>
     <%= text.html_safe %>
    </p>
    <% date = Time.parse(tweet.created_at).strftime('%d.%m.%Y %H:%M') %>
    <p class="date">published on <%= content_tag :time, date, datetime: tweet.created_at %></p>
    <p>
     <% unless tweet.urls.empty? %>
       Links:
       <% tweet.urls.each_with_index do |url, index| %>
         <%= content_tag :a, "[#{index+1}]", href: url, class: :entities %>
       <% end %>
      <% end %>
    </p>
    </article>
    <% end %>

Model:

    :::ruby app/models/nosql_tweet.rb
    class NosqlTweet
      include Tire::Model::Persistence

      property :text
      property :screen_name
      property :created_at
      property :hashtags
      property :urls
      property :user_mentions

      def self.search(params)
        #Tire.search('statuses', type: 'mongodb', page: params[:page], per_page: 3) do |search|
        Tire.search('nosql_tweets', page: params[:page], per_page: 8) do |search|
          per_page = search.options[:per_page]
          current_page = search.options[:page] ? search.options[:page].to_i : 1
          offset = search.options[:per_page] * (current_page - 1)

          search.query do
            boolean do
              #must { string params[:q].blank? ? "*" : params[:q] }
              must { string params[:q] } if params[:q].present?
              must { range :created_at, lte: Time.zone.now }
            end
          end
          search.sort { by :created_at, "desc" }
          search.highlight text: {number_of_fragments: 0}, options: {tag: '<mark>'}

          search.size per_page
          search.from offset
        end
      end
    end

Pobieramy style stronicowania ze strony
[Samples of pagination styles for will_paginate](http://mislav.uniqpath.com/will_paginate/)
i modyfikujemy *application.css*:

    :::css app/assets/stylesheets/application.css
    /*
     * This is a manifest file that'll automatically include all the stylesheets available in this directory
     * and any sub-directories. You're free to add application-wide styles to this file and they'll appear at
     * the top of the compiled file, but it's generally better to create a new file per style scope.
     *= require_self
     *= require pagination
     *= require nosql_tweets
    */

## Fasety

**TODO:** Dodać wyszukiwanie fasetowe po hashtagach.


# JSON dump indeksu nosql_tweet

Zobacz search API:

* [scroll](http://www.elasticsearch.org/guide/reference/api/search/scroll.html)
* [scan](http://www.elasticsearch.org/guide/reference/api/search/search-type.html)

Ściąga:

* a search request can be scrolled by specifying the *scroll* parameter;
  `scroll=4m` indicates for how long (*co to oznacza? 4 minuty czy 4 milisekundy*)
  the nodes that participate in the search will maintain relevant resources
  in order to continue and support it
* the *scroll_id* should be used when scrolling
  (along with the scroll parameter, to stop the scroll from expiring);
  the *scroll_id* **changes for each scroll request**
  and only the most recent one should be used
* the “breaking” condition out of a scroll is when no hits has been returned;
  the *hits.total* will be maintained between scroll requests

Przykład pokazujący jak to działa:

    :::bash
    curl -X GET 'localhost:9200/nosql_tweets/_search?search_type=scan&scroll=10m&size=4&pretty=true'

Opcjonalnie możemy dopisać kryteria wyszukiwania, wszystko:

    :::json
    {
       "query" : {
         "match_all" : {}
       }
    }

albo:

    :::json
    {
       "query": {
          "query_string" : {
             "query" : "some query string here"
          }
       }
    }

Wtedy zmieniamy wywołanie *curl* na:

    :::bash
    curl -XGET 'localhost:9200/nosql_tweets/_search?search_type=scan&scroll=10m&size=4&pretty=true' -d '
    {
       "query" : {
         "match_all" : {}
       }
    }'

Wynik wykonania tego polecenia, to przykładowo:

    :::json
    {
      "_scroll_id" : "c2NhbjsxOzE6Q29xZ01qdkJTZHVRdTA1Ow=",
      "took" : 10,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "failed" : 0
      },
      "hits" : {
        "total" : 105,
        "max_score" : 0.0,
        "hits" : [ ]
      }
    }

Teraz wykonujemy tyle razy polecenie:

    :::bash
    curl -XGET 'localhost:9200/_search/scroll?scroll=10m&pretty=true' \
      -d 'przeklikujemy ostatnią wersję _scroll_id'

aż otrzymamy pustą tablicę *hits.hits*:

    :::json
    {
      "_scroll_id" : "c2lZ1UTsxO3RvdGFsX2hpdHM6MTM5Ow=",
      "took" : 128,
      "timed_out" : false,
      "_shards" : {
        "total" : 1,
        "successful" : 1,
        "failed" : 0
      },
      "hits" : {
        "total" : 2024,
        "max_score" : 0.0,
        "hits" : [ ]
        ...

Przykładowa implementacja tego algorytmu w NodeJS (v0.6.12)
+ moduł [Restler](https://github.com/danwrong/restler) (v2.0.0):

    :::js dump-tweets.js
    var rest = require('restler');

    var iterate = function(data) {  // funkcja rekurencyjna
      rest.get('http://localhost:9200/_search/scroll?scroll=10m', { data: data._scroll_id } )
        .on('success', function(data, response) {
          if (data.hits.hits.length != 0) {
            data.hits.hits.forEach(function(tweet) {
              console.log(JSON.stringify(tweet)); // wypisz JSONa w jednym wierszu
            });
            iterate(data);
          };
        });
    };

    rest.get('http://localhost:9200/nosql_tweets/_search?search_type=scan&scroll=10m&size=32')
      .on('success', function(data, response) {
        iterate(data);
      });

Skrypt ten uruchamiamy tak:

    :::bash
    node dump-tweets.js

Oczywiście wcześniej musimy umieścić dane w indeksie *nosql_tweets*.
JTZ? Opisałem to w [README tutaj](https://github.com/wbzyl/est).

**Uwaga:** Korzystając z tego skryptu, możemy łatwo przenieść
dane z Elasticsearch do MongoDB:

    :::bash
    node json_dump-nosql_tweets.js | mongoimport --upsert -d test -c tweets --type json


# Rivers allows to index streams

Zamiast samemu pisać kod do pobierania statusów z Twittera możemy
użyć do tego celu wtyczki *river-twitter*.

Instalacja wtyczek *rivers* jest prosta:

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

Repozytoria z kodem wtyczek są na Githubie [tutaj](https://github.com/elasticsearch).

MongoDB River Plugin for ElasticSearch:

* [elasticsearch-river-mongodb](https://github.com/richardwilly98/elasticsearch-river-mongodb)

**Uwaga**: Po instalacji wtyczki, należy zrestartować *ElasticSearch*.


## River Twitter

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
            "bulk_size" : 20
        }
    }

Sprawdzanie statusu *River Twitter*:

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

A tak raportowane jest pobranie paczki z tweetami na konsoli:

    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Establishing connection.
    [2011-12-16 12:54][INFO ][cluster.metadata           ] [Hazard] [_river] update_mapping [my_rivers] (dynamic)
    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Connection established.
    [2011-12-16 12:54][INFO ][twitter4j.TwitterStreamImpl] Receiving status stream.
    [2011-12-16 12:57][INFO ][cluster.metadata           ] [Hazard] [tweets] update_mapping [nosql] (dynamic)

Wyszukiwanie:

    :::bash
    curl 'http://localhost:9200/tweets/nosql/_search?q=text:mongodb&fields=user.name,text&pretty=true'
    curl 'http://localhost:9200/tweets/nosql/_search?pretty=true' -d '
    {
        "query" : {
            "match_all" : { }
        }
    }'

Przy okazji możemy sprawdzić jak zaimplemetowany jest *mapping* w Tiver Twitter:

    :::bash
    curl 'http://localhost:9200/tweets/_mapping?pretty=true'


# Zadania

1\. Zainstalować wtyczkę *Wikipedia River*. Wyszukiwanie?

2\. Przeczytać [Creating a pluggable REST endpoint](http://www.elasticsearch.org/tutorials/2011/09/14/creating-pluggable-rest-endpoints.html).

3\. Zainstalować wtyczkę [hello world](https://github.com/brusic/elasticsearch-hello-world-plugin/).

4\. Napisać swoją wtyczkę do Elasticsearch.

5\. [Filename search with ElasticSearch](http://stackoverflow.com/questions/9421358/filename-search-with-elasticsearch).
