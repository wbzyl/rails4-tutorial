#### {% title "Konfiguracja środowiska dla Rails 3" %}

W użyciu jest wiele implementacji i wersji języka Ruby. Dla przykładu:
Ruby MRI w wersjach 1.8.7, 1.9.2, Ruby Enterprise Edition – 1.8.7,
jRuby – 1.5.0, Rubinius – 1.0.1, MagLev, IronRuby – 1.0.  Po trosze
wynika to z popularności frameworka Ruby on Rails.

Ruby Version Manager umożliwia zainstalowanie i przełączanie
się między różnymi implementacjami i wersjami języka Ruby.
Jest to ważne teraz, ponieważ aktualnie przechodzimy z wersji
1.8.7 na wersję 1.9.2.

Zanim zaczniemy pracę z Ruby on Rails powinniśmy też skonfigurować
konsolę języka Ruby (**irb**) oraz konsolę frameworka Ruby on Rails
(**rails console**).


# RVM – Ruby Version Manager

Dlaczego [RVM] [rvm]?
„RVM helps ensure that all aspects of ruby are completely contained
within user space, strongly encouraging **non-root usage**.”

Podstawowe polecenia RVM:

    :::shell-unix-generic
    rvm install ree    # alias na ostatnią wersję, np. ree-1.8.7-2011.03
    rvm install 1.9.2  # alias na ostatnią wersję, np. ruby-1.9.2-p180
    rvm list
    rvm use ree
    rvm current

Potrzebujemy więcej szczegółów:

    :::shell-unix-generic
    rvm env
    ruby -v
    which ruby
    rvm disk-usage all
      Downloaded Archives Usage: 4,0K
      Extracted Source Code Usage: 4,0K
      Log Files Usage: 4,0K
      Rubies Usage: 96M
      Gemsets Usage: 306M
      Total Disk Usage: 404M

Na koniec ustawiamy domyślną wersję Ruby:

    :::shell-unix-generic
    rvm --default use 1.9.2

Po instalacji w ścieżce *PATH* powinny pojawić się katalogi:

    echo $PATH
    ...
    HOME/.rvm/gems/ruby-1.9.2-p180/bin:
    HOME/.rvm/gems/ruby-1.9.2-p180@global/bin:
    HOME/.rvm/rubies/ruby-1.9.2-p180/bin:
    HOME/.rvm/bin:
    ...

Dla każdego projektu rails powinniśmy w katalogu głównym aplikacji
umieścić plik *.rvmrc*, na przykład:

<pre>rvm ruby-1.9.2-p180
</pre>

Więcej o konfiguracji:

* Ryan McGeary.
  [“Vendor Everything” Still Applies](http://ryan.mcgeary.org/2011/02/09/vendor-everything-still-applies/)
* Jérémy Lecour.
  [„Advice on using Ruby, RVM, Passenger, Rails, Bundler, … in development”](http://jeremy.wordpress.com/2010/08/19/ruby-rvm-passenger-rails-bundler-in-development/).
* Wayne E. Segui.
  [RVM: Ruby Version Manager – rvmrc](http://rvm.beginrescueend.com/workflow/rvmrc/).
* Balazs Nagy. [Vendoring gems with style](http://blog.js.hu/2011/05/18/vendoring-gems-with-style/) –
  z bloga warto zapamiętać te polecenia:

        bundle exec gem install bundler
        bundle show bundler


## Zestawy gemów

W trakcie instalacji dla każdej wersji Rubiego
tworzone są dwa zestawy gemów (ang. *gemset*):

* **default** (domyślny, bez nazwy)
* **global**

Do zestawu **global** dodajemy gemy używane
we wszystkich projektach. Na przykład

    rvm use ruby-1.9.2-p180@global
    gem install bundler rack bundler
    rvm use ruby-1.9.2-p180


## Gemy & Bundler

Gemy instalujemy za pomocą polecenia:

    :::shell-unix-generic
    bundle install --path=$HOME/.gems

Albo lokalnie, w aplikacji:

    :::shell-unix-generic
    bundle install --path=.bundle/gems


Od tej chwili, polecenie *bundle* będzie instalować gemy
w podanej lokalizacji.


# RVM na Sigmie

Po zastosowaniu opisanej powyżej konfiguracji do Sigmy
obserwujemy, że wszystkie polecenia działają **bardzo, bardzo wolno**.

Jakie jest tego powód łatwo stwierdzić, wykonując na przykład
takie polecenia:

    :::shell-unix-generic
    strace rails new slow
    cd slow
    strace rails server

Aby temu zaradzić na Sigmie została zainstalowana wersja „system wide RVM”.
Po przejściu na tę wersję, polecenia powinny się szybciej uruchamiać.


## System wide RVM krok po kroku

Usuwamy katalog z instalacją RVM (zwalniamy ok. 250 MB):

    :::shell-unix-generic
    rm -rf ~/.rvm

W plikach *~/.bashrc* oraz *~/.bashrc_profile* wykomentowujemy wiersz:

    :::shell-unix-generic
    [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

Zamiast niego wstawiamy wiersz:

    :::shell-unix-generic
    [[ -s /usr/local/lib/rvm ]] && source /usr/local/lib/rvm

Dla instalacji „system wide”, powinniśmy mieć w *PATH* katalogi:

    echo $PATH
    ...
    /usr/local/rvm/gems/ruby-1.9.2-p180/bin:
    /usr/local/rvm/gems/ruby-1.9.2-p180@global/bin:
    /usr/local/rvm/rubies/ruby-1.9.2-p180/bin:
    /usr/local/rvm/bin:
    /usr/local/rubyee/bin


# Konfiguracja konsoli

Oto moja konfiguracja konsoli (dla Ruby i dla Rails):

    :::ruby ~/.irbrc
    require 'rubygems'
    require 'wirble'
    require 'hirb'
    # start wirble (with color)
    Wirble.init
    Wirble.colorize
    Hirb.enable
    if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
      require 'logger'
      RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
    end

oraz gemów:

    :::ruby ~/.gemrc
    ---
    gem: --no-rdoc --no-ri
    :verbose: true
    :benchmark: false

**Uwaga:** Niestety, teraz oba gemy – *wirble* i *hirb*
trzeba będzie dopisywać do każdego pliku *Gemfile* aplikacji Rails.
Jest to uciążliwe. Ale jak to obejść?


## Dokumentacja online

Instalujemy gemy:

    gem install rdoc rdoc-data

Wykonujemy polecenia:

    rdoc-data

W katalogu *doc* aplikacji Rails tworzymy katalog *rails* z dokumentacją
API Rails oraz katalog *guides* z samouczkami:

    git clone git://github.com/rails/rails.git
    cd rails
    ... bundle install ...
    rake rdoc
    cd railties
    rake generate_guides

Zobacz też:

    gem help server

Sprawdzamy jak to działa:

    ri Array#each
    ri validates
    ri ActiveModel::Validations::ClassMethods#validates
    ri find


# Roadmap for Learning Rails

Roadmap specially designed for a beginner to navigate their way to Rails mastery.

{%= image_tag "/images/Learning-Rails-Roadmap.png", :alt => "[Learning Rails Roadmap]" %}

[Źródło](http://techiferous.com/2010/07/roadmap-for-learning-rails/)


[rvm]: http://rvm.beginrescueend.com/ "Ruby Version Manager"
