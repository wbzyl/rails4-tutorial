#### {% title "Fortunka v1.0" %}

<blockquote>
 <p>
  {%= image_tag "/images/new-project.jpg", :alt => "[nowy projekt]" %}
 </p>
 <p class="author"><a href="http://www.eyefetch.com/image.aspx?ID=901780">New project car</a></p>
</blockquote>

Jednym ze sprawdzonych sposobów kontynuacji projektu jest rozpoczęcie
go od nowa.

Tym razem nie użyjemy generatora „scaffold”. Skorzystamy z generatora
*responders_controller* z gemu *responders*.

Co na tym zyskujemy opisano tutaj:

* [Responders](https://github.com/plataformatec/responders)
* [ActionController::Responder](http://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/responder.rb)
* [One in Three: Inherited Resources, Has Scope and Responders](http://blog.plataformatec.com.br/tag/respond_with/)
  – zawiera opis *FlashResponder* (korzysta z **I18N**) oraz *HttpCacheResponder*
* para: **respond_with** & **respond_to**

Ale rusztowanie aplikacji wygenerujemy za pomocą szablonu aplikacji Rails:

    :::bash
    rails new fortune-responders \
      -m https://raw.github.com/wbzyl/rat/master/html5-twitter-bootstrap.rb \
      --skip-bundle


## Robótki ręczne…

Zaczynamy od dopisania gemu *responders* do *Gemfile*:

    :::ruby Gemfile
    gem 'sqlite3'

    gem 'thin'

    gem 'responders'
    gem 'will_paginate'
    gem 'faker', :group => :development

    # silence assets pipeline log messages
    gem 'quiet_assets', :group => :development

Instalujemy gemy i wykonujemy procedurę *post-install*:

    :::bash
    bundle install
    rails generate responders:install
        create  lib/application_responder.rb
       prepend  app/controllers/application_controller.rb
        insert  app/controllers/application_controller.rb
        create  config/locales/responders.en.yml

Generujemy **resource controller** dla Fortunki:

    :::bash
    rails generate responders_controller
      ...
      Description:
        Stubs out a scaffolded controller and its views. Different from rails
        scaffold_controller, it uses respond_with instead of respond_to blocks.
        Pass the model name, either CamelCased or under_scored. The controller
        name is retrieved as a pluralized version of the model name.

    rails generate responders_controller Fortune
        create  app/controllers/fortunes_controller.rb
        invoke  erb
        create    app/views/fortunes
        create    app/views/fortunes/index.html.erb
        create    app/views/fortunes/edit.html.erb
        create    app/views/fortunes/show.html.erb
        create    app/views/fortunes/new.html.erb
        create    app/views/fortunes/_form.html.erb
      ...

*resource controller* definiuje siedem metod:

* *index*, *show*
* *new*, *create*
* *edit*, *update*
* *destroy*

Oto kod wygenerowanego kontrolera (z ręcznie dopisanym wierszem *respond_to*):

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      def index
        @fortunes = Fortune.all
        respond_with(@fortunes)
      end
      def show
        @fortune = Fortune.find(params[:id])
        respond_with(@fortune)
      end
      def new
        @fortune = Fortune.new
        respond_with(@fortune)
      end
      def edit
        @fortune = Fortune.find(params[:id])
      end
      def create
        @fortune = Fortune.new(params[:fortune])
        @fortune.save
        respond_with(@fortune)
      end
      def update
        @fortune = Fortune.find(params[:id])
        @fortune.update_attributes(params[:fortune])
        respond_with(@fortune)
      end
      def destroy
        @fortune = Fortune.find(params[:id])
        @fortune.destroy
        respond_with(@fortune)
      end
    end

Dla porównania kod kontrolera wygenerowanego przez generator *scaffold*:
{%= link_to "fortunes_controller.rb", "/rails31/scaffold/fortunes_controller.rb" %}.

Generujemy model *Fortune*, migrujemy i zapisujemy w bazie dane testowe:

    :::bash
    rails generate model Fortune quotation:text source:string
    rake db:migrate
    rake db:seed

zmieniamy routing, tak aby uri

    http://localhost:3000

przekierowywał na:

    http://localhost:3000/fortunes


## Wchodzimy na stronę główną…

…i od razu widzimy, że coś jest nie tak!

Nie są wypisywane fortunki. Widzimy tylko przyciski.  Od razu to
naprawimy – dopisujemy trochę kodu *boilerplate* do szablonów:
*_form*, *index*, *show*.

Aplikację po tych poprawkach klonujemy z repo:

    :::bash
    git clone git@github.com:wbzyl/fortunes-responders.git

gdzie (przy okazji) zwiększyłem w formularzu szerokość elementów
*input* i *textarea*:

    :::css
    input, textarea {
      width: 100%;
    }


# Dochodząc do v1.0

Zaczynamy od najłatwiejszej rzeczy – paginacji.
Ze strony [Ruby Toolbox](https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=pagination)
widzimy, że tak naprawdę mamy tylko jedną opcję:

* [will_paginate](https://github.com/mislav/will_paginate)
* [samples of pagination styles for will_paginate](http://mislav.uniqpath.com/will_paginate/)

Zmiany w kodzie będziemy wprowadzać na osobnej gałęzi:

    :::bash
    git checkout -b pagination

Po zaimplementowaniu paginacji, wykonamy rebase na gałąź master
i usuniemy niepotrzebną już gałąź paginate.

Podmieniamy w kodzie metody *index* kontrolera *FortunesController*:

    :::ruby
    @fortunes = Fortune.order('created_at DESC').page(params[:page]).per_page(4)

Dopisujemy do widoku *index*:

    :::rhtml app/views/fortunes/index.html.erb
    <div class="digg_pagination">
      <div class="page_info">
        <%= page_entries_info @fortunes %>
      </div>
      <%= will_paginate @fortunes, :container => false %>
    </div>

Stylizacja. Korzystamy z gotowego kodu:

* [digg-style, extra content](https://github.com/wbzyl/rat/blob/master/less/digg_pagination.less)

Pobieramy plik i zapisujemy go w katalogu: *app/assets/stylesheets*.
Dopisujemy go do manifestu *application.css.less*:

    :::css
    @import "twitter/bootstrap";
    @import "digg_pagination";

Zrobione? Zrobione!

Zabieramy się za i18n:

* [Translating will_paginate output (i18n)](https://github.com/mislav/will_paginate/wiki/I18n)

Dopisujemy do pliku *en.yml*:

    :::yaml
    en:
      will_paginate:
        previous_label: "«"
        next_label: "»"
        page_gap: "…"
        page_entries_info:
          single_page:
            zero:  "No %{model} found"
            one:   "Displaying 1 %{model}"
            other: "Displaying all %{count} %{model}"
          single_page_html:
            zero:  "No %{model} found"
            one:   "Displaying <b>1</b> %{model}"
            other: "Displaying <b>all&nbsp;%{count}</b> %{model}"
          multi_page: "Displaying %{model} %{from} - %{to} of %{count} in total"
          multi_page_html: "Displaying %{model} <b>%{from} – %{to}</b> of <b>%{count}</b> in total"

(Zamieniam previous, next i page na «, » i …, odpowiednio.)

Gotowa paginacja? Gotowa! Czyli teraz pora na małe rebase.
Poniższe polecenia wykonujemy będąc na gałęzi *pagination*
(powinniśmy na niej być):

    :::bash
    git status
    git add .
    git commit -m "gotowa paginacja z will_paginate"
    gitk --all
    git rebase -i master
    gitk --all
    git checkout master
    git merge pagination
    gitk --all
    git branch -d pagination
    git tag v0.0.1


## Walidacja

Do czego jest nam potrzebna walidacja wyjaśniono w samouczku
[Active Record Validations and Callbacks](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html).

* Baza powinna zawsze zawierać prawidłowe dane.
* Zanim zapiszemy coś w bazie powinniśmy sprawdzić
  czy dane które chcemy umieścić w bazie są poprawne.
* Gdzie to sprawdzenie najlepiej wykonać?
  W przeglądarce? W aplikacji Rails?
  Lepiej w kontrolerze, czy modelu? Dlaczego?
  Może lepiej walidację zostawić to serwerowi bazy?

Dopisujemy walidację do modelu *Fortune*:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      validates :quotation, presence: true
      validates :quotation, length: { maximum: 256 }
      validates :quotation, uniqueness: { case_sensitive: false }

      validates :source, length: { in: 3..64 }, allow_blank: true
    end

Sprawdzamy na konsoli Rails jak działa walidacja:

    :::ruby
    f = Fortune.new
    f.valid?
      => false
    f.errors.messages
      => {:quotation=>["can't be blank"]}
    f.errors[:quotation].any?
      => true
    f.save
      => false
    f.source = "a"
    f.valid?
    f.errors.messages
    f.source = ""
    f.valid?
    f.errors

Pozostałe rzeczy: *validates_with*, *validates_each*, walidacja warunkowa,
walidacja dla powiązanego modelu *validates_associated*, opcja `:on` –
kiedy walidować (`:create`, `:update`, `:save` itd.), walidacja warunkowa


**Ważne:** Powinniśmy sprawdzić jak działa walidacja w przeglądarce.
Sama konsola to za mało!

Dodatkowa lektura:

* [validates :rails_3, :awesome => true](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)
* [Creating Custom Validation Methods](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html#creating-custom-validation-methods)
* [Building Rails 3 custom validators](http://www.perfectline.ee/blog/building-ruby-on-rails-3-custom-validators)
* [Sexy Validation in Rails3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)


## Formularze z *simple_form*

Jak pisać formularze w aplikacjach Rails opisano w samouczku
[Rails Form helpers](http://edgeguides.rubyonrails.org/form_helpers.html).
Po lekturze tego samouczka jedna sprawa jest jasna: „forms aren’t easy”.
Za to autorzy [simple_form](https://github.com/plataformatec/simple_form)
obiecują, że z ich gemem „forms are easy!”.

Dostępne opcje znajdziemy pliku *simple_form.rb*. Dla przykładu
zmienimy walidację HTML5 na *false*:

    :::ruby config/initializers/simple_form.rb
    # Tell browsers whether to use default HTML5 validations (novalidate option).
    # Default is enabled.
    config.browser_validations = false

W wygenerowanym formularzu dopisujemy *:rows => 6*. Domyślna wartość, ok. 40,
to zdecydowanie za dużo.

    :::rhtml
    <%= simple_form_for(@fortune) do |f| %>
      <%= f.error_notification %>
      <div class="form-inputs">
        <%= f.input :quotation, :input_html => { :rows => 6 } %>
        <%= f.input :source %>
      </div>
      <div class="form-actions">
        <%= f.button :submit %>
      </div>
    <% end %>

<!--  niepotrzebne z Bootsrap
Zaczynamy od ustawienia takiego samego fontu dla elementów *input[type=text]* oraz *textarea*:

    :::css public/stylesheets/applications.css
    input[type="text"], textarea {
      font: inherit;
    }

Inaczej, elementy te przy takiej samej liczbie kolumn, bądą miały różną szerokość.
(Albo można ustawić *width* dla elementów *input* oraz *textarea*.)
-->


<blockquote>
  {%= image_tag "/images/fraunhofer-lines.jpg", :alt => "[Fraunhofer lines]" %}
  <p>
    [Herschel do Babbage’a, kiedy ten nie był w stanie dojrzeć ciemnych
    linii Fraunhofera]
    Często nie widzimy czegoś dlatego, że
    <b>nie wiemy jak to zobaczyć</b>, a nie na skutek
    jakichś braków w organie widzenia…
    Nauczę cię jak je dostrzec.
  </p>
</blockquote>


## Responders

Google podpowiada, że *responder* to hiszpańskie słowo na odpowiadać / odezwać / odczytać.
Zapoznawanie się z tą biblioteką zaczynamy od lektury
[README](https://github.com/plataformatec/responders),
gdzie dowiadujemy się, że mamy do dyspozycji trzy prekonfigurowane respondery:

* *FlashResponder* (i18n dla komunikatów flash)
* *HttpCacheResponder* (dodaje do żądania nagłówek Last-Modified)
* *CollectionResponder* (po uaktualnieniu lub zapisaniu rekordu w bazie jesteśmu przekierowywani na index)

Co więcej, możemy pisać swoje responders oraz używać ich w zestawach.
Czego nie będziemy robić. Ale za to zainstalujemy powyższe responders
i skonfigurujemy Fortunkę tak aby z nich korzystała.

Generator *responders:install* utworzył plik locales:

    :::yaml config/locales/responders.en.yml
    en:
      flash:
        actions:
          create:
            notice: '%{resource_name} was successfully created.'
          update:
            notice: '%{resource_name} was successfully updated.'
          destroy:
            notice: '%{resource_name} was successfully destroyed.'
            alert: '%{resource_name} could not be destroyed.'
        en:

modyfikuje plik *application_controller.rb*:

    :::ruby app/controllers/application_controller.rb
    require "application_responder"

    class ApplicationController < ActionController::Base
      self.responder = ApplicationResponder
      respond_to :html
      ...

gdzie dopisujemy format `:json`:

    :::ruby
    respond_to :json, except: [:create, :update, :destroy]

Tworzy plik *application_responder.rb*:

    :::ruby lib/application_responder.rb
    class ApplicationResponder < ActionController::Responder
      include Responders::FlashResponder
      include Responders::HttpCacheResponder

      # Uncomment this responder if you want your resources to redirect to the collection
      # path (index action) instead of the resource path for POST/PUT/DELETE requests.
      # include Responders::CollectionResponder
    end

gdzie odkomentowujemy linijkę z *CollectionResponder*. Co to da?

**koniec wykładu 22.04.2012**

    :::bash
    git commit -m "...responders..."
    ... rebase ...
    git tag v0.0.2


## Grand refactoring

W widoku *index* skorzystamy z *implicit loop*. Wycinamy pętlę

    :::rhtml app/views/fortunes/index.html.erb
    <article class="index">
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.fortune.quotation" %></span>
        <span class="value"><%= fortune.quotation %></span>
      </div>
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.fortune.source" %></span>
        <span class="value"><%= fortune.source %></span>
      </div>
    <div class="form-actions">
      <%= link_to 'Show', fortune, class: 'btn btn-mini'%>
      <%= link_to 'Edit', edit_fortune_path(fortune), class: 'btn btn-mini'%>
      <%= link_to 'Destroy', fortune, confirm: 'Are you sure?', method: :delete, class: 'btn btn-mini btn-danger'%>
    </div>
    </article>

Wycięty kodu wklejamy do nowego pliku *_fortune.html.erb* (liczba pojedyncza!)

Podmieniamy zawartość pliku *index.html.erb* na:

    :::rhtml app/views/fortunes/index.html.erb
    ... tytuł i digg pagination bez zmian ...

    <%= render partial: 'fortune', collection: @fortunes %>

    <div class="form-actions">
      <%= link_to 'New Fortune', new_fortune_path, class: 'btn btn-primary'%>
    </div>

Szablon częściowy *_fortune.html.erb* renderowany jest wielokrotnie,
w pętli po zmiennej *fortune* (konwencja *@fortunes* → *fortune*):


## RSS: atom

Dopisujemy do kontrolera:

    :::ruby
    respond_to :html, :atom

i dodajemy nowy widok:

    :::ruby app/views/fortunes/index.atom.builder
    atom_feed do |feed|
      feed.title "My Fortunes"
      feed.updated @fortunes.first.updated_at
      @fortunes.each do |fortune|
        feed.entry(fortune) do |entry|
          entry.content fortune.quotation, type: "html"
        end
      end
    end

W pliku z layoutem dopisujemy w znaczniku *head*:

    :::rhtml app/views/layouts/application.html.erb
    <%= auto_discovery_link_tag(:atom, fortunes_path(:atom)) %>

Aby sprawdzić jak to działa, wchodzimy na stronę:

    http://localhost:3000/fortunes.atom


# Wyszukiwanie w fortunkach

Na stronie z listą fortunek dodamy formularz, który będzie filtrował
dane po polu *quotation*:

    :::rhtml app/views/fortunes/index.html.erb
    <%= form_tag fortunes_path, method: :get, id: "fortunes_search", class: "form-inline" do %>
      <%= text_field_tag :query, params[:query] %>
      <%= submit_tag "Search", name: nil, class: "btn" %>
    <% end %>

Poprawiamy wygląd formularza:

    :::css
    #fortunes_search {
      margin-top: 1em;
      margin-bottom: 2em;
    }
    #search {
      width: 30%;
    }

Aby odfiltrować zbędne rekordy, musimy w *FortunesController*
w metodzie *index* przekazać tekst, który wpisano w formularzu
(użyjemy metody *search*, mała refaktoryzacja):

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.order('created_at DESC').text_search(params[:search]).page(params[:page]).per_page(4)
      respond_with(@fortunes)
    end

kod metody wpisujemy w klasie *Fortune*:

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        # SQLite i PostgreSQL
        where('quotation LIKE ?', "%#{search}%")
        # tylko PostgreSQL; i – ignore case
        # where("quotation ilike :q or source ilike :q", q: "%#{query}%")
      else
        scoped
      end
    end

Metoda *text_search* jest wykonywana zawsze po wejściu na stronę *index*,
nawet jak nic nie wyszukujemy. Prześledzić działanie *search*? Jak?
Co oznacza *scoped*?

### Nowe idee w wyszukiwaniu

* Florian R. Hanke.
  [Picky](https://github.com/floere/picky) –
  easy to use and fast Ruby semantic search engine.
  Przykłady:
  - [twixtel](http://www.twixtel.ch/),
  - [gemsearch](http://gemsearch.heroku.com/)


<blockquote>
<p><a hred="http://sigma.inf.ug.edu.pl/~jdarecki/fedora15.html">Instalacja MySQl, PostgreSQL... w Fedorze 15</p></p>
</blockquote>

## Full text search with PostgreSQL

Instalujemy gemy *pg*, *texticle, *pg_search*:

    :::ruby
    gem 'pg'
    gem 'texticle', require: 'texticle/rails'
    gem 'pg_search'

Zmieniamy bazę w *database.yml*:

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

Pozostaje utworzyć bazy i wykonać migracje:

    :::bash
    rake db:create:all
    rake db:migrate


### Transfer bazy: Sqlite → PostgreSQL

* David Dollar.
  [Valkyrie](https://github.com/ddollar/valkyrie) – transfer data between databases
* Ricardo Chimal.
  [Taps](https://github.com/ricardochimal/taps) – simple database import/export app

Dodajemy gemy *valkyrie* i *taps* do grupy *development* i wykonujemy:

    :::bash
    bundle install --binstubs

Przerzucamy bazę development z SQLite do PostgreSQL:

    :::bash
    # nie zadziałało… problemy z authentication
    bin/valkyrie sqlite://db/development.sqlite3 \
      postgres://wbzyl@localhost/fortune_responders_development
    # też nie działało
    # bin/taps server sqlite://db/development.sqlite3 wbzyl secret
    # bin/taps pull postgres://wbzyl@localhost/fortune_responders_development \
    #   http://wbzyl:secret@localhost:5000

Zmieniamy konfigurację
([psql: FATAL…](http://www.cyberciti.biz/faq/psql-fatal-ident-authentication-failed-for-user/)):

    :::text /var/lib/pgsql/data/pg_hba.conf
    local	all	all	trust
    host	all	127.0.0.1/32	trust

i ponownie wykonujemy polecenie *valkyrie*.


## Full text search with PostgreSQL

Zaczynamy od

Korzystamy z operatora @@. Model:

    :::ruby
    def self.text_search(query)
      if query.present?
        where("quotation @@ :q or source @@ :q", q: query)
      else
        scoped
      end
    end

Dodatkowe wyjaśnienia na konsoli DB:

    :::sql
    select 'ninja turtles @@ 'turtles';
    select to_tsvector('ninja turtles') @@ plainto_tsquery('turtles');
    select to_tsvector('english', 'ninja turtles') @@ plainto_tsquery('english', 'turtles'); -- stemming
    select to_tsvector('simple', 'ninja turtles') @@ plainto_tsquery('simple', 'turtles');   -- without
    select to_tsvector('simple', 'ninja turtles') @@ to_tsquery('simple', 'turtles');        -- one word
    select to_tsvector('simple', 'ninja turtles') @@ to_tsquery('simple', 'turtles & turtles');   -- and
    select to_tsvector('simple', 'ninja turtles') @@ to_tsquery('simple', 'turtles | turtles');   -- or
    select to_tsvector('simple', 'ninja turtles') @@ to_tsquery('simple', 'turtles & !turtles');  -- not

**Rank**:

    :::sql
    select ts_rank(to_tsvector('ninja turtles'), to_tsquery('turtles'));

Poprawki w modelu:

    :::ruby
    def self.search(query)
      if query.present?
        rank = <<-RANK
          ts_rank(to_tsvector(quotation), plainto_tsquery(#{sanitize(query)})) +
          ts_rank(to_tsvector(source), plainto_tsquery(#{sanitize(query)}))
        RANK
        where("quotation @@ :q or source @@ :q", q: query).order("#{rank} desc")
      else
        scoped
      end
    end


## Texticle

* Aaron Patterson.
  [Texticle](https://github.com/tenderlove/texticle) –
  full text search capabilities from PostgreSQL

Ta sama funkcjonalność co wyżej (z rank?).

Zmiany w modelu:

    :::ruby
    def self.text_search(query)  # zamiana na text_search -- konflikt z Texticle, poprawić w kontrolerze
      if query.present?
        search(query)
      else
        scoped
      end
    end


## PG_search

* [pg_search](https://github.com/Casecommons/pg_search)

Z *README*: wyszukiwanie w jednym modelu – *pg_search_scope*
lub w kilku modelach – *multisearch*.

Dopisujemy w modelu (nie używa słownika 'english', nie działa stemming):

    :::ruby
    include PgSearch
    pg_search_scope :search, against: [:quotation, :source]  # defines `search` method

    def self.text_search(query)
      if query.present?
        search(query)
      else
        scoped
      end
    end

Dodajemy stemming:

    :::ruby
    pg_search_scope :search, against: [:quotation, :source],
      using: {tsearch: {dictionary: "english"}}

**TODO:** Łatwe wyszukiwanie w powiązanych modelach.




## TODO: Ajaxujemy filtrowanie

Trzeba wykonać kilka nieoczywistych rzeczy. Wszystkie szczegóły opisano
w [Search, Sort, Paginate with AJAX](http://asciicasts.com/episodes/240).
Niestety, niektóre rzeczy tam opisane są zbędne albo już nieaktualne
(bo, na przykład, dotyczą *will_paginate*). Ale jest za to opisane
jak dodać **sortowanie**.

Wyszukane fortunki umieścimy w elemencie *div* z id *fortunes*,
a paginator w elemencie *div* z id *paginator*
(po co? zob. kod szablonu poniżej).
Podstawowa rzecz: „To make the paging work with AJAX we need
**to modify the pagination links** so that they make an AJAX
request when clicked instead of linking to another page.”:

    :::rhtml app/views/fortunes/index.html.erb
    <div id="paginator">
      <%= paginate @fortunes, :remote => true %>
    </div>

Żądanie AJAX korzystają z szablonu **index.js.erb**:

    :::jquery_javascript app/views/fortunes/index.js.erb
    // render _fortune.html.erb partial
    $("#fortunes").html("<%= escape_javascript(render(@fortunes)) %>");
    // modify pagination links
    $('#paginator').html('<%= escape_javascript(paginate(@fortunes, :remote => true).to_s) %>');

Sam „search” formularz też należy zajaxować:

    :::rhtml app/views/fortunes/index.html.erb
    <%= form_tag fortunes_path, :remote => true, :method => :get, :id => "fortunes_search" do %>


# Tagowanie

Tagowanie dodamy, korzystając z gemu
[acts-as-taggable-on](http://github.com/mbleigh/acts-as-taggable-on).
Po instalacji gemu, zgodnie z tym o co napisano w *README* wykonujemy
polecenia:

    rails generate acts_as_taggable_on:migration
    rake db:migrate

Warto przyjrzeć się wygenerowanej migracji:

    :::ruby
    class ActsAsTaggableOnMigration < ActiveRecord::Migration
      def self.up
        create_table :tags do |t|
          t.string :name
        end
        create_table :taggings do |t|
          t.references :tag

          # You should make sure that the column created is
          # long enough to store the required class names.
          t.references :taggable, :polymorphic => true
          t.references :tagger, :polymorphic => true

          t.string :context
          t.datetime :created_at
        end
        add_index :taggings, :tag_id
        add_index :taggings, [:taggable_id, :taggable_type, :context]
      end

      def self.down
        drop_table :taggings
        drop_table :tags
      end
    end

<blockquote>
 <p>
  A little inaccuracy saves a world of explanation.
 </p>
</blockquote>

[Polimorficzne powiązanie](http://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations)
oznacza, że jeden model może być w relacji *belongs_to*
do więcej niż jednego modelu:

    :::ruby
    t.references :taggable, :polymorphic => true

co tłumaczy się na:

    :::ruby
    t.integer :taggable_id
    t.string  :taggable_type

Innymi słowy mamy następujące powiązania między modelami:

* *Tagging* belongs to *Fortune*
* *Fortune* has many *Taggings*

Na konsoli wygląda to tak:

    :::ruby
    f = Fortune.find 1
    f.tag_list = "everything nothing always"            # proxy
    # f.tag_list = ['everything', 'nothing', 'always']  # tak też można
    f.save
    f.tags
    f.taggings


### Dodajemy losowe tagi do fortunek

Poprawiamy *seeds.rb*:

    :::ruby db/seeds.rb
    platitudes = File.readlines(Rails.root.join('db', 'platitudes.u8'), "\n%\n")
    tags = ['always', 'always', 'sometimes', 'never', 'maybe', 'ouch', 'wow', 'nice', 'wonderful']
    platitudes.map do |p|
      reg = /\t?(.+)\n\t\t--\s*(.*)\n%\n/m
      m = p.match(reg)
      if m
        f = Fortune.new :quotation => m[1], :source => m[2]
      else
        f = Fortune.new :quotation => p[0..-4], :source => Faker::Name.name
      end
      f.tag_list = tags.sample(rand(tags.size - 3))
      f.save
    end

Teraz, kasujemy bazę i wrzucamy jeszcze raz cytaty, ale tym razem
z tagami:

    rake db:drop
    rake db:migrate
    rake db:seed


## Zmiany w kodzie modelu

Dopisujemy do modelu:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      acts_as_taggable_on :tags
      ActsAsTaggableOn::TagList.delimiter = " "

Przy okazji, zmieniliśmy domyślny znak do oddzielania tagów z przecinka
na spację.

W widoku częściowym *_form.html.erb* dopisujemy:

    :::rhtml app/views/fortunes/_form.html.erb
    <%= f.input :tag_list, :input_html => {:size => 40} %>

w widoku częściowym *_fortune.html.erb* (część widoku *index.html.erb*),
oraz w widoku *show.html.erb* (2 razy):

    :::rhtml app/views/fortunes/_fortune.html.erb
    <p><i>Tags:</i> <%= @fortune.tag_list %></p>


## Chmurka tagów

Aby utworzyć chmurkę tagów, niestety nie tak ładną jak ta poniżej:

{%= image_tag "/images/wordly.png", :alt => "[chmurka tagów]" %}

dopisujemy do widoku *index*:

    :::rhtml app/views/fortunes/index.html.erb
    <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
      <%= link_to tag.name, LINK_DO_CZEGO?, :class => css_class %>
    <% end %>

Aby ten kod zadziałał musimy zdefiniować zmienną *@tags*, wczytać kod
metody pomocniczej *tag_cloud*, wystylizować chmurkę tagów oraz
podmienić *LINK_DO_CZEGO?* na coś sensownego.

Zaczniemy od zmiennej *@tags*:

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.search(params[:search]).order(:source).page(params[:page]).per(4)
      @tags = Fortune.tag_counts
      respond_with(@fortunes)
    end

Teraz spróbujemy przyjrzeć się bliżej, debugging, zmiennej *tag*:

    :::rhtml
    <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
      <%= link_to tag.name, fortunes_path, :class => css_class %>
      <%= debug(tag.class) %>
      <%= debug(tag) %>
    <% end %>

Po ponownym wczytaniu strony *fortunes\#index* widzimy, że
zmienna *tag*, to obiekt klasy:

    :::ruby
    ActsAsTaggableOn::Tag(id: integer, name: string)

na przykład:

    :::yaml
    attributes:
      id: 1
      name: sometimes
      count: 151

a wygenrowany link, to:

    :::html
    <a href="/fortunes" class="css3">sometimes</a>

Nie jest to to o co nam chodzi.
Później zamienimy ten link na link do tagów.

Tagi powinny mieć wielkość zależną od częstości występowania:

    :::css public/stylesheets/application.css
    .css1 { font-size: 1.0em; }
    .css2 { font-size: 1.2em; }
    .css3 { font-size: 1.4em; }
    .css4 { font-size: 1.6em; }

Tyle debuggowania – usuwamy zbędny kod z *debug*. Opakowujemy *tag_cloud*
elementem *div\#tag_cloud*, ustawiamy jego szerokość, powiedzmy na
250px i pozycjonujemy abolutnie w prawym górnym rogu, gdzie jest
trochę wolnego miejsca:

    :::css public/stylesheets/application.css
    quotation {
      position: relative;
    }
    #tag_cloud {
      background-color: #E1F5C4; /* jasnozielony */
      padding: 1em;
      width: 250px;
      position: absolute;
      right: 1em;
      top: 1em;
    }

I już możemy obejrzeć rezultaty naszej pracy!


## Dodajemy własną akcję do REST

Mając chmurkę z tagami, wypadałoby olinkować tagi tak, aby
po kliknięciu na nazwę wyświetliły się fortunki otagowane
tą nazwą.

Zaczniemy od zmian w routingu. Usuwamy
wiersz z `resources :fortunes`. Zamiast niego wklejamy:

    :::ruby config/routes.rb
    resources :fortunes do
      collection do
        get :tags
      end
    end

Sprawdzamy routing:

    rake routes

i widzimy, że mamy **jeden** dodatkowy uri:

    tags_fortunes GET /fortunes/tags(.:format) {:action=>"tags", :controller=>"fortunes"}

Na koniec, zamieniamy link w chmurce tagów na:

    :::ruby
    <%= link_to tag.name, tags_fortunes_path(:name=>tag.name), :class => css_class %>

Pozostała refaktoryzacja *@tags*, oraz napisanie metody *tags*:

    :::ruby app/controllers/fortunes_controller.rb
    before_filter :only => [:index, :tags] do
      @tags = Fortune.tag_counts
    end

    def index
      @fortunes = Fortune.search(params[:search]).order(:source).page(params[:page]).per(4)
      respond_with(@fortunes)
    end

    # respond_with nic nie wie o tags
    def tags
      @fortunes = Fortune.tagged_with(params[:name]).order(:source).page(params[:page]).per(4)
      respond_with(@fortunes) do |format|
        format.html { render :action => 'index' }
        format.js   { render :action => 'index' }
      end
    end

Gotowe! Przyjrzeć się jak to działa.


<blockquote>
 <p>
  {%= image_tag "/images/surgery.jpg", :alt => "[surgery.com]" %}
 </p>
 <p>Software is invisible and <b>unvisualizable</b>. Geometric abstractions are
  powerful tools. The floor plan of a building helps both architect and
  client evaluate spaces, traffic flows, views. Contradictions and
  omissions become obvious.</p>
 <p>In spite of progress in restricting and simplifying the structures of
  software, they remain inherently unvisualizable, and thus do not
  permit the mind to use some of its most powerful conceptual
  tools. This lack not only impedes the process of design within one
  mind, it severely hinders communication among minds.</p>
 <p class="author">— Frederick P. Brooks, Jr.</p>
</blockquote>

# Fortunki z komentarzami

W widoku *show.html.erb* fortunki powinna być możliwość dopisywania
własnych komentarzy, dodawania obrazków kojarzących się nam
z fortunką. Na początek zabierzemy się za komentarze.

Przygotujemy sobie też stronę ze wszystkimi komentarzami.
Przyda się adminowi przy usuwaniu, edycji komentarzy.

Będziemy pracować na nowej gałęzi:

    git checkout -b comments

Dopiero po sprawdzeniu, że wszystkie zmiany są OK,
wykonamy rebase na master.

Zaczynamy od wygenerowania rusztowania dla zasobu *Comment*:

    rails g resource Comment fortune:references \
        author:string quotation:string

Zagnieżdżamy zasoby i sprawdzamy jak wygląda teraz routing:

    :::ruby
    resources :fortunes do
      resources :comments
      collection do
        get :tags
      end
    end

Po tej zmianie polecenie

    rake routes

wypisuje nowy routing:

                         GET    /fortunes/:fortune_id/comments          {:action=>"index",   :controller=>"comments"}
        fortune_comments POST   /fortunes/:fortune_id/comments          {:action=>"create",  :controller=>"comments"}
     new_fortune_comment GET    /fortunes/:fortune_id/comments/new      {:action=>"new",     :controller=>"comments"}
                         GET    /fortunes/:fortune_id/comments/:id      {:action=>"show",    :controller=>"comments"}
                         PUT    /fortunes/:fortune_id/comments/:id      {:action=>"update",  :controller=>"comments"}
         fortune_comment DELETE /fortunes/:fortune_id/comments/:id      {:action=>"destroy", :controller=>"comments"}
    edit_fortune_comment GET    /fortunes/:fortune_id/comments/:id/edit {:action=>"edit",    :controller=>"comments"}


oraz stary routing, który też obowiązuje:

    tags_fortunes GET    /fortunes/tags     {:action=>"tags",    :controller=>"fortunes"}
                  GET    /fortunes          {:action=>"index",   :controller=>"fortunes"}
         fortunes POST   /fortunes          {:action=>"create",  :controller=>"fortunes"}
      new_fortune GET    /fortunes/new      {:action=>"new",     :controller=>"fortunes"}
                  GET    /fortunes/:id      {:action=>"show",    :controller=>"fortunes"}
                  PUT    /fortunes/:id      {:action=>"update",  :controller=>"fortunes"}
          fortune DELETE /fortunes/:id      {:action=>"destroy", :controller=>"fortunes"}
     edit_fortune GET    /fortunes/:id/edit {:action=>"edit",    :controller=>"fortunes"}

             root        /                  {:controller=>"fortunes", :action=>"index"}

Przechodzimy do modelu *Comment*, gdzie znajdujemy dopisane
przez generator powiązanie:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
    end

Przechodzimy do modelu *Fortune*, gdzie sami dopisujemy drugą stronę powiązania:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      has_many :comments, :dependent => :destroy
      ...

Nie zapominamy o migracji:

    rake db:migrate

Teraz wykonanie na konsoli:

    :::ruby
    Fortune.first.comments  #=> []

pokazuje, że komentarze pierwszej fortunki tworzą pustą tablicę.
Aby dodać komentarz możemy postąpić tak:

    :::ruby
    Fortune.first.comments << Comment.new(:author=>"Ja", :quotation=>"Fajne!")
    Comment.all


### Gdzie będziemy wyświetlać komentarze?

Komentarze dla konkretnej fortunki wypiszemy w jej widoku *show*:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
      <h2>Comments</h2>
      <% @fortune.comments.each do |comment| %>
       <p>Autor:<br><%= comment.author %></p>
       <div class="comment">
         <b>Quotation:</b> <%= comment.quotation %>
       </div>
       <p>
         <%= link_to "Delete", [@fortune, comment], :confirm => t('helpers.data.sure'), :method => :delete %>
       </p>
      <% end %>
    <% end %>

**Jakie nowe rzeczy pojawiły się powyższym kodzie?**


### Gdzie będziemy dodawać nowe komentarze?

Najwygodniej byłoby dodać też formularz do widoku *show*:

    :::rhtml app/views/fortunes/show.html.erb
    <h2>Add new comment</h2>
    <%= simple_form_for [@fortune, @fortune.comments.build] do |f| %>
      <%= f.input :author, :input_html => {:size => 40} %>
      <%= f.input :quotation, :input_html => {:rows => 4, :cols => 40} %>
      <%= f.button :submit %>
    <% end %>

**Nowe rzeczy w kodzie?**
Dlaczego kod ten jest taki pokrętny: **@fortune.comments.build** ?
Czy samo *Comment.new* nie wystarczyłoby?


## Kontroler dla komentarzy

W pustym kontrolerze utworzonym przez generator **uważnie** wpisujemy:

    :::ruby app/controllers/comments_controller.rb
    class CommentsController < ApplicationController
      before_filter do
        @fortune = Fortune.find(params[:fortune_id])
      end

      def create
        @comment = @fortune.comments.build(params[:comment])
        @comment.save
        respond_with(@fortune, @comment, :location => @fortune)
      end

      def destroy
        @comment = @fortune.comments.find(params[:id])
        @comment.destroy
        respond_with(@fortune, @comment, :location => @fortune)
      end
    end

W powyższym kodzie wymuszamy za pomocą konstrukcji z *location*,
przeładowanie strony z fortunką po zapisaniu w bazie
nowej fortunki lub jej usunięciu.

To jeszcze nie wszystko! Musimy napisać metody *edit* oraz *update*.
Należy pomyślić też o widoku do edycji komentarzy!

Ale teraz zabierzemy się za refaktoryzację kodu.


## Refaktoryzacja widoku „show”

Usuwamy kod formularza pod znacznikiem *h2\#Add new comments* powyżej.
Tworzymy z usuniętego kodu szablon częściowy *comments/_form.html.erb*:

    :::rhtml app/views/comments/_form.html.erb
    <%= simple_form_for [@fortune, @comment] do |f| %>
      <%= f.input :author, :input_html => {:size => 40} %>
      <%= f.input :quotation, :input_html => {:rows => 4, :cols => 40} %>
      <%= f.button :submit %>
    <% end %>

**Uwaga:** W usuniętym kodzie należy fragment *@fortune.comments.build*
zamienić na *@comment*, a zmienną *@comment* – zdefiniować
w metodzie *show* kontrolera *FortunesController*:

    :::ruby app/controllers/fortunes_controller.rb
    def show
      @fortune = Fortune.find(params[:id])
      @comment = Comment.new
      respond_with(@fortune)
    end

Następnie usuwamy pętlę pod *h2\#Comments* powyżej. Z ciała tej
pętli tworzymy drugi szablon częściowy *comments/_comment.html.erb*:

    :::rhtml app/views/comments/_comment.html.erb
    <p><i>Autor:</i> <%= comment.author %></p>
    <div class="comment"><i>Quotation:</i>
      <%= comment.body %>
    </div>
    <p>
      <%= link_to "Delete", [@fortune, comment], :confirm => t('helpers.data.sure'), :method => :delete %>
    </p>

Na koniec poprawiamy kod widoku *show*, wstawiając nowe szablony częściowe:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
      <h2>Comments</h2>
      <%= render :partial => 'comments/comment', :collection => @fortune.comments %>
    <% end %>

    <h2>Add new comment</h2>
    <%= render :partial => 'comments/form' %>


## Reszta obiecanego kodu

…czyli metody *edit* oraz *update*:

    :::ruby app/controllers/comments_controller.rb
    def edit
      @comment = @fortune.comments.find(params[:id])
    end

    def update
      @comment = @fortune.comments.find(params[:id])
      @comment.update_attributes(params[:comment])
      respond_with(@fortune, @comment, :location => @fortune)
    end

oraz brakujący link do edycji fortunki:

    :::rhtml app/views/comments/_comment.html.erb
    <%= link_to 'Edit', edit_fortune_comment_path(@fortune, comment) %>

no i szablon widoku – *comments/edit.html.erb*:

    :::rhtml app/views/comments/edit.html.erb
    <% title "Editing comment" %>
    <%= render :partial => 'form' %>
    <p class="links clear">
      <%= link_to 'Show Fortune', @comment.fortune %>
    </p>


## Walidacja komentarzy

Będziemy wymagać aby każde pole było niepuste:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
      validates :author, :presence => true
      validates :body, :presence => true
    end

Musimy też utworzyć widok *comments/new.html.erb*:

    :::rhtml app/views/comments/new.html.erb
    <% title "New comment" %>
    <%= render :partial => 'form' %>
    <p class="links clear"><%= link_to 'Back', @comment.fortune %></p>

Będziemy go potrzebować jak użytkownik kilknie przycisk
„Create Comment” przy jednym z pól pustym.

**BUG:** W Chromie ten kod nie działa. Zamiast Railsów
poprawność danych sprawdza Chrome –
uaktywnia sprawdzanie zawartości pól formularza.

Pojawia się też komunikat po angielsku:

    Please fill out this field.

Często nie w tym polu co trzeba. Gdzie się tłumaczy te komunikaty?
Jak to wyłączyć?


# TODO

* Widok strony indeks na wzór layoutu *Masonry* –
  [Isotope](http://isotope.metafizzy.co/)
* Obrazki w fortunkach: skorzystać z gemu
  [CarrierWave](https://github.com/jnicklas/carrierwave/)
  (zob. też Trevor Turk,
  [A Gentle Introduction to CarrierWave](http://www.engineyard.com/blog/2011/a-gentle-introduction-to-carrierwave/)).
* [Multiple files upload with carrierwave and nested_form](http://lucapette.com/rails/multiple-files-upload-with-carrierwave-and-nested_form/)


## Engines are back in Rails… 3.1

Engine to miniaturowa aplikacja, gem albo wtyczka.
Zazwyczaj za pomocą engine dodajemy dodatkową funkcjonalność
do całej aplikacji Rails. Na przykład
autentykację (Devise), paginację (Kaminari, alternatywa dla Will Paginate).

Engines dla Rails wymyślił [James Adams](https://github.com/lazyatom/engines).
Z engines był jeden problem. Nie było gwarancji, że nowa wersja Rails
będzie będzie działać ze starymi engines. Wersja Rails 3.1 ma to zmienić.

Nieco Railsowej archeologii:

* [Guide: Things You Shouldn't Be Doing In Rails](http://glu.ttono.us/articles/2006/08/30/guide-things-you-shouldnt-be-doing-in-rails) –
 artykuł z 2005 roku
* [Odpowiedź J. Adamsa](http://article.gmane.org/gmane.comp.lang.ruby.rails/29166)


{%= image_tag "/images/head-element.png", :alt => "[source: http://diveintohtml5.org/]" %}<br>
(źródło M. Pilgrim. <a href="http://diveintohtml5.org/">Dive into HTML5</a>)


## Google Analytics

Google Analytics zajmiemy się przy wdrażaniu aplikacji na Heroku.

