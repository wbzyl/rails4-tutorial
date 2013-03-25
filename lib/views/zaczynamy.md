#### {% title "Fortunka v0.0" %}

<blockquote>
 {%= image_tag "/images/ken-arnold.jpg", :alt => "[Ken Arnold]" %}
 <p>
  Fortunka (Unix) to program „which will display quotes or
  witticisms. Fun-loving system administrators can add fortune to users’
  <i>.login</i> files, so that the users get their dose of wisdom each time
  they log in.”
 </p>
 <p>Autorem najczęściej instalowanej wersji jest Ken Arnold.
 </p>
</blockquote>

Prezentację możliwości frameworka *Ruby on Rails* zaczniemy od
implementacji bazodanowej aplikacji www *hello world*.
Taka aplikacja powinna implementować interfejs CRUD, czyli

* ***C**reate* (*insert*) — dodanie nowych danych
* ***R**ead* (*select*) – wyświetlenie istniejących danych
* ***U**pdate* – edycję istniejących danych
* ***D**elete* — usuwanie istniejących danych.

Naszą aplikacją *hello world* będzie *Fortunka* w której zaimplementujemy
interfejs CRUD dla [fortunek](http://en.wikipedia.org/wiki/Fortune_(Unix\)),
czyli krótkich cytatów.


## MVC ≡ Model / Widok / Kontroler

<blockquote>
 {%= image_tag "/images/frederick-brooks.jpg", :alt => "[Frederick P. Brooks, Jr.]" %}
 <p>To see what rate of progress one can expect in software technology,
  let us examine the difficulties of that technology. Following
  Aristotle, I divide them into <b>essence</b>, the difficulties inherent in
  the nature of software, and <b>accidents</b>, those difficulties that today
  attend its production but are not inherent.</p>
 <p>I believe the hard part of building software to be the specification,
   design, and testing of this conceptual construct, not the labor of
   representing it and testing the fidelity of the representation. We
   still make syntax errors, to be sure; but they are fuzz compared with
   the conceptual errors in most systems.
 </p>
 <p class="author">— Frederick P. Brooks, Jr.</p>
</blockquote>

**Czym jest Ruby on Rails:**
„Ruby on Rails is an **MVC** framework for web application development.
MVC is sometimes called a design pattern, but thats not technically
accurate. It is in fact an amalgamation of design patterns (sometimes
referred to as an architecture pattern).”

„Gang of Four” („GoF” = E. Gamma, R. Helm, R. Johnson, J. Vlissides) tak definiuje
MVC w książce [Wzorce Projektowe](http://www.wnt.com.pl/product.php?action=0&prod_id=986)):
„Model jest obiektem aplikacji. Widok jego ekranową reprezentacją,
zaś Koordynator (kontroler)  definiuje sposób, w jaki interfejs użytkownika
reaguje na operacje wykonywane przez użytkownika. Przed MVC
w projektach interfejsu użytkownika te trzy obiekty były na ogół
łączone. **MVC rozdziela je, aby zwiększyć elastyczność i możliwość
wielokrotnego wykorzystywania.**”

{%= image_tag "/images/mvc-rails.png", :alt => "[MVC w Rails]" %}<br>
Schemat aplikacji WWW korzystającej ze wzorca MVC
[(źródło)](http://betterexplained.com/articles/intermediate-rails-understanding-models-views-and-controllers/)

Dlaczego tak postępujemy?<br>
„MVC rozdziela widoki i model, ustanawiając między nimi protokół
powiadamiania. Widok musi gwarantować, że jego wygląd odzwierciedla
stan modelu. Gdy tylko dane modelu się zmieniają, model powiadamia
zależące od niego widoki. Dzięki temu każdy widok ma okazję do
uaktualnienia się. To podejście umożliwia podłączenie wielu widoków do
jednego modelu w celu zapewnienia różnych prezentacji tych danych.
Można także tworzyć nowe widoki dla modelu bez potrzeby modyfikowania
go.”

Więcej szczegółów na temat MVC:

* Shane Brinkman-Davis,
  [Essence of MVC](http://www.essenceandartifact.com/2012/12/the-essence-of-mvc.html)


## Jak działa MVC w Rails?

Na przykładzie aplikacji **MyGists** i **MyStaticPages**.


### MyGists

Generujemy rusztowanie aplikacji i instalujemy gemy z których
będzie ona korzystać:

    :::bash
    rails new my_gists --skip-bundle
    cd my_gists

Usuwamy niepotrzebne gemy z pliku *Gemfile*:

    :::ruby Gemfile
    gem 'sass-rails'

dopisujemy gemy z których będziemy korzystać:

    :::ruby Gemfile
    gem 'thin'
    gem 'pygments.rb'
    gem 'redcarpet'

Szybko zainstalujemy używane przez aplikację gemy korzystając
gemów zainstalowanych w systemie:

    :::bash
    bundle install --local

Ale możemy też pobrać gemy z internetu i zainstalować je
u siebie, np. w katalogu *~/.gems*:

    :::bash
    bundle install --path=$HOME/.gems

Szablon aplikacji CRUD utworzymy za pomocą generatora kodu
o nazwie *scaffold*:

    :::bash
    rails generate scaffold gist snippet:text lexer:string description:string

Pozostaje wykonać migrację:

    :::bash
    rake db:migrate

uruchomić serwer HTTP:

    :::bash
    rails server --port 3000

Na koniec sprawdzimy routing aplikacji wykonując na konsoli polecenie:

    :::bash
    rake routes

Lektura dokumentacji [link_to](http://api.rubyonrails.org/).
Co to są *assets*? a *partial templates* (szablony częściowe), na
przykład *_form.html.erb*.

Kolorowanie kodu –
[Syntax Highlighting](http://railscasts.com/episodes/207-syntax-highlighting-revised).

Podmieniamy zawartośc pliku *app/views/gists/show.html.erb* na:

    :::rhtml
    <%= raw Pygments.highlight(@gist.snippet, lexer: @gist.lexer) %>
    <p>
      <b>Description:</b> <%= @gist.description %>
    </p>
    <%= link_to 'Edit', edit_gist_path(@gist) %> |
    <%= link_to 'Back', gists_path %>

Dodajemy nowy plik *app/assets/stylesheets/pygments.css.erb*:

    :::rhtml
    <%= Pygments.css(style: "colorful") %>

*TODO:* Poprawić pozostałe widoki. Zacząć od *index.html.erb*.
Zwiększyć rozmiar fontu do co najmniej 18px.
Zwiększyć wielkość elementu *textarea* w formularzu
w szablonie częściowym *_form.html.erb*.


### MyStaticPages

Jak wyżej, usuwamy niepotrzebne gemy z pliku *Gemfile*
dodajemy gemy z których będziemy korzystać i je instalujemy.

Następnie generujemy rusztowanie aplikacji:

    :::bash
    rails new my_static_pages --skip-bundle --skip-test-unit
    cd my_static_pages
    bundle install --local

W tej aplikacji skorzystamy z generatora kodu o nazwie *controller*:

    :::bash
    rails generate controller pages welcome about

      create  app/controllers/pages_controller.rb
       route  get "pages/about"
       route  get "pages/welcome"
      invoke  erb
      create    app/views/pages
      create    app/views/pages/welcome.html.erb
      create    app/views/pages/about.html.erb

Routing:

    :::bash
    rake routes

      pages_welcome GET /pages/welcome(.:format) pages#welcome
        pages_about GET /pages/about(.:format)   pages#about

co oznacza, że te strony będą dostępne z adresów
*/pages/welcome* i */pages/about*.

Lektura Rails API oraz Rails Guides:

* routing: *get*, *match*
* metody pomocnicze: *content_for*
* layout kontrolera, layout aplikacji

Zrób to sam (kod jest poniżej):

* własne metody pomocnicze: *title*
* sensowniejszy routing: */pages/about* → */about*, */pages/welcome* → */welcome*

W implementacji metody *title* skorzystamy z metody *provide*.

Na każdej stronie wpisujemy jej tytuł w taki sposób:

    :::rhtml
    <% provide :title, 'About Us' %>

W layoucie aplikacji podmieniamy kod znacznika *title* na:

    :::rhtml
    <title>Moje strony | <%= content_for :title %></title>

I już możemy sprawdzić jak to działa.

A oto inna, bardziej solidna implementacja:

    :::ruby application_helper.rb
    def title(content)
      content_for(:title, content)
    end

    def page_title
      delimiter = "| "
      if content_for?(:title)
        "#{delimiter}#{content_for(:title)}"
      end
    end

Przy tej implementacji, w layoucie aplikacji podmieniamy kod znacznika *title* na:

    :::rhtml
    <title>Moje strony <%= page_title %></title>

Teraz na stronach, które *mają tytuł* wpisujemy:

    :::rhtml
    <% title 'About Us' %>

*Pytanie:* Na czym polega „solidność tej implementacji”?

W pliku *config/routes.rb* wygenerowany kod:

    :::ruby config/routes.rb
    get "pages/welcome"
    get "pages/about"

wymieniamy na:

    :::ruby config/routes.rb
    match "welcome", to: "pages#welcome"
    match "about", to: "pages#about"

Przy zmienionym routingu wykonanie polecenia `rake routes` daje:

    welcome  /welcome(.:format) pages#welcome
      about  /about(.:format)   pages#about

co oznacza, że te strony są dostępne z krótszych, niż poprzednio,
adresów */welcome* i */about*.


## Podsumowanie

Opcje używane przy generowaniu rusztowania aplikacji
zapisujemy w pliku  *~/.railsrc*:

    :::bash ~/.railsrc
    --skip-bundle
    --skip-test-unit

Zamiast ręcznej edycji pliku *Gemfile* oraz modyfikacji plików
konfiguracyjnych możemy użyć szablonu aplikacji rails,
który zrobi to za nas.
Wystarczy podać nazwę szablonu w poleceniu *rails new*:

    :::bash
    rails new xxx --template wbzyl-template.rb

Taki szablon łatwo napisać samemu, na przykład
{%= link_to "wbzyl-template.rb", "/app_templates/wbzyl-template.rb" %}
pokazuje jakie jest może być proste.


{%= image_tag "/images/dilbert-agile-programming.png", :alt => "[Agile Programming]" %}

# Fortunka krok po kroku

<!--
[Anything less than 16px is a costly mistake](http://www.smashingmagazine.com/2011/10/07/16-pixels-body-copy-anything-less-costly-mistake/) –
-->

Podobne aplikacje:

* [Proverb Hunter](http://proverbhunter.com/)
* …?

1\. Zaczynamy od wygenerowania rusztowania aplikacji i przejścia do
katalogu z wygenerowanym rusztowaniem:

    :::bash
    rails new my_fortune --template wbzyl-template-rails4.rb
    cd my_fortune

źródło {%= link_to "wbzyl-template-rails4.rb", "/doc/rails4/wbzyl-template-rails4.rb" %}
({%= link_to "kod", "/app_templates/wbzyl-template-rails4.rb" %}).

Teraz możemy skorzystać z generatora *bootstrap:partial*
(navbar, navbar-devise, carousel):

    :::bash
    rails generate bootstrap:partial navbar

Wygenerowany szablon częściowy dopisujemy
w elemencie *body* layoutu aplikacji:

    :::rhtml app/views/layouts/application.html.erb
    <%= render partial: 'shared/navbar' %>

Przy okazji ***poprawiamy wygenerowany layout***
(można usunąć prawą kolumnę i wstawić swoje linki).

Generujemy rusztowanie (*scaffold*) dla fortunek:

    :::bash
    rails generate scaffold fortune quotation:text source:string

Tworzymy bazę i generujemy w niej tabelkę *fortunes* –
krótko mówiąc **migrujemy**:

    rake db:create
    rake db:migrate

Zmieniamy routing i ustawiamy stronę startową aplikacji, dopisując
w pliku konfiguracyjnym *config/routes.rb*:

    :::ruby config/routes.rb
    Fortunka::Application.routes.draw do
      resources :fortunes
      root to: 'fortunes#index'

Powinniśmy jeszcze nadpisać wygenerowane szablony
szablonami korzystającymi z Bootstrapa:

    :::bash
    rails generate bootstrap:themed fortunes

*Uwaga:* Aby wykonać polecenie *rake* w trybie produkcyjnym
*poprzedzamy je napisem RAILS_ENV=production*, przykładowo:

    :::bash
    RAILS_ENV=production rake db:migrate
    RAILS_ENV=production rake db:seed

Teraz już mozna sprawdzić jak to wszystko działa, uruchamiając serwer *thin*:

    :::bash
    rails server -p 3000

i wchodząc na stronę:

    http://localhost:3000

2\. Zapełniamy bazę jakimiś danymi, dopisując do pliku *db/seeds.rb*:

    :::ruby db/seeds.rb
    Fortune.create! quotation: 'I hear and I forget. I see and I remember. I do and I understand.'
    Fortune.create! quotation: 'Everything has its beauty but not everyone sees it.'
    Fortune.create! quotation: 'It does not matter how slowly you go so long as you do not stop.'
    Fortune.create! quotation: 'Study the past if you would define the future.'

Powyższe fortunki umieszczamy w bazie, wykonujac na konsoli polecenie:

    :::bash
    rake db:seed  # load the seed data from db/seeds.rb

Powyższy kod „smells” (dlaczego?) i należy go poprawić.
Na przykład tak jak to zrobiono tutaj
{%= link_to "seeds.rb", "/database_seed/seeds-fortunes.rb" %}.

Jeśli kilka rekordów w bazie to za mało, to możemy do pliku
*db/seeds.rb* wkleić {%= link_to "taki kod", "/database_seed/seeds.rb" %}
i ponownie uruchomić powyższe polecenie.

3\. Aby poprawić nieco layout i wygląd aplikacji skorzystaliśmy
z gemu *twitter-bootstrap-rails* ułatwiającego użycie
frameworka [Twitter Bootstrap](http://twitter.github.com/bootstrap/)
w aplikacjach Rails.

Jak z niego korzystać opisano tutaj:

* [Twitter Bootstrap for Rails 3.1 Asset Pipeline](https://github.com/seyhunak/twitter-bootstrap-rails)
* [Twitter Bootstrap Basics](http://railscasts.com/episodes/328-twitter-bootstrap-basics?view=asciicast) –
  screencast
* [Customize Bootstrap](http://twitter.github.com/bootstrap/customize.html)
* [FontAwesome](http://fortawesome.github.com/Font-Awesome/) –
  the iconic font designed for use with Twitter Bootstrap

Sam framework jest napisany w Less:

* [{less}](http://lesscss.org/) – the dynamic stylesheet language

Przykładowy {%= link_to "layout aplikacji", "/bootstrap/application.html.erb" %}
korzystający z Twitter Bootstrap.

4\. Kilka propozycji zmian domyślnych ustawień.

Parametrów Bootstrapa:

    :::css app/assets/stylesheets/bootstrap_and_overrides.css.less
    @baseFontSize: 18px;
    @baseLineHeight: 24px;

    @navbarBackground: #8E001C;
    @navbarBackgroundHighlight: #8E001C;
    @navbarText: #FBF7E4;
    @navbarLinkColor: #FBF7E4;

    .navbar .brand { color: #E7E8D1; }

Szablonu formularza *SimpleForm*:

    :::rhtml _form.html.erb
    <%= f.input :quotation, :input_html => { :rows => "4", :class => "span6" } %>
    <%= f.input :source, :input_html => { :class => "span6" } %>

Na pasku *navbar* umieścimy kilka ikonek z fontu *FontAwesome*:

    :::rhtml app/views/shared/_navbar.html.erb
    <div class="container">
      <%= link_to icon("quote-left", "Fortunes"), root_path, class: "brand" %>
      <ul class="nav pull-right">
        <li><%= link_to icon("home", "Tao"), "http://tao.inf.ug.edu.pl/" %></li>
        <li><%= link_to icon("ambulance", "ASI"), "http://wbzyl.inf.ug.edu.pl/rails4/" %></li>
      </ul>
    </div>

Powyżej użyliśmy metody pomocniczej *icon*. Kod tej metody zapiszemy
w pliku *application_helper.rb*:

    :::ruby app/helpers/application_helper.rb
    module ApplicationHelper
      def icon(name, title="")
        raw "<i class='icon-#{name}'></i>#{title}"
      end
    end

Odstęp po ikonce ustawiamy w arkuszu *application.css*:

    :::css
    i[class^="icon-"] { padding-right: .5em; }

I już! Wersja 0.0 Fortunki jest gotowa.


## I co dalej?

1\. **Walidacja**, czyli sprawdzanie poprawności (zatwierdzanie)
danych wpisanych w formularzach. Przykład, dopisujemy w modelu:

    :::ruby app/models/fortune.rb
    validates :quotation, length: {
      minimum: 8,
      maximum: 128
    }
    validates :source, presence: true

Zobacz też samouczek
[Active Record Validations and Callbacks](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html).

2\. **Wirtualne Atrybuty.**  Przykład: cenę książki pamiętamy
w bazie w groszach, ale chcemy ją wypisywać i edytować w złotówkach.

Załóżmy taką schema:

    :::ruby schema.rb
    create_table "books", :force => true do |t|
      t.string   "author"
      t.string   "title"
      t.string   "isbn"
      t.integer  "price"
    end

Do modelu dopisujemy dwie metody („getter” i „setter”):

    :::ruby book.rb
    class Book < ActiveRecord::Base
      def price_pln
        price.to_d / 100 if price
      end
      def price_pln=(pln)
        self.price = pln.to_d * 100 if pln.present?
      end
    end

Zamieniamy we wszystkich widokach *price* na *price_pln*, przykładowo:

    :::rhtml _form.html.erb
    <%= f.input :price_pln %>

Walidacja wirtualnych atrybutów,
zobacz [Virtual Attributes](http://railscasts.com/episodes/16-virtual-attributes-revised?view=asciicast).

4\. **Tagging: (tylko dla Rails 3)**

* Gem [acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)
* [Tagging](http://railscasts.com/episodes/382-tagging) – \#382 RailsCasts

Przykład do przetestowania na konsoli:

    :::ruby
    book = Book.find 1
    book.tag_list

    book.tag_list = "awesome, slick, hefty"
    book.save
    book.tag_list

    Book.tagged_with "slick"
    Book.tagged_with ["slick", "hefty"]

Dodajemy listę tagów do formularza:

    :::rhtml _form.html.erb
    <%= f.input :tag_list, :label => "Tags (separated by spaces)" %>

Dopisujemy w modelu:

    :::ruby
    acts_as_taggable_on :tags

a na końcu pliku *application.rb* dopisujemy:

    :::ruby config/application.rb
    ActsAsTaggableOn.delimiter = ' ' # use space as delimiter

Pozostałe rzeczy robimy tak jak to przedstawiono w screencaście.


## Fortunka – jeszcze dwie uwagi

1\. Potrzebne nam gemy wyszukujemy na [The Ruby Toolbox](https://www.ruby-toolbox.com/).
Tam też sprawdzamy, czy gem jest aktywnie rozwijany,
czy będzie działał z innymi gemami i wersjami Ruby, itp.

2\. Modyfikujemy domyślne ustawienia konsoli Ruby
(i równocześnie konsoli Rails):

    :::ruby ~/.irbrc
    require 'irb/completion'
    require 'irb/ext/save-history'

    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"

    IRB.conf[:PROMPT_MODE] = :SIMPLE

    # remove the SQL logging
    # ActiveRecord::Base.logger.level = 1 if defined? ActiveRecord::Base

    def y(obj)
      puts obj.to_yaml
    end

    # break out of the Bundler jail
    # from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
    if defined? Bundler
      Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
      Gem::Specification.reset
      load 'rubygems/custom_require.rb'
    end

    if defined? Rails
      begin
        require 'hirb'
        Hirb.enable
      rescue LoadError
      end
    end


<!--
  albo wpsiujemy w pliku do *rubygems/custom_require.rb* (Ruby 2.0).
-->


## Co to jest REST?

<blockquote>
{%= image_tag "/images/hfrails_cover.png", :alt => "[Head First Rails]" %}
<p>
  If you use REST, your teeth will be brighter,
  your life will be happier,
  and all will be goodnes and sunshine with the world.
</p>
<p class="author">– David Griffiths</p>
</blockquote>

Zaczynamy od lektury artykułu:

* [How REST replaced SOAP on the Web: What it means to you](http://www.infoq.com/articles/rest-soap).

Krótka historia World Wide Web:

* 1990–91 — Tim Berners-Lee wynalazł i zaimplementował:
  URI, HTTP, HTML, pierwszy serwer WWW, pierwszą przeglądarkę
  („Nexus”), edytor WYSIWYG dla HTML.
* 1993 — Roy Fielding (ten od Apacha) zdefiniował
  *Web’s architectural style WWW*: client-serwer, cache,
  stateless, uniform interface (resources), layered system, code-on-demand
* 2000 — po pokonaniu problemów ze **skalowalnością** WWW,
  Roy Fielding użył nazwy **REST** dla *architectural style* WWW.

Kilka uwag o terminologii:

* The REST architectural style is commonly applied to the design of
  APIs for modern web services.
* Having a REST API makes a web service “RESTful.”
* A REST API consists of an assembly of interlinked resources.

W aplikacjach Rails operacje CRUD wykonujemy korzystając z REST API:

1. Dane są zasobami (ang. *resources*). Fortunka to zbiór
   cytatów, dlatego cytaty są *resources*.
2. Każdy zasób ma swój unikalny URI.

Polecenie:

    :::bash
    rake routes

wypisuje szczegóły REST API aplikacji.

<blockquote>
<p>
  While the scaffold generator is great for prototyping, it’s not so great for
  delivering simple code that is well-tested and works precisely the way we would
  like it to.
</p>
<p class="author">— Y. Katz, R. A. Bigg</p>
</blockquote>

### Generator scaffold (Rails 4)

Rusztowanie dla zasobu (ang. *resource*) *fortune* zostało wygenerowane
za pomocą polecenia:

    :::bash
    rails generate scaffold fortune quotation:text source:string

Stosujemy się do konwencji nazywania frameworka Rails.
Używamy liczby pojedynczej (generujemy zasób dla modelu).

Oto utworzony przez generator kontroler:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      before_action :set_fortune, only: [:show, :edit, :update, :destroy]
      # GET /fortunes
      # GET /fortunes.json
      def index
        @fortunes = Fortune.all
      end
      # GET /fortunes/1
      # GET /fortunes/1.json
      def show
      end
      # GET /fortunes/new
      def new
        @fortune = Fortune.new
      end
      # GET /fortunes/1/edit
      def edit
      end
      # POST /fortunes
      # POST /fortunes.json
      def create
        @fortune = Fortune.new(fortune_params)

        respond_to do |format|
          if @fortune.save
            format.html { redirect_to @fortune, notice: 'Fortune was successfully created.' }
            format.json { render action: 'show', status: :created, location: @fortune }
          else
            format.html { render action: 'new' }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # PATCH/PUT /fortunes/1
      # PATCH/PUT /fortunes/1.json
      def update
        respond_to do |format|
          if @fortune.update(fortune_params)
            format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: 'edit' }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # DELETE /fortunes/1
      # DELETE /fortunes/1.json
      def destroy
        @fortune.destroy
        respond_to do |format|
          format.html { redirect_to fortunes_url }
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_fortune
          @fortune = Fortune.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def fortune_params
          params.require(:fortune).permit(:quotation, :source)
        end
    end


### Rendering response

…czyli renderowaniem odpowiedzi zajmują się takie kawałki kodu:

    :::ruby
    respond_to do |format|
      format.html  { redirect_to fortunes_url }
      format.json  { head :no_content }
      format.js                                  # use destroy.js.erb template
    end

What that says is:

1. If the client wants HTML in response to this
action, use the default template for this action
(for *index* it is *index.html.erb*).

2. If the client wants JSON, return response 204<br>
(`gem install cheat; cheat http`).

3. If the client wants JS, use the default template
for this action (for *destroy* it is *destroy.js.html*).

Rails determines the desired response format from
the HTTP **Accept header** submitted by the client.

Klientem może być przeglądarka, ale może też być
inny program, na przykład *curl*:

    :::bash
    curl -I -X GET -H 'Accept: application/json' http://localhost:3000/fortunes/1

W ostatnich wersjach Rails
(zob. [Critical Ruby On Rails Issue Threatens 240,000 Websites](http://www.informationweek.com/security/vulnerabilities/critical-ruby-on-rails-issue-threatens-2/240145891))
wymagane jest przesłanie tokena CSRF.

Poniższe polecenia wykonają się bez błędów jeśli usuniemy
z layoutu aplikacji ten wiersz:

    :::rhtml app/views/layouts/application.html.erb
    <%= csrf_meta_tags %>

Teraz polecenia z *curl* powinny zadziałać:

    curl    -X DELETE -H 'Accept: application/json' http://localhost:3000/fortunes/1
    curl -I -X DELETE http://localhost:3000/fortunes/1.json
    curl    -X DELETE http://localhost:3000/fortunes/1
    curl -v -X POST -H 'Content-Type: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes.json
    curl    -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes

Jeśli pozostawimy bez zmian layout, to rekordy można usuwać
na konsoli przeglądarki, na przykład tak usuwamy rekord z *id=6*:

    :::js
    $.ajax({
      url: 'http://localhost:3000/fortunes/6.json',
      type: 'DELETE',
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    })

Powyżej korzystamy z funkcji *jQuery.ajax*. Zobacz też:

Korzystanie z curla jest bardziej skomplikowane:

    :::bash
    # pobieramy cookie do pliku *cookie* oraz filtrujemy CSRF-Token
    curl http://localhost:3000/fortunes --cookie-jar cookie  | grep csrf
    # kopiujemy csrf-token do polecenia poniżej; zakładamy, że fortunka 12 istnieje
    curl -X DELETE -H 'X-CSRF-Token: 0Dm3mqmcWcajzHkSAzqczDnLllmhlVVaNYB5Fo1tYA0=' --cookie cookie localhost:3000/fortunes/10.json
    # nie było przekierowania, możemy ponownie użyć ten sam CSRF-Token
    curl -X DELETE -H 'X-CSRF-Token: 0Dm3mqmcWcajzHkSAzqczDnLllmhlVVaNYB5Fo1tYA0=' --cookie cookie localhost:3000/fortunes/11.json

* [Understand Rails Authenticity Token](http://stackoverflow.com/questions/941594/understand-rails-authenticity-token)
* [cURLing with Rails’ authenticity_token](http://robots.thoughtbot.com/post/3035393350/curling-with-rails-authenticity-token)
* [WARNING: Can’t verify CSRF token authenticity Rails](http://stackoverflow.com/questions/7203304/warning-cant-verify-csrf-token-authenticity-rails)

Linki do dokumentacji:

* [respond_to](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_to)
* [respond_with](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_with),
  [ActionController::Responder](http://api.rubyonrails.org/classes/ActionController/Responder.html)


### Przykład respond_to CSV

Dopisujemy w pliku *application.rb*:

    :::ruby config/application.rb
    require File.expand_path('../boot', __FILE__)

    require 'csv'        #<= NEW!
    require 'rails/all'

W kodzie modelu *Fortune* dodajemy metodę *to_csv*:

    :::ruby app/models/fortune.rb
    def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |fortune|
          csv << fortune.attributes.values_at(*column_names)
        end
      end
    end

*Uwaga:* W metodzie *to_csv* możemy podać nazwy kolumn, na przykład:

    :::ruby
    def self.to_csv
      CSV.generate do |csv|
        csv << ["last_name", "first_name"]
        all.each do |list|
          csv << list.attributes.values_at("last_name", "first_name")
        end
      end
    end

Sprawdzamy jak to działa:

    :::bash
    curl http://localhost:3000/fortunes.csv

Zobacz też:

* gem [axlsx](https://github.com/randym/axlsx) –
  xlsx generation with charts, images, automated column width,
  customizable styles and full schema validation
* [eksport do arkusza kalkulacyjnego](http://railscasts.com/episodes/362-exporting-csv-and-excel).


### CSV via szablon *index.csv.ruby*

Na początek utworzymy plik *index.csv.ruby* o takiej zawartości:

    :::ruby app/views/lists/index.csv.ruby
    "hello CSV world"

I sprawdzamy czy to działa:

    :::bash
    curl localhost:3000/fortunes.csv

Jeśli otworzy się arkusz kalkulacyjny w którym jest wpisane `hello world`
to będzie oznaczać że kod zadziałał.

Teraz podmieniamy zawartość pliku *index.csv.ruby* na:

    :::ruby
    response.headers["Content-Disposition"] = 'attachment; filename="fortunes.csv"'

    CSV.generate do |csv|
      csv << ["id", "quotation", "source"]
      @fortunes.each do |fortune|
        csv << [
          fortune.id,
          fortune.quotation,
          fortune.source
        ]
      end
    end

I jeszcze raz sprawdzamy czy to działa.

*Uwaga:* W aplikacjach Rails 3 wymagana jest inicjalizacja:

    :::ruby config/initializers/ruby_template_handler.rb
    ActionView::Template.register_template_handler(:ruby, :source.to_proc)

<!--

W kodzie kontrolera w metodzie *index* w bloku *respond_to*:

    :::ruby
    respond_to do |format|
      format.html
      format.json
      format.csv { send_data @fortunes.to_csv }
    end

    CSV.generate do |csv|
      csv << ["nazwisko", "imię", "login", "repo", "link"]
      @lists.each do |list|
        login, name = list.repo.strip.sub(/^https:\/\/github.com\//, "").split("/", 2)
        csv << [
          list.last_name,
          list.first_name,
          login,
          name
          # list_url(list) # możemy użyć metody pomocniczej
        ]
      end
    end

Oczywiście w powyższym kodzie wpisujemy dane modelu z naszej aplikacji.
Powyżej użyłem danych dla fikcyjnego modelu *List*.

-->


## Markdown via Ruby Template Handler

Zdefiniujemy swój program obsługi plików w formacie Markdown.
Powiążemy go z rozszerzeniami *.md* i *.markdown*.
Oznacza to, na przykład, że **zamiast** widoku *show.html.erb*
będzie można użyć widoku *show.html.md*

Program obsługi zaimplementujemy tak, aby w widokach można było użyć
wstawek ERB.

W kodzie skorzystamy z gemu *redcarpet*:

    :::ruby Gemfile
    gem "redcarpet"

Przykładowa implementacja:

    :::ruby config/initializers/markdown_template_handler.rb
    class MarkdownTemplateHandler
      def self.call(template)
        erb = ActionView::Template.registered_template_handler(:erb)
        source = erb.call(template)
        <<-SOURCE
        renderer = Redcarpet::Render::HTML.new
        options = { fenced_code_blocks: true }
        Redcarpet::Markdown.new(renderer, options).render(begin;#{source};end)
        SOURCE
      end
    end
    ActionView::Template.register_template_handler(:md, :markdown, MarkdownTemplateHandler)

Zob. [RailsCasts \#379](http://railscasts.com/episodes/379-template-handlers).

Teraz po usunięciu szablonu *show.html.erb*:

    :::bash
    rm app/views/fortunes/show.html.erb

i utworzeniu szablonu *show.html.md*, na przykład:

    :::rhtml app/views/fortunes/show.html.md
    <%- model_class = Fortune -%>
    # <%=t '.title', :default => model_class.model_name.human %>

    <%= @fortune.quotation %>

    *<%= @fortune.source %>*

    [<%=t '.back', :default => t("helpers.links.back") %>](<%= fortunes_path %>) |
    [<%=t '.edit', :default => t("helpers.links.edit") %>](<%= edit_fortune_path(@fortune) %>) |
    <%= link_to t('.destroy', default: t("helpers.links.destroy")), fortune_path(@fortune),
      method: 'delete',
      data: {
        confirm: t('.confirm',
        default: t("helpers.links.confirm",
        default: 'Are you sure?'))
      },
      class: 'btn btn-danger' %>

zostanie on użyty zamiast usuniętego szablonu *.html.erb*.

Zobacz też José Valim,
[Multipart templates with Markerb](http://blog.plataformatec.com.br/2011/06/multipart-templates-with-markerb/).
Nazwa gemu [markerb](https://github.com/plataformatec/markerb) to skrót na
„multipart templates made easy with Markdown + ERb”.

<!--

Zobacz też {%= link_to "PDF Renderer", "/pdf-renderer" %}.

### Migracje

Aby utworzyć bazę danych o nazwie podanej w pliku
*config/database.yml* oraz tabelę zdefiniowaną w pliku
<i>db/migrate/2011*****_create_fortunes.rb</i>
wykonujemy polecenie:

    rake db:migrate

Generator dopisał do pliku z routingiem *config/routes.rb*:

    resources :fortunes

Porównanie kodu kontrolera
{%= link_to "users_controller.rb", "/rails31/scaffold/users_controller.rb" %}
wygenerowanego za pomocą polecenia:

    rails generate scaffold User login:string email:string

z diagramem przedstawionym na poniższym obrazku
([źródło](http://www.railstutorial.org/images/figures/mvc_detailed-full.png)):

{%= image_tag "/images/mvc_detailed.png", :alt => "[MVC w Rails]" %}<br>

pomaga „zobaczyć” jak RESTful router tłumaczy żądania na kod
kontrolera.

Zasoby REST mogą mieć różne reprezentacje, na przykład HTML, XML,
JSON, CSV, PDF, itd.

Wygenerowany kontroler obsługuje tylko dwie reprezentacje: HTML i JSON.
Ale kiedy będziemy potrzebować dodatkowej reprezentacji danych,
to możemy zacząć od modyfikacji powyższego kodu.

Po modyfikacji otrzymamy kod który, niestety, nie będzie taki DRY jak mógłoby być.
Prawdziwie DRY kod otrzymamy korzystając z generatorów
*responders:install* oraz *responders_controller*
(zawiera je gem *responders*).
Dlaczego? Przyjrzymy się temu na wykładzie „Fortunka v1.0”.


Jeśli nie będziemy korzystać z formatu JSON, to powinniśmy usunąć nieużywany kod
z kontrolera. Tak będzie wyglądał odchudzony *UsersController*:

    :::ruby
    class UsersController < ApplicationController
      # GET /users
      def index
        @users = User.all
      end
      # GET /users/1
      def show
        @user = User.find(params[:id])
      end
      # GET /users/new
      def new
        @user = User.new
      end
      # GET /users/1/edit
      def edit
        @user = User.find(params[:id])
      end
      # POST /users
      def create
        @user = User.new(params[:user])
        if @user.save
          redirect_to @user, notice: 'User was successfully created.'
        else
          render action: "new"
        end
      end
      # PUT /users/1
      def update
        @user = User.find(params[:id])
        if @user.update_attributes(params[:user])
          redirect_to @user, notice: 'User was successfully updated.'
        else
          render action: "edit"
        end
      end
      # DELETE /users/1
      def destroy
        @user = User.find(params[:id])
        @user.destroy
        redirect_to users_url
      end
    end

Taka edytowanie kodu dla każdego wygenerowanego kontrolera
byłoby męczące. Możemy tego uniknąć wstawiając do katalogu:

    lib/templates/rails/scaffold_controller/

swój szablon {%= link_to "controler.rb", "/rails31/scaffold/controller.erb" %}
({%= link_to "źródło", "/doc/rails31/scaffold/controller.rb" %}).

Ale zamiast edytować kod kontrolera, powinniśmy skorzystać
z metod *respond_with* i *respond_to*.

-->


## Zapisywanie przykładowych danych w bazie

Tutaj przećwiczymy proste zastosowanie gemów *Faker*
i *Populator* (o ile już działa z Rails 4).

Zaczynamy od wygenerowania rusztowania dla zasobu Friend:

    :::bash
    rails g scaffold friend last_name:string first_name:string phone:string motto:text
    rake db:migrate

i od „monkey patching” kodu gemu *Faker*:

    :::ruby faker_pl.rb
    module Faker
      class PhoneNumber
        SIMPLE_FORMATS  = ['+48 58-###-###-###', '(58) ### ### ###']
        MOBILE_FORMATS  = ['(+48) ###-###-###', '###-###-###']

        def self.pl_phone_number(kind = :simple)
          Faker::Base.numerify const_get("#{kind.to_s.upcase}_FORMATS").sample
        end
      end
    end

(zob. też [ten gist](https://gist.github.com/165751)).

Sprawdzamy jak to działa na konsoli:

    :::bash
    irb

gdzie wpisujemy:

    :::ruby
    require 'faker'
    require './faker_pl'
    Faker::PhoneNumber.pl_phone_number :mobile
    Faker::Name.first_name
    Faker::Name.last_name

Jeśli wszystko działa tak jak powinno, to w pliku *db/seeds.rb*
możemy wpisać:

    :::ruby db/seeds.rb
    require Rails.root.join('db', 'faker_pl')

    Friend.populate(100..200) do |friend|
      friend.first_name = Faker::Name.first_name
      friend.last_name = Faker::Name.last_name
      friend.phone = Faker::PhoneNumber.pl_phone_number :mobile
      friend.motto = Populator.sentences(1..2)
    end

Teraz wykonujemy:

    :::bash
    rake db:seed

zapełniając tabelę *friends* danymi testowymi.

Chociaż przydałoby się dodać do powyższego kodu coś w stylu:

    :::ruby
    Friend.populate(1000..5000) do |friend|
      # passing array of values will randomly select one
      friend.motto = ["akapity", "z kilku", "fajnych książek"]
    end


## Uruchamiamy serwer WWW

<blockquote>
 <p>
  {%= image_tag "/images/nifty-secretary.jpg", :alt => "[nifty secretary]" %}
 </p>
 <p class="author">źródło: <a href="http://e-girlfriday.com/blog/">Retro Graphics, WordPress Site</a></p>
</blockquote>

Każdy serwer ma swoje mocne i słabe strony.

[Thin](http://code.macournoyer.com/thin/)
is a Ruby web server that glues together 3 of the best Ruby libraries
in web history:

* the *Mongrel* parser, the root of *Mongrel* speed and security
* *Event Machine*, a network I/O library with extremely high scalability,
  performance and stability
* *Rack*, a minimal interface between webservers and Ruby frameworks

[Unicorn](http://unicorn.bogomips.org/)
is an HTTP server for Rack applications designed to only serve
fast clients on low-latency, high-bandwidth connections and take
advantage of features in Unix/Unix-like kernels. Slow clients should
only be served by placing a reverse proxy capable of fully buffering
both the the request and response in between Unicorn and slow
clients.

[Rainbows!](http://rainbows.rubyforge.org/)
is an HTTP server for sleepy Rack applications. It is based
on Unicorn, but designed to handle applications that expect long
request/response times and/or slow clients.
