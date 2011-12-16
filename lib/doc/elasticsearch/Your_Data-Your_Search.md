# Your Data, Your Search

Nieco zmienione przykłady
z [Your Data, Your Search](http://www.elasticsearch.org/blog/2010/02/12/yourdatayoursearch.html).

Książka:

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

Wyszukiwanie:

    curl 'http://localhost:9200/amazon/books/_search?pretty=true&q=author.first_name:Jack'

CD:

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

Wyszukiwanie:

    curl 'http://localhost:9200/amazon/cds/_search?pretty=true&q=label:Interscope'


## Wyszukiwanie

Po kilku typach:

    curl 'http://localhost:9200/amazon/books,cds/_search?pretty=true&q=name:energy'

Po wszystkich typach:

    curl 'http://localhost:9200/amazon/_search?pretty=true&q=name:energy'
