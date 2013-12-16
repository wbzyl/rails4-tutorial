#### {% title "RVM – zarządzanie wersjami Ruby+Rails" %}

W użyciu jest wiele implementacji i wersji języka Ruby. Dla przykładu:
Ruby MRI w wersjach 1.8.7, 1.9.3, 2.0.0, Ruby Enterprise Edition – 1.8.7,
jRuby – 1.5.0, Rubinius – 1.0.1, MagLev, IronRuby – 1.0.

Ruby Version Manager umożliwia zainstalowanie i przełączanie
się między różnymi implementacjami i wersjami języka Ruby.


# RVM – Ruby Version Manager

Dlaczego [RVM] [rvm]?
„RVM helps ensure that all aspects of ruby are completely contained
within user space, strongly encouraging **non-root usage**.”

Podstawowe polecenia RVM:

    :::bash
    rvm list known
    rvm install 2.0.0-p247
    rvm list

    rvm install 2.0.0-p353
    rvm gemset copy 2.0.0-p247 2.0.0-p353

    rvm use 2.0.0-p353

    rvm --default 2.0.0-p353    # ustawiamy domyślną wersję Ruby
    rvm remove --archive --gems 2.0.0-p247

    rvm docs generate           # generujemy dokumentację

<!--

    rvm docs generate-ri

[Instalacja patchowanej wersji Ruby](http://astrails.com/blog/2012/11/13/rvm-install-patched-ruby-for-faster-rails-startup):

    :::bash
    rvm get head # uaktualnij RVM
    ls $rvm_path/patches/ruby/1.9.3/p392
      railsexpress
    rvm install 1.9.3-p392 --patch railsexpress -n railsexpress

Łata railsexpress przyśpiesza uruchamianie aplikacji Rails.
Zobacz też
[Making your ruby fly](http://alisnic.net/blog/making-your-ruby-fly/) na blogu Andrei Lisnica.
Na przykład:

    :::bash
    time rake routes # 3.6s dla 1.9.3
    time rake routes # 1.7s dla 1.9.3 + railsexpress
    time rake routes # 1.9s dla 2.0.0

-->

Podstawowe informacje o zainstalowanych wersjach:

    :::bash
    rvm list
    rvm current

Więcej szczegółów:

    :::bash
    rvm env
    rvm disk-usage all # dla sześciu wersji języka ruby + gemy

        Downloaded Archives Usage: 39M
               Repositories Usage: 136M
      Extracted Source Code Usage: 1,1G
                  Log Files Usage: 1,5M
                   Packages Usage: 1,2M
                     Rubies Usage: 293M
                    Gemsets Usage: 1,7G
                   Wrappers Usage: 472K
            Temporary Files Usage: 4,0K
                Other Files Usage: 7,5M
                 Total Disk Usage: 3,2G

    rvm disk-usage total

      Total Disk Usage: 3,2G


## Zestawy gemów

W trakcie instalacji dla każdej wersji Rubiego
tworzone są dwa zestawy gemów (ang. *gemset*):

* **default** (domyślny, bez nazwy)
* **global**


## Rails & Bundler

Gemy możemy zainstalować lokalnie, na przykład w katalogu *.gems*:

    :::bash
    bundle install --path=$HOME/.gems

Od tej chwili, polecenie *bundle* będzie instalować gemy w podanej lokalizacji.


## RVM w stylu Gentoo-Linux

W Gentoo nie ma potrzeby instalowania ekstra kontrolera wersji [RVM].
Istnieje ogólno-systemowy mechanizm konfiguracji zainstalowanych pakietów.
W skrócie polega on tym, że pakiet który posiada opcje konfiguracji, dostarcza systemowemu
"kontenerowi konfiguracji" własny skrypt eselect.
Jest to elestyczny mechanizm który przy pomocy jednej komendy systemowej "eselect", pozwla
szybko zorientować się:

* jakie pakiety systemowe dostarczają opcje konfiguracji
* jakie opcje dostarcza wybrany pakiet

Zanim zobaczymy to w praktyce, przejdźmy całą ścieżkę od instalacji po konfigurację pakietu.


### Ruby on Rails w dystrybucji Gentoo

Prezentowany opis wyszukania pakietów, ich instalacji oraz sprawdzenia aktualnej konfiguracji,
pomija szczegóły związane z wersją systemu ( stabilna, niestabilna ) oraz
ustawieniami flag kompilacji (USE flags).


### Dostępne wersje Rubiego i Rails

Sprawdźmy w systemie jakie wersje: Ruby, Rails są dostępne.
Możemy to zrobić metodą:

(i) szybszą – wymaga zainstalowanego pakietu app-portage/eix który podczas
instalacji tworzy sobie bazę danych dostępnych pakietów:

    :::bash
    eix -e ruby
    eix -e rails

(ii) standardową – trwa dłużej, przeszukuje metadane pakietów:

    :::bash
    emerge -s ruby
    emerge -s rails


### Instalacja

Instalacja sprowadza się do wpisania poleceń:

    :::bash
    emerge dev-lang/ruby
    emerge dev-ruby/rails

lub w jednym kawałku:

    :::bash
    emerge emerge dev-lang/ruby dev-ruby/rails

Kod źródłowy pakietów zostanie pobrany, po czym uruchomiona zostanie
kompilacja której przebieg możemy śledzić na ekranie – widok radujący
serce każdego programisty.


### Sprawdzenie opcji konfiguracyjnych zainstalowanych wersji pakietów

Gentoo posiada wygodny mechanizm konfigurowania zainstalowanych
pakietów.  Służy do tego polecenie „eselect”. Wywołanie polecenia bez
parametrów, wyświetli nam listę dostępnych do konfiguracji pakietów
lub ustawień systemowych.

Na przykład polecenie:

    :::bash
    eselect ruby

wyświetli:

    :::bash
    Usage: eselect ruby <action> <options>

    Standard actions:
      help                      Display help text
      usage                     Display usage information
      version                   Display version information

    Extra actions:
      cleanup                   This action is not to be called manually.
      list                      Lists available Ruby profiles.
      set <target>              Switches to a ruby profile.
            target                  Target name or number (from 'list' action)
      show                      Prints the current configuration.

Podobnie polecenie:

    :::bash
    eselect rails

wyświetli:

    :::bash
    Usage: eselect rails <action> <options>

    Standard actions:
      help                      Display help text
      usage                     Display usage information
      version                   Display version information

    Extra actions:
      list                      List available Ruby on Rails versions
      set <target>              Set a new Ruby on Rails version
            target                  Target name or number (from 'list' action)
      show                      Manage Ruby on Rails versions
      update                    Updates the rails symlink to the latest version
                available

Jeśli przeprowadzone przez nas instalacje, były kolejnymi instalacjami
wersji tych pakietów, to z pomocą eselect możemy wybrać wersję Ruby
i Rails na której zamierzamy pracować.
