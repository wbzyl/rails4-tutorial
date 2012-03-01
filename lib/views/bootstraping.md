#### {% title "Bootstraping Rails application" %}

*Bootstraping*, to „stawanie na własne nogi”,
a w informatyce — inicjowanie początkowe aplikacji.

Tak więc, przez „bootstraping Rails application” możemy
rozumieć zainicjalizowanie szablonu aplikacji ulubionymi gemami,
własnymi wtyczkami, dodanie szablonu z atrakcyjnym layoutem,
usunięcie niepotrzebnych plików, itp.

W ostatnich wersjach Rails cały taki proces można
zautomatyzować za pomocą tzw. *Rails application templates*.
Szablon aplikacji Rails, to skrypt w języku Ruby korzystający z metod
[Rails template API][rta].

Poniżej opiszę swój szablon aplikacji Rails, który nazwałem *html5-twitter-bootstrap.rb*.

Aby skorzystać z powyższego szablonu wystarczy podać ścieżkę (lub URL)
do pliku z szablonem w poleceniu *rails*, na przykład:

    :::bash terminal
    rails new ⟨app_name⟩ --template html5-twitter-bootstrap.rb --skip-bundle
    rails new ⟨app_name⟩ \
      --template https://raw.github.com/wbzyl/rat/master/html5-twitter-bootstrap.rb \
      --skip-bundle

[bv]: http://twitter.github.com/bootstrap/download.html#variables
[rta]: http://guides.rubyonrails.org/rails_application_templates.html


## Porządki po *rails new*

Zaczynamy od usunięcia niepotrzebnych plików:

    :::ruby html5-twitter-bootstrap.rb
    remove_file 'public/index.html'
    remove_file 'app/assets/images/rails.png'

Przy okazji przechodzimy z notacji RDoc na Markdown:

    :::ruby
    remove_file 'README.rdoc'
    name = ask("Gimme your application name: ", :magenta)
    create_file 'README.md' do
      "# #{name}\n"
    end


## Bootstrap, from Twitter

Dlaczego korzystam z frameworka Bootstrap?

* [{less}](http://lesscss.org/) – the dynamic stylesheet language
* Ken Collins
  - [LESS Is More - Using Twitter's Bootstrap In The Rails 3.1 Asset Pipeline](http://metaskills.net/2011/09/26/less-is-more-using-twitter-bootstrap-in-the-rails-3-1-asset-pipeline/) – Rails know-how
  - [less-rails](https://github.com/metaskills/less-rails)
  - [less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap)
* Bootstrap, [Customize variables](http://twitter.github.com/bootstrap/download.html#variables):

Gemy *less-rails*, *less-rails-bootstrap* potrzebują do działania
jakiegoś *JavaScript runtime*. Najprostsza instalacja *runtime*
prowadzi przez instalację tych gemów:

    :::ruby
    gem 'execjs', :group => :development
    gem 'therubyracer', :group => :development

Pozostały kod:

    :::ruby
    gem 'less-rails'
    gem 'less-rails-bootstrap'

    inside('app/assets/stylesheets') do
      remove_file 'application.css'
      navbar_color = ask("Gimme your navbar color: ", :magenta)

      create_file 'application.css.less' do
        <<-APPLICATION.gsub(/^\s{4}/, '')
        @import "twitter/bootstrap";
        @baseFontSize: 18px;
        @baseLineHeight: 24px;
        @navbarBackgroundHighlight: #{navbar_color};
        @navbarBackground: darken(#{navbar_color}, 20%);
        body {
          padding-top: 60px;
        }
        footer {
          margin-top: 36px;
        }
        .navbar-inner {
             #gradient > .vertical(@navbarBackgroundHighlight, @navbarBackground);
        }
        .navbar {
           .brand {
             font-size: 24px;
           }
        }
        APPLICATION
      end
    end

    inside('app/assets/javascripts') do
      gsub_file 'application.js', /\/\/= require_tree \./ do
        "//= require twitter/bootstrap\n\n" +
        "$(document).ready(function(){\n  //...\n});\n"
      end
    end

Wygenerowana aplikacja korzysta z layoutu o nazwie
[Bootstrap starter template](http://twitter.github.com/bootstrap/examples/starter-template.html):

    :::ruby
    inside('app/views/layouts') do
      remove_file 'application.html.erb'
      get "https://raw.github.com/wbzyl/rat/master/templates/starter-template.html.erb", "application.html.erb"
      gsub_file "application.html.erb", /Bootstrap, from Twitter/, "#{app_name}"
    end

(link do [application.html.erb](https://github.com/wbzyl/rat/blob/master/templates/starter-template.html.erb))


## Refaktoryzacja szablonów częściowych

Z layoutu aplikacji przenioslem kilka rzeczy do szablonów częściowych:

    :::ruby
    inside('app/views/common') do
      get 'https://raw.github.com/wbzyl/rat/master/templates/common/_flashes.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/templates/common/_footer.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/templates/common/_header.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/templates/common/_menu.html.erb'
      gsub_file "_menu.html.erb", /Project name/, "#{app_name}"
    end

Linki do źródeł:

* [_flashes.html.erb](https://github.com/wbzyl/rat/blob/master/templates/common/_flashes.html.erb)
* [_footer.html.erb](https://github.com/wbzyl/rat/blob/master/templates/common/_footer.html.erb)
* *_header.html.erb* – na razie nie użyty w layoucie
* [_menu.html.erb](https://github.com/wbzyl/rat/blob/master/templates/common/_menu.html.erb)

*TODO:* dostosować do wersji Bootstrap 2.0.


## Formularze

Z pozostałych gemów, na pierwszy ogień idzie mój faworyt:

    :::ruby
    gem 'simple_form'

Poniżej wkleiłem komunikat, który pojawił się w trakcie instalacji:

Inside your views, use the `simple_form_for` with one of the Bootstrap form
classes, `.form-horizontal`, `.form-inline`, `.form-search` or
`.form-vertical`, as the following:

    :::ruby
    simple_form_for(@user, :html => {:class => 'form-horizontal' }) do |form|

Linki do dokumentacji:

* [Simple Form](https://github.com/plataformatec/simple_form) –
  forms made easy for Rails! It's tied to a simple DSL, with no opinion on markup
* [simple_form-bootstrap](https://github.com/rafaelfranca/simple_form-bootstrap) –
  example application with SimpleForm and Twitter Bootstrap
* [posts tagged *simple_form*](http://blog.plataformatec.com.br/tag/simple_form/)
  z bloga [\<plataforma/>](http://blog.plataformatec.com.br/)

## Gemy użyteczne w development

Moje ulubione gemy:

    :::ruby
    gem 'wirble', :group => :development
    gem 'hirb', :group => :development

(zob. też konfiguracja *irb* oraz konsoli Rails)


## Instalacja gemów

To jest proste:

    :::ruby
    #run 'bundle --path=$HOME/.gems install --binstubs --local'
    run 'bundle --path=$HOME/.gems install --binstubs'

## Post install

Koniecznie musimy wykonać polecenie:

    :::ruby
    generate 'simple_form:install --bootstrap'

Dlaczego?  Poneważ kopiowane są szablony. Skąd i jakie?

* [SimpleForm 2.0 + Bootstrap: for you with love](http://blog.plataformatec.com.br/2012/02/simpleform-2-0-bootstrap-for-you-with-love/)


## Podmiana widoku – przechodzę na HTML5

Dlaczego?

    :::ruby
    inside('lib/templates/erb/scaffold') do
      get 'https://raw.github.com/wbzyl/rat/master/lib/templates/erb/scaffold/index.html.erb'
    end

(link do [index.html.erb](https://github.com/wbzyl/rat/blob/master/lib/templates/erb/scaffold/index.html.erb))


## Testowanie szablonu – przykładowy scaffold

Te polecenia były przydatne tylko w trakcie pisania szablonu:

    :::ruby
    generate 'scaffold post title:string body:text published:boolean'
    run 'rm app/assets/stylesheets/scaffolds.css.scss'
    run 'rm app/assets/stylesheets/posts.css.scss'
    rake 'db:migrate'
    route "root :to => 'posts#index'"

Z ostatecznej wersji szablonu je usunąłem.


## Metody pomocnicze – layout helpers

Moje ulubione metody skopiowane z kodu gemu R. Bates’a
[Nifty Generators](https://github.com/ryanb/nifty-generators):

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


## I to by było tyle

Na koniec najważniejsze rzeczy:

    :::ruby
    git :init
    git :add => "."
    git :commit => "-a -m 'bootstrapped application'"

oraz post install message:

    :::ruby
    say <<-eos
    ============================================================================
      Your new Rails application is ready to go.
      Don't forget to scroll up for important messages from installed generators.
    eos


## Użyteczne linki

* [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/) –
  simple and flexible HTML, CSS, and Javascript for popular user
  interface components and interactions
* [Using LESS with Bootstrap](http://twitter.github.com/bootstrap/less.html)
* [Beautiful Buttons for Twitter Bootstrappers](http://charliepark.org/bootstrap_buttons/)

Warto też przeczytać trzy posty Pata Shaughnessy:

- [Twitter Bootstrap, Less, and Sass: Understanding Your Options for Rails 3.1](http://rubysource.com/twitter-bootstrap-less-and-sass-understanding-your-options-for-rails-3-1/)
- [Too good to be true! Twitter Bootstrap meets Formtastic and Tabulous](http://rubysource.com/too-good-to-be-true-twitter-bootstrap-meets-formtastic-and-tabulous/)
- [How to Customize Twitter Bootstrap’s Design in a Rails app](http://rubysource.com/how-to-customize-twitter-bootstrap%E2%80%99s-design-in-a-rails-app/)

