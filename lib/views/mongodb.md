#### {% title "Mongoid + OmniAuth via GitHub" %}

☸ Mongo links:

* Ryan Bates, [Mongoid](http://railscasts.com/episodes/238-mongoid?view=asciicast) – asciicast
* Durran Jordan, [Mongoid](http://mongoid.org/docs.html) – dokumentacja gemu
* Karl Seguin.
  - [The MongoDB Interactive Tutorial](http://tutorial.mongly.com/tutorial/index)
  - [MongoDB Geospatial Interactive Tutorial](http://tutorial.mongly.com/geo/index)
  - [The Little MongoDB Book](http://openmymind.net/mongodb.pdf)

☸ Simple Form:

* [GitHub](https://github.com/plataformatec/simple_form)
* [Wiki](https://github.com/plataformatec/simple_form/wiki)
* [SimpleForm 2.0 + Bootstrap: for you with love](http://blog.plataformatec.com.br/tag/simple_form/)
* [SimpleForm + Twitter Bootstrap sample application](https://github.com/rafaelfranca/simple_form-bootstrap)

☸ OmniAuth:

* [Demo App](http://www.omniauth.org/), [kod aplikacji](https://github.com/intridea/omniauth.org)
* [Github](https://github.com/intridea/omniauth)
* [Wiki](https://github.com/intridea/omniauth/wiki)
* [OmniAuth Github strategy](https://github.com/intridea/omniauth-github)
* [OmniAuth Identity strategy](https://github.com/intridea/omniauth-identity)

☸ LESS + Twitter Bootstrap:

* [{less}](http://lesscss.org/) – the dynamic stylesheet language
* [less-rails](https://github.com/metaskills/less-rails)
* [less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap)
* [Customize and download Bootstrap](http://twitter.github.com/bootstrap/customize.html)
  (customize variables)

☸ Fonty z ikonkami:

* [Font Awesome](http://fortawesome.github.com/Font-Awesome/),
  [less-rails-fontawesome](https://github.com/wbzyl/less-rails-fontawesome) gem (mój)
* [Fontello](http://fontello.com/)

☺☕♥ ⟵ kody takich znaczków odszuka za nas [Shapecatcher](http://shapecatcher.com/)
Benjamina Milde. My musimy je tylko naszkicować.

☸ Hosting:

* [Cloud Hosted MongoDB](https://mongolab.com/home)
  ([{blog: mongolab}](http://blog.mongolab.com/))
* [Node.js + MongoDB = Love: Guest Post from MongoLab](http://joyeur.com/2011/10/26/node-js-mongodb-love-guest-post-from-mongolab/)


<blockquote>
 {%= image_tag "/images/genesis-selling_england.jpg", :alt => "[Genesis, Selling England by the Pound]" %}
 <p class="author"><a href="http://www.genesisfan.net/genesis/albums/selling-england-by-the-pound">Genesis,
   Selling England by the Pound</a></p>
</blockquote>

# Lista obecności, 12/13

… to prosta aplikacja CRUD do zrządzania listą obecności studentów.

Dane studentów zapisywane będą w bazie MongoDB. Do zarządzania bazą
wykorzystamy gem Mongoid.
Autentykacja to OmniAuth ze strategią *omniauth-github*.
Autoryzację zaprogramujemy sami.

Kod gotowej aplikacji umiesciłem w (prywatnym) repozytorium Git
na serwerze Bitbucket:

* [lista-obecności-2013](https://bitbucket.org/wbzyl/lista-obecnosci-2013)

Budowanie aplikacji zaczynamy od skopiowania szablonu aplikacji
[mongoid+omniauth-twitter](https://bitbucket.org/wbzyl/mongoid-omniauth-twitter)
i zmienienia w plikach:

* *secret_token.rb*
* *session_store.rb*

wartości tych stałych:

    :::ruby
    # Your secret key for verifying the integrity of signed
    # cookies. If you change this key, all old signed
    # cookies will become invalid! Make sure the secret
    # is at least 30 characters and all random, no regular
    # words or you'll be exposed to dictionary attacks.
    MongoidOmniauthTwitter::Application.config.secret_token = '1955..[cut]..2012'

    # Use the database for sessions instead of the cookie-based default,
    # which shouldn't be used to store highly confidential information
    MongoidOmniauthTwitter::Application.config.session_store :cookie_store,
      key: '_lista_obecnosci_2013_session



Po wprowadzeniu tych poprawek, zajmiemy się większymi
poprawkami w wygenerowanym kodzie. Dopiero po tych zmianach
przystąpimy do pisania kodu aplikacji.


### Konfiguracja bazy MongoDB

Podmieniamy zawartość pliku *mongoid.yml* na:

    :::yaml config/mongoid.yml
    development:
      sessions:
        default:
          database: lista_obecnosci_2013_development
          hosts:
            - localhost:27017
    production:
      sessions:
        default:
          database: lista_obecnosci_2013_production
          hosts:
            - localhost:27017
    test:
      sessions:
        default:
          database: lista_obecnosci_2013_test
          hosts:
            - localhost:27017
          options:
            consistency: :strong
            # In the test environment we lower the retries and retry interval to
            # low amounts for fast failures.
            max_retries: 1
            retry_interval: 0


### LESS

W pliku ***application.css.less*** podmieniamy linie kodu z *require* na:

    :::css
    *= require_self
    *= require bootstrap_and_overrides.css

Dodajemy pusty plik *app/assets/stylesheets/lista_obecnosci.less*.

Na końcu pliku *bootstrap_and_overrides.css.less* dopisujemy:

    :::css app/assets/stylesheets/bootstrap_and_overrides.css.less
    @import "lista_obecnosci";

Kod LESS zmieniający wygląd aplikacji będziemy wpisywać
w pliku *lista_obecnosci.less*. Na razie zwiększymy rozmiar fontu,
odstęp międzywierszowy (interlinię) oraz podmienimy kilka kolorów:

    :::css app/assets/stylesheets/lista_obecnosci.less
    @baseFontSize: 18px;
    @baseLineHeight: 26px;
    @textColor: black;

    @navbarBackground: black;
    @navbarBackgroundHighlight: black;
    @navbarText: white;

    @navbarBrandColor: #FF9800;

    @navbarLinkColor: white;
    @navbarLinkColorHover: #7E8AA2;
    @navbarLinkColorActive: @navbarLinkColorHover;


### Usuwamy timestamps

Pliki z danymi studentów zwykle otrzymuję z sekretariatu Instytutu Informatyki.
Pliki są w formacie OpenOffice lub Excel.
Dane każdej grupy są zapisane w osobnych plikach.
Format danych w każdym pliku jest „ciut” inny.

Dane możemy zaimportować do bazy korzystając z programu *mongoimport*:

    :::bash terminal
    mongoimport --drop \
      -d lista_obecnosci_2013_development -c students \
      --headerline --type csv wd.csv


Niestety, w ten sposób nie można zapisać w kolekcji dat
(atrybuty *created_at* i *updated_at*).

*Uwaga:* Aby dodać daty, wystarczy po zaimportowaniu danych
wykonać na konsoli Rails:

    :::ruby
    Student.find_each(&:save!)

Jednak daty można zapisać w kolekcji, o ile dane będą w formacie JSON:

    :::json
    {
      "first_name" : "Jan",
      "last_name" : "Kuszelas",
      "login" : "jkuszelas",
      "class_name" : "nosql",
      "updated_at" : { "$date" : 1355365444000 },
      "created_at" : { "$date" : 1355365444000 }
    }

Do zapisu dat używamy deskryptora *$date*.
(Cały JSON musimy zapisać jednym wierszu.)

*Uwaga:* Na konsoli *mongo* możemy sprawdzić jaką datę przedstawia
`1355365444000` w taki sposób:

    :::js
    new Date(1355365444000) //=> ISODate("20121213T02:24:04Z")

Jak widać daty wprowadzają duże zamieszanie w trakcie importu danych.
Ale po włączeniu obsługi dat do każdego modelu:

    :::ruby
    include Mongoid::Timestamps

korzystanie z nich nie sprawia już żadnego problemu.

Ponieważ nie będziemy używać dat w aplikacji usuniemy kod
który z nich korzysta. Daty pozostawimy tylko w modelu *Role*.


### OmniAuth + Github + Private ENV Variables

Dokumentacja OmniAuth i strategii OmniAuth GitHub:

* [OmniAuth: Standardized Multi-Provider Authentication](https://github.com/intridea/omniauth)
* [OmniAuth GitHub](https://github.com/intridea/omniauth-github),
* [Managing Multiple Providers](https://github.com/intridea/omniauth/wiki/Managing-Multiple-Providers),
  [Separating Authentication and Identity with OmniAuth](http://blog.railsrumble.com/2010/10/08/intridea-omniauth/)

Sposoby na „Keeping Environment Variables Private” opisano tutaj:

* Taylor Mock & Daniel Kehoe,
  [Rails Environment Variables](http://railsapps.github.com/rails-environment-variables.html)
* dyskusja na ten temat na [Hacker News](http://news.ycombinator.com/item?id=4918484)

Z pliku *Gemfile* usuwamy gem *omniauth-twitter*, a zamiast niego dopisujemy
gem *omniauth-github* po czym instalujemy gemy:

    :::bash
    bundle install

W kontrolerze *SessionsControllers* w metodzie `new` podmieniamy
ścieżkę `/auth/twitter` na `/auth/github`:

    :::ruby
    class SessionsController < ApplicationController
      def new
        redirect_to '/auth/github'
      end

Pozostało jeszcze zarejestrować aplikację na swoim koncie na
[GitHubie](https://github.com/account/applications).

*Ważne:*
Jeśli aplikacja będzie działać na *localhost:3000*, to
w trakcie rejestracji w formularzu wpisujemy:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb
    Callback: http://localhost:3000

(Oczywiście, powyżej podajemy jakiś swój URL)

Jeśli — na *sigma.ug.edu.pl:3000*, to wpisujemy:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb
    Callback: http://sigma.ug.edu.pl:3000

(Oczywiście zamiast portu *3000* podajemy port na którym będzie działać nasza
aplikacja na Sigmie; URL – jw.)

Następnie ze strony [omniauth-github](https://github.com/intridea/omniauth-github)
kopiujemy do pliku *omniauth.rb* kod, który
dostosowujemy do konwencji Rails:

    :::ruby config/initializers/omniauth.rb
    OmniAuth.config.logger = Rails.logger

    raw_config = File.read("#{ENV['HOME']}/.credentials/applications.yml")
    github = YAML.load(raw_config)['github']
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :github, github['omniauth_provider_key'], github['omniauth_provider_secret']
    end

Dane zarejestrowanej na GitHubie aplikacji wpisujemy w pliku
*applications.yml* w taki sposób:

    :::yaml .credentials/applications.yml
    github:
      omniauth_provider_key: tutaj wklejamy klucz Client ID
      omniauth_provider_secret: tutaj wklejamy klucz Client Secret

*Ważne:* Nie usuwamy wygenerowanego kodu, tylko go wykomentowujemy.
Kod się jeszcze przyda przy wdrażaniu aplikacji na Heroku.

I to by było tyle, jeśli chodzi o oczywiste poprawki w aplikacji wygenerowanej
za pomocą generatora aplikacjii Rails Composer. Było tego całkiem sporo!


<blockquote>
 {%= image_tag "/images/coding-drunk.jpg", :alt => "[Coding Drunk]" %}
 <p class="author"><a href="http://radiogrraphie.org/blog/index.php?tag/fun">Blogogrraphie</a></p>
</blockquote>

# Zaczynamy kodzenie aplikacji

(Oczywiście kodzenie to pisanie kodu.)

Kodzenie zaczynamy od poprawek w wygenerowanym rusztowaniu
dla modelów *User* i *Student*.

**Użytkownik** zalogowany przez swoje konto na Githubie może być
**studentem** bywającym na jednym lub kilku prowadzonych
przeze mnie laboratoriach (dwa wytłuszczone rzeczowniki = dwa modele).

Z powyższego opisu wynika, że między modelami *User* i *Student*
jest relacja jeden do wielu.

Autentykację (czyli sprawdzenie tożsamości użytkownika)
scedujemy na GitHuba. Użyjemy gemu *OmniAuth* i strategii *OmniAuth-GitHub*.

Do autoryzacji (czyli przydzielania uprawnień)
użyjemy gemu *Rolify*. Utworzymy dwie role: „Admin” i „Owner”.
Admin w zasadzie może przeprowadzać dowolne operacje na dokumentach.
Wyjątkiem będzie zmienianie niektórych atrybutów otrzymanych z GitHuba,
na przykład *uid* lub *nickname*. Owner może przeglądać tylko swoje dane
i może zmieniać wartości tylko niektórych atrybutów, na przykład *full_name*
lub *login*. Wartości pozostałych atrybutów, przykładowo
*presences* lub *comments*, może zmieniać tylko Admin.

W aplikacji użyję gemu *strong_parameters* do filtrowania
atrybutów. Przykładowo, Adminowi odfiltrujemy atrybuty *uid* i *nickname*,
a Ownerowi – *class_name* i *comments*.


### Tworzenie ról za pomocą Rolify

Metoda *resourcify* gemu [rolify](https://github.com/EppO/rolify)
pozwala na powiązanie roli z konkretnym lub dowolnym egzemplarzem modelu.
Aby utworzyć taką rolę dopisujemy *resourcify* do modelu:

    :::ruby student.rb
    class Student
      include Mongoid::Document
      resourcify

Teraz role powiązane z modelem tworzymy za pomocą metody *add_role* lub *grant*.
Przykładowo tak kodujemy role dla konkretnego użytkownika:

    :::ruby
    # przyjmujemy, że Student belongs_to User
    user = User.first
    student = Student.first

    # rola powiązana z dowolnym egzemplarzem modelu (nie będziemy korzystać)
    user.add_role :student, Student
    user.grant    :student, Student

    # rola powiązana z konkretnym egzemplarzem modelu
    student.user.add_role :owner, student
    student.user.grant    :owner, student

Role nie powiązane z żadnymi zasobami, to role *globalne*, przykładowo:

    :::ruby
    user.add_role :admin     # rola globalna

Więcej przykładów znajdziemy na [wiki](https://github.com/EppO/rolify/wiki/Usage).


### Na czym polega technika „strong parameters”?

W Rails 3 problem „mass-assignment” zwalczamy za pomocą **attr_accessible**.
W Rails 4 – będziemy używać techniki **strong parameters**.
Technika ta polega na odfiltrowywaniu niektórych parametrów z hasza *params*.

Zanim skorzystamy z tej techniki musimy usunąć już wygenerowaną autoryzację –
usuwamy gem *cancan* z *Gemfile*, usuwamy plik *ability.rb*
z katalogu *models*, a w pliku *application_controller.rb*
wykomentowujemy końcowy fragment. W aplikacji Rails 3 trzeba też
zainstalować gem *strong parameters*.

<!--

2\. Ustawić w pliku *application.rb* zmienną `whitelist_attributes` na *false*:

    :::ruby config/application.rb
    config.active_record.whitelist_attributes = false

(Wystarczy wykomentować ten wiersz?)

3\. Włączyć `ActiveModel::ForbiddenAttributesProtection` do wszystkich modeli.
Na przykład można to zrobić tak:

    :::ruby /config/initializers/strong_parameters.rb
    ActiveRecord::Base.send(:include,  ActiveModel::ForbiddenAttributesProtection)

-->

Klasa `ActionController::Parameters` definuje dwie metody:

* `require(key)` – fetches the key out of the hash and raises
   a `ActionController::ParameterMissing` error if it’s missing
* `permit(keys)` – selects only the passed keys out of the parameters hash,
   and sets the permitted attribute to true

Jak używać tych metod jest opisane tutaj:

* [Strong Parameters](http://railscasts.com/episodes/371-strong-parameters)
* [Ruby On Rails Security Guide](http://edgeguides.rubyonrails.org/security.html)
* [Upgrading to Rails 4 – Parameters Security Tour](http://iconoclastlabs.com/cms/blog/posts/upgrading-to-rails-4-parameters-security-tour)

Oto prosty przykład użycia:

    :::ruby console
    params = ActionController::Parameters.new({
      user: {
        name: 'Octocat',
        age:  4,
        role: 'admin'
      }
    })
    # => {"user"=>{"name"=>"Octocat", "age"=>4, "role"=>"admin"}}

    # celowa pomyłka: :person zamiast :user
    permitted = params.require(:person).permit(:name, :age)
    # => ActionController::ParameterMissing: key not found: person

    params.require(:user).permit(:age)
    # => {"age"=>4}

    permitted = params.require(:user).permit(:name, :age)
    # => {"name"=>"Octocat", "age"=>4}

    permitted            # => {"name"=>"Octocat", "age"=>4}
    permitted.class      # => ActionController::Parameters
    permitted.permitted? # => true

    permitted.include? :admin # => false

    User.first.update_attributes!(permitted)
    # => #<User id: 1, name: "Octocat", age: 4, role: "admin">


## Model User

Na razie widok *index* dla *users* prezentuje się tak:

{%= image_tag "/images/lista-obecnosci-users-2013.png", :alt => "[Lista obecności / Users, 12/13]" %}

Scaffold + Bootstrap – w sumie banał i rutyna.
Widok ten jest dostępny tylko dla Admina. Pewnie kiedyś trzeba będzie
go poprawić.


### GitHub i OmniAuth

Po zalogowaniu się użytkownika w aplikacji, zapisujemy jego dane przesłane
z Githuba w kolekcji *users*; gdy w danych brak jest adresu email,
to prosimy użytkownika o jego wpisanie.
Pierwszy zalogowany użytkownik będzie Adminem.

Cały ten proces jest zaprogramowany w kodzie kontrolera *SessionsController*:

    :::ruby
    class SessionsController < ApplicationController
      def new
        redirect_to '/auth/github'
      end

      def create
        auth = request.env["omniauth.auth"]

        unless user = User.where(provider: auth['provider'], uid: auth['uid'].to_s).first
          user = User.create_with_omniauth(auth)
          if User.count == 1        # make the first user an admin
            user.add_role :admin    # add global role
          else
            user.grant :owner, user # add local role
          end
        end

        session[:user_id] = user.id

        if user.email.blank?
          redirect_to edit_user_path(user), notice: "Please enter your email address."
        else
          redirect_to root_url, notice: "Signed in!"
        end
      end

      def destroy
        reset_session
        redirect_to root_url, notice: "Signed out!"
      end
      def failure
        redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
      end
    end


### Czym jest OmniAuth?

[OmniAuth](https://github.com/intridea/omniauth) is a library that
standardizes multi-provider authentication for web applications. […]
Once the user has authenticated OmniAuth simply sets a special hash
called the *Authentication Hash* on the Rack environment:

    :::ruby sessions_controller.rb
    request.env['omniauth.auth']

This information is meant to be as normalized as possible.
Some fields will **always** be present:

* **provider** – the provider with which the user authenticated
  (e.g. 'twitter' or 'facebook')
* **uid** – an identifier unique to the given provider, such as a
  Twitter user ID; **should be stored as a string**
* **info** – a hash containing information about the user
* **name** - the best display name known to the strategy; usually a
  concatenation of first and last name, but may also be an arbitrary
  designator or nickname for some strategies
* **email** (optional) – the email of the authenticating user; should
  be provided if at all possible (but some sites such as Twitter do
  not provide this information)

Pozostałe pola są opisane na wiki w artykule
[Auth Hash Schema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema).

*UID*, na przykład użytkownika *octocat*, możemy sprawdzić wykonując
polecenie:

    :::bash
    curl -i https://api.github.com/users/octocat

Wartość wpisana w polu ID to UID użytkownika na serwerze GitHub.
Przykładowo UID użytkownika *octocat* to 583231.


### Poprawki kodzie modelu

W modelu *User* usuwamy *attr_accessible*, dopisujemy
powiązanie z (jeszcze nieistniejącym) modelem *Student*,
dodajemy kod dla atrybutu *nickname*:

    :::ruby user.rb
    class User
      include Mongoid::Document

      has_many :students, dependent: :delete

      rolify # https://github.com/EppO/rolify

      field :provider, type: String
      field :uid, type: String
      field :name, type: String
      field :email, type: String     # Github – optional
      field :nickname, type: String  # Github – login

      # run 'rake db:mongoid:create_indexes' to create indexes
      index({ email: 1 }, { unique: true, background: true })

      default_scope asc(:nickname)

      def self.create_with_omniauth(auth)
        create! do |user|
          user.provider = auth['provider']
          user.uid = auth['uid']
          if auth['info']
             user.name = auth['info']['name'] || ""
             user.email = auth['info']['email'] || ""
             user.nickname = auth['info']['nickname'] || ""
          end
        end
      end
    end


### Autoryzacja użytkowników

W kontrolerze będziemy filtrować atrybuty. Autoryzację przeniesiemy do
*ApplicationController* i klasy *Permission*.

    :::ruby users_controller.rb
    class UsersController < ApplicationController
      before_filter :authorize

      def index
        @users = User.all
      end
      def edit
        @user = User.find(params[:id])
        # email attribute
      end
      def update
        @user = User.find(params[:id])
        if @user.update_attributes(user_params)
          redirect_to root_url
        else
          render :edit
        end
      end
      def destroy
        @user = User.find(params[:id])
        @user.destroy

        respond_to do |format|
          format.html { redirect_to users_url }
          format.json { head :no_content }
        end
      end

      private

        def user_params
          # params[:user]
          if current_user.has_role? :admin
            params.require(:user).permit(:role_ids, :name, :email)
          else
            params.require(:user).permit(:email)
          end
        end
        def current_resource
          @current_resource ||= User.find(params[:id]) if params[:id]
        end
    end

Pozostałe metody użyte w kodzie kontrolera są zdefiniowane
w *ApplicationController*:

    :::ruby application_controller.rb
    class ApplicationController < ActionController::Base
      protect_from_forgery

      helper_method :current_user
      helper_method :user_signed_in?

      delegate :allow?, to: :current_permission
      helper_method :allow?

      private
        def current_user
          begin
            @current_user ||= User.find(session[:user_id]) if session[:user_id]
          rescue Exception => e
            nil
          end
        end
        def authorize
          if !current_permission.allow?(params[:controller], params[:action], current_resource)
            redirect_to root_url, alert: "Only admin can access this page."
          end
        end
        def current_permission
          @current_permission ||= Permission.new(current_user)
        end
        def current_resource
          nil
        end
        def user_signed_in?
          return true if current_user
        end
    end

Dane użytkowników może przeglądać i edytowawać tylko Admin,
z wyjątkiem atrybutu *email*, który edytować może też jego właściciel.

Uprawnienia są przydzielane w klasie *Permission*. Do sprawdzania uprawnień
używamy metody `allow?`.

    :::ruby permission.rb
    class Permission < Struct.new(:user)
      def allow?(controller, action, resource = nil)
        if user
          return true if controller == "users" && action.in?(%w[index destroy]) &&
            user.has_role?(:admin)
          return true if controller == "users" && action.in?(%[edit update]) &&
            (user.has_role?(:admin) || user.has_role?(:owner, resource))
        end

        false
      end
    end

Powyższy kod wzorowany jest na
[Authorization from Scratch Part 1](http://railscasts.com/episodes/385-authorization-from-scratch-part-1).


## Scaffolding Student

Stroną główną aplikacji „Lista obecności” będzie widok *index* modelu *Student*:

{%= image_tag "/images/lista-obecnosci-2013.png", :alt => "[Lista obecnsosci 12/13]" %}

Jak widać na obrazku powyżej, obecności nie były jeszcze sprawdzane. Stąd
„0” w pierwszej kolumnie.

Generujemy rusztowanie dla modelu *Student*.
Oczywiście w aplikacji *Dziennik Lekcyjny* nie może zabraknąć
atrybutów obecność i uwagi:

    :::bash terminal
    rails generate scaffold Student \
      first_name:String last_name:String \
      login:String \
      repository:String \
      class_name:String group:String \
      presences:Array \
      comments:String
    rm app/assets/stylesheets/scaffolds.css.less

Wygenerowana ze scaffold widoki nie korzystają z Twitter Bootstrap.
Aby to zmienić, nadpisujemy je za pomocą polecenia:

    :::bash
    rails generate bootstrap:themed students


### Model

Do wygenerowanego kodu dopisujemy wartości domyślne atrybutów do modelu
oraz powiązanie z modelem *User*:

    :::ruby student.rb
    class Student
      include Mongoid::Document

      resourcify # https://github.com/EppO/rolify/wiki/Configuration

      belongs_to :user

      field :first_name, type: String
      field :last_name, type: String
      field :login, type: String
      field :presences, type: Array
      field :class_name, type: String, default: "unallocated"
      field :group, type: String, default: "2013-summer"
      field :comments, type: String
      field :repository, type: String

      default_scope asc(:last_name, :first_name)

      def full_name
        [first_name, last_name].join(' ')
      end
      def full_name=(name)
        split = name.split(' ', 2)
        self.first_name = split.first
        self.last_name = split.last
      end
      def presences_list
        presences.to_a.join(' ') # .to_a handles nil attribute
      end
      def presences_list=(string)
        list = string.strip.split(' ') # najpierw strip, później split
        set(:presences, list)
      end
      def presences_length
        presences.to_a.length
      end
    end


### Widoki

Formularz:

    :::rhtml _form.html.erb
    <%= simple_form_for @student, html: { class: 'form-horizontal' } do |f| %>
      <%= f.input :full_name, placeholder: 'Imię Nazwisko', hint: 'Imię Nazwisko' %>
      <%= f.input :login %>
      <%= f.input :presences_list, label: "Presences (m-d)", input_html: { class: "span8"} %>
      <%= f.input :class_name, as: :select,
                  collection: { "nieprzydzielony" => "unallocated",
                                "architektura serwisów internetowych" => "asi",
                                "języki programowania" => "jp",
                                "projekt zespołowy" => "pz",
                                "techniki internetowe" => "ti",
                                "technologie nosql" => "nosql" },
                  input_html: { class: "span8", disabled: false } %>

      <%= f.association :user, collection: User.only(:nickname), label_method: :nickname %>

      <%= f.input :comments, as: :text, input_html: { class: "span8", rows: "6" } %>
      <%= f.input :repository, input_html: { class: "span8"} %>
      <div class="form-actions">
        <%= f.button :submit, class: 'btn-primary' %>
        <%= link_to t('.cancel', default: t("helpers.links.cancel")),
                    students_path, class: 'btn' %>
      </div>
    <% end %>

Poprawki w widoku *index*:

    :::rhtml index.html.erb
    <%- model_class = Student -%>
    <div class="page-header">
      <h4><%= link_to raw("<i class='icon-user icon-large'></i>  ") +
                  t('.new', default: t("helpers.links.new")),
                  new_student_path, class: 'btn btn-primary' %>
          <%=t '.title', default: model_class.model_name.human %>
      </h4>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th><%= model_class.human_attribute_name(:full_name) %></th>
          <th><%= model_class.human_attribute_name(:login) %></th>
          <th><%= model_class.human_attribute_name(:class_name) %></th>
          <th>GitHub</th>
          <th><%=t '.actions', :default => t("helpers.actions") %></th>
        </tr>
      </thead>
      <tbody>
        <% @students.each do |student| %>
          <tr>
            <td><%= student.presences_length %></td>
            <td><%= student.full_name %></td>
            <td><%= student.login %></td>
            <td><%= student.class_name %></td>
            <td><%= link_to_if_on_github student %></td>
            <td>
              <%= link_to t('.edit', default: t("helpers.links.edit")),
                          edit_student_path(student), class: 'btn btn-mini' %>
              <%= link_to t('.destroy', default: t("helpers.links.destroy")),
                          student_path(student),
                          method: :delete,
                          data: { confirm:
                            t('.confirm',
                              default: t("helpers.links.confirm",
                                default: 'Are you sure?')) },
                          class: 'btn btn-mini btn-danger' %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>

Podobne poprawki wprowadzamy w pozostałych widokach.

*TODO:* W kodzie powyżej użyć szablonu częściowego *_student.html.erb*.


### Kontroler

Dopisujemy *authorize*, *students_params* i *current_resource*.
W metodzie update zamieniamy przekierowanie z *student_path* na *root_path*.

Rolę `:owner` dodamy użytkownikowi, którego dane zostały uaktualnione
danymi z GitHuba z kolekcji *User*.
Tę rolę ograniczamy do dopiero co uaktualnionego egzemplarza modelu *Student*.

    :::ruby
    class StudentsController < ApplicationController
      before_filter :authorize

      def update
        @student = Student.find(params[:id])
        respond_to do |format|
          if @student.update_attributes(student_params)

            # scope role to a resource instance
            @student.user.grant(:owner, @student) if @student.user

            format.html { redirect_to root_path, notice: 'Student was successfully updated.' }
            ...
          else
            ...
          end
        end
      end

      private
        def student_params
          if current_user.has_role?(:admin)
            params.require(:student).permit(:user_id, :full_name,
              :login, :presences_list, :class_name, :comments, :repository)
          else
            params.require(:student).permit(:full_name,
              :login, :repository)
          end
        end
        def current_resource
          @current_resource ||= Student.find(params[:id]) if params[:id]
        end
    end


Na konsoli Rails, sprawdzamy jak dizałają role lokalne:

    :::ruby console
    user = User.where(uid: '1198062').first # zakładamy, że taki użytkownik kiedyś się zalogował
    user.has_role? :admin
    user.has_role? :student
    user.has_role? :student, Student
    user.has_role? :student, user.students.first


### Autoryzacja studentów

Po dopisaniu uprawnień studentów nadal można je wszystkie ogarnąć.

    :::ruby permission.rb
    class Permission < Struct.new(:user)
      def allow?(controller, action, resource = nil)
        return true if controller == "students" && action == "index"

        if user
          return true if controller == "users" && action.in?(%w[index destroy]) &&
            user.has_role?(:admin)
          return true if controller == "users" && action.in?(%[edit update]) &&
            (user.has_role?(:admin) || user.has_role?(:owner, resource))

          return true if controller == "students" &&
            (user.has_role?(:admin) || (action.in?(%w[edit update show]) && user.has_role?(:owner, resource)))
        end

        false
      end
    end


### Seeding students collection

Na razie zapełnimy kolekcję *students* takimi przykładowymi danymi:

    :::ruby seeds.rb
    Student.destroy_all

    Student.create! full_name: "Jan Kuszelas", login: "jkuszelas", class_name: "nosql"
    Student.create! full_name: "Felicjan Klonowski", login: "fklonowski", class_name: "jp"
    Student.create! full_name: "Joga Korolczyk", login: "jkorolczyk", class_name: "ti"
    Student.create! full_name: "Simona Grabczyk", login: "sgrabczyk", class_name: "asi"
    Student.create! full_name: "Irena Kamińska", login: "ikaminska", class_name: "pz"
    Student.create! full_name: "Kazimierz Jankowski", login: "kjankowski", class_name: "unallocated"
    Student.create! full_name: "Włodzimierz Bzyl", login: "wbzyl", class_name: "unallocated"
    Student.create! full_name: "Octo Cat", login: "ocat", class_name: "unallocated"


## Gauges, czyli mierniki

Do sprawdzania **obecności** spróbujemy czegoś niesztampowego –
[mierników](https://developers.google.com/chart/interactive/docs/gallery/gauge)
z [Google Chart Tools](https://developers.google.com/chart/). Tak to ma się
prezentować:

{%= image_tag "/images/gauges-2013.png", :alt => "[Lista obecności, 12/13]" %}

W semestrze jest piętnaście laboratoriów. Jak widać powyżej zajęcia się dopiero
zaczęły. Przyciski są dla Admina do dodawania obecności
na laboratoriach. Przewidziany jest eksport danych do formatu arkusza
kalkulacyjnego (Excel, OpenOffice).

Zaczniemy od wygenerowania nowego kontrolera z metodą index (bez modelu, nie
będzie potrzebny):

    :::bash
    rails g controller gauges index update


### Autoryzacja gauges

Dopisujemy dwie linijki do pliku *permission.rb*:

    :::ruby permission.rb
    class Permission < Struct.new(:user)
      def allow?(controller, action, resource = nil)
        ...
        return true if controller == "gauges" && action == "index"
        if user
          ...
          return true if controller == "guages" && user.has_role?(:admin)
        end
        false
      end
    end

czyli każdy może wejść na stronę z miernikami, ale tylko Admin może
uaktualnić wskazania mierników:

    :::ruby gauges_controller.rb
    class GaugesController < ApplicationController
      # GET /students
      def index
        @students = Student.all
      end
      # PUT /students/1
      def update
        @student = Student.find(params[:id])
        if current_user && current_user.has_role?(:admin)
          @student.add_to_set(:presences, today_presence)
          redirect_to(gauges_url) && return
        end
        redirect_to(root_url, alert: 'Only admin can do that.')
      end
    end

Zostało jeszcze uaktualnienie routingu:

    :::ruby routes.rb
    MongoidOmniauthTwitter::Application.routes.draw do
      resources :users, :only => [:index, :edit, :update, :destroy]
      resources :students
      resources :gauges, :only => [:index, :update]
      ...

### Widok z gauges

[Gauges](https://developers.google.com/chart/interactive/docs/gallery/gauge)
pochodzą z Google Visualisation Tools.
Aby z nich skorzystać musimy wczytać „google API loader”,
po czym załadować pakiet *gauge*.

Mierniki generowane są w widoku *index*:

    :::rhtml views/gauges/index.html.erb
    <%- model_class = Student -%>
    <% content_for :head do %>
      <script type='text/javascript' src='https://www.google.com/jsapi'></script>
      <%= javascript_include_tag 'google_gauges' %>
    <% end %>
    <div class="page-header">
      <h3>Obecności na zajęciach</h3>
    </div>

    <% @students.each do |student| %>
      <%= content_tag :div, class: "gauge" do -%>
        <%= content_tag :div, "",
              { id: student.login, data: { presences_length: student.presences_length } } %>
        <%= link_to raw("<i class='icon-dashboard'> </i>") + student.last_name,
                gauge_path(student), method: :put, class: 'btn' %>
      <% end %>
    <% end %>

Plik *google_gauges.js* jest wczytywany tylko na stronie *index*:

    :::js app/assets/javascripts/google_gauges.js
    google.load('visualization', '1', {packages:['gauge']});
    google.setOnLoadCallback(drawGauges);

    function drawGauges() {
      var options = {
        width: 162, height: 162, redFrom: 13, redTo: 15,
        yellowFrom: 10, yellowTo: 13, greenFrom: 8, greenTo: 10,
        max: 15, minorTicks: 0, majorTicks: [0, 15]
      };
      $('.gauges.index .gauge > div[id]').each(function() {
        var gauges = new google.visualization.Gauge(document.getElementById(this.id));
        var data = google.visualization.arrayToDataTable([
          [this.id], [$(this).data('presences-length')]
        ]);
        gauges.draw(data, options);
      });
    }

Powyższy kod inicjalizuje mierniki i umieszcza je na stronie.
Login studenta i jego liczbę obecności są pobierane z *id* oraz
atrybutu *data* wygenrowanego kodu HTML.


## TODO: Wyszukiwanie grup studentów

W menu umieściłem wszystkie swoje grupy laboratoryjne
w semestrze letnim, r. akad. 2011/12:

{%= image_tag "/images/dziennik-menu.png", :alt => "[dziennik menu]" %}

Dane studentów zapisywane są w kolekcji *students*.
Aby wyszukać wszystkich studentów z jednej grupy w zapytaniu
dodaję: nazwę grupy, rok i semestr:

    :::rhtml app/views/common/_menu.html.erb
    <%= link_to "Dziennik lekcyjny, lato 11/12", root_path, class: "brand" %>

    <ul class="nav">
      <li class="active"><a href="http://tao.inf.ug.edu.pl">Home</a>
      <li><%= link_to "About", root_path %>
      <li class="dropdown" data-dropdown="dropdown">
        <a href="#" class="dropdown-toggle">Classes</a>
        <ul class="dropdown-menu">
          <li><%= link_to "architektura serwisów internetowych", students_path(class_name: "asi", year: 2011, semester: "summer") %>
          <li><%= link_to "techologie nosql", students_path(class_name: "nosql", year: 2011, semester: "summer") %>
          <li class="divider"></li>
          <li><a href="http://inf.ug.edu.pl/plan">plan zajęć</a>
        </ul>
      </li>
      <li><%= link_to "Admin", admin_students_path %>
    </ul>
    <form action="" class="pull-right">
      <button class="btn" type="submit">Sign in through GitHub</button>
    </form>

Studentów wyszukuję w metodzie *index* kontrolera.
Docelowo, należałoby przenieść wyszukiwanie do modelu.

    :::ruby
    # GET /students
    # GET /students.json
    def index
      # logger.info "☻ request query parametereq.query_parameters}"

      class_name = params[:class_name] || "unknown"
      year = params[:year] || "2011"
      semester = params[:semester] || "summer"

      if params[:class_name]
        @students = Student.where(class_name: class_name, year: year, semester: semester)
      else
        @students = Student.where(year: 2011) # dodać class_name: "unallocated" ?
      end

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @students }
      end
    end


## TODO: Dodawanie (nie)obecności

**Tylko wersja AJAX**

Aktualnie kliknięcie w „buźkę” przy nazwisku studenta, przeładowuje stronę
wyświetlając ją z dodaną kropką (nieobecność).

Po przeładowaniu, strona wyświetla się od początku, a nie od miejsca
w w którym kliknęliśmy. Takie zachowanie jest szczególnie uciążliwe
przy kilku stronicowych listach studentów. Użyję Ajaxa aby to zmienić.

Zaczniemy od dodania formatu JSON do metody *not_present*:

    :::ruby app/controllers/students_controller.rb
    # PUT /students/1/not_present
    # PUT /students/1/not_present.json
    def not_present
      @student = Student.find(params[:id])

      respond_to do |format|
        if @student.add_to_set(:absences, today_absence)
          format.html { redirect_to students_url, notice: 'Student absences were successfully updated.' }
          format.json { render :json => { value: bullets(@student.absences) }.to_json }
        else
          format.html { render action: "edit" }
          format.json { render json: @student.errors, status: :unprocessable_entity }
        end
      end
    end

Po podmianie kodu, mamy problemy. Po kliknięciu '☺' w oknie przeglądarki
pojawia się komunikat:

    undefined method `bullets' for #<StudentsController:0x00...>

Oznacza to, że musimy przenieść kod metody pomocniczej *bullets* do
*ApplicationController* i dodać ją z powrotem do metod pomocniczych:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      helper_method :today_absence, :bullets
      ...

Aby po kliknięciu w link z '☺' wykonał się kod z *format.json*
wystarczy, bo korzystamy z adapteru *jQuery-UJS*,
zmodyfikować *link_to* w taki sposób:

    :::rhtml app/views/students/index.html.erb
    <div class="presence"><%= link_to '☺', not_present_student_path(student),
        method: :put, remote: true, data: { type: :json } %>
    </div>

Adapter *jQuery-UJS* zmienia funkcję każdego linku z atrybutem *data-remote*
(generowanym przez *link_to* z argumentem *remote: true*).
Taki link wysyła żądanie *jQuery.ajax()*.

Po tej zmianie w kodzie, strona nie powinna być przeładowywana.
Pozostaje uaktualnić jej zawartość.

Na początek przyjrzymy się na konsoli przeglądarki wysyłanym
żądaniom i odbieranym odpowiedziom:

    :::js students.js
    $('a[data-type=\"json\"]').bind('ajax:success', function(event, data, status, xhr) {
      var link = $(this);
      console.log(link);
      console.log(JSON.stringify(data)); // prettyprint JSON object
    });

Z tego co widać, wystarczy odebrać wysłany przez naszą
aplikację obiekt JSON i uaktualnić zawartość strony:

    :::ruby students.js
    $('a[data-type=\"json\"]').bind('ajax:success', function(event, data, status, xhr) {
      var div = $(this).parent();
      div.html('☻'); // replace content div.presence with the black smiley

      var absences = div.parent().find('.absences');
      absences.html(data.value);
    });

Gotowe!


## TODO: Routing (sprawdzić i ujednolicić terminologię)

OmniAuth ma wbudowany routing dla wspieranych dostawców (*providers*).
Dla Githuba jest to:

    /auth/github          # przekierowanie na Github
    /auth/github/callback # przekierowanie po pomyślnej autentykacji
    /auth/failure         # tutaj, w przeciwnym wypadku

Dlatego w pliku *routes.rb* wpisujemy:

    :::ruby config/routes.rb
    match '/auth/:provider/callback' => 'session#create'
    match '/auth/failure' => 'session#failure'

Metody pomocnicze *signout_path*, *signin_path* też zwiększą
czytelność kodu:

    :::ruby config/routes.rb
    match '/signout' => 'session#destroy', :as => :signout
    match '/signin' => 'session#new', :as => :signin


## Zapisujemy powyższe dane w bazie MongoDB

Wygenerowany kod dla modelu *User* (dodać *default* dla roli?):

    :::ruby app/models/user.rb
    class User
      include Mongoid::Document

      include Mongoid::Timestamps

      rolify
      field :provider, type: String
      field :uid, type: String
      field :name, type: String
      field :email, type: String
      attr_accessible :role_ids, :as => :admin
      attr_accessible :provider, :uid, :name, :email
      # run 'rake db:mongoid:create_indexes' to create indexes
      index({ email: 1 }, { unique: true, background: true })

      def self.create_with_omniauth(auth)
        create! do |user|
          user.provider = auth['provider']
          user.uid = auth['uid']
          if auth['info']
             user.name = auth['info']['name'] || ""
             user.email = auth['info']['email'] || ""
          end
        end
      end

    end


# TODO: Autoryzacja

**UWAGA:** Powinno wystarczyć *strong_parameters*.



## Jak działają Strong Parametergewać przykładową aplikację i scaffold.
Na konsoli sprawdzić jak to działa:
*require*, *permit*

* [Strong Parameters](http://railscasts.com/episodes/371-strong-parameters?view=asciicast)
* [Upgrading to Rails 4 - Parameters](http://iconoclastlabs.com/cms/blog/posts/upgrading-to-rails-4-parameters-security-tour)


## Usunąć?

Autoryzację zaimplementujemy korzystając z gemu
[CanCan](https://github.com/ryanb/cancan).
Dopisujemy go do *Gemfile*:

    :::ruby
    gem 'cancan'

i instalujemy wykonując polecenie *bundle*.

Do aplikacji dodamy trzy role:

* **admin** — czyli ja, może wszystko
* **student** — może przeglądać swoje dane, może modyfikować
  atrybuty: *comments*, inne atrybuty?

Będzie też „guest user”:

* **guest** – może przeglądać dane na stronie głównej


## CanCan Abilities

* [CanCan README](https://github.com/ryanb/cancan)

1\. Handle Unauthorized Access:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      rescue_from CanCan::AccessDenied do |exception|
        redirect_to root_url, alert: exception.message
      end
    end

Zobacz [Exception Handling](https://github.com/ryanb/cancan/wiki/exception-handling).

W *StudentsController* dopisujemy:

    :::ruby app/controllers/students_controller.rb
    class StudentsController < ApplicationController
      load_and_authorize_resource
      # skip_authorize_resource :only => :index

W *UsersController* dopisujemy:

    :::ruby app/controllers/users_controller.rb
    class UsersController < ApplicationController
      load_and_authorize_resource

2\. [Define Abilities](https://github.com/ryanb/cancan/wiki/Defining-Abilities):

    :::ruby
    rails g cancan:ability

Wygenerowana klasa, po poprawkach:

    :::ruby app/models/ability.rb
    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new     # guest user (not logged in)

        if user.admin?
          can :manage, :all
        elsif user.student?
          can [:index, :show, :edit, :update], Student, uid: user.uid
        else
          can :index, Student
        end
      end

    end

Dopisujemy do *ApplicationController*:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      helper_method :current_user

      private

      def current_user
        begin
          @current_user ||= User.find(session[:user_id]) if session[:user_id]
        rescue Mongoid::Errors::DocumentNotFound
          nil
        end
      end

    end

Do modelu *User* dopisujemy:

    :::ruby app/models/user.rb
    def admin?
      uid == 8049  # mój id na githubie
    end
    def student?
      (uid != nil) && (uid != 8049)
    end


Jak zabezpieczyć się przed „mass-assignment”:

* [ActiveModel::MassAssignmentSecurity::ClassMethods](http://api.rubyonrails.org/classes/ActiveModel/MassAssignmentSecurity/ClassMethods.html)
* [attr_protected](http://api.rubyonrails.org/classes/ActiveModel/MassAssignmentSecurity/ClassMethods.html#method-i-attr_protected)
* [attr_accessible](http://api.rubyonrails.org/classes/ActiveModel/MassAssignmentSecurity/ClassMethods.html#method-i-attr_accessible)

Cytat: „Mass assignment security provides an interface for protecting
attributes from end-user assignment. For more complex permissions,
mass assignment security may be handled outside the model by extending
a non-ActiveRecord class, such as a controller, with this behavior.”


# Kilka uwag na marginesie…

1\. W trybie produkcyjnym, aplikacja korzysta ze skopilowanych *assets*:

    :::bash
    bin/rake assets:precompile   # Compile all the assets named in config.assets.precompile

Po przejściu do trybu development, powinniśmy usunąć skopilowane pliki:

    :::bash
    bin/rake assets:clean

Jeśli tego nie zrobimy, to zmiany w plikach JavaScript i CSS nie zostaną użyte.

2\. Sprawdzić czymportowane pliki należy dopisać do listy *config.assets.precompile*, na przykład

    :::ruby config/environments/production.rb
    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w( dziennik-lekcyjny )

3\. **i18n**: Dodajemy do katalogu *config/initializers* plik *mongoid.rb*
w którym wpisujemy (*i18n*):

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

Od razu zmieniamy domyślne locale na polskie (co to znaczy?):

    :::ruby config/application.rb
    config.i18n.default_locale = :pl

Replica sets, master/slave, multiple databases – na razie
pomijamy. Sharding – też.


4\. Kilka uwag o robieniu kopii zapasowych danych z bazy MongoDB.

Eksport do pliku tekstowego:

    :::bash terminal
    mongoexport -d dziennik_lekcyjny -c students -o students-$(date +%Y-%m-%d).json
    mongoexport -d dziennik_lekcyjny -c users -o users-$(date +%Y-%m-%d).json

Wybieramy format JSON. Teraz odtworzenie bazy z kopii zapasowej
może wyglądać tak:

    :::bash terminal
    mongoimport --drop -d dziennik_lekcyjny -c students students-2012-03-03.json
    mongoimport --drop -d dziennik_lekcyjny -c users users-2012-03-03.json

Możemy też wykonać zrzut bazy. Zrzut wykonujemy na **działającej** bazie:

    :::bash
    mongodump -d dziennik_lekcyjny -o backup

A tak odtwarzamy zawartość bazy z zrzutu:

    :::bash
    mongorestore -d test --drop backup/dziennik_lekcyjny/

**Uwaga:** W powyższym przykładzie backup wszystkich kolekcji z bazy
*dziennik_lekcyjny* importujemy do bazy *test*, a nie
do *dziennik_lekcyjny*! Tak na wszelki wypadek, aby bezmyślne
przeklikanie nie skończyło się katastrofą!