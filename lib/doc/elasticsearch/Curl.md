# Użyteczne zapytania

Tire search:

    tire.search(page: params[:page], per_page: self.per_page) do
      query do
        boolean do
          must { string params[:q], default_operator: "AND" } if params[:q].present?
        end
    ...

Zwraca tylko opakowującego JSONA:

    curl -X GET "http://localhost:9200/tweets/_search?pretty=true" -d '{"query":{"bool":{}}}'

Query String query, opis z API:

    http://www.elasticsearch.org/guide/reference/query-dsl/query-string-query.html

Przykłady:

    {
        "query_string" : {
            "default_field" : "content",         // defaults to _all
            "query" : "this AND that OR thus"
        }
    }
    {
        "query_string" : {
            "fields" : ["content", "name^5"],
            "query" : "this AND that OR thus",
            "use_dis_max" : true
        }
    }

Books:

    curl -X GET "http://localhost:9200/books/book/_search?pretty=true" \
      -d '{"query":{"bool":{"must":[{"query_string":{"query":"W*","default_operator":"AND"}}]}},"size":4}'

    curl -X GET "http://localhost:9200/books/book/_search?pretty=true" \
      -d '{"query":{"bool":{"must":[{"query_string":{"query":"W*","default_operator":"AND"}}]}},"size":4,"from":4}'

    curl -X GET "http://localhost:9200/books/book/_search?pretty=true" \
      -d '{"query":{"bool":{"must":[{"query_string":{"query":"title:Idiot p:One","default_operator":"AND"}}]}},"size":4}'

    curl -X GET "http://localhost:9200/books/book/_search?pretty=true&size=1&from=4" \
      -d '{"query":{"bool":{"must":[{"query_string":{"query":"W*","default_operator":"AND"}}]}}}'

## Twitter

    curl -X GET "http://localhost:9200/tweets/_search?pretty=true" -d '{"query":{"matchAll":{}},"size":1}'
    {
      "took" : 1,
      "timed_out" : false,
      "_shards" : {
        "total" : 5,
        "successful" : 5,
        "failed" : 0
      },
      "hits" : {
        "total" : 250,
        "max_score" : 1.0,
        "hits" : [ {
          "_index" : "tweets",
          "_type" : "nosql",
          "_id" : "147808239067729921",
          "_score" : 1.0, "_source" : {"text":"'Rails Curve Into a Dreamy Autumn' by Lisa Holmgreen -  http://t.co/67gh5u3z via @fineartamerica",
             "created_at":"2011-12-16T22:40:04.000Z","source":"<a href=\"http://twitter.com/tweetbutton\" rel=\"nofollow\">Tweet Button</a>",
             "truncated":false,"mention":[{"id":16828262,"name":"Fine Art America","screen_name":"FineArtAmerica","start":81,"end":96}],
             "retweet_count":0,"hashtag":[],
             "link":[{"url":"http://t.co/67gh5u3z","display_url":"fineartamerica.com/featured/rails…",
                "expand_url":"http://fineartamerica.com/featured/rails-curve-into-a-dreamy-autumn-lisa-holmgreen.html","start":56,"end":76}],
             "user":{"id":218267626,"name":"Amy M Bradley","screen_name":"amy77bradley77","location":"Enterprise,Or",
                "description":"I am living with and caring for disabled family members. Looking for good pay online steady income."}}
        } ]
    }
