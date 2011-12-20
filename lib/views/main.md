# Prezentacje – 9.01, 16.01

<blockquote>
  {%= image_tag "/images/why.jpg", :alt => "[_Why]" %}
  <p>
    When you don’t create things, you become defined by your tastes
    rather than ability. Your tastes only narrow and exclude people.
    So create.
  </p>
  <p class="author"><a href="http://www.smashingmagazine.com/2010/05/15/why-a-tale-of-a-post-modern-genius/">— Why the Lucky Stiff</a></p>
</blockquote>

Poniżej wpisałem **orientacyjne** godziny rozpoczęcia prezentacji.

<table class="span-16" summary="harmonogram">
  <colgroup>
    <col class="table1"/>
    <col class="table2"/>
  </colgroup>
  <caption><em>Harmonogram prezentacji</em></caption>
  <thead>
  </thead>

<tbody>

 <tr>
 <td>10:15–10:30 <b>(9.01)</b></td>
 <td>Dragonborn</td>
 </tr>

 <tr>
 <td>10:30–10:45 <b>(9.01)</b></td>
 <td>ZTM</td>
 </tr>

 <tr>
 <td>10:45–11:00 <b>(9.01)</b></td>
 <td>Panda50</td>
 </tr>

 <tr>
 <td>11:00–11:15 <b>(9.01)</b></td>
 <td>Tańczący z Railsami</td>
 </tr>

 <tr>
 <td>11:15–11:30 <b>(9.01)</b></td>
 <td>Zadziory</td>
 </tr>

 <tr>
 <td>11:30–11:45 <b>(9.01)</b></td>
 <td>Grupa Zła</td>
 </tr>

 <tr>
 <td>11:45–12:00 <b>(9.01)</b></td>
 <td>Unnamed</td>
 </tr>

 <tr>
 <td></td>
 <td></td>
 </tr>

 <tr>
 <td>10:15–10:30 <b>(16.01)</b></td>
 <td>Inception</td>
 </tr>

 <tr>
 <td>10:30–10:45 <b>(16.01)</b></td>
 <td>MotoMyszy z Marsa</td>
 </tr>

 <tr>
 <td>10:45–11:00 <b>(16.01)</b></td>
 <td>Git-is-Git</td>
 </tr>

 <tr>
 <td>11:00–11:15 <b>(16.01)</b></td>
 <td>Pejdżer</td>
 </tr>

 <tr>
 <td>11:15–11:30 <b>(16.01)</b></td>
 <td>Pod Murzynem</td>
 </tr>

 <tr>
 <td>11:30–11:45 <b>(16.01)</b></td>
 <td>Somateria</td>
 </tr>

 <tr>
 <td>11:45–12:00 <b>(16.01)</b></td>
 <td>???</td>
 </tr>

</tbody>
</table>

[Proponowana forma prezentacji](http://philip.greenspun.com/seia/writeup):

* *Elevator pitch* (30 sekund).
  Wyjaśnić jaki problem został rozwiązany
  i dlaczego prezentowane rozwiązanie jest lepsze od już istniejących.
* Demo gotowej aplikacji (5 minut)
  (Należy powiedzieć czy aplikacja została wdrożona czy nie).
* Slajd architektury systemu oraz użytych komponentów
  (2 minuty).
* Omówienie najtrudniejszych wyzwań technicznych projektu
  i jak zostały one rozwiązane (2 minuty, dodatkowe slajdy)
* Przyszłość (1 minuta).
  Jakie są planowane następne „milestones”?
  Kto będzie rozwijał aplikację?


<!--

[2011.11.28] [Coding - the new Latin](http://www.bbc.co.uk/news/technology-15916677).

[2011.10.26] [Method chaining and lazy evaluation in Ruby](http://jeffkreeftmeijer.com/2011/method-chaining-and-lazy-evaluation-in-ruby/) –
we’ll write a library that can chain method calls to build up a
MongoDB query in this article.

[2011.10.21] Poprawioną wersję *Elevation* dla Rails umieściłem
[tutaj](https://gist.github.com/1303620).
Przygotowałem też szablon aplikacji korzystający z HTML5Boilerplate.
Na razie jest [tutaj](https://gist.github.com/1304698).

[2011.10.20] Coś do poczytania.
David Lynch, [XSS is fun!](http://davidlynch.org/blog/2011/10/xss-is-fun/).

[2011.10.18] RailsConf 2011,
[David Heinemeier Hansson](http://www.youtube.com/watch?v=cGdCI2HhfAU)
opowiada o nowych rzeczach w Rails 3.1
(styl programowania — *junk drawer*).

Nie czujesz się pewnie z Ruby — spróbuj swoich sił na [Try Ruby!](http://tryruby.org/)
albo na [Learn Ruby The Hard Way](http://ruby.learncodethehardway.org/).

Nigdy nie korzystałeś z frameworka MVC, wejdź na
[Rails for Zombies](http://www.codeschool.com/courses/rails-for-zombies).

Wszystkie projekty przygotowywane na zajęciach należy trzymać na swoim
koncie na *github.com*. (Oczywiście, wcześniej należy założyć tam
sobie konto.)

Projekty piszemy w **Rails** wersji co najmniej **3.1**.

Przed utworzeniem pierwszego repozytorium
należy podać Gitowi swoje **prawdziwe i aktualne** dane:

    git config --global user.name "Imię Nazwisko"
    git config --global user.email "twój aktualny email"


<a href="http://wbzyl.inf.ug.edu.pl/sp/git">Parę aliasów dla Gita i Bash’a</a>
oszczędzi nam wiele żmudnego wpisywania z klawiatury.

-->

**Legenda:** *[R-]* -- brak README.md z opisem funkcjonalności aplikacji.

# Rozpiska wykładów

1. {%= link_to "Zapoznajemy się z Ruby", "/ruby19" %}
1. {%= link_to "„Fortunka” v0.0", "/zaczynamy" %}
1. {%= link_to "Makieta aplikacji, czyli layout", "/layouty" %}
1. {%= link_to "Wyszukiwanie z ElasticSearch", "/elasticsearch" %}
1. {%= link_to "Mongoid + OmniAuth z autoryzacją przez GitHub", "/mongodb" %}
1. {%= link_to "TDD, BDD…", "/testowanie" %}
1. {%= link_to "ActiveRecord na konsoli", "/active-record" %}
1. {%= link_to "Krok po kroku odkrywamy Heroku", "/heroku" %}
1. {%= link_to "Remote links", "/remote-links" %}
1. {%= link_to "„Fortunka” v1.0", "/fortunka" %}
1. {%= link_to "„Blog” na dwóch modelach", "/2models" %}
1. {%= link_to "Wysyłanie poczty", "/mail" %}
1. {%= link_to "Autentykacja z Devise", "/devise" %}
1. {%= link_to "Autoryzacja z CanCan", "/cancan" %}
1. {%= link_to "I18n", "/i18n" %}
1. {%= link_to "FormBuilder v. gem simple_form", "/form-builder" %}
1. {%= link_to "Ajax & jQuery", "/ajax-jquery" %}

<!--

TODO:

1. {%= link_to "Aplikacja „Leniwiec” (klon pastie)", "/pastie" %}
1. {%= link_to "Aplikacja „Todo”", "/todo" %}
1. {%= link_to "Aplikacja „Blog”", "/blog" %}
1. {%= link_to "Aplikacja „Store”", "/store" %}
1. {%= link_to "Aplikacja „Ale kino”", "/ale-kino" %}
1. {%= link_to "Wyszukiwanie", "/searching" %}
1. {%= link_to "Bezpieczeństwo", "/security" %}
1. {%= link_to "Caching", "/caching" %}
1. {%= link_to "Walidacja", "/walidacja" %}
1. {%= link_to "Autentykacja z Authlogic", "/authlogic" %}
-->

<!--
1. {%= link_to "Mobile apps", "/mobile" %}
1. {%= link_to "Autoryzacja I", "/authorization" %}
1. {%= link_to "Autoryzacja II", "/declarative-authorization" %}
-->

Konfiguracja – RVM, konsola, dokumentacja online:

* {%= link_to "Konfiguracja środowiska dla Rails", "/konfiguracja" %}
* {%= link_to "Szablony aplikacji Rails", "/rails-templates" %}
  (gotowe szablony – [railswizard.org](http://railswizard.org/))

## Laboratoria

* {%= link_to "Zadania", "/zadania" %}


<blockquote>
  <p>
    Jeden z wykładowców powiedział mi, że człowiek
    zaczyna używać dopiero rozumu, kiedu kończą mu się
    wszystkie możliwości. Wcześniej korzysta tylko
    z procedur.
  </p>
  <p class="author">— Robert Krool</p>
</blockquote>

# Dokumentacja

Na początek zaczynamy od przeczytania
[Rails Guides (Edge)](http://guides.rails.info/):

1. [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html).
2. [Active Record Query Interface](http://guides.rubyonrails.org/active_record_querying.html).
3. [Rails Form helpers](http://guides.rubyonrails.org/form_helpers.html).
4. Dalej już według własnego uznania,
   wybieramy kolejny *Przewodnik* do przestudiowania.

Know your options! [The Ruby Toolbox](http://ruby-toolbox.com/).

[Is Your Code Ready For Rails 3.1?](http://www.railsplugins.org/).


<blockquote>
  {%= image_tag "/images/samuel-coleridge.jpg", :alt => "[_Why]" %}
  <p>
    [O komputerze Babbage’a]
    nowa poezja musi stworzyć nowy gust,
    zgodnie z którym zostanie doceniona.
  </p>
  <p class="author">— Samuel Coleridge (1772–1834)</p>
</blockquote>

## API

* [Rails Searchable API Doc](http://railsapi.com/)
* [Edge API](http://edgeapi.rubyonrails.org/)
* [API dock](http://apidock.com/) – Ruby on Rails, RSpec, Ruby


## Screencasty

* Ryan Bates. [Railscasts](http://railscasts.com/)
* [Rails Performance Resources](http://railslab.newrelic.com/) —
  Expert advice on tuning and optimizing your Rails app


## Podręczniki do Rails

* Michael Hartl.
  [Ruby on Rails Tutorial. Learn Rails by Example](http://www.railstutorial.org/book).


## Misc stuffisz masz

* [Rails 3 Application Templates](https://github.com/RailsApps/rails3-application-templates)
* [Examples of how to build PDFs in Rails with Prawn and Prawnto](http://prawn.heroku.com/)
* [Exploring the stdlib: logger](http://rbjl.net/50-exploring-the-stdlib-logger)


<blockquote>
 <p>
  TelescopicText is primarily a set of tools for creating expanding texts in a similar way.
 </p>
 <p class="author"><a href="http://www.telescopictext.org/">Telescopic text</a></p>
</blockquote>

## Pomysły na aplikacje WWW

Rails Rumble Leaderboard
[2009](http://r09.railsrumble.com/entries),
[2010](http://r10.railsrumble.com/entries):
The Rails Rumble is an annual 48 hour web application development
competition in which teams of skilled web application developers get
one weekend to design, develop, and deploy the best web property that
they can, using the power of Ruby and Rails.

Korzystamy z nierelacyjnych baz danych:

* Jim Neath.
  [Using Redis with Ruby on Rails](http://jimneath.org/2011/03/24/using-redis-with-ruby-on-rails.html)
* Ryan Bates.
  [Mongoid](http://railscasts.com/episodes/238-mongoid),
  [MongoDB and MongoMapper](http://railscasts.com/episodes/194-mongodb-and-mongomapper)


## Rails 3 stuff only

* [Rails Dispatch](http://www.railsdispatch.com/) – Rails
  news delivered fresh
  ([linki do wszystkich postów](http://www.railsdispatch.com/posts))
* [Rails Engines](http://edgeapi.rubyonrails.org/classes/Rails/Engine.html) –
  [How to build a rails 3 engine and set up test with rspec](http://olympiad.posterous.com/how-to-building-a-rails-3-engine-and-set-up-t),
  [Rails 3 Plugins - Part 2 - Writing an Engine](http://www.themodestrubyist.com/2010/03/05/rails-3-plugins---part-2---writing-an-engine/),
  [Create your own Rails3 engine (part 1)](http://ror-e.com/info/videos/5)
* [Rails 3: Fully Loaded](http://intridea.com/2011/5/13/rails3-gems) – lista najlepszych gemów dla Rails 3
* [Rails 3.0 and 3.1 Example Apps and Tutorials](http://railsapps.github.com/)

Najświeższe posty:

* [Blog w 20 minut](http://www.railsdispatch.com/posts/rails-3-makes-life-better)
  (wideo [Build a Blog Update](http://vimeo.com/10732081))
* [How Rails 3 Enables More Choices](http://www.railsdispatch.com/posts/how-rails-3-enables-more-choices-part-1) (part 1)


[railsplugins]: http://www.railsplugins.org/ "Is Your Plugin Ready For Rails 3?"
