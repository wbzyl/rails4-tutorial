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

Pozostało jeszcze zarejestrować aplikację na
[GitHubie](https://github.com/settings/applications).

Jeśli zamierzamy korzystać ze strategii *omniauth-twitter*, to aplikację
rejestrujemy na [Twitterze](https://dev.twitter.com/apps/new).
Więcej szczegółów znajdziemy
w [Rails Tutorial for OmniAuth with Mongoid](http://railsapps.github.com/tutorial-rails-mongoid-omniauth.html).

*Ważne:*
Jeśli aplikacja będzie działać na *localhost:3000*, to
w trakcie rejestracji na w GitHubie formularzu wpisujemy:

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

Jak zabezpieczaliśmy się przed „mass-assignment” w Rails 3:

* [ActiveModel::MassAssignmentSecurity::ClassMethods](http://api.rubyonrails.org/classes/ActiveModel/MassAssignmentSecurity/ClassMethods.html)
* [attr_accessible](http://api.rubyonrails.org/classes/ActiveModel/MassAssignmentSecurity/ClassMethods.html#method-i-attr_accessible)

Zanim skorzystamy z tej techniki musimy usunąć już wygenerowaną autoryzację –
usuwamy gem *cancan* z *Gemfile*, usuwamy plik *ability.rb*
z katalogu *models*, a w pliku *application_controller.rb*
wykomentowujemy końcowy fragment. W aplikacji Rails 3 trzeba też
zainstalować gem *strong parameters*.

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
Widok ten jest dostępny tylko dla Admina. Niechybnie Admin będzie chciał
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
        # does not work with when deployed to passenger sub-uri
        # redirect_to '/auth/github'
        # but this does work
        redirect_to(request.env['SCRIPT_NAME'].to_s + '/auth/github')
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


### Poprawki w kodzie modelu User

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

W kontrolerze będziemy tylko filtrować atrybuty. Autoryzację przeniesiemy do
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
        helper_method :current_user

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
        helper_method :user_signed_in?
    end

Dane użytkowników może przeglądać i edytować tylko Admin,
z wyjątkiem atrybutu *email*, który edytować może też właściciel.

Uprawnienia są przydzielane w klasie *Permission*. Do sprawdzania uprawnień
napiszemy metodę *allow?*

    :::ruby app/models/permission.rb
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
[Authorization from Scratch Part 1](http://railscasts.com/episodes/385-authorization-from-scratch-part-1)
R. Batesa.


## Scaffolding Student

Stroną główną aplikacji „Lista obecności” jest strona na której
można zobaczyć ile razy student był obecny na zajęciach i na której
można edytować dane studentów (oczywiście, obecności też):

{%= image_tag "/images/lista-obecnosci-2013.png", :alt => "[Lista obecnsosci 12/13]" %}

Jak widać na powyższym obrazku, obecności nie były jeszcze sprawdzane.
Stąd „0” w pierwszej kolumnie.

Generujemy rusztowanie dla modelu *Student*.
Oczywiście w aplikacji „Lista obecności” nie może zabraknąć
atrybutu obecność uwagi:

    :::bash terminal
    rails generate scaffold Student \
      first_name:String last_name:String \
      login:String \
      repository:String \
      class_name:String group:String \
      presences:Array \
      comments:String
    rm app/assets/stylesheets/scaffolds.css.less

Widoki wygenerowane ze scaffold widoki nie korzystają z Twitter Bootstrap.
Aby to zmienić, nadpisujemy je za pomocą generatora:

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

      # wirtualne atrybuty: full_name, presences_list
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
        <%= render partial: "student", collection: @students %>
      </tbody>
    </table>

Wiersz tabeli z danymi studenta renderujemy w widoku częściowym *student*:

    :::rhtml
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

Podobne poprawki wprowadzamy w pozostałych widokach.


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


Na konsoli Rails, sprawdzamy jak działają te role lokalne:

    :::ruby console
    user = User.where(uid: '1198062').first # zakładamy, że taki użytkownik kiedyś się zalogował
    user.has_role? :admin
    user.has_role? :owner
    user.has_role? :owner, Student
    user.has_role? :owner, user.students.first  #=> true


### Autoryzacja studentów

Po dopisaniu uprawnień studentów do klasy *Permission* kod jest w dalszym
ciągu czytelny:

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
z [Google Chart Tools](https://developers.google.com/chart/):

{%= image_tag "/images/gauges-2013.png", :alt => "[Lista obecności, 12/13]" %}

Liczba na mierniku pokazuje ile razy student był obecny na zajęciach.
W semestrze jest piętnaście laboratoriów. Dlatego zakres miernika to 0–15.
Jak widać na załączonym obrazku, zajęcia dopiero się
zaczęły.

Admin klikając przyciski dodaje obecności.

W następnej wersji aplikacji przewidziany jest eksport danych do formatu
Excel, OpenOffice i PDF.

Tym razem zaczniemy od wygenerowania nowego kontrolera
z metodami `index` i `update` (bez modelu, nie będzie nam potrzebny):

    :::bash
    rails g controller gauges index update


### Autoryzacja gauges

To tylko dwa wiersze kodu dopisane w pliku *permission.rb*:

    :::ruby app/models/permission.rb
    class Permission < Struct.new(:user)
      def allow?(controller, action, resource = nil)
        ...
        return true if controller == "gauges" && action == "index"
        if user
          ...
          return true if controller == "gauges" && user.has_role?(:admin)
        end
        false
      end
    end

Z kodu wynika, że każdy może wejść na stronę z miernikami,
ale tylko Admin może uaktualniać wskazania mierników:

    :::ruby gauges_controller.rb
    class GaugesController < ApplicationController
      before_filter :authorize

      # GET /students
      def index
        @students = Student.all
      end
      # PUT /students/1
      def update
        @student = Student.find(params[:id])

        if @student.add_to_set(:presences, today_presence)
          redirect_to gauges_url
        else
          redirect_to gauges_url, alert: 'This can’t happen. Attribute presences wasn’t updated.'
        end
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
    <%= render partial: "gauge", collection: @students %>

Sam miernik jest generowany przez widok częściowy *_gauge.html.erb*:

    :::rhtml app/views/gauges/_gauge.html.erb
    <%= content_tag :div, class: "gauge" do -%>
      <%= content_tag :div, "", {
            id: gauge.login, data: { presences_length: gauge.presences_length }
          } %>
      <%= link_to raw("<i class='icon-dashboard'> </i>") + gauge.last_name,
            gauge_path(gauge), method: :put, class: 'btn' %>
    <% end %>

I wczytywany tylko na stronie *index*, plik *google_gauges.js*:

    :::js app/assets/javascripts/google_gauges.js
    google.load('visualization', '1', {packages:['gauge']});
    google.setOnLoadCallback(drawGauges);

    function drawGauges() {
      var options = {
        width: 162, height: 162,
        redFrom: 13, redTo: 15,
        yellowFrom: 10, yellowTo: 13,
        greenFrom: 8, greenTo: 10,
        max: 15,
        minorTicks: 0, majorTicks: [0, 15]
      };
      $('.gauges.index .gauge > div[id]').each(function() {
        drawGauge(this, options);
      });
    };

    function drawGauge(domElement, options) {
      var gauges = new google.visualization.Gauge(document.getElementById(domElement.id));
      var data = google.visualization.arrayToDataTable([
        [domElement.id], [$(domElement).data('presences-length')]
      ]);
      gauges.draw(data, options);
    };

Powyższy kod inicjalizuje mierniki i umieszcza je na stronie.
Login studenta i jego liczba obecności na zajęciach są odczytywane
z *id* oraz atrybutu *data* z kodu HTML.


## Wyszukiwanie grup studentów

Do menu aplikacji dodamy dwie listy rozwijane *Classes* i *Gauges*
z listą moich grup laboratoryjnych z semestru letniego r. ak. 12/13:

{%= image_tag "/images/lista-obecnosci-menu.png", :alt => "[dziennik menu]" %}

Dane studentów zapisywane są w kolekcji *students*.
Aby wyszukać wszystkich studentów z jednej grupy w zapytaniu
dodaję: nazwę grupy, rok i semestr:

    :::rhtml app/views/common/_menu.html.erb
    <%= link_to "Lista obecności, 12/13", root_path, :class => 'brand' %>
    <ul class="nav">
      <% if user_signed_in? %>
        <li>
        <%= link_to 'Logout', signout_path %>
        </li>
      <% else %>
        <li>
        <%= link_to 'Login through Github', signin_path %>
        </li>
      <% end %>
      <% if user_signed_in? %>
        <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            Classes <b class="caret"></b>
          </a>
          <ul class="dropdown-menu">
            <li><%= link_to "techologie nosql", students_path(class_name: "nosql") %>
            <li><%= link_to "projekt zespołowy", students_path(class_name: "pz") %>
            <li class="divider"></li>
            <li><%= link_to "architektura serwisów internetowych", students_path(class_name: "asi") %>
            <li><%= link_to "techniki internetowe", students_path(class_name: "ti") %>
            <li class="divider"></li>
            <li><a href="http://inf.ug.edu.pl/plan/?nauczyciel=Bzyl">plan zajęć</a>
          </ul>
        </li>
            <li class="dropdown">
          <a href="#" class="dropdown-toggle" data-toggle="dropdown">
            Gauges <b class="caret"></b>
          </a>
          <ul class="dropdown-menu">
            <li><%= link_to "techologie nosql", gauges_path(class_name: "nosql") %>
            <li><%= link_to "projekt zespołowy", gauges_path(class_name: "pz") %>
            <li class="divider"></li>
            <li><%= link_to "architektura serwisów internetowych", gauges_path(class_name: "asi") %>
            <li><%= link_to "techniki internetowe", gauges_path(class_name: "ti") %>
          </ul>
        </li>
        <% if current_user.has_role? :admin %>
        <li>
          <%= link_to 'Admin', users_path %>
        </li>
        <% end %>
      <% end %>
    </ul>

Filtrowanie (selekcję) studentów przez atrybut *class_name* dodajemy
w metodzie *index* kontrolerów *StudentsControler* i *GaugesController*:

    :::ruby
    def index
      @students = Student.class_name(class_name)
      ...
    end

W kontrolerze *ApplicationController* dodajemy metodę prywatną *class_name*:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      ...
      private
        def class_name
          (params[:class_name] if user_signed_in?) || "unallocated"
        end
        helper_method :class_name

Na koniec w modelu *Student* dodajemy *scope*:

    :::ruby app/models/student.rb
    scope :class_name, ->(name) do
      where(class_name: name).asc(:last_name, :first_name)
    end


## Remote – dodawanie obecności

W widoku częściowym *_gauge.html.erb* dopisujemy do *link_to* atrybuty
*remote* i *data*:

    :::rhtml app/views/gauges/_gauge.html.erb
    <%= link_to raw("<i class='icon-dashboard'> </i>") + gauge.last_name,
          gauge_path(gauge),
          method: :put,
          remote: true, data: { type: :json },
          class: 'btn' %>

W kontrolerze *gauges_controller.rb* przechodzimy na *respond_to/respond_with*
i zmieniamy kod metody *update*:

    :::ruby app/controllers/gauges_controller.rb
    class GaugesController < ApplicationController
      respond_to :html, only: [:index]
      respond_to :json, only: [:update]

      # PUT /students/1
      def update
        @student = Student.find(params[:id])
        @student.add_to_set(:presences, today_presence)

        respond_with(@student) do |format|
          format.json { render json: @student }
        end
      end

Teraz kliknięcie przycisku, powoduje wysłanie żądania AJAX do metody
*update* kontrolera *GaugesController*. Metoda *update* odpowiada na to
żądanie wysyłając do przeglądarki odpowiedź z danymi studenta.

Odpowiedzi wysyłane przez aplikację możemy podejrzeć w przeglądarce,
na przykład w zakładce *Sieć/XHR* rozszerzenia *Firebug*:

    :::json
    {
      "_id": "50d0c6f0e138238121000001",
      "class_name": "nosql",
      "first_name": "Jan",
      "last_name": "Kuszelas",
      "login": "jkuszelas",
      "presences": ["12-20"],
      ...
    }

lub na konsoli o ile do pliku *google_gauges.js* dopiszemy:

    :::js app/assets/javascripts/google_gauges.js
    function drawGauges() {
      ...
      $('a[data-type=\"json\"]').on('ajax:success', function(event, data, status, xhr) {
        link = $(this);                    // zmienna globalna
        console.log(link);
        console.log(JSON.stringify(data)); // prettyprint JSON object
      });
    };

Z tego co widać na konsoli, wystarczy odszukać miernik z linkiem:

    :::js
    link.closest(".gauge").children("div[id]")

i uaktualnić jego wskazania:

    :::ruby app/assets/javascripts/google_gauges.js
    $('a[data-type=\"json\"]').on('ajax:success', function(event, data, status, xhr) {
      // console.log(data.login, data.presences);
      var div = $(this).closest(".gauge").children("div[id]").get(0); // get DOM element
      var gauges = new google.visualization.Gauge(div);
      var gauge_data = google.visualization.arrayToDataTable([
        [data.login], [data.presences.length]
      ]);
      gauges.draw(gauge_data, options);
    });

*TODO:* W kodzie *google_gauges.js* robimy to samo na dwa różne sposoby.
Refaktoryzacja? Zobacz też
[jQuery & Ajax (revised)](http://railscasts.com/episodes/136-jquery-ajax-revised?view=asciicast).


## Ukrywamy przyciski

Tylko admin może korzystać z wszystkich przycisków.
Studenci moga tylko podejrzeć swoje dane i edytować swój email,
imię i nazwisko, login, nazwę rpozytorium na GitHubie.

W tym celu w polach fomularza użyjemy atrybutu *disabled*.
Najpierw zdefiniujemy metodę pomocniczą *disable_attr?*, przykład użycia:

    :::rhtml
    <%= f.input :login, input_html: { disabled: disable_attr?(:login) } %>

Przydałoby się własne *FormFor*! TODO.

Na razie taka implementacja, tylko dla modelu *Students*.
Kod w *StudentsController*:

    :::ruby
    def disable_attr?(attribute)
      if current_user.has_role? :admin
        return false
      else
        return ![:email, :full_name, :login, :repository].include?(attribute)
      end
    end
    helper_method :disable_attr?

Póki co nie wiem jak sprawdzać zgnieżdzone hasze w params. Na przykład

    :::ruby
    params = [ :full_name, :comments, {user_attributes: [ :email ]} ]


## Nested attributes i strong parameters

W formularzu dla modelu *Student*, dodajemy pole do zmiany jego *email*,
który zdefiniowany jest w modelu *User*.

Atrybuty z innego modelu umieścimy w formularzu korzystając
z *nested attributes*. W tym celu dopisujemy do modelu *Student*:

    :::ruby
    belongs_to :user
    accepts_nested_attributes_for :user

W metodzie *student_params* dodajemy do parametrów *permit*
powiązany atrybut *user.email*:

    :::ruby
    def student_params
      if current_user.has_role?(:admin)
        params.require(:student).permit(:user_id, :full_name,
          :login, :presences_list, :class_name, :comments, :repository)
      else
        # permit nested attributes for User model
        # Mongoid uses user_attributes, ActiveRecord – user?
        params.require(:student).permit({ user_attributes: [:email] },
          :full_name, :login, :repository)
      end
    end

Zmiany w formularzu modelu *Student* (korzystamy z metody pomocniczej
*Device*):

    :::rhtml
    <%# https://github.com/plataformatec/simple_form/wiki/Nested-Models %>
    <%= f.simple_fields_for :user do |u| %>
      <%= u.input :email %>
    <% end %>

## Uruchamianie aplikacji w trybie produkcyjnym

Same problemy…

1\. Niepoprawne ścieżki do FontAwesome. Są takie:

    :::js
    url(/assets/..)

Ale jeśli korzystamy z gemu passenger + sub-ur, to powinny być
poprzedzone *sub-uri*, przykładowo:

    :::js
    url(/lista/assets/..)

2\. W plikach konfiguracyjnych serwera Nginx należy wpisać:

    :::js
    location ~* ^/assets/ {
      expires 1y;
      add_header Cache-Control public;
      add_header Last-Modified "";
      add_header ETag "";
      break;
    }

3\. Jeśli nie wdrażamy aplikacji na Heroku, to musimy sami skompilować
assets:

    :::bash
    rake assets:precompile

4\. Kod z *google_gauges.js* jest wykorzystywany naa stronach z miernikami
(*gauges*).  Plik ten nie jest kompilowany, ponieważ nie jest uwzględniony
w *application.js*. Musimy go uwzględnić w konfiguracji trybu produkcyjnego:

    :::ruby config/environments/production.rb
    config.assets.precompile += %w( google_gauges.js )


# Uwagi na marginesie…

1\. OmniAuth ma wbudowany routing dla wspieranych dostawców (*providers*).
Dla Githuba mamy:

    /auth/github          # przekierowanie na Github
    /auth/github/callback # przekierowanie po pomyślnej autentykacji
    /auth/failure         # tutaj, w przeciwnym wypadku

Dlatego w pliku *routes.rb* wpisujemy:

    :::ruby config/routes.rb
    match '/auth/:provider/callback' => 'sessions#create'
    match '/signin' => 'sessions#new', :as => :signin
    match '/auth/failure' => 'sessions#failure'
    match '/signout' => 'sessions#destroy', :as => :signout

2\. W trybie produkcyjnym, aplikacja korzysta ze skompilowanych *assets*:

    :::bash
    bin/rake assets:precompile   # Compile all the assets named in config.assets.precompile

Po przejściu do trybu development, powinniśmy usunąć skopilowane pliki:

    :::bash
    bin/rake assets:clean

Jeśli tego nie zrobimy, to zmiany w plikach JavaScript i CSS nie zostaną użyte.

3\. **i18n**: Dodajemy do katalogu *config/initializers* plik *mongoid.rb*
w którym wpisujemy (*i18n*):

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

Od razu zmieniamy domyślne locale na polskie (co to znaczy?):

    :::ruby config/application.rb
    config.i18n.default_locale = :pl

4\.„Rails scaffold-generated links are not DRY, and it becomes even worse,
when someone tries to make them I18n-friendly”. Za pomocą gemu
[link_to_action](https://github.com/denispeplin/link_to_action) możemy
„oczyścić/wysuszyć” kod w widokach.

5\. Uwagi o robieniu kopii zapasowych danych z bazy MongoDB.

Eksport do pliku tekstowego:

    :::bash terminal
    mongoexport -d lista_obecnosci -c students -o students-$(date +%Y-%m-%d).json
    mongoexport -d lista_obecnosci -c users -o users-$(date +%Y-%m-%d).json

Wybieramy format JSON. Teraz odtworzenie bazy z kopii zapasowej
może wyglądać tak:

    :::bash terminal
    mongoimport --drop -d lista_obecnosci -c students students-2013-01-17.json
    mongoimport --drop -d lista_obecnosci -c users users-2013-01-17.json

Możemy też wykonać zrzut bazy, który wykonujemy na **działającej** bazie:

    :::bash
    mongodump -d lista_obecnosci -o backup

A tak odtwarzamy zawartość bazy z zrzutu:

    :::bash
    mongorestore -d test --drop backup/lista_obecnosci/

**Uwaga:** W powyższym przykładzie kopię zapasową kolekcji z bazy
*lista_obecnosci_2013_production* importujemy do bazy *test*, a nie
do *lista_obecnosci_2013_production*! Zamiast nazwy bazy
*lista_obecnosci_2013_production* wpisałem *lista_obecnosci*.
To tak na wszelki wypadek, aby bezmyślne przeklikanie powyższego
kodu nie skończyło się katastrofą!