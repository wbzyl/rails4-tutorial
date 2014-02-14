#### {% title "Zadania" %}

<blockquote>
<p>
  Always code as if the guy who ends up maintaining your code will be
  a violent psychopath who knows where you live.
</p>
<p class="author">— Rick Osborne</p>
</blockquote>

1\. Rozgrzewka – Zapoznajemy się z językiem Ruby:

* Rozwiązać wszystkie zadania na [Ruby Monk](http://rubymonk.com/).

2\. Aby otrzymać pozytywną ocenę z laboratorium należy:

1. Uruchomić dwie z trzech aplikacje omówionych na pierwszych
  wykładach i opisanych [tutaj](http://wbzyl.inf.ug.edu.pl/rails4/zaczynamy).
2. Wybrać jedną z tych aplikacji i wdrożyć ją na [ShellyCloud](https://shellycloud.com/).
3. Dodać do wybranej aplikacji rzeczy opisane w sekcji ***TODO***.
4. Wykonać pull request do [tego repozytorium](https://github.com/rails4/asi)
  z linkiem do swojego repozytorium z kodem wdrożonej aplikacji.
  Ostateczny termin wysłania pull request upływa **26.03.2014**.

3\. Aby uzyskać pozytywną ocenę z egzaminu należy:

1. Wdrożyć aplikację napisaną w Ruby on Rails z testami napisanymi w RSpec.
  Kod aplikacji umieścić w repozytorium na Githubie.
  Aplikację należy przygotowywać w trybie Agile (najpierw piszemy testy).
2. Wykonać pull request do [tego repozytorium](https://github.com/rails4/asi)
  z linkiem do repozytorium z kodem wdrożonej aplikacji
  i linkiem do działającej aplikacji.
  Ostateczny termin wysłania pull request upływa **21.03.2014**.

Zalecane jest przygotowanie projektu w małym zespole (2–4 osobowym).


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

    :::bash terminal
    rvm list

Wynik wykonania tego polecenia powinien być taki:

    rvm rubies

    =* ruby-2.1.0 [ x86_64 ]

    # => - current
    # =* - current && default
    #  * - default

Inne użyteczne polecenia:

    rvm current
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
    rvm install 2.1.0

Pozostałe szczegóły instalacji opisano {%= link_to "tutaj", "/konfiguracja" %}.

2\. Instalujemy RVM i Ruby w wersjach 2.0.0 i 2.1.0 na swoim komputerze.
