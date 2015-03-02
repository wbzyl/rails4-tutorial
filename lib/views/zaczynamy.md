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


## Rails Girls

* [Rails Girls Warsaw Programme](http://dotclass.org/rails-girls-warsaw-programme/)

Co dalej?

* Skorzystać z jednego z API z tej listy
  [gist](https://gist.github.com/wbzyl/9989677)
  (przykład [My Movies](https://github.com/rails4/my_movies) –
  pokazujący o co chodzi; niestety, nieco za skomplikowany).


## MyGists

Zaczynamy od wygenerowania rusztowanie aplikacji:

    :::bash
    rails new my_gists --skip-bundle

Następnie przechodzimy do katalogu z wygenerowanym kodem:

    :::bash
    cd my_gists

gdzie w pliku *Gemfile* dopisujemy gemy z których będziemy
korzystać:

    :::ruby Gemfile
    gem 'pygments.rb'
    gem 'redcarpet'
    gem 'quiet_assets'

Gemy instalujemy za pomocą programu *bundle*:

    :::bash
    bundle install

Jeśli nie mamy uprawnień do instalacji gemów w systemie,
instalujemy je gdzieś w swoim katalogu domowym, np. w katalogu *~/.gems*:

    :::bash
    bundle install --path=$HOME/.gems

Ale jeśli gemy z których korzystamy są już zainstalowane w systemie, to
możemy użyć opcji `--local` w trakcie ich instalacji.
Taka instalacja wykonuje się dużo szybciej!

Szablon aplikacji CRUD utworzymy za pomocą generatora kodu
o nazwie *scaffold*:

    :::bash
    rails generate scaffold gist snippet:text lang:string description:string

Po wygenerowaniu kodu wykonujemy migrację:

    :::bash
    rake db:migrate

Po uruchomieniu prostego serwera HTTP:

    :::bash
    rails server --port 3000

Aplikacja jest dotępna z takiego url *localhost:3000*.

Routing aplikacji sprawdzamy wykonując na konsoli polecenie:

    :::bash
    rake routes

lub w przeglądarce *localhost:3000/rails/info/routes*.

Więcej informacji znajdziemy w sekcji
[Routing](http://guides.rubyonrails.org/routing.html) w Rails Guides.

Kolorowanie kodu:

* [Syntax Highlighting](http://railscasts.com/episodes/207-syntax-highlighting-revised).
* [Pygments.rb](https://github.com/tmm1/pygments.rb)

Na koniec podmieniamy zawartośc pliku *app/views/gists/show.html.erb* na:

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

Lektura dokumentacji funkcji pomocniczej [link_to](http://api.rubyonrails.org/).
Co to są *assets*? a *partial templates* (szablony częściowe),
na przykład *_form.html.erb*.


## MyStaticPages

Jak wyżej, usuwamy niepotrzebne gemy z pliku *Gemfile*
dodajemy gemy z których będziemy korzystać.

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


### TODO

1. Dodać stronę *todo*. Skorzystać z wtyczki jQuery
   [Isotope](http://isotope.metafizzy.co/) ([github](https://github.com/desandro/isotope))
   do wyświetlania na stronie *index* karteczek z rzeczami do zrobienia.
2. Użyć [ReStructuredText](http://en.wikipedia.org/wiki/ReStructuredText).
   Zob. też [GitHub Markup](https://github.com/github/markup),
   gem [RbST](https://github.com/alphabetum/rbst).
3. Użyć gemu [Carrierwave](https://github.com/carrierwaveuploader/carrierwave)
   do wstawiania obrazków.


## MyPlaces

Generujemy szablon aplikacji:

    rails new my_places --skip-bundle --skip-test-unit --skip-active-record

Dopisałem opcję `--skip-active-record` ponieważ będziemy
korzystać z bazy MongoDB i gemu (drivera)
[Mongoid](http://mongoid.org/en/mongoid/index.html).

W pliku *Gemfile* usuwamy gem *sass-rails* i dopisujemy gem Mongoid:

    :::ruby Gemfile
    # gem 'mongoid', '~> 3.1.6'
    gem 'mongoid', github: 'mongoid/mongoid'

Przy okazji dodamy pliki *.ruby-version*:

    :::text .ruby-version
    2.1.0

oraz *.ruby-gemset*:

    :::text .ruby-gemset
    my_places

Na koniec wygenerujemy plik konfiguracyjny dla MongoDB:

    rails g mongoid:config
      create  config/mongoid.yml


### Moje lotniska

Tym razem zaczniemy od importu ciekawych miejsc do bazy MongoDB.

Pobieramy plik *airports.csv* ze strony
[Our Airports](http://www.ourairports.com/data/).
Pobrane dane zapiszemy w bazie MongoDB w kolekcji *airports*.
za pomocą programu *mongoimport*:

    mongoimport --collection airports  --headerline --type csv airports.csv
      connected to: 127.0.0.1
      2014-02-08T21:44:49.825+0100 check 9 45618
      2014-02-08T21:44:49.897+0100 imported 45617 objects

Oto przykładowy rekord zapisany w kolekcji *airports*:

    :::json
    {
      "_id": ObjectId("52f6973f4fc0cda07918c564"),
      "id": 6523,
      "ident": "00A",
      "type": "heliport",
      "name": "Total Rf Heliport",
      "latitude_deg": 40.07080078125,
      "longitude_deg": -74.9336013793945,
      "elevation_ft": 11,
      "continent": "NA",
      "iso_country": "US",
      "iso_region": "US-PA",
      "municipality": "Bensalem",
      "scheduled_service": "no",
      "gps_code": "00A",
      "iata_code": "",
      "local_code": "00A",
      "home_link": "",
      "wikipedia_link": "",
      "keywords": ""
    }

W kolekcji *airports*, ciekawe dla mnie miejsca, to dokumenty
z informacjami o lotniskach w Polsce.
Dokumenty te przekształcimy na takie GeoJSON-y:

    :::json
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [0, 0]
      },
      "properties": {
        "title": "Konstancin-Jeziorna Airfield",
        "description": "small_airport",
        "marker-size": "medium",
        "marker-symbol": "airport"
      }
    }

i w takim formacie zapiszemy je w kolekcji *lotniska*.

Wszystkie te rzeczy wykonamy na konsoli *mongo*,
korzystając z takiego kodu:

    :::js mongo
    var cursor = db.airports.find({iso_country: "PL"})
    while (cursor.hasNext()) {
      var doc = cursor.next()
      var spec = {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [doc["longitude_deg"], doc["latitude_deg"]]
        },
        "properties": {
          // a title to show when this item is clicked or hovered over
          "title": doc["name"],
          // a description to show when this item is clicked or hovered over
          "description": doc["type"],
          "marker-size": "medium",
          "marker-symbol": "airport"
        }
      };
      db.lotniska.insert(spec);
    }
    db.lotniska.count(); #-> 170

W markerach na mapkach (GitHub, Mapbox) wykorzystywany jest zestaw ikon
[Maki](https://www.mapbox.com/maki/) z [Mapbox](https://www.mapbox.com/).
W GeoJSON-ach powyżej użyjemy ikony o nazwie *airport*.


### Prosta wizualizacja danych

Zanim zapiszemy dane o lotniskach w bazie i w kolekcji aplikacji
MyPlaces przyjrzymy się im bliżej.

W tym celu dokumenty z kolekcji *lotniska* zapiszemy
w pliku w przyjaźniejszym formacie
[simplestyle spec v1.1.0](https://github.com/mapbox/simplestyle-spec/tree/master/1.1.0).
Pliki w tym formacie są renderowane w postaci mapek przez serwer
GitHub.

Do zmiany formatu użyjemy programów *mongoexport*
i [jq](http://stedolan.github.io/jq/):

    mongoexport -c lotniska | \
    jq '{type, geometry, properties}' | \
    jq -s . | \
    jq '{"type": "FeatureCollection", features: .}' \
    > lotniska.geojson

*Pytanie:* Czy można to zrobić prościej?

Plik {%= link_to "lotniska.geojson", "/doc/data/lotniska.geojson" %}
umieściłem w repozytorium na GitHubie i wyrenderowaną mapkę
można obejrzeć [tutaj](https://github.com/rails4/asi/blob/master/lotniska.geojson)
lub poniżej:

<script src="https://embed.github.com/view/geojson/rails4/asi/master/lotniska.geojson?height=640&width=640"></script>



### Mongoid

* [Mongoid](http://railscasts.com/episodes/238-mongoid?view=asciicast) –
  asciicast #238
* [Mongoid + Rails](http://mongoid.org/en/mongoid/docs/rails.html)
* w [Mongoid + Documents](http://mongoid.org/en/mongoid/docs/documents.html)
  przeczytać sekcję *Custom field serialization*:
  „You can define custom types in Mongoid and determine how they are
  serialized and deserialized. You simply need to provide 3 methods on
  it for Mongoid to call to convert your object to and from MongoDB
  friendly values”. Przyda się przy tworzeniu formularzy.

Jeśli zajrzymy do pliku *config/mongoid.yml*:

    :::yaml
    development:
      sessions:
        default:
          database: my_places_development
          hosts:
            - localhost:27017
          options:
            # Change the default write concern. (default = { w: 1 })
            # write:
            # w: 1
      # Configure Mongoid specific options. (optional)
      options:
        # Includes the root model name in json serialization. (default: false)
        # include_root_in_json: false
        # Include the _type field in serializaion. (default: false)
        # include_type_for_serialization: false

to zobaczymy, że aplikacja MyPlaces oczekuje w trybie *development*,
że dane zostaną zapisane w bazie o nazwie *my_places_development*.

Teraz wygenerujemy *entire resource* dla danych:

    rails generate scaffold airport type:String geometry:Hash properties:Hash

Ponieważ nazwa *resource* to *airport*, dane
zapisujemy w kolekcji o nazwie *airports*:

    mongoexport -d test -c lotniska | \
    mongoimport -d my_places_development -c airports --drop --type json

Sprawdzamy na konsoli rails, czy stosujemy się do *convention over
configuration* używanych w aplikacjach Rails.

    :::ruby
    rails console --sandbox
    a = Airport.first
      #<Airport _id: 52f92e405debff06c39ea6ee,
       type: "Feature",
       geometry: {"type"=>"Point",
                  "coordinates"=>[22.5142993927002, 49.6575012207031]},
       properties: {"title"=>"Arlamów Airport",
                    "description"=>"small_airport",
                    "marker-size"=>"medium", "marker-symbol"=>"airport"}>
    a.type
      # "Feature"
    a.geometry["coordinates"].class
      # Array
    a.properties["description"] = "big_airport"
    a.save

Jest dobrze!


### Mapka zamiast tabeli

Po wejściu na stronę *airports* renderowana jest tabelka.
Tabelki nie specjalnie nadają się do prezentacji GeoJSON-ów.

Dlatego kod widoku:

    :::rhtml app/views/airports/index.html.erb
    <h1>Listing airports</h1>
    <table>
      <thead>
        <tr>
          <th>Type <th>Geometry <th>Properties <th> <th> <th>
        </tr>
      </thead>
      <tbody>
        <% @airports.each do |airport| %>
          <tr>
            <td><%= airport.type %></td>
            <td><%= airport.geometry %></td>
            <td><%= airport.properties %></td>
            <td><%= link_to 'Show', airport %></td>
            <td><%= link_to 'Edit', edit_airport_path(airport) %></td>
            <td><%= link_to 'Destroy', airport, method: :delete, data: { confirm: 'Are you sure?' } %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    <br>
    <%= link_to 'New Airport', new_airport_path %>

zastąpimy mapką. Do generowania mapek użyjemy biblioteki
[Leaflet](http://leafletjs.com/).
Przy okazji, warto wiedzieć, zobacz
[Mapping geoJSON files on GitHub](https://help.github.com/articles/mapping-geojson-files-on-github),
że mapki na GitHubie też korzystają z biblioteki Leaflet oraz wtyczki do niej
o nazwie [Leaflet.markercluster](https://github.com/Leaflet/Leaflet.markercluster).


### Leaflet maps from scratch

Zanim się zabierzemy za dodawanie mapki do widoku
*index.html.erb* przyjrzyjmy się tym przykładom:
[index, overlays and layers, geojson](https://github.com/wbzyl/rails4-tutorial/tree/master/lib/doc/leafletjs).

Podmieniamy kod widoku *index.html.erb* na:

    :::rhtml
    <div id="map"></div>
    <%= javascript_include_tag "airports", "data-turbolinks-track" => true %>

Dodajemy plik *airports.js*:

    :::js app/assets/javascripts/airports.js
    // dane z OpenStreetMap
    var osm = {
      url: 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> Contributors'
    };

    // tworzymy mapkę – współrzędne: [ szerokość, długość ]
    var map = L.map('map').setView([52.05735, 19.19209], 6);  // center: Łęczyca, zoom: 6
    var osmTileLayer = L.tileLayer(osm.url, {attribution: osm.attribution})
    osmTileLayer.addTo(map);

    // dodajemy markery do mapki
    $.getJSON("/airports", function(data) {
      console.log(data.length);

      L.geoJson(data, {
        pointToLayer: function (feature, latlng) {
          return L.marker(latlng, { riseOnHover: true });
        },
        onEachFeature: function(feature, layer) {
          layer.bindPopup(feature.properties.title + '<br>(' + feature.properties.description + ')');
        }
      }).addTo(map);
    });

Na koniec dodajemy bibliotekę Leaflet do layoutu aplikacji.

Szablon aplikacji [MyPlaces](https://github.com/wbzyl/my_places)
do pobrania z GitHuba.


### Leaflet maps via leaflet-rails gem

Czy warto skorzystać z jakiegoś gemu?

* [leaflet-rails](https://github.com/axyjo/leaflet-rails)
* [leaflet-providers preview](http://leaflet-extras.github.io/leaflet-providers/preview/)


### TODO

1. W aplikacji *MyPlaces* operacje CRUD zaprogramować jako remote (AJAX).
Do CREATE i DELETE użyć mapki.
1. Utworzyć indeks [2dsphere](http://docs.mongodb.org/manual/core/2dsphere/).
Natępnie dodać wyszukiwanie lotnisk.
1. Użyć gemu [Geocoder](https://github.com/alexreisner/geocoder).


*Wskazówki:*

- Ideę JTZ (mniej więcej) opisał R. Bates w epizodzie #136 RailsCasts,
[jQuery & Ajax (revised)](http://railscasts.com/episodes/136-jquery-ajax-revised?view=asciicast).
- W pkt. 1. można użyć wtyczki do Leaflet:
[Leaflet.draw](https://github.com/Leaflet/Leaflet.draw)
([demo](http://leaflet.github.io/Leaflet.draw/)) lub wtyczki
[Leaflet Plotter](https://github.com/scripter-co/leaflet-plotter).


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
    rails new my_app --template wbzyl-template.rb

**TODO:**
Taki szablon łatwo napisać samemu, na przykład
{%= link_to "wbzyl-template.rb", "/app_templates/wbzyl-template.rb" %}
pokazuje jakie może to być proste.


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
