#### {% title "Zadania" %}

<blockquote>
<p>
  Always code as if the guy who ends up maintaining your code will be
  a violent psychopath who knows where you live.
</p>
<p class="author">— Rick Osborne</p>
</blockquote>

1\. Zapoznajemy się z językiem Ruby.

2\. Projekt indywidualny:

* prosta aplikacja Rails (przykłady – Fortunka, Trekking)
* prosta aplikacja korzystająca z nierelacyjnej bazy danych (przykładowo MongoDB lub Redis)

3\. Projekt zespołowy:

* Wybór tematu projektu, podział na grupy, założenie repozytoriów: ??.??.2012
* Rozliczenie projektu zespołowego: ??.??.2012
* Prezentacje gotowych projektów: ??.01.2013

Każdą aplikację należy uruchomić w trybie produkcyjnym
na Sigmie, Heroku lub innym serwerze.
Aplikacja powinna być dostępna **24/7**.

<blockquote>
{%= image_tag "/images/ralph-waldo-emerson.jpg", :alt => "[Ralph Waldo Emerson]" %}
<p>
  Jeśli ktoś potrafi napisać lepszą książkę, wygłosić lepsze kazanie,
  albo sporządzić lepszą pułapkę na myszy niż jego sąsiad, to choćby
  zbudował swój dom w lesie, świat wydepcze ścieżkę do jego drzwi.
</p>
<p class="author">— Ralph Waldo Emerson (1803–1882)</p>
</blockquote>


## Zapoznajemy się z językiem Ruby

1\. Sprawdzamy instalację języka Ruby na Sigmie i instalujemy
system Ruby na swoim komputerze.

Wykonujemy polecenie:

    :::bash terminal
    rvm list

Wynik wykonania tego polecenia powinien być taki:

    rvm rubies

       ruby-1.9.2-p320 [ x86_64 ]
       ruby-1.9.2-p320-n32 [ i386 ]
       ruby-1.9.3-head [ x86_64 ]
       ruby-1.9.3-head-i32 [ i686 ]
    =* ruby-1.9.3-p194 [ x86_64 ]

    # => - current
    # =* - current && default
    #  * - default

Wchodzimy na konsolę języka Ruby:

    :::bash terminal
    irb

Na konsoli wpisujemy kod i uruchamiamy go:

    :::ruby irb
    2 + 2
    [1,2,3,4].map { |x| x + 1 }

Rezultat wykonania tych poleceń:

    => 4
    => [2, 3, 4, 5]

Wychodzimy z konsoli:

    exit

Jeśli wszystko działa, to można spróbować instalacji
[RVM](http://beginrescueend.com/) na swoim komputerze.
Następnie należy doinstalować pozostałe wymagane pakiety.
Jakie? Odpowiedź uzyskamy wykonując polecenie:

    :::bash terminal
    rvm requirements

Dopiero teraz możemy zainstalować wersję Ruby
z której będziemy korzystać na zajęciach:

    :::bash terminal
    rvm install 1.9.3

Pozostałe szczegóły instalacji opisano {%= link_to "tutaj", "/konfiguracja" %}.

2\. Rozwiązujemy wszystkie zadania na [Ruby Monk](http://rubymonk.com/).

3\. *Z Pythona na Ruby.*
Zadanie polega na przetłumaczeniu z języka Python na język Ruby
[tego skryptu](http://code.google.com/intl/pl-PL/apis/maps/documentation/elevation/#CreatingElevationCharts).
Linki przydatne do rozwiązania tego zadania:

* [Elevation](http://code.google.com/intl/pl-PL/apis/maps/documentation/javascript/services.html#Elevation) –
  dwa proste przykłady.
* [The Google Elevation API](http://code.google.com/intl/pl-PL/apis/maps/documentation/elevation/).
* [Google Maps API Family](http://code.google.com/intl/pl-PL/apis/maps/)
* [Google Maps Javascript API V3 Reference](http://code.google.com/intl/pl-PL/apis/maps/documentation/javascript/reference.html)


## Prosta aplikacja Rails

Piszemy prostą aplikację Rails. Co oznacza „prosta aplikacja”
jest wyjaśnione poniżej.


### Fortunka

1. Dodać paginację do widoku *index*.
Skorzystać z gemu [kaminari](https://github.com/amatsuda/kaminari).
Wystylizować linki do kolejnych „stron”.
Jak to się robi opisał Vitaly Friedman,
[Pagination Gallery: Examples And Good Practices](http://www.smashingmagazine.com/2007/11/16/pagination-gallery-examples-and-good-practices/) i Mislav Marohnić,
[Samples of pagination styling for will_paginate](http://mislav.uniqpath.com/will_paginate/).
2. Na stronie głównej użyć jednej z wtyczek jQuery:
   - [DataTables](http://datatables.net/), zob. [RailsCast \#340](http://railscasts.com/episodes/340-datatables)
   - [Masonry](http://masonry.desandro.com/) – dynamic layout plugin for jQuery
   - [Isotope](http://isotope.metafizzy.co/) – jQuery plugin for magical layouts
3. Dodać „AJAX rating” dla komentarzy.
Skorzystać z jakiejś gotowej wtyczki lub gemu
(wcześniej sprawdzić czy wybrana biblioteka działa z jQuery 1.6+ Rails 3.1+).
4. Dodać autentykację. Zrobić to tak jak, to
przedstawił R. Bates w screencaście
[Simple OmniAuth](http://railscasts.com/episodes/241-simple-omniauth).
5. Dodać komentarze.
6. Skorzystać z bazy PostgreSQL i jednego z rozszerzeń.
Tutaj [PostgreSQL most useful extensions](http://blog.railsware.com/2012/04/23/postgresql-most-useful-extensions/)
jest krótka lista, tutaj –
[Hstore](http://railscasts.com/episodes/345-hstore) przykład jak korzystać z takich rozszerzeń.
7. Uprościć kod formularzy. Jak?
Obejrzeć screencast R. Batesa [Simple Form](http://railscasts.com/episodes/234-simple-form).
Następnie zamienić wygenerowane formularze na formularze korzystajęce
z metod [tego gemu](http://github.com/plataformatec/simple_form).
Skorzystać z jednego z gemów:
   * [Chosen](http://harvesthq.github.com/chosen/) – plugin that makes long,
   unwieldy select boxes much more user-friendly
   * [jQuery Tokeninput](http://loopj.com/jquery-tokeninput/) – allows
   your users to select multiple items from a predefined list, using
   autocompletion as they type to find each item


### Trekking

O co może chodzić w aplikacji Trekking? Najprościej jest przekonać się
samemu wchodząc na stronę
[Google Maps JavaScript API v3 Example: Elevation](http://www.geocodezip.com/v3_elevation-profile_distance.html).

Użyteczne linki:

* [gmaps.js](http://hpneo.github.com/gmaps/) – the easiest way to use Google Maps
  ([źródło + kod przykładów](https://github.com/HPNeo/gmaps))
* [Geocoder Asciicast](http://railscasts.com/episodes/273-geocoder?view=asciicast)
* [Cartographer](https://github.com/joshuamiller/cartographer)
* [Map Icons Collection](http://mapicons.nicolasmollet.com/)

### Przechodzimy na nierelacyjną bazę danych

W swojej aplikacji zamienić relacyjną bazę danych na dokumentową bazę
danych, na przykład MongoDB, albo Redis, albo jakąś inną.

Kilka linków dla wariantu z bazą MongoDB:

* dokumentacja do gemu [Mongo](http://api.mongodb.org/ruby/current/)
* screencast R. Batesa, [Mongoid](http://railscasts.com/episodes/238-mongoid).


# Różne fajne rzeczy

1\. Rozszerzenia do przeglądarki Firefox:

* [Firebug](http://getfirebug.com/)
* [FireQuery](https://addons.mozilla.org/en-US/firefox/addon/firequery/)

2\. Rozszerzenia do przeglądarki Chrome:

* [PageSpeed](http://code.google.com/intl/pl-PL/speed/page-speed/docs/using_chrome.html)
* [Yslow](http://developer.yahoo.com/yslow/)

Sprawdzić jaką ocenę uzyska aplikacja od *YSlow* a jaką – od *PageSpeed*.
Zacząć od [Page Speed Online](http://pagespeed.googlelabs.com/pagespeed/).
*Ciekawy ekperyment:*
Jaką ocenę uzyskuje strona [Instytutu Informatyki](http://inf.ug.edu.pl/)
od [PageSpeed Online](http://pagespeed.googlelabs.com/pagespeed/)?

3\. *Faye* — a subscription/publishing server which makes it easy to do
push notifications within a Rails application:

* Uruchomić aplikację przedstawioną na screencaście R. Batesa,
  [Messaging with Faye](http://railscasts.com/episodes/260-messaging-with-faye).
* Odać „nieco prywatności” do tej aplikacji.
  W tym celu skorzystać z gemu [private_pub](https://github.com/ryanb/private_pub) –
  *handle pub/sub messaging through private channels in Rails*.
