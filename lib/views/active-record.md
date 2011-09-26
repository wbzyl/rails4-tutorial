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


## Badamy powiązanie wiele do wielu na konsoli

**TODO**

Między zasobami – *Assets* i opisującymi je słowmai kluczowymi – *Keywords*.
Dodatkowo, dla każdego zasobu określamy jego rodzaj – *AssetType*.

Przykład pokazujący o co nam chodzi:

* *Asset*: Cypress. A photo of a tree. (dwa atrybuty)
* *AssetType*: photo
* *Keyword*: tree, organic

Powiązanie między zasobami i opisującymi je słowami kluczowymi jest
wiele do wielu. Dlaczego?  Wprowadzamy dodatkowy model *AssetType*.

*Asset*:

    :::ruby
    class Asset < ActiveRecord::Base
      belongs_to :asset_tag
      has_and_belongs_to_many :keywords
    end

*AsssetTag*:

    :::ruby
    class AssetType < ActiveRecord::Base
      has_many :assets
    end

*Tag*:

    :::ruby
    class Tag < ActiveRecord::Base
      has_and_belongs_to_many :assets
    end

Chcemy zbadać powiązania między powyżej wygenerowanymi modelami.
Zabadamy powiązania z konsoli Rails.

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
