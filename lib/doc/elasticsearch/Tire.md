# Ruby – ElasticSearch + Tire

Instalujemy gem tire oraz yajl-ruby:

    gem install tire
    gem install yajl-ruby

Zapisujemy kilka cytatów w ElasticSearch:

    :::ruby
    require 'tire'
    require 'yajl/json_gem'

    fortunes = [
      { id: 1, type: 'quotes', text: "Jedną z cech głupstwa jest logika.", tags: ["logika", "głupstwo"] },
      { id: 2, type: 'quotes', text: "Znasz hasło do swojego wnętrza?", tags: ["hasło", "głupstwo"] },
      { id: 3, type: 'quotes', text: "Miał lwi pazur, ale brudny.", tags: ["lew", "pazur", "nauka"] },
      { id: 4, type: 'quotes', text: "Unikaj skarżącego się na brak czasu, chce ci zabrać twój.", tags: ["czas"] }
    ]

    Tire.index 'fortunes' do
      delete
      import fortunes
      refresh
    end

**Uwaga:** Domyślnym typem jest **document**. Pola *id* i *type* są wymagane.

Wyszukiwanie:

    curl 'localhost:9200/fortunes/quotes/_search?pretty=true&q=tags:logika'

Albo tak:

    curl 'localhost:9200/fortunes/_search?pretty=true&q=tags:logika'


## Facets

Search API – [Facets](http://www.elasticsearch.org/guide/reference/api/search/facets/index.html).

The facet aggregation will return counts for the most popular tags
across the documents matching your query — or across all documents in
the index.

Return scoped counts:

    curl -X POST "http://localhost:9200/fortunes/_search?pretty=true" -d '
      {
        "query" : { "query_string" : {"query" : "text:s*"} },
        "facets" : {
          "tags_counts" : {
             "terms" : {"field" : "tags"}
          }
        }
      }
    '
Return global counts:

    curl -X POST "http://localhost:9200/fortunes/_search?pretty=true" -d '
      {
        "query" : { "query_string" : {"query" : "text:s*"} },
        "facets" : {
          "tags_counts" : {
             "terms" : {"field" : "tags"},
             "global" : true
          }
        }
      }
    '
