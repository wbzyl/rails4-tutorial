# Zaczynamy  – luty 2017!

<blockquote>
  {%= image_tag "/images/coding-horror.jpg", :alt => "[Rails for Zombies]", :width => "300" %}
  <p>Any application that can be written in JavaScript,
    will eventually be written in JavaScript.</p>
  <p class="author"><a href="http://www.codinghorror.com/blog/2009/08/all-programming-is-web-programming.html">Atwood’s Law (2007)</a></p>
</blockquote>

* [World Wide Web](http://info.cern.ch/) – zobacz jak wyglądała pierwsza strona WWW
* Pierwsze aplikacje WWW – CGI ↬ PHP (≈ 2000 r.)
* [Comparison of web application frameworks](http://en.wikipedia.org/wiki/Comparison_of_web_application_frameworks)
* Potrzebne nam gemy można wyszukać na [The Ruby Toolbox](https://www.ruby-toolbox.com/).
* [Polskie forum Ruby on Rails](http://forum.rubyonrails.pl/)
* [Rails Rumble](http://blog.railsrumble.com/); [check winners](http://railsrumble.com/entries/winners)
* [Who is already on Rails?](http://rubyonrails.org/applications):
  - [GitHub](https://github.com/) – ok. 4 mln programistów
  - [Twitter](https://twitter.com/) – „hits half a billion tweets a day” (26.10.2012)
* [Try Elixir](https://www.codeschool.com/courses/try-elixir/) and
  [Phoenix](http://www.phoenixframework.org) – alternatywa?


## Praktyczne rzeczy…

Nie znasz języka Ruby – zacznij od [Try Ruby!](http://tryruby.org/)
lub zmierz się z [Ruby Monk](http://rubymonk.com/);
albo przeczytaj [Learn Ruby The Hard Way](http://ruby.learncodethehardway.org/) (Zed A. Shaw)
lub [Learn to Program](http://pine.fm/LearnToProgram/) (Chris Pine).

Nigdy nie używałeś frameworka MVC. Zacznij od kursu
[Rails for Zombies](http://www.codeschool.com/courses/rails-for-zombies-redux).

Aplikacje WWW będziemy pisać w **Ruby on Rails** w wersji **5.0+**
i w Ruby w wersji **2.3.0**.

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

1. {%= link_to "Zapoznajemy się z językiem Ruby", "/ruby20" %}
1. {%= link_to "Wysyłanie poczty", "/mail" %}
1. {%= link_to "FormBuilder v. gem simple_form", "/form-builder" %}
1. {%= link_to "Konfiguracja środowiska dla Rails", "/konfiguracja" %}.

Programowanie aplikacji Ruby on Rails wymaga odpowiedniego skonfigurowania edytora.
Konfiguracja edytora Emacs w wersji co najmniej v24.1 jest prosta:
`M-x package-list-packages` i z listy wybieramy i instalujemy pakiet
[Rinari](http://rinari.rubyforge.org/Navigation.html).
Równie prosto konfiguruje się edytor {%= link_to "Sublime Text 2", "/sublime_text" %}.


<blockquote>
  <p>
    Jeden z wykładowców powiedział mi, że człowiek
    zaczyna używać dopiero rozumu, kiedy kończą mu się
    wszystkie możliwości. Wcześniej korzysta tylko z procedur.
  </p>
  <p class="author">— Robert Krool</p>
</blockquote>


## Misz masz…

* [TIOBE Programming Community Index](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html)
* [Examples of how to build PDFs in Rails with Prawn and Prawnto](http://prawn.heroku.com/)
* [Exploring the stdlib: logger](http://rbjl.net/50-exploring-the-stdlib-logger)
* Evan Miller.
  [How Not To Sort By Average Rating](http://evanmiller.org/how-not-to-sort-by-average-rating.html)
* [Code Climate Blog](http://blog.codeclimate.com/):
  [7 Patterns to Refactor Fat ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
