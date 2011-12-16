# Ruby – ElasticSearch + Tire

Instalujemy gem tire oraz yajl-ruby:

    gem install tire
    gem install yajl-ruby

Przechodzimy na konsolę:

Zapisujemy kilka *dokumentów* w ElasticSearch:

    :::bash
    ruby store-articles.rb

**Uwaga:** Domyślnym typem jest **document**.

Wyszukiwanie:

    curl 'localhost:9200/articles/document/_search?pretty=true&q=tags:ruby'

Albo tak:

    curl 'localhost:9200/articles/_search?pretty=true&q=tags:ruby'
