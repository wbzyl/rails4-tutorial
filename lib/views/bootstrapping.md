#### {% title "Bootstrapping Rails application" %}

*Bootstrapping*, to „stawanie na własne nogi”,
a w informatyce — inicjowanie początkowe aplikacji.

Innymi słowy, „bootstrapping Rails application” oznacza
zainicjalizowanie rusztowania aplikacji ulubionymi gemami,
dodanie szablonów z atrakcyjnym layoutem,
usunięcie niepotrzebnych plików, itp.

W ostatnich wersjach Rails cały taki proces można
zautomatyzować za pomocą tzw. *Rails Application Templates*.
Szablon aplikacji Rails, to skrypt w języku Ruby korzystający z metod
[Rails template API](http://edgeguides.rubyonrails.org/rails_application_templates.html).


# Rails Composer

… [to generator rusztowania aplikacji Rails na sterydach](http://railsapps.github.com/rails-composer/).

Użyję generatora aplikacji *Rails Composer*, do wygenerowania rusztowania
aplikacji korzystającej z bazy MongoDB z logowaniem przez OmniAuth+Twitter.

Ponieważ zamierzamy skorzystać z bazy NoSQL, do wywołania generatora
dopisujemy kilka opcji:

    :::bash
    rails new myapp \
      -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb \
      -T -O --skip-bundle

(*-T* — skip test unit, *-O* — skip active record)

**Ważne:** Na pierwsze pytanie zadane przez generator *Composer* wybieramy opcję **1**:

    1)  I want to build my own application

a dalej już wybieramy opcje według własnego uznania.


## Sprzątamy po generatorze…

Jeśli wybraliśmy opcję **Twitter Bootstrap z LESS**  usuwamy gem *sass-rails*
z pliku *Gemfile* i w katalogu *app/assets/stylesheets* zmieniamy rozszerzenie
wygenerowanych plików z `.css.sass` na `.css.less`.

Dopiero po tych poprawkach instalujemy gemy:

    :::bash
    bundle install

Na koniec sprawdzamy, czy wygenerowana aplikacja działa
wykonując „smoke (sanity) test”:

    :::bash
    rake -T
    rake spec

Jeśli wszystko jest OK, to przystępujemy do konfiguracji wygenerowanej aplikacji.


## Konfiguracja strategii OmniAuth+Twitter

W pliku *omniauth.rb* wykomentowujemy wygenerowany kod:

    :::ruby config/initializers/omniauth.rb
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :twitter, ENV['OMNIAUTH_PROVIDER_KEY'], ENV['OMNIAUTH_PROVIDER_SECRET']
    end

zamiast niego wpisujemy:

    :::ruby config/initializers/omniauth.rb
    OmniAuth.config.logger = Rails.logger

    raw_config = File.read("#{ENV['HOME']}/.credentials/applications.yml")

    twitter = YAML.load(raw_config)['twitter']
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :twitter, twitter['omniauth_provider_key'], twitter['omniauth_provider_secret']
    end

a w użytym w kodzie powyżej pliku *applications.yml* wpisujemy:

    :::yaml
    twitter:
      omniauth_provider_key: __ Consumer key __
      omniauth_provider_secret: __ Consumer secret __

Oczywiście zamiast tekstu ‘\_\_ ... \_\_’ powyżej wpisujemy dane
ze strony z [swoimi aplikacjami](https://dev.twitter.com/apps/).
Moja aplikacja została zarejestrowana na tej stronie
pod nazwą „OmniAuth+Mongoid via localhost”.

W trakcie rejestracji w pole *Callback URL* wpisałem:

    http://127.0.0.1:3000


### Jakie rzeczy pominięto?

Konfiguracja MongoDB oraz inicjalizację baz danych. Została zrobiona
przez generator:

    :::bash
    rails generate mongoid:config
    rake db:drop
    rake db:create
    rake db:mongoid:create_indexes
    rake db:seed

Jeśli jest potrzeba zapełnienia kolekcji danymi testowymi lub
przygotowania bazy do testów, to wykonujemy:

    :::bash
    rake db:reseed
    rake db:test:prepare

Kiedyś trzeba będzie skonfigurować bazę danych dla
trybu **production**.


### Co nie działa?

Musimy dopisać do modelu *Users* „timestamps”:

    :::ruby app/models/user.rb
    class User
      include Mongoid::Document
      include Mongoid::Timestamps

Inaczej kliknięcie w zakładkę Admin generuje błąd.
Przy okazji, dopiszę też timestamps do modelu *Role*.






**Uwagi:**
1\. Strategia *omniauth-github* ma jakiś bug (4.12.2012)
i logowanie nie działa; próba zalogowania zwraca *Callback Error*.
2\. Zobacz też [Simple OmniAuth (revised)](http://railscasts.com/episodes/241-simple-omniauth-revised?view=asciicast).

Więcej szablonów aplikacji Rails:

* [Rails Examples, Tutorials, and Starter Apps](http://railsapps.github.com/rails-examples-tutorials.html)
* [Rails App for Omniauth with Mongoid](https://github.com/RailsApps/rails3-mongoid-omniauth),
  [tutorial](http://railsapps.github.com/tutorial-rails-mongoid-omniauth.html).


Reszta: [Rails App for Omniauth with Mongoid](http://railsapps.github.com/tutorial-rails-mongoid-omniauth.html).


# Mój szablon dla Rails 3.1

Poniżej opiszę swój szablon aplikacji Rails, który nazwałem *html5-twitter-bootstrap.rb*,
ponieważ użyłem w nim komponentów [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/)
i layoutu [Bootstrap starter template](http://twitter.github.com/bootstrap/examples/starter-template.html).

Aby skorzystać z powyższego szablonu wystarczy podać ścieżkę (lub URL)
do pliku z szablonem w poleceniu *rails*, na przykład:

    :::bash terminal
    rails new ⟨app_name⟩ \
      --template html5-twitter-bootstrap.rb \
      --skip-bundle \
      --skip-test-unit
    rails new ⟨app_name⟩ \
      --template https://raw.github.com/wbzyl/rat/master/html5-twitter-bootstrap.rb \
      --skip-bundle \
      --skip-test-unit

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

oraz pytamy użytkownika o nazwę aplikacji (problemy z polskimi diakrytykami?):

    :::ruby
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
    gem 'less-rails', :group => :assets
    gem 'less-rails-bootstrap', :group => :assets

    inside('app/assets/stylesheets') do
      remove_file 'application.css'
      navbar_color = ask("Gimme your navbar color: ", :magenta)
      get 'https://raw.github.com/wbzyl/rat/master/templates/starter-application.css.less', 'starter-application.css.less'
      gsub_file 'application.js', /@grayDark/, "#{navbar_color}"
    end

    inside('app/assets/javascripts') do
      gsub_file 'application.js', /\/\/= require_tree \./ do
        "//= require twitter/bootstrap\n\n" +
        "$(document).ready(function() { });"
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

**Koniecznie** przyjrzeć się
[application.html.erb](https://github.com/wbzyl/rat/blob/master/templates/starter-template.html.erb).


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

Gemy instaluję lokalnie. Wybrałem jeden wspólny katalog
dla trybu development:

    :::ruby
    #run 'bundle --path=$HOME/.gems install --binstubs --local'
    run 'bundle --path=$HOME/.gems install --binstubs'

Możemy też gemy instalować w katalogu aplikacji:

    :::ruby
    run 'bundle --path=tmp install --binstubs'


## Post install

Wykonujemy polecenie:

    :::ruby
    generate 'simple_form:install --bootstrap'

które kopiuje trzy pliki do odpowiednich katalogów:
initializer (*simple_form.rb*), locales (*simple_form.en.yml*),
szablon dla scaffold (*_form.html.erb*). Przy okazji
wypisywana jest następująca ściągawka:

Inside your views, use the `simple_form_for` with one of the Bootstrap form
classes, `.form-horizontal`, `.form-inline`, `.form-search` or
`.form-vertical`, as the following:

    :::ruby
    simple_form_for(@user, :html => {:class => 'form-horizontal' }) do |form|

Więcej informacji:

* [Simple Form 2.0 + Bootstrap: for you with love](http://blog.plataformatec.com.br/2012/02/simpleform-2-0-bootstrap-for-you-with-love/)
* [Simple Form](https://github.com/plataformatec/simple_form)


## Podmiana widoku – przechodzę na HTML5

Dlaczego te akurat te (a nie inne) szablony?

    :::ruby
    inside('lib/templates/erb/scaffold') do
      get 'https://raw.github.com/wbzyl/rat/master/lib/templates/erb/scaffold/index.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/lib/templates/erb/scaffold/show.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/lib/templates/erb/scaffold/new.html.erb'
      get 'https://raw.github.com/wbzyl/rat/master/lib/templates/erb/scaffold/edit.html.erb'
    end

([link do szablonów](https://github.com/wbzyl/rat/blob/master/lib/templates/erb/scaffold/))


## Metody pomocnicze – layout helpers

Na koniec kilka użytecznych metod skopiowanych z gemu R. Bates’a
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


## Bootstrap 2.0 meets Rails 3.2

Po wygenerowaniu rusztowania aplikacji, przyjrzyjmy
się jak się sprawdza framework Bootstrap w aplikacji Rails.

W tym celu skorzystajmy z generatora scaffold:

    :::bash
    rails g scaffold post title:string body:text published:boolean \
      --skip-stylesheets --skip-test-framework
    rake db:migrate

Następnie na konsoli dodajmy kilka postów:

    :::ruby
    Post.create! title: "ala", body: "mam kota, mam kota", published: true
    Post.create! title: "ola", body: "mam psa", published: true

Niestety domyślny wygląd widoków *index* i *show* pozostawia
wiele do życzenia. Poprawimy te widoki za pomocą kilku linijek
kodu JavaScript dopisanego do *application.js*:

    :::js app/assets/javascripts/application.js
    $(document).ready(function() {
      $('article .attribute')
        .addClass('row').css('margin-bottom', '.25em')
        .find('.name').addClass('span2').css('text-align', 'right')
        .end()
        .find('.value').addClass('span10');
    });

albo kodu Less dopisanego do *application.css.less*:

    :::css
    article {
      &.index {
        margin-bottom: 1em; }
      .attribute {
        .makeRow();
        margin-bottom: .25em;
       .name {
          color: @blueDark;
          .makeColumn(2);
          text-align: right;
          &:after {
            content: ":"; } }
        .value {
          .makeColumn(10); } }
    }

(zobacz [Scaffolding](http://twitter.github.com/bootstrap/scaffolding.html), Default grid system)


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

