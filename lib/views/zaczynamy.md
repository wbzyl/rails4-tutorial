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

Podobne aplikacje:

* [Proverb Hunter](http://proverbhunter.com/)
* …?

1\. Zaczynamy od wygenerowania rusztowania aplikacji i przejścia do
katalogu z wygenerowanym rusztowaniem:

    :::bash
    rails new fortunka --skip-bundle
    cd fortunka

Dobrze jest od razu zmienić rozmiar fontu na
[co najmniej 16 pikseli](http://www.smashingmagazine.com/2011/10/07/16-pixels-body-copy-anything-less-costly-mistake/) –
„anything less is a costly mistake”.

2\. Usuwamy domyślną stronę aplikacji:

    :::bash
    rm public/index.html

3\. Do pliku *Gemfile* dopisujemy gemy z których będziemy korzystać:

    :::ruby Gemfile
    # Łatwiejsze w użyciu formularze
    gem 'formtastic'
    # albo
    # gem 'simple_form'

    # Alternatywne dla WEBricka serwery WWW
    # gem 'thin'
    # gem 'unicorn'
    # gem 'rainbows'

    # Dopisujemy brakujące gemy (niedopatrzenie autorów Rails 3.1.3)
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

    :::bash
    bundle install --binstubs --path=$HOME/.gems

O ile mamy uprawnienia do zapisu w odpowiednich katalogach,
to możemy zainstalować gemy globalnie (niezalecane, dlaczego?):

    :::bash
    bundle install --binstubs

*Uwaga:* Jeśli gemy wpisane do *Gemfile* (oraz gemy od nich zależne)
mamy zainstalowane w systemie, to to polecenie wykona się dużo szybciej:

    :::bash
    bundle install --local --binstubs --path=$HOME/.gems

Niektóre gemy, wymagają procedury *post-install*.
Przykładowo, dla gemu *Formtastic* wykonujemy polecenie:

    :::bash
    bin/rails generate formtastic:install
      create  config/initializers/formtastic.rb
      create  lib/templates/erb/scaffold/_form.html.erb

oraz powinniśmy dopisać arkusz CSS tego gemu do pliku *application.css*:

    :::css app/assets/stylesheets/application.css
    *= require formtastic
    *= require_self
    *= require_tree .

a dla *Simple Form* – polecenie:

    bin/rails generate simple_form:install

5\. Generujemy rusztowanie (*scaffold*) dla fortunek:

    :::bash
    bin/rails g scaffold fortune quotation:text source:string

6\. Tworzymy bazę i w nowej bazie umieszczamy tabelkę *fortunes* –
krótko mówiąc **migrujemy**:

    :::bash
    bin/rake db:create  # Create the database from config/database.yml for the current Rails.env
    bin/rake db:migrate # Migrate the database (options: VERSION=x, VERBOSE=false)

7\. Ustawiamy stronę startową aplikacji, dopisując, przed
kończącym *end*, w pliku konfiguracyjnym *config/routes.rb*:

    :::ruby config/routes.rb
    root :to => fortunes#index'

8\. Zapełniamy bazę jakimiś danymi, dopisując do pliku *db/seeds.rb*:

    :::ruby db/seeds.rb
    Fortune.create :quotation => 'I hear and I forget. I see and I remember. I do and I understand.'
    Fortune.create :quotation => 'Everything has its beauty but not everyone sees it.'
    Fortune.create :quotation => 'It does not matter how slowly you go so long as you do not stop.'
    Fortune.create :quotation => 'Study the past if you would define the future.'

Następnie umieszczamy powyższe fortunki w bazie, wykonujac w terminalu
polecenie:

    bin/rake db:seed  # Load the seed data from db/seeds.rb

Jeśli kilka rekordów w bazie to za mało, to możemy do pliku
*db/seeds.rb* wkleić {%= link_to "taki kod", "/database_seed/seeds.rb" %}
i ponownie uruchomić powyższe polecenie.

9\. Teraz możemy już uruchomić domyślny serwer Rails:

    :::bash
     bin/rails server -p 3000

Albo jeden z alternatywnych serwerów:

    :::bash
     bin/thin -p 3000 start
     bin/unicorn -p 3000
     bin/rainbows -p 3000       # nie polecam w trybie development

Aby obejrzeć działającą aplikację pozostaje wejść na stronę:

     http://localhost:3000


# Fortunka – szczegóły

Poniżej przedstawiamy bardziej szczegółowy opis niektórych kroków.


## Krok 1 – rusztowanie aplikacji

Prawie całą powyższą procedurę można zautomatyzować.
Wystarczy napisać swój szablon dla aplikacji Rails
i następnie go użyć:

    :::bash
    rails new fortunka -m ⟨url albo ścieżka do szablonu⟩

Oczywiście możemy też skorzystać z jakiegoś gotowego szablonu.
Na przykład z jednego [z moich szablonów](https://github.com/wbzyl/rails31-html5-templates):

    :::bash
    rails new fortunka -m https://raw.github.com/wbzyl/rails31-html5-templates/master/html5-boilerplate.rb --skip-bundle
    rails new fortunka -m https://raw.github.com/wbzyl/rails31-html5-templates/master/html5-bootstrap.rb --skip-bundle


## Krok 3 - dodajemy nowe gemy

Dlaczego dopisaliśmy takie a nie inne gemy?

Przy okazji modyfikujemy domyślne ustawienia konsoli Ruby i konsoli
Rails:

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


## Krok 4 – instalujemy gemy

Opcji `--path` używamy tylko raz. Następnym razem uruchamiamy program
*bundle* bez tej opcji. Możemy też pominąć argument *install*.


## Krok 5 - generator scaffold dla fortunek

### Co to jest REST?

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

### Generator scaffold

Rusztowanie dla zasobu (ang. *resource*) *fortune* zostało wygenerowane
za pomocą polecenia:

    rails generate scaffold fortune quotation:text source:string

Stosujemy się do konwencji nazywania frameworka Rails.
Używamy liczby pojedynczej (generujemy zasób dla modelu).

Oto utworzony przez generator kontroler:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      # GET /fortunes
      # GET /fortunes.json
      def index
        @fortunes = Fortune.all
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @fortunes }
        end
      end
      # GET /fortunes/1
      # GET /fortunes/1.json
      def show
        @fortune = Fortune.find(params[:id])
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @fortune }
        end
      end
      # GET /fortunes/new
      # GET /fortunes/new.json
      def new
        @fortune = Fortune.new
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @fortune }
        end
      end
      # GET /fortunes/1/edit
      def edit
        @fortune = Fortune.find(params[:id])
      end
      # POST /fortunes
      # POST /fortunes.json
      def create
        @fortune = Fortune.new(params[:fortune])
        respond_to do |format|
          if @fortune.save
            format.html { redirect_to @fortune, notice: 'Fortune was successfully created.' }
            format.json { render json: @fortune, status: :created, location: @fortune }
          else
            format.html { render action: "new" }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # PUT /fortunes/1
      # PUT /fortunes/1.json
      def update
        @fortune = Fortune.find(params[:id])
        respond_to do |format|
          if @fortune.update_attributes(params[:fortune])
            format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }
            format.json { head :ok }
          else
            format.html { render action: "edit" }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # DELETE /fortunes/1
      # DELETE /fortunes/1.json
      def destroy
        @fortune = Fortune.find(params[:id])
        @fortune.destroy

        respond_to do |format|
          format.html { redirect_to fortunes_url }
          format.json { head :ok }
        end
      end
    end


### Rendering response

…czyli renderowaniem odpowiedzi zajmują się takie kawałki kodu:

    :::ruby
    respond_to do |format|
      format.html  { redirect_to fortunes_url }
      format.js      # destroy.js.erb
      format.json  { render json: @fortunes }
    end

What that says is:

1. If the client wants HTML in response to this
action, use the default template for this action
(for *index* it is *index.html.erb*).

2. If the client wants JS, use the default template
for this action (for *destroy* it is *destroy.js.html*).

3. But if the client wants JSON,
return the list of fortunes in JSON format.”

Rails determines the desired response format from the HTTP **Accept
header** submitted by the client.

Klientem może być przeglądarka, ale może też być
inny program, na przykład *curl*:

    :::bash
    curl -I -X GET -H 'Accept: application/json' http://localhost:3000/fortunes/1
    curl    -X DELETE -H 'Accept: application/json' http://localhost:3000/fortunes/1
    curl -I -X DELETE http://localhost:3000/fortunes/1.json
    curl    -X DELETE http://localhost:3000/fortunes/1
    curl -v -X POST -H 'Content-Type: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes.json
    curl    -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes

Linki do dokumentacji:

* [respond_to](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_to)
* [respond_with](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_with)


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

Wygenerowany kontroler obsługuje tylko dwie reprezentacje: HTML i JSON.
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
byłoby męczące. Unikniemy tego umieszczając w katalogu:

    lib/templates/rails/scaffold_controller/

plik {%= link_to "controler.rb", "/doc/rails31/scaffold/controller.rb" %}.


## Krok 8 - umieszczamy jakieś dane w bazie

Przećwiczymy proste zastosowania gemóww *Faker*
i *Populator* (o ile już działa z Rails 3.1)
korzystając z wygenrowanego kodu:

    rails g scaffold friend last_name:string first_name:string phone:string motto:text
    rake db:migrate

Zaczynamy od „monkey patching” kodu gemu *Faker*:

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

Sprawdzamy jak to działa na konsoli:

    bundle exec irb

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

    rake db:seed

zapełniając tabelę *friends* danymi testowymi.

Chociaż przydałoby się dodać do powyższego kodu coś w stylu:

    :::ruby
    Friend.populate(1000..5000) do |friend|
      # passing array of values will randomly select one
      friend.motto = ["akapity", "z kilku", "fajnych książek"]
    end


<blockquote>
 <p>
  {%= image_tag "/images/nifty-secretary.jpg", :alt => "[nifty secretary]" %}
 </p>
 <p class="author">źródło: <a href="http://e-girlfriday.com/blog/">Retro Graphics, WordPress Site</a></p>
</blockquote>

## Krok 9 - uruchamiamy serwer www

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
