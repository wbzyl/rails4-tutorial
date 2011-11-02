#### {% title "Korzystamy z bazy MongoDB" %}

Kilka linków na początek:

* Ryan Bates, [Mongoid](http://railscasts.com/episodes/238-mongoid?view=asciicast) – asciicast
* Durran Jordan, [Mongoid](http://mongoid.org/docs.html) – dokumentacja gemu
* Karl Seguin. [The Little MongoDB Book]()
* Karl Seguin. Interactive tutorials:
  - [The MongoDB Interactive Tutorial](http://tutorial.mongly.com/tutorial/index)
  - [MongoDB Geospatial Tutorial](http://tutorial.mongly.com/geo/index)

# Lista obecności

Prosta aplikacja implementująca CRUD.

1\. Instalacja gemów:

    :::ruby Gemfile
    gem 'formtastic'
    gem "mongoid", "~> 2.3"
    gem "bson_ext", "~> 1.4"

Przy okazji wykomentowujemy sqlite3.

2\. Konfiguracja:

    rails g formtastic:install
    rails g mongoid:config

W pliku *config/application.rb* wykomentowujemy wiersz:

    :::ruby
    require 'rails/all'

Zamiast tego wiersza dopisujemy:

    :::ruby
    require "action_controller/railtie"
    require "action_mailer/railtie"
    require "active_resource/railtie"
    require "rails/test_unit/railtie"
    require "sprockets/railtie"

3\. I18N

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

4\. Replica sets, master/slave, multiple databases
– na razie pomijamy. Sharding – też.


### Import listy studentów do MongoDB

    mongoimport -d lo_development -c students --headerline --type csv asi2011.csv


## Formtastic

Scaffold:

    rails g scaffold Student nazwisko:String imie:String indeks:Integer specjalnosc:String grupa:Integer uwagi:String

TODO: Poprawiamy wygenerowany formularz.


## TODO: na koniec dodajemy nieobecności



## Różny misz masz…

* K. Seguin, [The MongoDB Collection](http://mongly.com/)
* K. Seguin, [Blog](http://openmymind.net/)
