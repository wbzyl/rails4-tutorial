#### {% title "ActiveRecord w przykładach" %}

**TODO** Lista przykładów:

1.  Badamy powiązanie wiele do wielu na konsoli
6.  Dopisywanie rekordów do bazy :action => 'authors'
7.  Pobieranie rekordów za pomocą <i>find</i> :action => 'find'
8.  Przeglądanie pobranych rekordów :action => 'iterate'
9.  Efektywne pobieranie rekordów z kliku tabel :action => 'retrieving_data'
10. Uaktualnianie danych :action => 'updating_data'
11. Wymuszanie integralności danych :action => 'validation'
13. Zapobieganie „race conditions” :action => 'transactions'
14. Ręczne sortowanie z użyciem acts_as_list :action => 'sorting'
7.  Sortowanie za pomocą drag &amp; drop :action => 'drag_and_drop'
21. Powiązania polimorficzne :action => 'polymorphic_associations'
XX. Coś prostego: single-table inheritance :action => 'single-table-inheritance'

Zaczniemy od sprawdzenia jakie mamy zainstalowane w systemie
Rubies oraz zestawy gemów:

    rvm list
    rvm list gemsets

Następnie, na potrzeby przykładów z tego wykładu, tworzymy zestaw
gemów o nazwie *ar*:

    rvm use --create ruby-1.9.2-p290@ar
    gem install bundler rails
    rvm info
    rvm current

Co daje takie podejście?


## Why Associations?

Przykład z rozdziału 1
[A Guide to Active Record Associations](http://guides.rubyonrails.org/association_basics.html).
Zobacz też [ActiveRecord::ConnectionAdapters::TableDefinition](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html)

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

    rails generate model Customer name:string
    rails generate model Order order_date:datetime order_number:string customer:references

Migrujemy i przechodzimy na konsolę:

    rake db:migrate
    rails console

gdzie dodajemy klienta i dwa jego zamówienia:

    :::ruby
    Customer.create :name => 'wlodek'
    @customer = Customer.first  # jakiś klient
    Order.create :order_date => Time.now, :order_number => '1003/1', :customer_id => @customer.id
    Order.create :order_date => Time.now, :order_number => '1003/2', :customer_id => @customer.id
    Order.all

A tak usuwamy z bazy klienta i wszystkie jego zamówienia:

    :::ruby
    @customer = Customer.first
    @orders = Order.where :customer_id => @customer.id
    @orders.each { |order| order.destroy }
    @customer.destroy


### Dodajemy powiązania między modelami

Po dopisaniu kod usalającego powiązania między tymi modelami:

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
    @order = @customer.orders.create :order_date => Time.now, :order_number => '1003/3'
    @order = @customer.orders.create :order_date => Time.now, :order_number => '1003/4'

Usunięcie kilenta wraz z wszystkimi jego zamówieniami jest też proste:

    :::ruby
    @customer = Customer.find 1
    @customer.destroy


## Badamy powiązanie wiele do wielu na konsoli

Między zasobami – *assets* i opisującymi je cechami – *tags*.

Przykład pokazujący o co nam chodzi:

* *Asset*: Cypress. A photo of a tree. (dwa atrybuty)
* *Tag*: tree, organic

Między zasobami i opisującymi je cechami mamy powiązanie wiele do
wielu. Dlaczego?

Dodatkowo, dla każdego zasobu będziemy określać jego rodzaj –
*asset_type*.  Przykład:

* *Asset*: Cypress. A photo of a tree.
* *AssetType*: Photo

Między zasobem a rodzajem zasobu mamy powiązanie wiele do jednego.

Tak jak poprzednio skorzystamy z generatora do wygenerowania
**boilerplate code**:

    rails g model AssetType name:string
    rails g model Asset name:string description:text asset_type:references
    rails g model Tag name:string

Dla powiązania wiele do wielu między *Asset* i *Tag*
musimy, zgodnie z konwencją Rails, dodać tabelę
o nazwie *assets_tags*:

    rails g model AssetsTags asset:references tag:references

W migracji dopisujemy *:id => false* (dlaczego?)
i usuwamy niepotrzebne *timestamps*:

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

Dopiero teraz migrujemy i usuwamy niepotrzebny model:

    rake db:migrate
    rm app/models/assets_tags.rb

Na koniec, dodajemy powiązania.

*Asset*:

    :::ruby
    class Asset < ActiveRecord::Base
      has_and_belongs_to_many :tags
      belongs_to :asset_type
    end

*Tag*:

    :::ruby
    class Tag < ActiveRecord::Base
      has_and_belongs_to_many :assets
    end

*AssetType* (dlaczego nie wystarczy krótsza nazwa *Type*):

    :::ruby
    class AssetType < ActiveRecord::Base
      has_many :assets
    end


Chcemy zbadać powiązania między powyżej wygenerowanymi modelami.
Zabadamy powiązania z konsoli Rails.

    :::ruby
    a = Asset.find 1
    a.tags
    t = Tag.find [1, 2]
    a.tags << t

Wydzielić z migracji *seed.rb*:

    :::ruby
    class BuildDatabase < ActiveRecord::Migration
      def self.up
        create_table :asset_types do |t|
          t.string :name
        end
        create_table :assets do |t|
          t.integer :asset_type_id
          t.string :name
          t.text :description
        end
        create_table :ttags do |t|
          t.string :name
        end
        create_table :assets_tags, :id => false do |t|
          t.integer :asset_id
          t.integer :keyword_id
        end

        insert "insert into asset_types values (1, 'Photo')"
        insert "insert into asset_types values (2, 'Painting')"
        insert "insert into asset_types values (3, 'Print')"
        insert "insert into asset_types values (4, 'Drawing')"
        insert "insert into asset_types values (5, 'Movie')"
        insert "insert into asset_types values (6, 'CD')"

        insert "insert into assets values (1, 1, 'Cypress', 'A photo of a tree.')"
        insert "insert into assets values (2, 5, 'Blunder', 'An action file.')"
        insert "insert into assets values (3, 6, 'Snap', 'A recording of a fire.')"

        insert "insert into tags values (1, 'hot')"
        insert "insert into tags values (2, 'red')"
        insert "insert into tags values (3, 'boring')"
        insert "insert into tags values (4, 'tree')"
        insert "insert into tags values (5, 'organic')"

        insert "insert into assets_tags values (1, 4)"
        insert "insert into assets_tags values (1, 5)"
        insert "insert into assets_tags values (2, 3)"
        insert "insert into assets_tags values (3, 1)"
        insert "insert into assets_tags values (3, 2)"

      end

      def self.down
        drop_table :assets_tags
        drop_table :assets
        drop_table :asset_types
        drop_table :tags
      end
    end


Konsola Rails:

    :::bash
    a = Asset.find(3)
    y a
    a.name
    a.description
    a.asset_type.name
    a.tags
    a.tags.each { |t| puts t.name }
    y a.asset_type
    y a.tags
    a.tags.each { |t| puts t.name }
    aa = Asset.find(:first)
    puts aa.to_yaml

Podejrzeć co jest wypisywane na terminalu.
