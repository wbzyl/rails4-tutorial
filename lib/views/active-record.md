#### {% title "ActiveRecord na konsoli" %}

Lista przykładów:

1. Why Associations?
1. Badamy powiązanie wiele do wielu na konsoli
1. Powiązania polimorficzne
1. Efektywne pobieranie danych z kilku tabel – Eager Loading
1. Rodzime typy baz danych
1. Sytuacje wyścigu, czyli *race conditions*
1. Sortable List in Ruby on Rails 3.1  **TODO:** przenieść do *Remote Links*


Zaczniemy od sprawdzenia jakie mamy zainstalowane w systemie
Rubies i zestawy gemów:

    rvm list
    rvm list gemsets

Następnie, na potrzeby przykładów z tego wykładu, utworzymy zestaw
gemów o nazwie *ar*:

    rvm use --create ruby-1.9.2-p290@ar
    gem install bundler rails
    rvm info
    rvm current

Co daje takie podejście?


### Dokumentacja:

* [ActiveRecord::Associations::ClassMethods](http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html)
* [ActiveRecord::Base](http://api.rubyonrails.org/classes/ActiveRecord/Base.html)


## Why Associations?

Przykład z rozdziału 1
[A Guide to Active Record Associations](http://guides.rubyonrails.org/association_basics.html).
Zobacz też [ActiveRecord::ConnectionAdapters::TableDefinition](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html).

Generujemy przykładową aplikację:

    rvm use ruby-1.9.2-p290@ar
    rails new why_associations --skip-bundle
    cd why_associations
    bundle install --path=.bundle/gems

Przy okazji ułatwimy sobie śledzenie kolejności
migracji dopisując do pliku *config/application.rb*:

    :::ruby
    config.active_record.timestamped_migrations = false

Skorzystamy z generatora do wygenerowania kodu dla dwóch modeli:

* *Customer* (klient) – atrybuty: *name*, …
* *Order* (zamówienie) – atrybuty: *order_date*, *order_number* …

Każdy klient może mieć wiele zamówień. Każde zamówienie
należy do jednego kilenta. Dlatego między kilentami i zamówieniami
mamy powiązanie jeden do wielu. Oznacza to, że powinniśmy dodać
jeszcze jeden atrybut (*foreign key*) do zamówień:

* *Order* (zamówienie) – atrybuty: **customer_id**, order_date, …

Generujemy *boilerplate code*:

    rails generate model Customer name:string
    rails generate model Order order_date:datetime order_number:string customer:references

Migrujemy i przechodzimy na konsolę:

    rake db:migrate
    rails console

gdzie dodajemy klienta i dwa jego zamówienia:

    :::ruby
    Customer.create :name => 'wlodek'
    @customer = Customer.first  # jakiś klient
    Order.create :order_date => Time.now, :order_number => '20111003/1', :customer_id => @customer.id
    Order.create :order_date => Time.now, :order_number => '20111003/2', :customer_id => @customer.id
    Order.all

A tak usuwamy z bazy klienta i wszystkie jego zamówienia:

    :::ruby
    @customer = Customer.first
    @orders = Order.where :customer_id => @customer.id
    @orders.each { |order| order.destroy }
    @customer.destroy


### Dodajemy powiązania między modelami

Po dopisaniu kod ustalającego powiązania między tymi modelami:

    :::ruby
    class Customer < ActiveRecord::Base
      has_many :orders, :dependent => :destroy
    end
    class Order < ActiveRecord::Base
      belongs_to :customer
    end

tworzenie nowych zamówień dla danego klienta jest łatwiejsze:

    :::ruby
    Customer.create(:name => 'rysiek')
    @customer = Customer.where(:name=> 'rysiek').first
    @order = @customer.orders.create :order_date => Time.now, :order_number => '20111003/3'
    @order = @customer.orders.create :order_date => Time.now, :order_number => '20111003/4'

Usunięcie kilenta wraz z wszystkimi jego zamówieniami jest też proste:

    :::ruby
    @customer = Customer.first  # jakiś klient
    @customer.destroy

Tak jest prościej.


## Badamy powiązanie wiele do wielu na konsoli

Między zasobami – *assets* i opisującymi je cechami – *tags*.

Przykład pokazujący o co nam chodzi:

* *Asset*: Cypress. A photo of a tree. (dwa atrybuty)
* *Tag*: tree, organic

Między zasobami i opisującymi je cechami mamy powiązanie wiele do
wielu.

Dodatkowo, każdy zasób przypisujemy do jednego z kilku rodzajów zasobów –
*AssetType*.  Przykład:

* *Asset*: Cypress. A photo of a tree.
* *AssetType*: Photo

Między zasobem a rodzajem zasobu mamy powiązanie wiele do jednego.

Tak jak poprzednio skorzystamy z generatora do wygenerowania
**boilerplate code**:

    rails g model AssetType name:string
    rails g model Asset name:string description:text asset_type:references
    rails g model Tag name:string

Dla powiązania wiele do wielu między *Asset* i *Tag*, zgodnie
z konwencją Rails, powinniśmy dodać tabelę o nazwie *assets_tags*
(nazwy tabel w kolejności alfabetycznej):

    rails g model AssetsTags asset:references tag:references

W migracji dopisujemy *:id => false* (dlaczego? konwencja Rails)
i usuwamy zbędne *timestamps* (też wymagane przez Rails?):

    :::ruby
    class CreateAssetsTags < ActiveRecord::Migration
      def change
        create_table :assets_tags, :id => false do |t|
          t.references :asset
          t.references :tag
        end
        add_index :assets_tags, :asset_id
        add_index :assets_tags, :tag_id
      end
    end

Dopiero teraz migrujemy i usuwamy niepotrzebny model
(w dowolnej kolejności):

    rm app/models/assets_tags.rb
    rake db:migrate

Na koniec, dodajemy powiązania do modeli:
    :::ruby
    class Asset < ActiveRecord::Base
      has_and_belongs_to_many :tags
      belongs_to :asset_type
    end

    class Tag < ActiveRecord::Base
      has_and_belongs_to_many :assets
    end

    class AssetType < ActiveRecord::Base
      has_many :assets
    end

Skorzystamy z zadania *rake* o nazwie *db:seed*
do umieszczenia danych w tabelach:

    :::ruby db/seeds.rb
    AssetType.create :name => 'Photo'
    AssetType.create :name => 'Painting'
    AssetType.create :name => 'Print'
    AssetType.create :name => 'Drawing'
    AssetType.create :name => 'Movie'
    AssetType.create :name => 'CD'

    Asset.create :name => 'Cypress', :description => 'A photo of a tree.', :asset_type_id => 1
    Asset.create :name => 'Blunder', :description => 'An action file.', :asset_type_id => 5
    Asset.create :name => 'Snap', :description => 'A recording of a fire.', :asset_type_id => 6

    Tag.create :name => 'hot'
    Tag.create :name => 'red'
    Tag.create :name => 'boring'
    Tag.create :name => 'tree'
    Tag.create :name => 'organic'

Ale wcześniej usuniemy bazę:

    rake db:drop
    rake db:schema:load

Powiązania dodamy na konsoli Rails:

    :::ruby
    a = Asset.find 1
    t = Tag.find [4, 5]
    a.tags << t
    Asset.find(2).tags << Tag.find(3)
    Asset.find(3).tags << Tag.find([1, 2])

Chcemy zbadać powiązania między powyżej wygenerowanymi modelami.
Zabadamy powiązania z konsoli Rails.

Konsola Rails:

    :::ruby
    a = Asset.find(3)
    y a
    a.name
    a.description
    a.asset_type.name
    a.tags
    a.tags.each { |t| puts t.name } ; nil
    y a.asset_type
    y a.tags
    a.tags.each { |t| puts t.name } ; nil
    aa = Asset.first
    puts aa.to_yaml

Przyjrzeć się uważnie co jest wypisywane na terminalu.


### Jeszcze jeden przykład: Author & Article

Między autorami i artykułami mamy powiązanie wiele do wielu.
Dlaczego?

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


## Powiązania polimorficzne

Typowy przykład. Trzy modele:

* *Person* (osoba)
* *Company* (firma)
* *PhoneNumber* (numer telefonu)

Osoba ma wiele numerów telefonów. Firma też ma wiele telefonów.
Niestety, numer telefonu może należeć do Osoby albo do Firmy.
Takie jest ograniczenie relacji *belongs_to* (należy do).

Możemy to ograniczenie obejść powielając model:

* *PersonPhoneNumber*
* *CompanyPhoneNumber*

Takie rozwiązanie prowadzi do powielania kodu. Dlatego
w Rails mamy inne rozwiązanie – *polymorphic associations*.

Zaczynamy od wygenerowania trzech modeli:

    rails g model Person name:string
    rails g model Company name:string
    rails g model PhoneNumber tel:string callable:references

Dopisujemy zależności do modeli:

    :::ruby
    class Person < ActiveRecord::Base
      has_many :phone_numbers, :as => :callable, :dependent => :destroy
    end
    class Company < ActiveRecord::Base
      has_many :phone_numbers, :as => :callable, :dependent => :destroy
    end

    class PhoneNumber < ActiveRecord::Base
      belongs_to :callable, :polymorphic => true
    end

Poprawiamy migrację wygenerowaną dla *phone_numbers*:

    :::ruby
    class CreatePhoneNumbers < ActiveRecord::Migration
      def change
        create_table :phone_numbers do |t|
          t.string :tel
          t.references :callable, :polymorphic => true
          t.timestamps
        end
      end
    end

*Uwaga:* wiersz kodu z *:polymorphic => true* powyżej, to to samo co:

    :::ruby
    t.integer :callable_id
    t.string  :callable_type

Migrujemy:

    rake db:migrate

Teraz już możemy przećwiczyć polimorfizm na konsoli Rails:

    rails c

gdzie wykonujemy następujący kod:

    :::ruby
    p = Person.create :name => 'wlodek'
    c = Company.create :name => 'ii'
    p.phone_numbers << PhoneNumber.create(:tel => '1234')
    c.phone_numbers << PhoneNumber.create(:tel => '5678')
    PhoneNumber.all
      +----+------+-------------+---------------
      | id | tel  | callable_id | callable_type
      +----+------+-------------+---------------
      | 1  | 1234 | 1           | Person
      +----+------+-------------+---------------
      | 2  | 5678 | 1           | Company
      +----+------+-------------+---------------
    p.phone_numbers
      +----+------+-------------+---------------
      | id | tel  | callable_id | callable_type
      +----+------+-------------+---------------
      | 1  | 1234 | 1           | Person
      +----+------+-------------+---------------

Jak działa *p.phone_numbers*?

Podobny przykład znajdziemy w przewodniku
[A Guide to Active Record Associations](http://guides.rubyonrails.org/association_basics.html#polymorphic-associations).

Inne przykłady:

* [acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)
* [acts_as_commentable](https://github.com/jackdempsey/acts_as_commentable) (tylko ActiveRecord)

Co w nich jest ciekawego?


## Efektywne pobieranie danych – Eager Loading

Prosty przykład jest opisany w sekcji
[Eager Loading Associations](http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
przewodnika „Active Record Query Interface”.

Nieco bardziej skomplikowany przykład:
fotografowie, galerie i zdjęcia.
Fotograf ma wiele galerii, w galerii jest wiele zdjęć.

Korzystamy z generatora:

    rails g model Photographer name:string
    rails g model Gallery photographer:references name:string
    rails g model Photo gallery:references name:string file_path:string

Dopisujemy brakujące powiązania w modelach:

    :::ruby
    class Photographer < ActiveRecord::Base
      has_many :galleries
    end

    class Gallery < ActiveRecord::Base
      has_many :photos
      belongs_to :photographer
    end

    class Photo < ActiveRecord::Base
      belongs_to :gallery
    end

Teraz migrujemy:

    rake db:migrate

Dopisujemy kod do pliku *db/seeds.rb* (albo wykonujemy go bezpośrednio
na konsoli Rails):

    :::ruby db/seeds.rb
    Photographer.create :name => 'Jan Saudek'
    Photographer.create :name => 'Stefan Rohner'

    Gallery.create :name => 'Nordic Light', :photographer_id => 1
    Gallery.create :name => 'Daily Life', :photographer_id => 2
    Gallery.create :name => 'India', :photographer_id => 2

    Photo.create :name => 'Shadows', :file_path => 'photos/img_1154.jpg', :gallery_id => 1
    Photo.create :name => 'Ice Formation', :file_path => 'photos/img_6836.jpg', :gallery_id => 1
    Photo.create :name => 'Unknown', :file_path => 'photos/img_8419.jpg', :gallery_id => 2
    Photo.create :name => 'Uptown', :file_path => 'photos/img_1243.jpg', :gallery_id => 2
    Photo.create :name => 'India Sunset', :file_path => 'photos/img_2349.jpg', :gallery_id => 2
    Photo.create :name => 'Summer', :file_path => 'photos/img_7744.jpg', :gallery_id => 3
    Photo.create :name => 'Two cats', :file_path => 'photos/img_1440.jpg', :gallery_id => 3
    Photo.create :name => 'Dogs', :file_path => 'photos/img_1184.jpg', :gallery_id => 3

Na konsoli wykonujemy:

    :::ruby
    galleries = Gallery.includes(:photographer, :photos).all

Wykonanie tego polecenia skutkuje trzykrotnym odpytaniem bazy:

    Gallery Load (0.2ms)  SELECT "galleries".* FROM "galleries"
    Photographer Load (0.1ms)  SELECT "photographers".* FROM "photographers" WHERE "photographers"."id" IN (1, 2)
    Photo Load (0.2ms)  SELECT "photos".* FROM "photos" WHERE "photos"."gallery_id" IN (1, 2, 3)

Teraz polecenia:

    :::ruby
    galleries[0].photographer
    galleries[0].photos

nie odpytują bazy – dane zostały wcześniej wczytane (*eager loading*).


## Rodzime typy baz danych

I jak są tłumaczone z typów danych języka Ruby.
Warto też przejrzeć przykłady
w [dokumentacji metody *column*](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html)

PostgreSQL:

    :::ruby activerecord/lib/active_record/connection_adapters/postgresql_adapter.rb
    NATIVE_DATABASE_TYPES = {
      :primary_key => "serial primary key",
      :string      => { :name => "character varying", :limit => 255 },
      :text        => { :name => "text" },
      :integer     => { :name => "integer" },
      :float       => { :name => "float" },
      :decimal     => { :name => "decimal" },
      :datetime    => { :name => "timestamp" },
      :timestamp   => { :name => "timestamp" },
      :time        => { :name => "time" },
      :date        => { :name => "date" },
      :binary      => { :name => "bytea" },
      :boolean     => { :name => "boolean" },
      :xml         => { :name => "xml" },
      :tsvector    => { :name => "tsvector" }
    }

SQLite:

    :::ruby activerecord/lib/active_record/connection_adapters/sqlite_adapter.rb
    def native_database_types
      {
        :primary_key => default_primary_key_type,
        :string      => { :name => "varchar", :limit => 255 },
        :text        => { :name => "text" },
        :integer     => { :name => "integer" },
        :float       => { :name => "float" },
        :decimal     => { :name => "decimal" },
        :datetime    => { :name => "datetime" },
        :timestamp   => { :name => "datetime" },
        :time        => { :name => "time" },
        :date        => { :name => "date" },
        :binary      => { :name => "blob" },
        :boolean     => { :name => "boolean" }
      }
    end

## Race Conditions

Czyli tzw. sytuacje wyścigu.
Poniżej przykład race condition w Rails.

Tworzymy dwa modele: magazyn (*Inventory*) i koszyk (*Cart*):

    rails g model Inventory name:string on_hand:integer
    rails g model Cart name:string quantity:integer

Oto wygenerowane migracje:

    :::ruby
    class CreateInventories < ActiveRecord::Migration
      def change
        create_table :inventories do |t|
          t.string :name
          t.integer :on_hand  # na stanie
        end
      end
    end

    class CreateCarts < ActiveRecord::Migration
      def change
        create_table :carts do |t|
          t.string :name
          t.integer :quantity, :default => 0  # dodane ręcznie
        end
      end
    end

Do modelu *Inventory* dodajemy walidację:

    :::ruby inventory.rb
    class Inventory < ActiveRecord::Base
      validate :on_hand_could_not_be_negative

      def on_hand_could_not_be_negative
        errors.add(:on_hand, "can't be negative") if on_hand < 0
      end
    end

na koniec migrujemy:

    rake db:migrate

Przechodzimy na konsolę Ruby:

    :::ruby
    Inventory.create :name => 'Laptop Eee PC 1000', :on_hand => 10

Przykład pokazujący sytuację race condition.
Dwóch klientów jednocześnie kupuje po 8 laptopów Eee PC 1000:

    :::ruby
    c1 = Cart.create :name => 'Laptop Eee PC 1000', :quantity => 8
    c2 = Cart.create :name => 'Laptop Eee PC 1000', :quantity => 8

Oczywiście, po tym jak pierwszy kilent dodał 8 laptopów do swojego
koszyka, zabraknie 6 laptopów dla drugiego klienta.
Dlatego, drugi klient powinien poczekać aż zostanie uaktualniony
stan magazynu.

Możemy to zaprogramować korzystając z transakcji i wyjątków:

    :::ruby
    laptop = 'Laptop Eee PC 1000'
    quantity = 8
    c1 = Cart.create :name => laptop, :quantity => quantity
    begin
      Cart.transaction do
        item = Inventory.find_by_name laptop
        item.on_hand -= quantity
        item.save!
      end
    rescue
      flash[:error] = "Sorry, laptopy właśnie się skończyły!"
    end

Podobnie postępujemy z drugim klientem. Oczywiście, powyższy
kod zamieniamy na metodę, np. o nazwie *add_item*,
którą dodajemy do *CartController*.


## Sortable List in Ruby on Rails 3.1

Nieco uproszczony przykład
z [Sortable List in Ruby on Rails 3 – Unobtrusive jQuery](http://webtempest.com/sortable-list-in-ruby-on-rails-3-almost-unobtrusive-jquery/)

    rails g scaffold Todo name:string
    rails g migration add_position_to_todos position:integer
    rake db:migrate

dodajemy dane testowe:

    :::ruby db/seed.rb
    Todo.create([{:name => 'Harry Potter'}, {:name => 'Twilight'}, {:name => 'Bible'}])

Migrujemy:

    rake db:seed

Do pliku *application.js* dopisujemy *jquery-ui.min*:

    :::js
    //= require jquery
    //= require jquery-ui.min
    //= require jquery_ujs
    //= require_tree .

Plik *jquery-ui.min.js* pobieramy ze strony

    https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.16/jquery-ui.min.js

(1.8.16 – ostatnia wersja na dzień 22.09.2011)
i zapisujemy go w katalogu *vendor/assets/javascripts/*.

Javascript do *index.html.erb*:

    :::rhtml index.html.erb
    <h1>Listing todos</h1>
    <ul id="todos">
    <% @todos.each do |todo| %>
      <li id="todo_<%= todo.id %>"><span class="handle">[drag]</span><%= todo.name %></li>
    <% end %>
    </ul>
    <br>
    <%= link_to 'New Todo', new_todo_path %>

    <% content_for :javascript do %>
      <%= javascript_tag do %>
        $('#todos').sortable({
            axis: 'y',
            dropOnEmpty: false,
            handle: '.handle',
            cursor: 'crosshair',
            items: 'li',
            opacity: 0.4,
            scroll: true,
            update: function() {
                $.ajax({
                    type: 'post',
                    data: $('#todos').sortable('serialize'),
                    dataType: 'script',
                    complete: function(request){
                        $('#todos').effect('highlight');
                    },
                    url: '/todos/sort'})
            }
        });
      <% end %>
    <% end %>

Do pliku *app/views/layouts/application.html.erb* dopisujemy
zaraz przed zamykającym znacznikem */body*:

    :::rhtml
    <%= yield :javascript %>

Kontroler:

    :::ruby
    class TodosController < ApplicationController
      def index
        @todos = Todo.order('todos.position ASC')
      end

      def sort
        @todos = Todo.scoped
        @todos.each do |todo|
          todo.position = params['todo'].index(todo.id.to_s)
          todo.save
        end
        render :nothing => true
      end

Jeszcze poprawki w CSS:

    :::css /app/assets/stylesheets/application.css
    .handle:hover {
      cursor: move;
    }

oraz w routingu:

    :::ruby config/routes.rb
    resources :todos do
      post :sort, :on => :collection
    end
    root to: "todos#index"

Jak to działa? Na konsoli wypisywane są parametry:

    Parameters: {"todo"=>["3", "1", "2"]}

gdzie

    3, 1, 2

to kolejność wyświetlanych na stronie elementów *li*.
Oznacza to, że todo z:

    id = 3 jest wyświetlane pierwsze (position = 0)
    id = 1 jest wyświetlane drugie   (position = 1)
    id = 2 jest wyświetlane trzecie  (position = 2)

Dlatego, taki kod ustawi właściwą kolejność *position*
wyświetlania:

    :::ruby
    todo[1].position = ["3", "1", "2"].index("1") = 2
    todo[2].position = ["3", "1", "2"].index("2") = 3
    todo[3].position = ["3", "1", "2"].index("3") = 1

Proste? Nie? Podejrzeć na konsoli Javascript, w zakładce Sieć,
nagłówki w wysyłanych żądaniach.

Zobacz też Demo [Sortable](http://jqueryui.com/demos/sortable/)
w jQuery-UI.

Nowe rekordy nie mają ustawionego atrybutu *position*.
Dlatego są wyświetlanie na końcu listy.
Możemy to zmienić, na przykład w taki sposób:

    :::ruby
    class Todo < ActiveRecord::Base
      before_create :add_to_list_bottom

      private

      def add_to_list_bottom
        bottom_position_in_list = Todo.maximum(:position)
        self.position = bottom_position_in_list.to_i + 1
      end
    end

Teraz nowe element pojawią się u dołu wyśwoetlanej listy.
Niestety, ten kod działa tylko(?) z *ActiveRecord*.
