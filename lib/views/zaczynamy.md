#### {% title "Kilka prostych przykładów" %}

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

Jak wygląda praca z frameworkiem Ruby on Rails
pokażemy na przykładzie aplikacji **MyGists** i **MyStaticPages**.

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


## MyGists

Generujemy rusztowanie aplikacji i instalujemy gemy z których
będzie ona korzystać:

    :::bash
    rails new my_gists --skip-bundle --skip-test-unit
    cd my_gists

Swoje opcje możemy wpisać w pliku *~/.railsrc *, na przykład

    :::bash
    --skip-bundle
    --skip-test-unit

Dopisujemy do pliku *Gemfile* gemy z których będziemy korzystać:

    :::ruby Gemfile
    gem 'pygments.rb'
    gem 'redcarpet'
    gem 'quiet_assets'

oraz usuwamy gemy z których nie będziemy korzystać:

    :::ruby Gemfile
    gem 'sass-rails', '~> 4.0.0'

Jeśli potrzebne gemy są już zainstalowane w systemie, to
możemy użyć opcji `--local` w trakcie ich instalacji:

    :::bash
    bundle install --local

Taraz instalacja powinna się wykonać dużo szybciej!

Możemy też pobrać gemy z internetu i zainstalować je
np. w katalogu *~/.gems*:

    :::bash
    bundle install --path=$HOME/.gems

Szablon aplikacji CRUD utworzymy za pomocą generatora kodu
o nazwie *scaffold*:

    :::bash
    rails generate scaffold gist snippet:text lang:string description:string

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
    <p id="notice"><%= notice %></p>
    <p>
      <strong>Lang:</strong>
      <%= @gist.lang %>
    </p>
    <p>
      <strong>Snippet:</strong>
    </p>
    <%= raw Pygments.highlight(@gist.snippet, lexer: @gist.lang) %>
    <p>
      <strong>Description:</strong>
      <%= @gist.description %>
    </p>
    <%= link_to 'Edit', edit_gist_path(@gist) %> |
    <%= link_to 'Back', gists_path %>

Dodajemy nowy plik *app/assets/stylesheets/pygments.css.erb*:

    :::rhtml
    <%= Pygments.css(style: "colorful") %>

**Zadania:**

1\. Poprawić pozostałe widoki. Zacząć od *index.html.erb*.

2\. Zwiększyć rozmiar fontu do co najmniej 18px.

3\. W formularzu w szablonie częściowym *_form.html.erb*.
zwiększyć wielkość elementu *textarea*.


## MyStaticPages

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

           Prefix Verb URI Pattern             Controller#Action
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
    match "welcome", to: "pages#welcome", via: 'get'
    match "about",   to: "pages#about",   via: 'get'

Przy zmienionym routingu wykonanie polecenia `rake routes` daje:

     Prefix Verb URI Pattern       Controller#Action
    welcome GET /welcome(.:format) pages#welcome
      about GET /about(.:format)   pages#about

co oznacza, że te strony są dostępne z krótszych, niż poprzednio,
adresów */welcome* i */about*.


## Podsumowanie

Często używane opcje zapisujemy w pliku  *~/.railsrc*:

    :::bash ~/.railsrc
    --skip-bundle
    --skip-test-unit

Zamiast ręcznej edycji pliku *Gemfile* oraz modyfikacji plików
konfiguracyjnych możemy użyć szablonu aplikacji Rails,
który zrobi to za nas.
Wystarczy podać nazwę szablonu w poleceniu *rails new*:

    :::bash
    rails new xxl --template wbzyl-template.rb

Taki szablon łatwo napisać samemu, na przykład
{%= link_to "wbzyl-template.rb", "/app_templates/wbzyl-template.rb" %}
pokazuje jakie może to być proste.


## MyPlaces

* Rails4 + MongoDB + [Mongoid](http://mongoid.org/en/mongoid/index.html)
* [Leafletjs](http://leafletjs.com/)
* [Lotniska](/doc/mongodb/geo/lotniska.geojson)



<blockquote>
 <p>
  {%= image_tag "/images/nifty-secretary.jpg", :alt => "[nifty secretary]" %}
 </p>
 <p class="author">źródło: <a href="http://e-girlfriday.com/blog/">Retro Graphics, WordPress Site</a></p>
</blockquote>

### Serwery WWW & aplikacje Rails

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

<blockquote>
  {%= image_tag "/images/puma-standard-logo.png", :alt => "[puma logo]" %}
</blockquote>

[Puma](http://puma.io/) is built for speed and **parallelism**.

[Rainbows!](http://rainbows.rubyforge.org/)
is an HTTP server for sleepy Rack applications. It is based
on Unicorn, but designed to handle applications that expect long
request/response times and/or slow clients.
