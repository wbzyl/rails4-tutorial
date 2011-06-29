#### {% title "Powiązania między modelami" %}

To się czyta z dużą przyjemnością:

* [ActiveRecord::Associations::ClassMethods](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)
* [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)


### Powiązanie jeden do wielu: Post & Comment

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

Przegladamy dokumentację powyżej i próbujemy z niej kilka przykładów:

    ... wpisujemy kilka poleceń z palca ...


## Powiązania wiele do wielu: Author & Article

* Utworzyć model *Author* za pomocą generatora.
* Jak wyżej, ale utworzyć model *Article*.
* Na koniec, utworzyć model *Bibinfo* – informacja bibliograficzna.

Dodać do modeli następujące powiązania:

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

Przejść na konsolę. Zapisać w tabelkach następujące pozycje:

* David Flanagan, Yukihiro Matsumoto. The Ruby Programming Language, 2008.
* Dave Thomas, Chad Fowler, Andy Hunt. Programming Ruby 1.9, 2009.
* Sam Ruby, Dave Thomas, David Heinemeier Hansson. Agile Web Development with Rails, 2011
* David Flanagan. jQuery Pocket Reference, 2010.

Wypróbować na konsoli poniższe powiązania:

    :::ruby
    author.articles
    article.authors
    author.bibinfos
    article.bibinfos
    bibinfo.author
    bibinfo.article


# Powiązania polimorficzne

Zaczynamy od lektury:

* [2.9 Polymorphic Associations](http://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations)

Zastosowania:

* [acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) (tylko ActiveRecord)

