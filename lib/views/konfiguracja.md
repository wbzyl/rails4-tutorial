#### {% title "Konfiguracja środowiska dla Rails 3" %}

W użyciu jest wiele implementacji i wersji języka Ruby. Dla przykładu:
Ruby MRI w wersjach 1.8.7, 1.9.2, Ruby Enterprise Edition – 1.8.7,
jRuby – 1.5.0, Rubinius – 1.0.1, MagLev, IronRuby – 1.0.  Po trosze
wynika to z popularności frameworka Ruby on Rails.

Ruby Version Manager umożliwia zainstalowanie i przełączanie
się między różnymi implementacjami i wersjami języka Ruby.
Jest to ważne teraz, ponieważ aktualnie przechodzimy z wersji
1.9 na wersję 2.0.

Zanim zaczniemy pracę z Ruby on Rails powinniśmy też skonfigurować
konsolę języka Ruby (**irb**) oraz konsolę frameworka Ruby on Rails
(**rails console**).


## Zestawy gemów

W trakcie instalacji dla każdej wersji Rubiego tworzone są dwa zestawy gemów
(ang. *gemset*):

* **default** (domyślny, bez nazwy)
* **global**

Do zestawu **global** dodajemy gemy używane we wszystkich projektach.
Na przykład

    rvm use ruby-2.2.1@global
    gem install bundler rails
    rvm use ruby-2.2.1


## Gemy & Bundler

Zazwyczaj gemy instalujemy w swoim katalogu domowym:

    :::bash
    bundle install --path=$HOME/.gems

albo dla każdej aplikacji osobno:

    :::bash
    bundle install --path=.bundle/gems

Od tej chwili, polecenie *bundle* będzie instalować gemy w podanej lokalizacji.


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

    # DO NOT WORK
    # break out of the Bundler jail
    # from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
    # if defined? Bundler
    #  Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
    #  Gem::Specification.reset
    #  load 'rubygems/custom_require.rb'
    # end

    # gem hirb musimy dopisać do pliku Gemfile
    if defined? Rails
      begin
        require 'hirb'
        Hirb.enable
      rescue LoadError
      end
    end

oraz gemów:

    :::ruby ~/.gemrc
    gem: --no-rdoc --no-ri
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
