#### {% title "Zadania" %}

<blockquote>
<p>
  Always code as if the guy who ends up maintaining your code will be
  a violent psychopath who knows where you live.
</p>
<p class="author">— Rick Osborne</p>
</blockquote>

* Z Pythona na Ruby.<br>
  Termin oddania: 9.10.11.
* Prosta aplikacja Rails (Fortunka, Trekking, …)<br>
  Termin oddania: 23.10.11.
* Przechodzimy na nierelacyjną bazę danych (MongoDB, …)<br>
  Termin oddania: 7.11.2011.
* Projekt zespołowy – wybór tematu projektu (podział na grupy, założenie repozytoriów, …)<br>
  Termin oddania: 20.11.2011.
* Rozliczenie projektu zespołowego<br>
  Termin oddania: 18.12.2011.
* Prezentacje gotowych projektów<br>
  Termin: styczeń 2012.

Projekty należy umieścić w osobnych repozytoriach git
na swoim koncie na *github.com*.


<blockquote>
{%= image_tag "/images/ralph-waldo-emerson.jpg", :alt => "[Ralph Waldo Emerson]" %}
<p>
  Jeśli ktoś potrafi napisać lepszą książkę, wygłosić lepsze kazanie,
  albo sporządzić lepszą pułapkę na myszy niż jego sąsiad, to choćby
  zbudował swój dom w lesie, świat wydepcze ścieżkę do jego drzwi.
</p>
<p class="author">— Ralph Waldo Emerson (1803–1882)</p>
</blockquote>

# Egzamin

Na egzamin należy przygotować i uruchomić serwis www wg własnego
pomysłu. Serwis piszemy w zespołach 4–5 programistów.<br/>
Prezentacje projektów: styczeń 2012. Harmonogram: grudzień 2011.


# FAQ

1. Co będzie jak nie oddam projektu w terminie?
   *Odpowiedź:* Ocena z laboratorium zostanie obniżona o 1.
1. Co będzie jeśli zespół nie zaprezentuje swojego projektu
   na jednym z wykładów w styczniu.
   *Odpowiedź:* Maksymalna ocena za taki projekt to 3.


# Zadania

…wraz opisem o co chodzi i co nalezy zaprogramować.


## Z Pythona na Ruby

Zadanie polega na przetłumaczeniu
[tego skryptu](http://code.google.com/intl/pl-PL/apis/maps/documentation/elevation/#CreatingElevationCharts)
na język Ruby.

Mniej lub bardziej użyteczne linki do tego zadania:

* [Elevation](http://code.google.com/intl/pl-PL/apis/maps/documentation/javascript/services.html#Elevation) –
  dwa proste przykłady.
* [The Google Elevation API](http://code.google.com/intl/pl-PL/apis/maps/documentation/elevation/).
* [Google Maps API Family](http://code.google.com/intl/pl-PL/apis/maps/)
* [Google Maps Javascript API V3 Reference](http://code.google.com/intl/pl-PL/apis/maps/documentation/javascript/reference.html)


## Prosta aplikacja Rails

Aplikacja powinna korzystać z layoutu przygotowanego z szablonu
[html5-boilerplate](https://github.com/paulirish/html5-boilerplate/blob/master/index.html).
Kod szablonu jest opisany na stronie [HTML5 Boilerplate](http://html5boilerplate.com/).

Na stronie [Initializr 2](http://www.initializr.com/) można wygenerować
„a clean customizable template based on Boilerplate with just what you need to start”.

Przykładowy [Rails 3.1+ compatible **Application Template** based on the HTML5 Boilerplate project](https://github.com/russfrisch/h5bp-rails)
przygotował [Russ Frisch](https://github.com/russfrisch).


### Fortunka v2.0

Funkcjonalność aplikacji można zwiększyć dodając na przykład:

1. Paginację do widoku *index*.
Skorzystać z gemu [kaminari](https://github.com/amatsuda/kaminari).
Wystylizować linki do kolejnych „stron”.
Jak to się robi opisał Vitaly Friedman,
[Pagination Gallery: Examples And Good Practices](http://www.smashingmagazine.com/2007/11/16/pagination-gallery-examples-and-good-practices/) i Mislav Marohnić,
[Samples of pagination styling for will_paginate](http://mislav.uniqpath.com/will_paginate/).
2. „AJAX rating” dla komentarzy.
Skorzystać z jakiejś gotowej wtyczki lub gemu
(wcześniej sprawdzić czy wybrana biblioteka działa z jQuery 1.6+ Rails 3.1+).
3. Autentykację. Zrobić to tak jak, to
przedstawił R. Bates w screencaście
[Simple OmniAuth](http://railscasts.com/episodes/241-simple-omniauth).
4. Komentarze, tak jak to będzie przedstawione na wykładzie.

Warto już teraz uprościć kod formularzy. Jak?
Obejrzeć screencast R. Batesa [Simple Form](http://railscasts.com/episodes/234-simple-form).
Następnie zamienić wygenerowane formularze na formularze korzystajęce
z metod [tego gemu](http://github.com/plataformatec/simple_form).


### Trekking

O co chodzi w aplikacji Trekking? Najprościej jest przekonać się
samemu wchodząc na stronę
[Google Maps JavaScript API v3 Example: Elevation](http://www.geocodezip.com/v3_elevation-profile_distance.html).

Mniej lub bardziej użyteczne linki:

* wtyczka jQuery [gMap](http://labs.mario.ec/jquery-gmap/) –
  gMap helps you embed Google Maps into your website.
  With only 2 KB in size it is very flexible and highly customizable
* [map icons collection](http://mapicons.nicolasmollet.com/)
* gem [Cartographer](https://github.com/joshuamiller/cartographer) (?)

Zainstalować następujące rozszerzenia do przeglądarki Firefox:

* [Firebug](http://getfirebug.com/)
* [FireQuery](https://addons.mozilla.org/en-US/firefox/addon/firequery/)
* [CSS Usage](https://addons.mozilla.org/en-US/firefox/addon/css-usage/)

oraz do przgladarki Chrome:

* [PageSpeed](http://code.google.com/intl/pl-PL/speed/page-speed/docs/using_chrome.html)
* [Yslow](http://developer.yahoo.com/yslow/)

1\. Działającą aplikację uruchomić w trybie *production*.
Sprawdzić jaką uzyska ocenę od *YSlow* a jaką od *PageSpeed*.

2\. Powtórzyć ocenę dla aplikacji uruchomionej w trybie *development*.

3\. Sprawdzić jakość kodu CSS za pomocą rozszerzenia *CSS Usage*.

**Zacząć** od [Page Speed Online](http://pagespeed.googlelabs.com/pagespeed/).

**Ciekawy ekperyment:**
[Strona www Instytutu Informatyki](http://inf.ug.edu.pl/) +
[PageSpeed Online](http://pagespeed.googlelabs.com/pagespeed/) +
[SpriteMe](http://spriteme.org/).


## Przechodzimy na nierelacyjną bazę danych

W swojej aplikacji zamienić relacyjną bazę danych na dokumentową bazę
danych MongoDB.

Kilka linków:

* dokumentacja do gemu [Mongo](http://api.mongodb.org/ruby/current/)
* screencast R. Batesa, [Mongoid](http://railscasts.com/episodes/238-mongoid).


# Zadania różne

Kilka pomysłów, gemów do wykorzystania w swoich projektach.


<blockquote>
 <p>
  {%= image_tag "/images/wesole_kontakty.jpg", :alt => "[wesołe kontakty]" %}
 </p>
 <p class="author">Wesołe kontakty</p>
</blockquote>

## Aplikacja „Kontakty”

Aplikacja *kontakty* powinna umożliwiać wpisywanie, edycję kontaktów.

Aplikacja powinna zawierać model *AddressBook* oraz inne konieczne do
działania modele. W bazie umieścić następujące dane: imię, nazwisko,
email, url strony www, adres.

Użyć rozszerzenia YSLow (*Firefox*) albo Speed Tracer (*Google Chrome*)
„to identify and fix performance problems in your web applications”.

<blockquote>
 <p>
  Have you ever even bothered to Google for “rails html template”?
 </p>
 <p class="author">— Dr Nic</p>
</blockquote>

1\. Do aplikacji dodać *gravatary*.
Skorzystać z jakiegoś gemu lub jakiejś wtyczki.

Albo zamiast wtyczki skorzystać z pomysłu przedstawionego
w [Cropping Images](http://railscasts.com/episodes/182-cropping-images).
W screencaście, R. Bates pokazuje jak
dodać do aplikacji zgrabny interfejs umożliwiający przycinanie
obrazków przed umieszczeniem ich w bazie danych.
Dodać taką funkcjonalność do budowanej aplikacji.

2\. Zmodyfikować formularz aplikacji tak aby korzystał
z [Fancy Sliding Form with jQuery](http://tympanus.net/codrops/2010/06/07/fancy-sliding-form-with-jquery/)
albo z czegoś podobnego w działaniu.

<blockquote>
<p>
  We send down exactly one .js and one .css file. If you are sending
  down more than one of each of these to the browser, you have a
  performance problem. Fix it with asset packager.
</p>
<p class="author">— Pivotal Labs</p>
</blockquote>

3\. Skompresować *static assets* za pomocą wtyczki
[Asset Packager] [asset-packager] –
„JavaScript and CSS Asset Compression for **Production** Rails Apps”,
albo, lepiej, z gemu [Jammit](https://github.com/documentcloud/jammit) –
„Industrial Strength Asset Packaging for Rails”.

Korzystając z rozszerzenia YSlow albo Speed Tracer sprawdzić wydajność
aplikacji przed i po instalacji tej wtyczki.
Opisać różnice w pliku README.

4\. Wersja 3.5 Firefoxa obsługuje
[W3C Geolocation API](http://dev.w3.org/geo/api/spec-source.html).
Korzystając z któregoś z gemów polecanych na stronie
[The Ruby Toolbox](http://www.ruby-toolbox.com/categories/geocoding___maps.html)
dodać geolokację do aplikacji.

5\. Dodać możliwośc dodawania tagów.  Na przykład takich: praca,
rodzina, znajomi, przypadkowi znajomi, uczelnia, wojsko, pizzeria, biblioteka itp.

* Zaimplementować tagowanie tak jak to jest pokazane na screencaście
  [More on Virtual Attributes](http://railscasts.com/episodes/167-more-on-virtual-attributes).
* Jeszcze raz tagowanie, ale tym razem skorzystać z wtyczki/gemu
  [acts-as-taggable-on](http://github.com/mbleigh/acts-as-taggable-on/).
  Autorem jest Michael Bleigh. Cytat:
  A tagging plugin for Rails applications that allows for custom
  tagging along dynamic contexts.

6\. Dodać „tags cloud”. Skorzystać z wtyczki jQuery
  [Tag Cloud](http://rohitsengar.cueblocks.net/jquery-tag-cloud-plugin/),
  albo czegoś podobnego.

7\. Dodać wyszukiwanie: nazwisko lub imię.

8\. Dodać wyszukiwanie po tagach.


<blockquote>
{%= image_tag "/images/martin-fowler.jpg", :alt => "[Martin Fowler]" %}
<p>
  Often when you come across something new it can be a good idea to
  overuse it in order to find out it's boundaries. This is a quite
  reasonable learning strategy. It's also why people always tend to
  overuse new technologies or techniques in the early days. People
  often criticize this but it's a natural part of learning. If you
  don't push something beyond its boundary of usefulness how do you
  find where that boundary is? The important thing is to do so in a
  relatively controlled environment so you can fix things when you
  find the boundary. (After all until we tried it I thought XML would
  be a good syntax for build files.)
</p>
<p class="author">- Martin Fowler</p>
</blockquote>

## Stylizacja Leniwca

1\. Do strony z wynikami wyszukiwania dodać paginację.
Skorzystać z gemu
[mislav-will-paginate](http://github.com/mislav/will_paginate/).

2\. Do wyszukiwarki dodać select-menu z listą języków
obsługiwanych przez gem *Ultraviolet*
(`uv -l syntaxes`). Zmodyfikować kod *leniwca.local*, tak aby
było możliwe wyszukiwanie fragmentów kodu z wybranego
języka. Wskazówka: objerzeć screencast
[Advanced Search Form](http://railscasts.com/episodes/111-advanced-search-form)
Uwaga: na liście języków umieścić „Wszystkie języki”,
„Języki skryptowe“ i „Języki kompilowane”.

3\. Wpisać listę wszystkich języków do tabelki *languages*.
Do select-menu pobrać tę listę z tej tabelki.

4\. Dodać „full text search”. Wykorzystać gem
[xapit](http://github.com/ryanb/xapit/) albo
[thinking-sphinx](http://github.com/freelancing-god/thinking-sphinx/).
Przykład korzystający *thinking-sphinx* można obejrzeć
na screencaście R. Batesa,
[Thinking Sphinx](http://railscasts.com/episodes/120-thinking-sphinx).

5\. Użyć innego ORM, np. Datamapper
\([przykład](http://github.com/dkubb/datamapper-on-rails/)\).


## Shoutbox

Przeczytać
[From CodeIgniter to Ruby on Rails: A Conversion](http://net.tutsplus.com/tutorials/ruby/from-codeigniter-to-ruby-on-rails-a-conversion/).

Przepisać aplikację *Shoutbox* na Rails 3. Zamiast MySQL użyć
SQLite albo Postgresql.


Zadanie ekstra: Uruchomić aplikację *Shoutbox* według opisu
[Shoutbox with Grasshopper and CouchDB](http://howtonode.org/grasshopper-shoutbox).


## Z życia leniwców

[A code snippet tool, intended for localhost usage](http://github.com/navyrain/navysnip/).
Add the following:

* Command line submission script
* Doubleclick to select all
* Submit-to-pastie button
* Search
* Add Rails-ish parsers to SHJS (erb, haml, sass)
* Tweak the PRE CSS or do something clever with wrapping
  to make long lines display nicely


## Photo Album

1\. [Extremely Simple Photo Album in
  Rails](http://rubyplus.org/episodes/92-Extremely-Simple-Photo-Album-in-Rails.html)

* You can extend this album so that the photo upload does not tie up
  the Mongrel process by using Background DRB, Merb etc.
* Add the feature where users can only add/edit photos to their album.
* When a photo is added instead of displaying the album index page,
  display the album show page so that users can continue uploading
  photos.


## JSON, XML

1\. [Faker.js](http://github.com/marak/Faker.js) —
generate massive amounts of fake data in Node.js and the browser.

Korzystając z Faker.js umieścić przykłądowe dane w bazie aplikacji
Rails.  To samo, ale dane umieścić w *seed.rb*, a same dane zapisać
w bazie:

    rake db:seed

2\. Przeczytać [Ruby Libxml Tutorial - Reader API](http://anurag-priyam.blogspot.com/2010/05/ruby-libxml-tutorial-reader-api.html)
i skorzystać.


## Redis

Cytat, [Redweb: A Web Interface for Redis](http://philosophyofweb.com/2010/02/redweb-a-web-interface-for-redis/):
„In my opinion, Redis is a superb option for a number of different use
cases (web bookmarks/tags, working with data locally, and much more).”

Sprawdzamy, czy tak jest. Zaczynamy od instalacji
[Redisa](http://github.com/antirez/redis) i [Redweb](http://github.com/tnm/redweb).

1\. Aplikacja „Bookmarks”. Inne przykłady:

* [NoSQL Twitter Applications](http://nosql.mypopescu.com/post/319859407/nosql-twitter-applications)
* [A NoSQL Use Case: URL Shorteners](http://nosql.mypopescu.com/post/597603446/a-nosql-use-case-url-shorteners)
* [Usecase: NoSQL-based Blogs](http://nosql.mypopescu.com/post/346471814/usecase-nosql-based-blogs)

2\. Node.JS + Redis + Pygments: [Snip](http://bitbucket.org/nikhilm/snip/src/).


[blueprint-css]: http://github.com/joshuaclayton/blueprint-css "A CSS framework"
[haml]: http://haml-lang.com/ "HAML: markup haiku"
[sass]: http://sass-lang.com/ "Sass makes CSS fun again"
[asset-packager]: http://github.com/sbecker/asset_packager "CSS and Javascript asset packager"
[compass]: http://github.com/chriseppstein/compass "A CSS stylesheet authoring environment"

## Faye

„Faye is a subscription/publishing server which makes it easy to do
push notifications within a Rails app.”

* Uruchomić aplikację przedstawioną na screencaście R. Batesa,
  [Messaging with Faye](http://railscasts.com/episodes/260-messaging-with-faye)
* dodać nieco prywatności do aplikacji, np. korzystając z [private_pub](https://github.com/ryanb/private_pub) –
  handle pub/sub messaging through private channels in Rails.
