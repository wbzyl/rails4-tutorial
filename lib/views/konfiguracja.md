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

    :::bash
    rvm install ree               # alias na ostatnią wersję, np. ree-1.8.7-2011.03
    rvm install 1.9.3-p125
    rvm --default use 1.9.3-p125
    rvm remove --gems 1.9.3-p125  # usuń też zainstalowane gemy

Info:

    rvm list
    rvm use ree
    rvm current


Potrzebujemy więcej szczegółów:

    :::bash
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

    :::bash
    rvm use 1.9.2 --default

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

    rvm use ruby-1.9.2-p180

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
    gem install bundler rails
    rvm use ruby-1.9.2-p180


## Gemy & Bundler

Gemy instalujemy w swoim katalogu domowym:

    :::bash
    bundle install --path=$HOME/.gems

albo dla każdej aplikacji osobno:

    :::bash
    bundle install --path=.bundle/gems

Od tej chwili, polecenie *bundle* będzie instalować gemy w podanej lokalizacji.


# „Multi-User install” RVM na Sigmie

Po zastosowaniu powyższej konfiguracji do Sigmy
obserwujemy, że wszystkie polecenia działają **bardzo, bardzo wolno**.
Jaki jest tego powód łatwo stwierdzić, wykonując polecenia:

    :::bash
    strace rails new slow
    cd slow
    strace rails server

Uruchomienie aplikacji Rails to wczytanie około 2000 plików.
Ponieważ Ruby nie jest „demonem szybkości” ładowania plików,
więc zajmuje to zwykle co najmniej kilkanaście sekund.

Daltego postąpimy inaczej.
Zaczyniemy od usunięcia pozostałości po „single-user installation”:

    :::bash
    rm -f $HOME/.rvm $HOME/.rvmrc

Następnie wykonamy polecenie:

    sudo bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

Zostanie utworzona grupa *rvm*, oraz do plików startowych dodana jest
ścieżka do programu katalogu */usr/local/rvm/bin*.

Teraz instalujemy ostatnią stabilną wersję 1.9.2 programu *ruby** (wrzesień 2011):

    rvm install ruby-1.9.2-p290

*Uwaga:* dodajemy siebie do grupy *rvm*:

    sudo gpasswd --add wbzyl rvm

Podstawowe gemy instalujemy, korzystając ze skryptu *rvmsudo*:

    rvm use ruby-1.9.2-p290 --default
    rvm use ruby-1.9.2-p290@global
    gem install rake bundler rails sqlite3 pg wirble hirb
    rvm use ruby-1.9.2-p290

*Uwaga:* szkielet aplikacji Rails tworzymy w następujący sposób:

    rails new hello_rails --skip-bundle
    cd hello_rails
    bundle install $HOME/.gems


# Konfiguracja konsoli

Oto moja konfiguracja konsoli (dla Ruby i dla Rails):

    :::ruby ~/.irbrc
    require 'irb/completion'
    require 'irb/ext/save-history'

    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
    IRB.conf[:PROMPT_MODE] = :SIMPLE

    # remove the SQL logging
    # ActiveRecord::Base.logger.level = 1 if defined? ActiveRecord::Base

    # an easy way to display the YAML representation of objects
    def y(obj)
      puts obj.to_yaml
    end

    # break out of the Bundler jail
    # from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
    if defined? Bundler
      Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
      Gem::Specification.reset
      load 'rubygems/custom_require.rb'
    end

    if defined? Rails
      begin
        require 'hirb'
        Hirb.enable
      rescue LoadError
      end
    end

oraz gemów:

    :::ruby ~/.gemrc
    ---
    gem: --no-rdoc
    :verbose: true
    :benchmark: false


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

## Misc

Znak zachęty można zdefiniować samemu. Oto przykład:

    :::ruby
    IRB.conf[:PROMPT][:CUSTOM] = {
      :PROMPT_I => ">> ",
      :PROMPT_N => ">> ",
      :PROMPT_S => nil,
      :PROMPT_C => ">> ",
      :RETURN => "%s\n"
    }
    IRB.conf[:PROMPT_MODE] = :CUSTOM


# Roadmap for Learning Rails

Roadmap specially designed for a beginner to navigate their way to Rails mastery.

{%= image_tag "/images/Learning-Rails-Roadmap.png", :alt => "[Learning Rails Roadmap]" %}

[Źródło](http://techiferous.com/2010/07/roadmap-for-learning-rails/)


[rvm]: http://rvm.beginrescueend.com/ "Ruby Version Manager"
