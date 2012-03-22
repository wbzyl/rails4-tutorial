#### {% title "Elasticsearch w przykładach" %}

Zapisujemy kilka dokumentów w ElasticSearch:

    :::bash
    curl -X DELETE 'localhost:9200/aphorisms'
    curl -X POST   'localhost:9200/aphorisms/_bulk' --data-binary @test.bulk
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


## Fasety

Terms facet:

    :::bash
    curl -X POST "http://localhost:9200/aphorisms/_search?pretty=true" -d '
      {
        "fields": [],
        "query" : { "query_string" : {"query" : "*"} },
        "facets" : {
          "keywords" : { "terms" : {"field" : "tags", "size": 4} }
        }
      }'
