#### {% title "Konsola aplikacji Rails" %}

# Konsola aplikacji Rails

To się czyta z dużą przyjemnością:

* [ActiveRecord::Associations::ClassMethods](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)
* [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)


### Powiązania jeden do wielu: Post & Comment

Zacząć od jednego modelu: *Post*.
Dodać drugi model *Comments* powiązany z pierwszym relacją
jeden do wielu.

Polecenia:

    rails g model post body:string
    rails g model comment body:string post:references
    rake db:migrate

W pliku *db/seeds.rb* dopisujemy kilka rekordów, wykonujemy:

    rake db:seed

Pozostałe rekordy dodamy na konsoli.

Zanim to zrobimy dopiszemy powiązania:

    :::ruby
    class Post < ActiveRecord::Base
      has_many :comments
    end
    class Comment < ActiveRecord::Base
      belongs_to :post
    end

Wreszcie pora na konsolę:

    rails c

gdzie wpisujemy na początek:

    :::ruby
    Post.all
    Comment.all

Teraz pora na:

    :::ruby
    post = Post.find(1)
    post.comments
    comment = Comment.find(1)
    comment.post

Przegladamy dokumentację i próbujemy nowych rzeczy:

    ... wpisujemy kilka poleceń z palca…


## Powiązania wiele do wielu: Author & Article

Zacząć od modelu *Author*. Konsola.

Dodajemy model *Article*. Konsola.

Dodajemy model *Bibinfo*.

Dodać powiązania:

    :::ruby
    class Author < ActiveRecord::Base
      has_many :articles, :through => :bibinfos
      has_many :bibinfos
    end
    class Article < ActiveRecord::Base
      has_many :authors, :through => :bibinfos
      has_many :bibinfos
    end
    class Bibinfo < ActiveRecord::Base
      belongs_to :author
      belongs_to :article
    end

Wypróbować na konsoli poniższe powiązania:

    :::ruby
    author.articles
    article.authors
    author.bibinfos
    article.bibinfos
    bibinfo.author
    bibinfo.article



## Kontrolery na konsoli

TODO:

    :::ruby
    app.class
    app.get '/fortunes'
    app.methods.sort.each {|m| puts m } ; nil
