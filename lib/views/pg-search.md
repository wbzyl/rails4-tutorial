#### {% title "Wyszukiwanie pełnotekstowe z PostgreSQL" %}

<blockquote>
<p><a href="http://sigma.inf.ug.edu.pl/~jdarecki/fedora15.html">Instalacja MySQl, PostgreSQL... w Fedorze 15</p></p>
</blockquote>

… czyli do *full text search* użyjemy gemów:

* [texticle](https://github.com/tenderlove/texticle)
* [pg_search](https://github.com/Casecommons/pg_search)

Dopisujemy gem *pg* oraz powyżej wspomniane gemy do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'pg'
    gem 'texticle', '~> 2.0', require: 'texticle/rails'
    gem 'pg_search'

i instalujemy je:

    :::bash
    bundle install

Musimy też zmienić konfigurację bazy w pliku *database.yml*:

    :::yaml
    development:
      adapter: postgresql
      encoding: unicode
      database: fortune_responders_development
      pool: 5
      username: wbzyl
      password:

    test:
      adapter: postgresql
      encoding: unicode
      database: fortune_responders_test
      pool: 5
      username: wbzyl
      password:

Pozostało utworzyć bazy i wykonać jeszcze raz migracje:

    :::bash
    rake db:create:all
    rake db:migrate


## Full text search with PostgreSQL

Zaczynamy od wyszukiwania za pomocą operatora *LIKE* (lub *iLIKE*):

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        # SQLite i PostgreSQL
        where('quotation like :q or source like :q', q: "%#{query}%")
        # tylko PostgreSQL; i – ignore case
        # where("quotation ilike :q or source ilike :q", q: "%#{query}%")
      else
        scoped
      end
    end

Możemy też użyć operatora @@ (tylko PostgreSQL):

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        where("quotation @@ :q or source @@ :q", q: query)
      else
        scoped
      end
    end

Zapytanie z operatorrem @@ wyszukuje wszystkie rekordy zawierające
wszystkie wpisane słowa, na przykład:

    late bird

<blockquote>
<h3>PostgreSQL & Polish</h3>
<ul>
<li><a href="http://www.depesz.com/2008/04/22/polish-tsearch-in-83-polski-tsearch-w-postgresie-83/">Polski
  tsearch w Postgresie 8.3</a>
<li><a href="http://marcinraczkowski.wordpress.com/2009/07/01/tsearch-w-rails-i-postgres-8-3/">TSearch
  w Rails i Postgresie 8.3</a>
<li><a href="http://www.depesz.com/2010/10/17/why-im-not-fan-of-tsearch-2/">Why
  I’m not fan of TSearch?</a>
</ul>
</blockquote>

### Zaawansowane wyszukiwanie

Zaczynamy od wpisania i wykonania kilku przykładów na konsoli DB:

    :::sql
    select 'ala has a cat' @@ 'cats';
    select to_tsvector('ala has a cat') @@ plainto_tsquery('cats');
    -- stemming
    select to_tsvector('english', 'ala has a cat') @@ plainto_tsquery('english', 'cats');
    -- without stemming
    select to_tsvector('simple', 'ala has a cat') @@ plainto_tsquery('simple', 'cats');
    -- one word
    select to_tsvector('simple', 'ala has a cat') @@ to_tsquery('simple', 'cat');
    -- and
    select to_tsvector('simple', 'ala has a cat') @@ to_tsquery('simple', 'cat & dog');
    -- or
    select to_tsvector('simple', 'ala has a cat') @@ to_tsquery('simple', 'cat | dog');
    -- not
    select to_tsvector('simple', 'ala has a cat') @@ to_tsquery('simple', 'cat & !dog');

Poprawki w modelu:

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        # where("quotation @@ :q or source @@ :q", q: query)
        orquery = <<-ORQUERY
          to_tsvector('english', quotation) @@ plainto_tsquery('english', #{sanitize(query)})
            or
          to_tsvector('english', source) @@ plainto_tsquery('english', #{sanitize(query)})
        ORQUERY
        where(orquery)
      else
        scoped
      end
    end


## Texticle

* Aaron Patterson.
  [Texticle](https://github.com/tenderlove/texticle) –
  full text search capabilities from PostgreSQL

Ta sama funkcjonalność co wyżej (z rank?), ale kod metody
*text_search* dużo prostszy:

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        search(query)    # metoda zdefiniowana w Texticle
      else
        scoped
      end
    end


## PG_search

* [pg_search](https://github.com/Casecommons/pg_search)

Ten gem implementuje wyszukiwanie pełnotekstowe w jednym modelu (*pg_search_scope*)
albo — w kilku modelach (*multisearch*).


### pg_search_scope

Dopisujemy w modelu (nie używa słownika 'english', nie działa stemming):

    :::ruby
    include PgSearch

    # definiujemy metodę `fortunes_search`
    pg_search_scope :fortunes_search, against: [:quotation, :source],
        using: {tsearch: {dictionary: "english"}}

    def self.text_search(query)
      if query.present?
        fortunes_search(query)    # metoda zdefiniowana powyżej
      else
        scoped
      end
    end

Wyniki posortowane malejąco względem „ranking search results”.


### multisearch

…to wyszukiwanie w wielu modelach:

    :::bash
    rake pg_search:migration:multisearch
    rake db:setup

do każdego modelu dodajemy dwie linijki kodu, na przykład
w modelu *Fortune* dopisujemy:

    :::ruby
    include PgSearch
    multisearchable :against => [:quotation, :source]

Następnie wykonujemy zadanie *rake*:

    :::bash
    rake pg_search:multisearch:rebuild MODEL=Fortune

Zrobione! Wchodzimy na konsolę, gdzie zadajemy kilka zapytań:

    :::ruby
    PgSearch.multisearch('bird bush')
    PgSearch.multisearch('bird bush').each { |doc| puts doc.content }


**Koniec wykładu 13.05.2012**

    :::bash
    git commit -m "... Wyszukiwanie z PostgreSQL ..."
    ... rebase ...
    git tag v0.0.3


### Ajaxujemy wyszukiwanie

Jest następujacy problem:
[Added option :ajax for remote page links](https://github.com/mislav/will_paginate/pull/133).
Oznacza to, że nie można zajaksować *pagination links*.
Można to obejść za pomocą jednej linijki kodu JavaScript:

    :::js app/assets/javascripts/application.js
    $('.digg_pagination a').data('remote', true)

Dalej postępujemy tak jak w rozdziale „Remote links”.

Takie obejście nie jest konieczne jeśli do paginacji użyliśmy
gemu [Kaminari](https://github.com/amatsuda/kaminari). Wystarczy dopisać w widoku:

    :::rhtml app/views/fortunes/index.html.erb
    <div id="paginator">
      <%= paginate @fortunes, :remote => true %>
    </div>
