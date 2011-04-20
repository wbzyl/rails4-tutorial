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
within user space, strongly encouraging **non-root usage**. Use of RVM
rubies provide a higher level of system security and therefore reduce
risk and overall system downtime. Additionally, since all processes
run as the user, a compromised ruby process will not be able to
compromise the entire system.”

Podstawowe polecenia RVM:

    :::shell-unix-generic
    rvm install ree    # alias ree-1.8.7
    rvm install 1.9.2  # alias ruby-1.9.2
    rvm use ree
    rvm list
    rvm gemset list
    rvm gemset use NAZWA_ZESTAWU_GEMÓW
    rvm gemset name

Dodatkowo możemy sprawdzić:

    :::shell-unix-generic
    ruby -v
    which ruby
    rvm env

Ustawiamy domyślną wersję:

    :::shell-unix-generic
    rvm --default use 1.9.2

Dla każdego projektu rails powinniśmy w katalogu głównym aplikacji
umieścić plik *.rvmrc* o następującej zawartości:

<pre>rvm use ree  # jeśli zmieniamy wersję na starszą
rvm --create gemset use NAZWA_ZESTAWU_GEMÓW_DLA_PROJEKTU
</pre>

Dlaczego tak należy postępować opisał J. Lecour,
[„Advice on using Ruby, RVM, Passenger, Rails, Bundler, … in development”](http://jeremy.wordpress.com/2010/08/19/ruby-rvm-passenger-rails-bundler-in-development/).

Więcej na ten temat napisał autor RVM – Wayne E. Segui,
[RVM: Ruby Version Manager – rvmrc](http://rvm.beginrescueend.com/workflow/rvmrc/).


## Zestawy gemów

W trakcie instalacji dla każdej wersji Rubiego
tworzone są dwa zestawy gemów (ang. *gemset*):

* **default** (bez nazwy)
* **global**

Do zestawu *global* dodajemy gemy używane we wszystkich projektach:

    rvm use 1.9.2
    rvm gemset use global
    gem install bundler rails wirble hirb

I jeszcze raz powtarzamy tę procedurę. Teraz dla *ree*.


## Dodatkowa lektura

Należy przeczytać dokumentację pakietów:

* thin
* unicorn, rainbows (gemy)
* nginx (serwer www)
* passenger (moduł dla apache i nginx)
* jQuery (biblioteka Javascript)

oraz przejrzeć co Google ma do powiedzenia na temat tych rzeczy.


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
Po przejściu na tę wersję, polecenia powinny się szybko uruchamiać.


## System wide RVM krok po kroku

Usuwamy katalog z instalacją RVM (zwalniamy ok. 250 MB):

    :::shell-unix-generic
    rm -rf ~/.rvm

W plikach *~/.bashrc* oraz *~/.bashrc_profile* wykomentowujemy wiersz:

    :::shell-unix-generic
    [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

Zamiast niego wstawiamy:

    :::shell-unix-generic
    [[ -s /usr/local/lib/rvm ]] && source /usr/local/lib/rvm

Teraz po wygenerowaniu rusztowania nowej aplikacji, dodajemy
w jej katalogu głównym plik *.rvmrc* o następującej zawartości:

    :::shell-unix-generic
    rvm use 1.9.2  # albo ree

Gemy instalujemy za pomocą polecenia:

    :::shell-unix-generic
    bundle install --path ~/.gems

Od tej chwili, polecenie *bundle* będzie instalować gemy
w katalogu *~/.gems* aplikacji.


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


**Uwaga:** oba gemy – *wirble* i *hirb* – należy dopisać do każdego
pliku *Gemfile* aplikacji Rails.


## Dokumentacja online

Instalujemy gemy:

    gem install rdoc rdoc-data

Wykonujemy polecenia:

    rdoc-data --install
    gem rdoc --all --overwrite

W katalogu *doc* aplikacji Rails tworzymy katalog *rails* z dokumentacją
API Rails oraz katalog *guides* z samouczkami:

    rake doc:rails
    rake doc:guides

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
