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


# Fortunka krok po kroku

1\. Zaczynamy od wygenerowania rusztowania aplikacji i przejścia do
katalogu z wygenerowanym rusztowaniem:

    rails new fortunka
    cd fortunka

Dobrze jest od razu zmienić rozmiar fontu na co najmniej
[16 pikseli](http://www.smashingmagazine.com/2011/10/07/16-pixels-body-copy-anything-less-costly-mistake/) –
„anything less is a costly mistake”.

2\. Usuwamy domyślną stronę aplikacji:

    rm public/index.html

3\. Do pliku *Gemfile* dopisujemy gemy z których będziemy korzystać:

    :::ruby Gemfile
    # Łatwiejsze w użyciu formularze
    gem 'simple_form'
    # albo
    # gem 'formtastic'

    # Alternatywne dla WEBricka serwery WWW
    gem thin
    gem unicorn
    gem rainbows

    # Dopisujemy brakujące gemy (niedopatrzenie autorów Rails 3.1.1)
    gem 'sass'
    gem 'coffee-script'

    group :development do
      # Ładniejsze wypisywanie rekordów na konsoli
      # (zob. konfiguracja irb w ~/.irbrc)
      gem 'wirble'
      gem 'hirb'
      # Bezproblemowe zapełnianie bazy danymi testowymi
      gem 'faker'
      gem 'populator'
    end

4\. Instalujemy gemy lokalnie:

    bundle install --binstubs --path=$HOME/.gems

Albo globalnie jeśli mamy uprawnienia do zapisu w odpowiednich katalogach.

*Uwaga:* Poniższe polecenie wykonuje się dużo szybciej:

    bundle install --local --binstubs --path=$HOME/.gems

(Oczywiście, o ile wymagane gemy są już zainstalowane w systemie.)

Niektóre gemy, do poprawnej instalacji wymagają *post-install*,
na przykład:

    rails generate simple_form:install  # dla simple_form
    rails generate formtastic:install   # dla formtastic

5\. Generujemy rusztowanie (*scaffold*) dla fortunek:

    rails g scaffold fortune quotation:text source:string

6\. Tworzymy bazę i w nowej bazie umieszczamy tabelkę *fortunes* –
krótko mówiąc **migrujemy**:

    rake db:create  # Create the database from config/database.yml for the current Rails.env
    rake db:migrate # Migrate the database (options: VERSION=x, VERBOSE=false)

7\. Ustawiamy stronę startową (główną?) aplikacji, dopisując, przed
kończącym *end*, w pliku konfiguracyjnym *config/routes.rb*:

    :::ruby config/routes.rb
    root :to => fortunes#index'

8\. Zapełniamy bazę danymi testowymi, dopisując do pliku *db/seeds.rb*:

    :::ruby db/seeds.rb
    Fortune.create :quotation => 'I hear and I forget. I see and I remember. I do and I understand.'
    Fortune.create :quotation => 'Everything has its beauty but not everyone sees it.'
    Fortune.create :quotation => 'It does not matter how slowly you go so long as you do not stop.'
    Fortune.create :quotation => 'Study the past if you would define the future.'

Następnie umieszczamy fortunki w bazie, wykonujac w terminalu
polecenie:

    rake db:seed  # Load the seed data from db/seeds.rb

Jeśli kilka rekordów w bazie to za mało, to możemy do pliku
*db/seeds.rb* wkleić {%= link_to "taki kod", "/database_seed/seeds.rb" %}.

8\. Teraz możemy już uruchomić domyślny serwer Rails:

     rails s -p 3000

Albo jeden z alternatywnych serwerów:

     bin/thin -p 3000 start
     bin/unicorn_rails -p 3000
     bin/rainbows -p 3000       # nie polecam w trybie development



## Krok 3


Konsola Rails:

    :::ruby ~/.irbrc
    IRB.conf[:PROMPT_MODE] = :SIMPLE

    require 'wirble'
    require 'hirb'

    Wirble.init
    Wirble.colorize
    Hirb.enable

    if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
      require 'logger'
      RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
    end

[Rainbows!](http://rainbows.rubyforge.org/)
is an HTTP server for sleepy Rack applications. It is based
on Unicorn, but designed to handle applications that expect long
request/response times and/or slow clients.

For Rack applications not heavily bound by slow external network
dependencies, consider Unicorn instead as it simpler and easier to
debug.

[Unicorn](http://unicorn.bogomips.org/)
is an HTTP server for Rack applications designed to only serve
fast clients on low-latency, high-bandwidth connections and take
advantage of features in Unix/Unix-like kernels. Slow clients should
only be served by placing a reverse proxy capable of fully buffering
both the the request and response in between Unicorn and slow
clients.


## Krok 4.

Opcji `--path` używamy tylko raz. Następnym razem uruchamiamy program
*bundle* bez tej opcji.  Możemy też pominąć argument *install*.


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

## Generator scaffold

Generujemy rusztowanie dla zasobu (ang. *resource*) *fortune*:

    rails generate scaffold fortune quotation:text

Stosujemy się do konwencji frameworka Rails.
Używamy liczby pojedynczej (generujemy zasób dla modelu).

Co wygenerował generator?

Aby utworzyć bazę danych o nazwie podanej w pliku
*config/database.yml* oraz tabelę zdefiniowaną w pliku
<i>db/migrate/2011*****_create_fortunes.rb</i>
wykonujemy polecenie:

    rake db:migrate

Generator dopisał do pliku z routingiem *config/routes.rb*:

    resources :fortunes

i być może ustawić root page.

Aby obejrzeć routing aplikacji wykonujemy polecenie:

    rake routes

Jak należy rozumieć, to co zostało wypisane przez to polecenie?

Uruchamiamy aplikację:

    rails s thin -p 16000

i sprawdzamy jak działa routing.

Wklejone poniżej obrazek oraz kod wygenerowanego kontrolera, pozwala
„zobaczyć” jak działa RESTful routing i kontroler.

{%= image_tag "/images/mvc_detailed.png", :alt => "[MVC w Rails]" %}<br>
Rails REST na przykładzie zasobu *users* ([źródło](http://www.railstutorial.org/images/figures/mvc_detailed-full.png))

Rails resource scaffold:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      # GET /fortunes
      # GET /fortunes.xml
      def index
        @fortunes = Fortune.all

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :xml => @fortunes }
        end
      end
      # GET /fortunes/1
      # GET /fortunes/1.xml
      def show
        @fortune = Fortune.find(params[:id])

        respond_to do |format|
          format.html # show.html.erb
          format.xml  { render :xml => @fortune }
        end
      end
      # GET /fortunes/new
      # GET /fortunes/new.xml
      def new
        @fortune = Fortune.new

        respond_to do |format|
          format.html # new.html.erb
          format.xml  { render :xml => @fortune }
        end
      end
      # GET /fortunes/1/edit
      def edit
        @fortune = Fortune.find(params[:id])
      end
      # POST /fortunes
      # POST /fortunes.xml
      def create
        @fortune = Fortune.new(params[:fortune])

        respond_to do |format|
          if @fortune.save
            format.html { redirect_to(@fortune, :notice => 'Fortune was successfully created.') }
            format.xml  { render :xml => @fortune, :status => :created, :location => @fortune }
          else
            format.html { render :action => "new" }
            format.xml  { render :xml => @fortune.errors, :status => :unprocessable_entity }
          end
        end
      end
      # PUT /fortunes/1
      # PUT /fortunes/1.xml
      def update
        @fortune = Fortune.find(params[:id])

        respond_to do |format|
          if @fortune.update_attributes(params[:fortune])
            format.html { redirect_to(@fortune, :notice => 'Fortune was successfully updated.') }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @fortune.errors, :status => :unprocessable_entity }
          end
        end
      end
      # DELETE /fortunes/1
      # DELETE /fortunes/1.xml
      def destroy
        @fortune = Fortune.find(params[:id])
        @fortune.destroy

        respond_to do |format|
          format.html { redirect_to(fortunes_url) }
          format.xml  { head :ok }
        end
      end
    end


Zasoby REST mogą mieć różne reprezentacje, na przykład HTML, XML,
JSON, CSV, PDF, itd.

Wygenerowane metody umożliwiają renderowanie tylko dwóch
reprezentacji: HTML i XML.
Ale kiedy będziemy potrzebować dodatkowej reprezentacji danych,
to możemy zacząć od modyfikacji powyższego kodu.

Po modyfikacji otrzymamy kod który, niestety, nie będzie taki DRY jak mógłoby być.
Prawdziwie DRY kod otrzymamy korzystając z generatorów
*responders:install* oraz *responders_controller*
(zawiera je gem *responders*).

Dlaczego? Przyjrzymy się temu na wykładzie „Fortunka v1.0”.


<blockquote>
 <p>
  {%= image_tag "/images/nifty-secretary.jpg", :alt => "[nifty secretary]" %}
 </p>
 <p class="author">źródło: <a href="http://e-girlfriday.com/blog/">Retro Graphics, WordPress Site</a></p>
</blockquote>


*Uwaga:* Do *Gemfile* został dopisany nowy gem, dlatego musimy go zainstalować:

    bundle install

A tak wygląda wygenerowany z nifty-scaffold kontroller, siedem metod i mniej kodu,
ale czy działa w Rails 3.1.1?

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      def index
        @fortunes = Fortune.all
      end
      def show
        @fortune = Fortune.find(params[:id])
      end
      def new
        @fortune = Fortune.new
      end
      def create
        @fortune = Fortune.new(params[:fortune])
        if @fortune.save
          redirect_to @fortune, :notice => "Successfully created fortune."
        else
          render :action => 'new'
        end
      end
      def edit
        @fortune = Fortune.find(params[:id])
      end
      def update
        @fortune = Fortune.find(params[:id])
        if @fortune.update_attributes(params[:fortune])
          redirect_to @fortune, :notice  => "Successfully updated fortune."
        else
          render :action => 'edit'
        end
      end
      def destroy
        @fortune = Fortune.find(params[:id])
        @fortune.destroy
        redirect_to fortunes_url, :notice => "Successfully destroyed fortune."
      end
    end

Sprawdzamy jak działa aplikacja z nowym kontrolerem:

    rails s thin -p 3000

Wchodzimy na stronę:

    http://localhost:3000/fortunes

Modyfikujemy plik *routes.rb*:

    :::ruby config/routes.rb
    Fortunka::Application.routes.draw do
      resources :fortunes
      # You can have the root of your site routed with "root"
      # just remember to delete public/index.html.
      root :to => "fortunes#index"
    end

Po zrestartowaniu serwera WWW i po wejściu na stronę:

    http://localhost:16000/

powinniśmy zobaczyć wyrenderowaną stronę:

    http://localhost:16000/fortunes


# Zapełnianie bazy danymi testowymi (7.11.2011)

Na tym etapie pisania aplikacji, powinniśmy umieścić w bazie trochę
fortunek. Łatwiej nam będzie modyfikować **niepuste** widoki.

Przykładowe fortunki możemy sami wpisać w pliku *db/seeds.rb*,
a następnie zapisać w bazie za pomocą:

    rake db:seed

Ale jeśli wystarczy nam zapełnienie bazy danymi testowymi,
możemy skorzystać z gemów: *faker* i *populator*.
Po dopisaniu ich w pliku *Gemfile* w sekcji **development**:

    :::ruby Gemfile
    group :development do
      gem 'responders'
      gem 'nifty-generators'
      gem 'wirble'
      gem 'hirb'
      gem 'faker'
      gem 'populator'
    end

i po zainstalowaniu:

    bundle

zaglądamy na te strony:

* [faker](http://faker.rubyforge.org/)
* [populator]()

szukając przykładów użycia.

Po tej lekturze przećwiczymy coś prostego, na przykład:

    rails g scaffold friend last_name:string first_name:string phone:string motto:text
    rake db:migrate

Nieco „monkey patching” kodu gemu Faker:

    :::ruby faker_pl.rb
    module Faker
      class PhoneNumber
        SIMPLE_FORMATS  = ['+48 58-###-###-###', '(58) ### ### ###']
        MOBILE_FORMATS  = ['(+48) ###-###-###', '###-###-###']

        def self.pl_phone_number(kind = :simple)
          Faker::Base.numerify const_get("#{kind.to_s.upcase}_FORMATS").rand
        end
      end
    end

(zob. też [ten gist](https://gist.github.com/165751)).

Przyszła wreszcie pora na wprawki konsolowe:

    bundle exec irb

gdzie piszemy:

    :::ruby
    require 'faker'
    require './faker_pl'
    Faker::PhoneNumber.pl_phone_number :mobile
    Faker::Name.first_name
    Faker::Name.last_name

Jeśli wszystko działa tak jak powinno, to w pliku *db/seeds.rb*
wpisujemy:

    :::ruby db/seeds.rb
    require Rails.root.join('db', 'faker_pl')

    Friend.populate(100..200) do |friend|
      friend.first_name = Faker::Name.first_name
      friend.last_name = Faker::Name.last_name
      friend.phone = Faker::PhoneNumber.pl_phone_number :mobile
      friend.motto = Populator.sentences(1..2)
    end

i wykonujemy:

    rake db:seed

Teraz z zapełniem Fortunki danymi testowymi nie powinno być problemu.
Chociaż przydałoby się zmodyfikować ten przykład z dokumentacji
gemu Populator:

    :::ruby
    Friend.populate(1000..5000) do |friend|
      # passing array of values will randomly select one
      friend.motto = ["akapity", "z kilku", "fajnych książek"]
    end



# Poprawiamy wygenerowane szablony

Przechodzimy do katalogu *app/views/fortunes* i edytujemy pliki,
kolejno według listy:

* *index.html.erb*
* *show.html.erb*
* *_form.html.erb*
* *new.html.erb*
* *edit.html.erb*
