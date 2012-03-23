#### {% title "Elasticsearch w przykładach" %}

Zapisujemy kilka dokumentów w ElasticSearch:

    :::bash
    curl -X DELETE 'localhost:9200/aphorisms'
    curl -X POST   'localhost:9200/aphorisms/_bulk' --data-binary @aphorisms.bulk
    curl -X POST   'localhost:9200/_refresh'

Dane (**uwaga:* każdy JSON wpisujemy w jednym wierszu):

    :::json test.bulk
    { "index": { "_type" : "steinhaus" } }
    { "quote": "Idioci i geniusze są wolni od obowiązku rozumienia dowcipów.",
      "tags": ["ludzie", "dowcipy", "człowiek"] }
    { "index": { "_type" : "steinhaus" } }
    { "quote": "Unikaj skarżącego się na brak czasu, chce ci zabrać twój. ",
      "tags": ["ludzie", "czas", "człowiek"] }
    { "index": { "_type" : "steinhaus" } }
    { "quote": "Ludzie myślą, mówią i robią to, czego nie wolno robić, o czym nie wolno mówić ani myśleć.",
      "tags": ["ludzie", "myślenie"] }
    { "index": { "_type" : "steinhaus" } }
    { "quote": "Między duchem a materią pośredniczy matematyka.",
      "tags": ["materia", "duch", "matematyka"] }
    { "index": { "_type" : "lec" } }
    { "quote": "Mężczyźni wolą kobiety ładne niż mądre, ponieważ łatwiej im przychodzi patrzenie niż myślenie.",
      "tags": ["ludzie", "kobiety", "mężczyźni"] }
    { "index": { "_type" : "lec" } }
    { "quote": "Podrzuć własne marzenia swoim wrogom, może zginą przy ich realizacji.",
      "tags": ["ludzie", "myślenie", "marzenia"] }
    { "index": { "_type" : "lec" } }
    { "quote": "By dojść do źródła, trzeba płynąć pod prąd.",
      "tags": ["źródło"] }
    { "index": { "_type" : "lec" } }
    { "quote": "Chociaż krowie dasz kakao, nie wydoisz czekolady.",
      "tags": ["zwierzęta", "krowa", "doić"] }


## Wyszukiwanie

[Search API](http://www.elasticsearch.org/guide/reference/api/search/):
„The query can either be provided using a simple query string as a
parameter, or using a request body.”

Przeszukaj wszystkie dokumenty, zwróć cztery:

    :::bash
    curl "localhost:9200/aphorisms/_search?pretty=true" -d '
      {
        "size": 4,
        "sort": { "_score": {}  },
        "query" : { "query_string" : {"query" : "do*"} }
      }'

Tylko jedno pole:

    :::bash
    curl "localhost:9200/aphorisms/_search?pretty=true" -d '
      { "query" : { "query_string" : {"query" : "quote:do*"} } }'
    curl "localhost:9200/aphorisms/_search?pretty=true" -d '
      { "query" : { "query_string" : {"query" : "tags:do*"} } }'
    curl "localhost:9200/aphorisms/_search?fields=quote&pretty=true" -d '
      { "query" : { "query_string" : {"query" : "tags:do*"} } }'
    curl "localhost:9200/aphorisms/_search?pretty=true" -d '
      { "fields": ["quote"],
        "query" : { "query_string" : {"query" : "tags:do*"} } }'


## Wyszukiwanie tylko w subdocuments

Przykładowe dokumenty:

    :::bash
    curl    -X DELETE 'localhost:9200/contacts'
    curl -s -X POST   'localhost:9200/contacts/_bulk' --data-binary @contacts.bulk
    curl    -X POST   'localhost:9200/_refresh'

Dane *contacts.bulk*:

    :::json contacts.bulk
    { "index": { "_type" : "private" } }
    { "created_at": "1965-03-01", "name": { "last": "Grabczyk",  "first": "Agata" }  }
    { "index": { "_type" : "private" } }
    { "created_at": "1966-03-10", "name": { "last": "Korolczyk", "first": "Bartek" }  }
    { "index": { "_type" : "private" } }
    { "created_at": "1966-03-20", "name": { "last": "Maciejak",  "first": "Adam" }  }
    { "index": { "_type" : "private" } }
    { "created_at": "1965-03-01", "name": { "last": "Jaworska",  "first": "Basia" }  }

Przykładowe zapytanie [Filed Query](http://www.elasticsearch.org/guide/reference/query-dsl/field-query.html):

    :::bash
    curl "localhost:9200/contacts/_search?pretty=true" -d '
      { "query": { "field": { "name.first": { "query": "A*" } } } }'
    curl "localhost:9200/contacts/_search?pretty=true" -d '
      { "query": { "field": { "name.first": "A*" } } }'


Range Query?


## Fasety

Terms facet:

    :::bash
    curl -X POST "http://localhost:9200/aphorisms/_search?pretty=true" -d '
      {
        "fields": [],
        "query": { "query_string": { "query": "*" } },
        "facets": {
          "keywords": { "terms": { "field": "tags", "size": 4 } }
        }
      }'
      ... wyniki wyszukiwania ...
      }, {
        "term" : "myślenie",
        "count" : 2
      }, {
      ...

Wyszukiwanie po fasecie *myślenie*:

    :::bash
    curl "localhost:9200/aphorisms/_search?pretty=true" -d '
      {
        "size": 4,
        "sort": { "_score": {}  },
        "query" : { "term": { "tags": "myślenie" } }
      }'
    ... wyniki wyszukiwania ...
    {
      "took" : 0,
      ...
      "hits" : {
        "total" : 2,
        "max_score" : 1.2380183,
        "hits" : [ {
          "_index" : "aphorisms",
          "_type" : "steinhaus",
          "_id" : "j0JWnItaRfuY4vJbVWHUWw",
          "_score" : 1.2380183, "_source" : { "quote": "Ludzie...", "tags": ["ludzie", "myślenie"] }
        }, {
          "_index" : "aphorisms",
          "_type" : "lec",
          "_id" : "N_jMl9dtR4atAGxDWfL9iw",
          "_score" : 0.9904146, "_source" : { "quote": "Podrzuć...", "tags": ["ludzie", "myślenie", "marzenia"] }
        } ]
      }


# Skrypt NodeJS „elasticimport”

Funkcjonalność podobna do programu *mongoimport*. Coś takiego:

    mongoimport
    connected to: 127.0.0.1
    no collection specified!
    Import CSV, TSV or JSON data into MongoDB.

    options:
      --help                  produce help message
      -v [ --verbose ]        be more verbose (include multiple times for more
                              verbosity e.g. -vvvvv)
      --version               print the program's version and exit
      -h [ --host ] arg       mongo host to connect to ( <set name>/s1,s2 for sets)
      --port arg              server port. Can also use --host hostname:port
      -u [ --username ] arg   username
      -p [ --password ] arg   password
      -d [ --db ] arg         database to use
      -c [ --collection ] arg collection to use (some commands)
      -f [ --fields ] arg     comma separated list of field names e.g. -f name,age
      --fieldFile arg         file with fields names - 1 per line
      --ignoreBlanks          if given, empty fields in csv and tsv will be ignored
      --type arg              type of file to import.  default: json (json,csv,tsv)
      --file arg              file to import from; if not specified stdin is used
      --drop                  drop collection first
      --headerline            CSV,TSV only - use first line as headers
      --stopOnError           stop importing at first error rather than continuing
      --jsonArray             load a json array, not one item per line.


JTZ? Teraz to jest nawet aż za proste…
