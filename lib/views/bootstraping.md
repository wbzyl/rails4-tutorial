#### {% title "Bootstraping Rails application" %}


*Bootstraping* może oznaczać „stawanie na własne nogi”, albo,
w informatyce, inicjowanie początkowe lub rozwijanie aplikacji.

Przez „bootstraping Rails application” rozumiem utworzenie
szablonu aplikacji z ulubionymi gemami dopisanymi
do pliku *Gemfile*, zainstalowanymi własnymi wtyczkami,
usuniętym plikiem *public/index.html*, dodanym preferowanym layoutem itp.

W ostatnich wersjach Rails cały taki proces można
zautomatyzować za pomocą tzw. *Rails application templates*.
Szablon aplikacji Rails, to skrypt w języku Ruby korzystający z metod
[Rails template API](http://guides.rubyonrails.org/rails_application_templates.html).

Poniżej opiszę swój szablon aplikacji Rails o nazwie *html5-twitter-bootstrap.rb*.

Aby wygenerować szablon aplikacji z powyższego szablonu wystarczy
podać ścieżkę (lub URL) do pliku z szablonem w poleceniu *rails*, na
przykład:

    :::bash terminal
    rails new ⟨app_name⟩ -m html5-twitter-bootstrap.rb --skip-bundle
    rails new ⟨app_name⟩ -m https://raw.github.com/wbzyl/rat/master/html5-twitter-bootstrap.rb --skip-bundle


## Podstawy

Zaczynamy od usunięcia niepotrzebnych rzeczy:

    :::ruby html5-twitter-bootstrap.rb
    remove_file 'public/index.html'
    remove_file 'app/assets/images/rails.png'

Przy okazji przechodzimy z RDoc na Markdown:

    :::ruby
    remove_file 'README.rdoc'
    name = ask("Gimme your application name: ", :magenta)
    create_file 'README.md' do
      "# #{name}\n"
    end


## Bootstrap, from Twitter

Skorzystamy z gemów *less-rails*, *less-rails-bootstrap*.

Lektura:

* [{less}](http://lesscss.org/) – the dynamic stylesheet language
* [rails know-how](http://metaskills.net/2011/09/26/less-is-more-using-twitter-bootstrap-in-the-rails-3-1-asset-pipeline/)
* [less-rails](https://github.com/metaskills/less-rails)
* [less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap)

Gemy:

    :::ruby
    gem 'execjs', :group => :development
    gem 'therubyracer', :group => :development

    gem 'less-rails'
    gem 'less-rails-bootstrap'

Poprawki w wygenerowanym przez *rails* JS:

    :::js application.js
    //= require twitter/bootstrap

    $(document).ready(function(){
      //...
    });

oraz CSS:

    :::css application.css.less
    @import "twitter/bootstrap";

    #foo {
      .border-radius(4px);
    }

Pozostałe gemy.


### Formularze

    :::ruby
    gem 'simple_form'


### Gemy użyteczne w development

    :::ruby
    gem 'wirble', :group => :development
    gem 'hirb', :group => :development


## Instalacja gemów oraz post install

    :::ruby
    #run 'bundle --local --path=$HOME/.gems install --binstubs'

    run 'bundle --path=$HOME/.gems install --binstubs'

    # remove_file 'app/views/layouts/application.html.erb'

    generate 'simple_form:install'

    # generate 'bootstrap:install --layout=hero --stylesheet-engine=less'


## Testowanie szablonu – przykładowy scaffold

    :::ruby
    generate 'scaffold post title:string body:text published:boolean'
    rake 'db:migrate'
    route "root :to => 'post#index'"


## Layout helpers

    :::ruby
    inside('app/helpers') do
      create_file 'layout_helper.rb' do
        <<-LAYOUT_HELPER.gsub(/^\s{4}/, "")
        # This module should be included in all views globally,
        # to do so you may need to add this line to your ApplicationController
        #   helper :layout
        #
        module LayoutHelper
          def title(page_title, show_title = true)
            content_for(:title) { page_title.to_s }
            @show_title = show_title
          end
          def show_title?
            @show_title
          end
          def stylesheet(*args)
            content_for(:head) { stylesheet_link_tag(*args) }
          end
          def javascript(*args)
            content_for(:head) { javascript_include_tag(*args) }
          end
        end
        LAYOUT_HELPER
      end
    end


## Layout – jaki?


Z Bootstrap? Pliki z repo z Githuba.



## Git

Na koniec...

    :::ruby
    git :init
    git :add => "."
    git :commit => "-a -m 'created initial application'"


## Info

Post install:

    :::ruby
    say <<-eos
      ============================================================================
      Your new Rails application is ready to go.

      Don't forget to scroll up for important messages from installed generators.
    eos




## Rusztowanie korzystające z frameworka Bootstrap


Thor:

    say("Complete!", :green)



[2012.02.02] **TODO**

Rusztowanie aplikacji wygenerujemy korzystając mojego szablonu aplikacji
(*application template*) o nazwie „html5-bootstrap.rb”:

    :::bash terminal
    rails new ⟨app name⟩ -m https://raw.github.com/wbzyl/rails31-html5-templates/master/html5-bootstrap.rb --skip-bundle

Szablon aplikacji korzysta z layoutu
[Starter template](http://twitter.github.com/bootstrap/examples/starter-template.html)

Szablon aplikacji korzysta z gemu
[less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap),
którego autorem jest Ken Collins.
Ken opisał jak korzystać *less-rails-bootstrap* na swoim blogu
w [LESS Is More - Using Twitter's Bootstrap In The Rails 3.1 Asset Pipeline](http://metaskills.net/2011/09/26/less-is-more-using-twitter-bootstrap-in-the-rails-3-1-asset-pipeline/).

Użyteczne linki:

* [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/) –
  simple and flexible HTML, CSS, and Javascript for popular user
  interface components and interactions
* [Customize Bootstrap variables](http://twitter.github.com/bootstrap/download.html#variables)
* [Using LESS with Bootstrap](http://twitter.github.com/bootstrap/less.html)
* [Bootstrap Generators](https://github.com/decioferreira/bootstrap-generators) –
  provides Twitter Bootstrap generators for Rails 3;
  [więcej informacji](http://decioferreira.github.com/bootstrap-generators/)
* [Beautiful Buttons for Twitter Bootstrappers](http://charliepark.org/bootstrap_buttons/)

Warto też przeczytać trzy posty Pata Shaughnessy:

- [Twitter Bootstrap, Less, and Sass: Understanding Your Options for Rails 3.1](http://rubysource.com/twitter-bootstrap-less-and-sass-understanding-your-options-for-rails-3-1/)
- [Too good to be true! Twitter Bootstrap meets Formtastic and Tabulous](http://rubysource.com/too-good-to-be-true-twitter-bootstrap-meets-formtastic-and-tabulous/)
- [How to Customize Twitter Bootstrap’s Design in a Rails app](http://rubysource.com/how-to-customize-twitter-bootstrap%E2%80%99s-design-in-a-rails-app/)

