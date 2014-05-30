#### {% title "Zadania" %}

1\. (Rozgrzewka) Zapoznać się z językiem Ruby, np.
rozwiązując wszystkie **٩(⊙_ʘ)۶** zadania na [Ruby Monk](http://rubymonk.com/).

2\. Aby otrzymać pozytywną ocenę z laboratorium należy:

1. Uruchomić dwie z trzech aplikacji omówionych na pierwszych
wykładach i opisanych [tutaj](http://wbzyl.inf.ug.edu.pl/rails4/zaczynamy).
2. Dodać do jednej z aplikacji rzeczy opisane w sekcji ***TODO***
i uruchomić tę aplikację na Sigmie w trybie produkcyjnym.
3. Wykonać pull request dopisując do pliku [README.md](https://github.com/rails4/asi)
link do działającej na Sigmie aplikacji.

Ostateczny termin wysłania pull request upływa **26.03.2014**.
Na ocenę bdb aplikację należy wdrożyć na [Heroku](https://www.heroku.com/).

<blockquote>
<p>
  Always code as if the guy who ends up maintaining your code will be
  a violent psychopath who knows where you live.
</p>
<p class="author">— Rick Osborne</p>
</blockquote>

3\. Wymagania dotyczące egzaminu opisane są w pliku
*README.md* z repozytorium [ASI](https://github.com/rails4/asi).

<!--

3\. Aby uzyskać pozytywną ocenę z egzaminu należy:

1. Wdrożyć na [Heroku](https://www.heroku.com/)
lub [Shelly Cloud](https://shellycloud.com/)
aplikację napisaną w [Ruby on Rails](http://rubyonrails.org/)
z testami napisanymi w [rspec-rails](https://github.com/rspec/rspec-rails).
2. Kod aplikacji umieścić w repozytorium na Githubie.
Aplikację należy przygotowywać w trybie Agile
(najpierw piszemy testy; będzie można to sprawdzić przeglądając logi).
3. Wykonać pull request dopisując do pliku [README.md](https://github.com/rails4/asi)
link do repozytorium z kodem wdrożonej aplikacji i link do wdrożonej
(i działającej) aplikacji.

Ostateczny termin wysłania pull request upływa **21.05.2014**.

-->

Zalecane jest przygotowanie projektu w małym (2–4 osobowym) zespole.
*Commit messages* należy pisać stosując się do wskazówek opisanych
tutaj – [Shiny new commit styles](https://github.com/blog/926-shiny-new-commit-styles)
i tutaj – [A Note About Git Commit Messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).


## Wdrażanie aplikacji na *Shelly Cloud*

TODO


<blockquote>
{%= image_tag "/images/ralph-waldo-emerson.jpg", :alt => "[Ralph Waldo Emerson]" %}
<p>
  Jeśli ktoś potrafi napisać lepszą książkę, wygłosić lepsze kazanie,
  albo sporządzić lepszą pułapkę na myszy niż jego sąsiad, to choćby
  zbudował swój dom w lesie, świat wydepcze ścieżkę do jego drzwi.
</p>
<p class="author">— Ralph Waldo Emerson (1803–1882)</p>
</blockquote>

## rvm – Ruby Version Manager

1\. Sprawdzamy instalację języka Ruby na Sigmie.

Wykonujemy polecenie:

    :::bash
    rvm list

Wynik wykonania tego polecenia powinien być taki:

    :::bash
    rvm rubies

    =* ruby-2.1.0 [ x86_64 ]

    # => - current
    # =* - current && default
    #  * - default

Inne użyteczne polecenia:

    :::bash terminal
    rvm current
    rvm disk-usage total
    rvm env

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

Opuszczamy konsolę:

    :::ruby
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
    rvm install 2.1.0

Pozostałe szczegóły instalacji opisano {%= link_to "tutaj", "/konfiguracja" %}.

2\. Instalujemy RVM i Ruby w wersjach 2.0.0 i 2.1.0 na swoim komputerze.
