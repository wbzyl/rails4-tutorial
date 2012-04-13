# Zaczynamy !

<blockquote>
  {%= image_tag "/images/matz-stallman.jpg", :alt => "[FSF 2011 Awards]" %}
  <p class="author">Yukihiro Matsumoto i Richard Stallman</p>
</blockquote>

[01.04.2012] [Rails 3.2.3 has been released](http://news.ycombinator.com/item?id=3780963) –
nowe wartości domyślne dla atrybutów, które są „accessible via mass assignment”.
Zainstalować dodatek [Tamper Data](https://addons.mozilla.org/pl/firefox/addon/tamper-data/).

[31.03.2012] [2011 Free Software Awards announced ](http://www.fsf.org/news/2011-free-software-awards-announced):
„This year, it was given to Yukihiro Matsumoto (aka Matz), the creator
of the Ruby programming language. Matz has worked on GNU, Ruby, and
other free software for over 20 years. He accepted the award in person
and spoke at the conference on his early experiences with free
software, especially the influence of GNU Emacs on Ruby.”

[31.03.2102] [20 Best Sites Built with Ruby on Rails](http://www.developerdrive.com/2011/09/20-best-sites-built-with-ruby-on-rails/).

[10.03.2012] W rozdziale [Filling in the layout](http://ruby.railstutorial.org/chapters/filling-in-the-layout?version=3.2#top),
książki M. Hartl’a, *Ruby on Rails Tutorial* opisano jak
użyć [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/) w swojej aplikacji.
Przy okazji można pobrać
[Font Awesome](http://fortawesome.github.com/Font-Awesome/) z ikonkami
specjalnie zaprojektowanymi dla tego frameworka.

[14.02.2012] [ror_ecommerce 1.0](http://www.ror-e.com/posts/26)

[10.02.2012] [Spree 1.0.0 Released](http://spreecommerce.com/blog/2012/02/09/spree-1-0-0-released/).


## Praktyczne rzeczy…

Nie czujesz się pewnie z Ruby — spróbuj swoich sił na [Try Ruby!](http://tryruby.org/);
albo na [Learn Ruby The Hard Way](http://ruby.learncodethehardway.org/) (autor Zed A. Shaw);
albo coś prostszego [Learn to Program](http://pine.fm/LearnToProgram/) (Chris Pine).

Nigdy nie korzystałeś z frameworka MVC, wejdź na
[Rails for Zombies](http://www.codeschool.com/courses/rails-for-zombies).

Wszystkie projekty przygotowywane na zajęciach należy trzymać na swoim
koncie na *github.com*.
Oczywiście, wcześniej należy założyć tam sobie konto.

Aplikacje tworzymy w **Rails** w wersji co najmniej **3.2.1**.

Przed utworzeniem pierwszego repozytorium
należy podać Gitowi swoje **prawdziwe i aktualne** dane:

    git config --global user.name "Imię Nazwisko"
    git config --global user.email "twój aktualny email"

<a href="http://wbzyl.inf.ug.edu.pl/sp/git">Parę aliasów dla Gita i Bash’a</a>
oszczędzi nam wiele żmudnego wpisywania z klawiatury.


<blockquote>
  {%= image_tag "/images/why.jpg", :alt => "[_Why]" %}
  <p>
    When you don’t create things, you become defined by your tastes
    rather than ability. Your tastes only narrow and exclude people.
    So create.
  </p>
  <p class="author"><a href="http://www.smashingmagazine.com/2010/05/15/why-a-tale-of-a-post-modern-genius/">— Why the Lucky Stiff</a></p>
</blockquote>

# Rozpiska wykładów

1. {%= link_to "Zapoznajemy się z Ruby", "/ruby19" %}
1. {%= link_to "„Fortunka” v0.0", "/zaczynamy" %}
1. {%= link_to "ActiveRecord na konsoli", "/active-record" %}
1. {%= link_to "Krok po kroku odkrywamy Heroku", "/heroku" %}
1. {%= link_to "Layout, czyli makieta aplikacji", "/layouty" %}
1. {%= link_to "Bootstraping Rails application", "/bootstraping" %}
1. {%= link_to "Remote links", "/remote-links" %}
1. {%= link_to "„Fortunka” v1.0", "/fortunka" %}
1. {%= link_to "Fortunka i18n & l10n", "/i18n" %}
1. {%= link_to "TDD, BDD…", "/testowanie" %}
1. {%= link_to "Mongoid + OmniAuth z autoryzacją przez GitHub", "/mongodb" %}
1. {%= link_to "„Blog” na dwóch modelach", "/2models" %}
1. {%= link_to "Wysyłanie poczty", "/mail" %}
1. {%= link_to "Autentykacja z Devise", "/devise" %}
1. {%= link_to "Autoryzacja z CanCan", "/cancan" %}
1. {%= link_to "FormBuilder v. gem simple_form", "/form-builder" %}

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
1. {%= link_to "Ajax & jQuery", "/ajax-jquery" %}
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

Zaczynamy od [Rails Guides](http://guides.rails.info/):

1. [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html).
2. [Active Record Query Interface](http://guides.rubyonrails.org/active_record_querying.html).
3. [Rails Form helpers](http://guides.rubyonrails.org/form_helpers.html).
4. Kolejny *Przewodnik* do przestudiowania wybieramy już według własnego uznania.
5. Michael Hartl.
   [Ruby on Rails Tutorial. Learn Rails by Example](http://www.railstutorial.org/book).


## Użyteczne rzeczy

* [The Ruby Toolbox](http://ruby-toolbox.com/) – know your options!
* [Responsive](http://mattkersley.com/responsive/) –
  web design testing tool
* [jsFiddle](http://jsfiddle.net/)– easy test you snippets before implementing


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


## Misz masz…

* [Rails 3 Application Templates](https://github.com/RailsApps/rails3-application-templates)
* [Examples of how to build PDFs in Rails with Prawn and Prawnto](http://prawn.heroku.com/)
* [Exploring the stdlib: logger](http://rbjl.net/50-exploring-the-stdlib-logger)
* [PubSub Chat Using HTML5 Web Socket and em-websocket](http://railstech.com/2011/12/pubsub-chat-using-html5-web-socket-and-em-websocket/)
* Evan Miller.
  [How Not To Sort By Average Rating](http://evanmiller.org/how-not-to-sort-by-average-rating.html)
* [What is Ember.js?](http://emberjs.com/)


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
