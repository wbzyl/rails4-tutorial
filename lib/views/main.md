# 20.02.2014 – zaczynamy !

<blockquote>
  {%= image_tag "/images/coding-horror.jpg", :alt => "[Rails for Zombies]", :width => "300" %}
  <p>Any application that can be written in JavaScript,
    will eventually be written in JavaScript.</p>
  <p class="author"><a href="http://www.codinghorror.com/blog/2009/08/all-programming-is-web-programming.html">Atwood’s Law (2007)</a></p>
</blockquote>

* [World Wide Web](http://info.cern.ch/) – zobacz jak wyglądała pierwsza strona WWW
* Pierwsze aplikacje WWW – CGI ↬ PHP (≈ 2000 r.)
* [Comparison of web application frameworks](http://en.wikipedia.org/wiki/Comparison_of_web_application_frameworks)
* [Ruby on Rails](http://rubyonrails.org/download):
  - [API](http://api.rubyonrails.org/)
  - [Rails Guides](http://edgeguides.rubyonrails.org/)
  - Michael Hartl,
  [Ruby on Rails Tutorial](http://ruby.railstutorial.org/ruby-on-rails-tutorial-book?version=4.0) –
  *Learn Rails by Example*
* Potrzebne nam gemy wyszukujemy na [The Ruby Toolbox](https://www.ruby-toolbox.com/).
* [RSpec](http://rspec.info/) – a testing tool for the Ruby programming language;
  [RSpec Rails](https://www.relishapp.com/rspec/rspec-rails/docs)
* [Polskie forum Ruby on Rails](http://forum.rubyonrails.pl/)
* [Rails Rumble](http://blog.railsrumble.com/); [check winners](http://railsrumble.com/entries/winners)
* [Who is already on Rails?](http://rubyonrails.org/applications):
  - [GitHub](https://github.com/) – ok. 4 mln programistów
  - [Twitter](https://twitter.com/) – „hits half a billion tweets a day” (26.10.2012)
* [Nitrous.io](https://www.nitrous.io/) – coding on remote boxes
* Dave Kennedy,
  [Give Vagrant a Place in Your Workflow](http://rubysource.com/give-vagrant-a-place-in-your-workflow/)
* [Docker](https://www.docker.io/) – an open source project to pack,
  ship and run any application as a lightweight container


## Praktyczne rzeczy…

Nie znasz języka Ruby – zacznij od [Try Ruby!](http://tryruby.org/)
lub zmierz się z [Ruby Monk](http://rubymonk.com/);
albo przeczytaj [Learn Ruby The Hard Way](http://ruby.learncodethehardway.org/) (Zed A. Shaw)
lub [Learn to Program](http://pine.fm/LearnToProgram/) (Chris Pine).

Nigdy nie używałeś frameworka MVC. Zacznij od kursu
[Rails for Zombies](http://www.codeschool.com/courses/rails-for-zombies-redux).

Aplikacje WWW będziemy pisać w **Ruby on Rails** w wersji **4.0.3**
i w Ruby w wersji **2.1.0**.

*Uwaga:* Przed utworzeniem pierwszego repozytorium Git
na swoim komputerze należy podać Gitowi swoje dane.
W tym celu wpisujemy na konsoli:

    git config --global user.name "Imię Nazwisko"
    git config --global user.email "twój aktualny email"

<a href="http://wbzyl.inf.ug.edu.pl/sp/git">Kilka aliasów dla Gita i Bash’a</a>
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

1. {%= link_to "Zapoznajemy się z językiem Ruby", "/ruby20" %}
1. {%= link_to "RVM - zarządzanie wersjami Rails i Ruby", "/rvm" %}
1. {%= link_to "Kilka prostych przykładów", "/zaczynamy" %}
1. {%= link_to "„Fortunka” v0.0", "/fortunka0" %}
1. {%= link_to "Odpowiedzi zależne od nagłówka MIME", "/respond_to" %}
1. {%= link_to "ActiveRecord na konsoli", "/active-record" %}
1. {%= link_to "Krok po kroku odkrywamy Heroku", "/heroku" %}
1. {%= link_to "Layout, czyli makieta aplikacji", "/layouty" %}
1. {%= link_to "Remote links", "/remote-links" %}
1. {%= link_to "Fortunka i18n & l10n", "/i18n" %}
1. {%= link_to "„Fortunka” v1.0", "/fortunka1" %}
1. {%= link_to "Autentykacja z Devise", "/devise" %}
1. {%= link_to "Autoryzacja z CanCan", "/cancan" %}
1. {%= link_to "Wyszukiwanie pełnotekstowe z PostgreSQL", "/pg-search" %}
1. {%= link_to "Mongoid + OmniAuth z autoryzacją przez GitHub", "/mongodb" %}

Różne rzeczy:

1. {%= link_to "Wysyłanie poczty", "/mail" %}
1. {%= link_to "FormBuilder v. gem simple_form", "/form-builder" %}
1. {%= link_to "Konfiguracja środowiska dla Rails", "/konfiguracja" %}.

Programowanie aplikacji Ruby on Rails wymaga odpowiedniego skonfigurowania edytora.
Konfiguracja edytora Emacs w wersji co najmniej v24.1 jest prosta:
`M-x package-list-packages` i z listy wybieramy i instalujemy pakiet
[Rinari](http://rinari.rubyforge.org/Navigation.html).
Równie prosto konfiguruje się edytor {%= link_to "Sublime Text 2", "/sublime_text" %}.

<!--

TODO:

1. {%= link_to "TDD, BDD…", "/testowanie" %}
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
1. {%= link_to "„Blog” na dwóch modelach", "/2models" %}
-->

<!--
1. {%= link_to "Mobile apps", "/mobile" %}
1. {%= link_to "Autoryzacja I", "/authorization" %}
1. {%= link_to "Autoryzacja II", "/declarative-authorization" %}
-->


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
4. Kolejny *przewodnik* do przestudiowania wybieramy już według własnego uznania.
5. Stefan Wintermeyer.
   [Ruby on Rails 3.2](http://xyzpub.com/en/ruby-on-rails/3.2/) – a beginner’s guide.
6. [Ruby on Rails for Developers](https://github.com/generalassembly/ga-ruby-on-rails-for-devs) –
   this course teaches experienced developers Ruby and Ruby on Rails.


## Użyteczne linki

* [The Ruby Toolbox](http://ruby-toolbox.com/) – know your options!
* [GitHub Style Guides](https://github.com/styleguide/)
* Greg Heileman.
  [Web Application Architectures](https://www.coursera.org/course/webapplications)


## API

* [Rails Searchable API Doc](http://railsapi.com/)
* [Edge API](http://edgeapi.rubyonrails.org/)
* [API dock](http://apidock.com/) – Ruby on Rails, RSpec, Ruby


<blockquote>
  {%= image_tag "/images/samuel-coleridge.jpg", :alt => "[_Why]" %}
  <p>
    [O komputerze Babbage’a]
    nowa poezja musi stworzyć nowy gust,
    zgodnie z którym zostanie doceniona.
  </p>
  <p class="author">— Samuel Coleridge (1772–1834)</p>
</blockquote>

## Screencasty

* Ryan Bates. [Railscasts](http://railscasts.com/)
* [Rails Performance Resources](http://railslab.newrelic.com/) —
  Expert advice on tuning and optimizing your Rails app
* Michael Hartl.
  [Using Sublime Text 2 with Ruby on Rails](http://www.youtube.com/watch?v=05x1Jk4rT1A)


## Misz masz…

* [TIOBE Programming Community Index](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html)
* [Examples of how to build PDFs in Rails with Prawn and Prawnto](http://prawn.heroku.com/)
* [Exploring the stdlib: logger](http://rbjl.net/50-exploring-the-stdlib-logger)
* Evan Miller.
  [How Not To Sort By Average Rating](http://evanmiller.org/how-not-to-sort-by-average-rating.html)
* [Code Climate Blog](http://blog.codeclimate.com/):
  [7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
