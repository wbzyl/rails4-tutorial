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

      rolify # https://github.com/EppO/rolify

      field :provider, type: String
      field :uid, type: String
      field :name, type: String
      field :email, type: String
      attr_accessible :role_ids, :as => :admin, :default => :student

Inaczej kliknięcie w zakładkę Admin generuje błąd.
Przy okazji, dopisujemy też *timestamps* do modelu *Role*.

Dla zalogowanego użytkownika ustawiamy domyślną rolę – *Student*.


### Poprawki w szablonach

Do widoku częściowego *_navigation.html.erb*
wklejamy kod wypisujący na pasku nawigacji
*Welcome Guest!* lub nazwę zalogowanego użytkownika:

    :::rhtml app/views/layouts/_navigation.html.erb
    <div class="pull-right">
      <ul class="nav">
        <% if user_signed_in? %>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            Logged in as <%= current_user.name %> <b class="caret"></b>
          </a>
          <ul class="dropdown-menu">
            <li><%= link_to "Your Profile", user_path(current_user) %></li>
            <li><%= link_to "Milestones", milestones_path %></li>
          </ul>
        </li>
        <% else %>
        <li class="navbar-text">Welcome Guest!</li>
        <% end %>
      </ul>
    </div>

Zalogowany użytkownik, z menu *dropdown* może przejść do strony
z informacjami o sobie. Przy okazji tworzymy jeszcze jedną
stronę statyczną „Milestones”; dodajemy tę stronę do routingu.


## Roles – Admin, Guest…

Pierwszy zalogowany użytkownik jest **Adminem**. Zostało to
zaimplementowane w metodzie *create* kontrolera *SessionsController*:

    :::ruby
    class SessionsController < ApplicationController
      def create
        # uncomment to debug omniauth.auth
        # raise request.env["omniauth.auth"].to_yaml

        auth = request.env["omniauth.auth"]
        user = User.where(:provider => auth['provider'],
           :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
        session[:user_id] = user.id
        user.add_role :admin if User.count == 1 # make the first user an admin

Wszystkie role zdefiniujemy w pliku *seeds.rb*:

    :::ruby db/seeds.rb
    Role.create! name: :admin
    Role.create! name: :guest

Następnie zapiszemy je w bazie:

    rake db:reseed

Na koniec zabieramy się za lekturę *README* gemu [Rolify](https://github.com/EppO/rolify),
aby dowiedzieć się jak korzystać z ról.


## Pozostałe rzeczy

… są opisane tutaj – [Rails App for Omniauth with Mongoid](http://railsapps.github.com/tutorial-rails-mongoid-omniauth.html).

Tutaj znajdziemy kilka szablonów aplikacji Rails:

* [Rails Examples, Tutorials, and Starter Apps](http://railsapps.github.com/rails-examples-tutorials.html)

Na koniec kilka użytecznych linków:

* [{less}](http://lesscss.org/) – the dynamic stylesheet language
* [less-rails](https://github.com/metaskills/less-rails)
* [less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap)
* [Using LESS with Bootstrap](http://twitter.github.com/bootstrap/less.html)
* [Customize and download Bootstrap](http://twitter.github.com/bootstrap/customize.html)
  (customize variables)


## Kod wart obejrzenia…

Aplikację wrzuciłem do prywatnego repo *mongoid+omniauth-twitter* na
Bitbucket. Warto przejrzeć kilka pierwszych commitów.

**Uwagi:**
1\. Strategia *omniauth-github* ma jakiś bug (4.12.2012)
i logowanie nie działa; próba zalogowania zwraca *Callback Error*.
2\. Zobacz też [Simple OmniAuth (revised)](http://railscasts.com/episodes/241-simple-omniauth-revised?view=asciicast).
