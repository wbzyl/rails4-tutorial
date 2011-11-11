#### {% title "Mongoid + OmniAuth z githubem i twitterem" %}

### Uwagi

[2011.11.11] Następna wersja z [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/) ?
z [Foundation](https://github.com/zurb/foundation) ?

[2011.11.11] Fajne i użyteczne. [Shapecatcher](http://shapecatcher.com/)
– unicode character recognition.

Mongo links:

* Ryan Bates, [Mongoid](http://railscasts.com/episodes/238-mongoid?view=asciicast) – asciicast
* Durran Jordan, [Mongoid](http://mongoid.org/docs.html) – dokumentacja gemu
* Karl Seguin.
  - [The MongoDB Interactive Tutorial](http://tutorial.mongly.com/tutorial/index)
  - [MongoDB Geospatial Interactive Tutorial](http://tutorial.mongly.com/geo/index)
  - [The Little MongoDB Book](http://openmymind.net/mongodb.pdf)

Formtastic:

* [Github Home](https://github.com/justinfrench/formtastic)
* [Flexible Formtastic styling with Sass](https://github.com/activestylus/formtastic-sass/blob/master/_formtastic_base.sass)
  – not longer supported
* [Formtastic without ActiveRecord](http://dondoh.tumblr.com/post/4142258573/formtastic-without-activerecord)

OmniAuth:

* [Demo App](http://www.omniauth.org/), [kod aplikacji](https://github.com/intridea/omniauth.org)
* [Github Home](https://github.com/intridea/omniauth)
* [Wiki](https://github.com/intridea/omniauth/wiki)
* [OmniAuth Github strategy](https://github.com/intridea/omniauth-github)
* [OmniAuth Identity strategy](https://github.com/intridea/omniauth-identity)
* [Rails 3.1 with Mongoid and OmniAuth](https://github.com/railsapps/rails3-mongoid-omniauth/wiki/Tutorial)
  – na razie nieaktualne

Hosting:

* [Cloud Hosted MongoDB](https://mongolab.com/home)
  ([{blog: mongolab}](http://blog.mongolab.com/))
* [Node.js + MongoDB = Love: Guest Post from MongoLab](http://joyeur.com/2011/10/26/node-js-mongodb-love-guest-post-from-mongolab/?utm_source=NoSQL+Weekly+Newsletter&utm_campaign=4ed79d28a1-NoSQL_Weekly_Issue_49_November_3_2011&utm_medium=email)


# Lista obecności

Przykładowa aplikacja CRUD listy obecności studentów.
W aplikacji korzystamy z bazy MongoDB via gem Mongoid,
oraz gemu OmniAuth ze strategiami *github* i *twitter*.

1\. Generujemy rusztowanie/szkielet aplikacji:

    :::bash terminal
    rails new lista_obecnosci -m https://raw.github.com/wbzyl/rails31-html5-boilerplates/master/html5-boilerplate.rb \
      --skip-bundle --skip-active-record --skip-test-unit

*Uwaga:* pomijamy instalację *SimpleForm*. Będziemy korzystać z *Formtastic*.

2\. Dopisujemy nowe gemy do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'formtastic'

    gem 'omniauth'
    gem 'omniauth-github'

    # 2011.11.10 – nie działa
    gem 'omniauth-contrib', :git => 'git://github.com/intridea/omniauth-contrib.git'

    gem 'mongoid', '~> 2.3'
    gem 'bson_ext', '~> 1.4'

    group :development do
      gem 'hirb'
      gem 'wirble'
    end

Następnie je instalujemy:

    :::bash terminal
    cd lista_obecnosci
    bundle install --path=$HOME/.gems --binstubs

3\. Dodajemy do katalogu *config/initializers* plik *mongoid.rb*
w którym wpisujemy (*i18n*):

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

4\. Dokończenie instalacji (*post–install*):

    :::bash terminal
    rails g mongoid:config
    rails g formtastic:install

Oto wygenerowany plik konfiguracyjny Mongoid:

    :::yaml config/mongoid.yml
    development:
      host: localhost
      database: lista_obecnosci_development
    test:
      host: localhost
      database: lista_obecnosci_test
    # set these environment variables on your prod server
    production:
      host: <%= ENV['MONGOID_HOST'] %>
      port: <%= ENV['MONGOID_PORT'] %>
      username: <%= ENV['MONGOID_USERNAME'] %>
      password: <%= ENV['MONGOID_PASSWORD'] %>
      database: <%= ENV['MONGOID_DATABASE'] %>
      # slaves:
      #   - host: slave1.local
      #     port: 27018
      #   - host: slave2.local
      #     port: 27019

Póki co zostawiamy go bez zmian.

Replica sets, master/slave, multiple databases – na razie
pomijamy. Sharding – też.

OmniAuth jest opisany w następnej sekcji.

5\. Oczywiście w aplikacji *Lista Obecności* nie może zabraknąć
atrybutów nieobecność i uwagi.

Generujemy rusztowanie dla modelu *Student*:

    :::bash terminal
    rails generate scaffold Student last_name:String first_name:String \
      id_number:Integer course:String group:String absences:Array comment:String

6\. Na koniec importujemy listę studentów do bazy MongoDB:

    :::bash terminal
    mongoimport --drop -d lista_obecnosci_development -c students --headerline --type csv wd.csv

Oto fragment pliku CSV z nagłówkiem:

    :::csv wd.csv
    last_name,first_name,id_number,course
    "Kuszelas","Jan",123123,"Aplikacje internetowe i bazy danych"
    "Klonowski","Felicjan",221321,"Algorytmy i struktury danych"
    "Korolczyk","Joga",356123,"Aplikacje internetowe i bazy danych"
    "Grabczyk","Simona",491231,"Algorytmy i struktury danych"
    "Kamińska","Irena",556123,"Aplikacje internetowe i bazy danych"
    "Jankowski","Kazimierz",628942,"Algorytmy i struktury danych"

Przy okazji uzupełnię ten punkt uwagami o robieniu kopii zapasowych bazy.

Eksport do pliku tekstowego:

    :::bash terminal
    mongoexport -d lista_obecnosci_development -c students -o wd-$(date +%Y-%m-%d).json

Wybieramy format JSON. Teraz odtworzenie bazy z kopii zapasowej
może wyglądać tak:

    :::bash terminal
    mongoimport --drop -d lista_obecnosci_development -c students wd-2011-11-08.json

Zrzut do plików binarnych wykonujemy na **działającej** bazie:

    :::bash
    mongodump -d lista_obecnosci_development -o backup
    mongorestore -d test --drop backup/lista_obecnosci_development/

**Uwaga:** W powyższym przykładzie backup wszystkich kolekcji z bazy
*lista_obecnosci_development* importujemy do bazy *test*, a nie
do *lista_obecnosci_development*!

7\. Pozostaje uruchomić serwer WWW:

    :::bash terminal
    rails server -p 3000

i wejść na stronę z listą obecności:

    http://localhost:3000/students

Jeśli aplikacja działa, to przechodzimy do nastepnych punktów.

8\. Dodajemy podstawową autentykację do aplikacji:

    :::ruby app/controllers/students_controller.rb
    http_basic_authenticate_with :name => ENV['LO_NAME'], :password => ENV['LO_PASSWORD']

„Sensitive data” zapiszemy w pliku *http-authentication.sh*:

    :::bash http-authentication.sh
    export LO_NAME="wbzyl"
    export LO_PASSWORD="razdwa"

Teraz przed uruchomieniem aplikacji musimy dodać te zmienne
do środowiska powłoki:

    :::bash http-authentication.sh
    source http-authentication.sh

9\. Do stylizacji formularzy użyjemy arkusza stylów gemu
*Formtastic*. W tym celu w pliku *application.css.sass*, wiersz:

    :::css app/assets/stylesheets/application.css.scss
    @import "simple-scaffold.css.scss";

zamieniamy na:

    :::css app/assets/stylesheets/application.css.scss
    @import "formtastic";
    @import "formtastic_ie7";
    @import "lista_obecnosci";

Kod arkusza *lista_obecnosci.css.scss* jest pod koniec tej sekcji.


## Zaczynamy od modelu Student

Co to są wirtualne atrybuty?
[More on Virtual Attributes](http://railscasts.com/episodes/167-more-on-virtual-attributes?view=asciicast).

Dodajemy metody getter i setter dla **wirtualnych atrybutów**
oraz ustawiamy domyślne sortowanie rekordów:

    :::ruby app/models/student.rb
    class Student
      include Mongoid::Document
      field :last_name, :type => String
      field :first_name, :type => String
      field :id_number, :type => Integer
      field :course, :type => String
      field :group, :type => String     # blue, red, green
      field :comment, :type => String
      field :absences, :type => Array

      # getter and setter
      def full_name
        [first_name, last_name].join(' ')
      end
      def full_name=(name)
        split = name.split(/\s+/, 2)
        self.first_name = split.first
        self.last_name = split.last
      end

      # obróbka tablicy w formularzu
      def absences_list
        absences.to_a.join(' ') # .to_a handles nil attribute
      end
      def absences_list=(string)
        list = string.gsub(/[,\s]+/, ' ').split(' ') # najpierw normalizacja, póżniej split
        set(:absences, list)
      end

      default_scope asc(:group, :last_name, :first_name)
    end


## Nowa strona główna aplikacji

Obrazek pokazujący o co nam chodzi (**TODO** do wymiany):

{%= image_tag "/images/lista-obecnosci.png", :alt => "[lista obecnosci: /index]" %}

Są cztery grupy studentów: niebieska, zielona, czerwona oraz
*unknown*.  Kliknięcie w śmieszek dopisuje do dokumentu studenta
nieobecność, przeładowuje stronę na której zostaje wypisana
pomarańczowa kropka przy nazwisku. Kropki po prawej stronie nazwiska
to liczba nieobecności.

Do generowania kropek używamy metody pomocniczej *bullets*. Suwak
pokazuje liczbę punktów, w zakresie 0–100, zdobytych przez studenta na
laboratorium.

Zmiany zaczniemy wprowadzać od dodania do routingu metody
*not_present*:

    :::ruby config/routes.rb
    resources :students do
      put 'not_present', :on => :member
    end

Następnie przemodelujemy szablon strony głównej:

    :::rhtml app/views/students/index.html.erb
    <% @students.each do |student| %>
    <article class="index">
      <div class="attribute">
        <div class="presence"><%= link_to '☺', not_present_student_path(student), method: :put %></div>
        <div class="full-name <%= student.group %>"><%= link_to student.full_name, student %></div>
        <div class="absences"><%= bullets(student.absences) %></div>
        <div class="links">
          <%= link_to '✎', edit_student_path(student) %>
          <%= link_to '✖', student, confirm: 'Are you sure?', method: :delete %>
        </div>
      </div>
    </article>
    <% end %>

Kod użytej powyżej metody pomocniczej *bullets*:

    :::ruby app/helpers/students_helper.rb
    module StudentsHelper
      def bullets(array)
        today = today_absence
        array.to_a.map do |d|
          today == d ? "<span class='today'>●</span>" : "●"
        end.join(' ').html_safe
      end
    end

i metody *today_absence*:

    :::ruby app/controllers/application_controller.rb
    helper_method :today_absence

    def today_absence
      time = Time.new
      "#{time.month}-#{time.day}"
    end

oraz metody *not_present*:

    :::ruby app/controllers/students_controller.rb
    # PUT /students/1/not_present
    def not_present
      @student = Student.find(params[:id])
      logger.info "☻ #{@student.full_name} absent at #{params[:absent]}"
      @student.add_to_set(:absences, today_absence)
      redirect_to students_url
    end

Po zapisaniu zmian w bazie przechodzimy na stronę główną:

    :::ruby app/controllers/students_controller.rb
    # PUT /students/1
    def update
      @student = Student.find(params[:id])

      if @student.update_attributes(params[:student])
        redirect_to students_url, notice: 'Student was successfully updated'
      else
        render action: "edit"
      end
    end


### Zmiany w pozostałych widokach

Zmieniany fragment w *show.html.erb*:

    :::rhtml app/views/students/show.html.erb
    <article class="single">
      <div class="attribute">
        <span class="value <%= @student.group %>"><%= @student.full_name %></span>
        <span class="absences"><%= @student.absences_list %></span>
      </div>
    <div class="attribute">
      <span class="name">Id:</span>
      <span class="value"><%= @student.id_number %></span>
    </div>
    <div class="attribute">
      <span class="name">Course:</span>
      <span class="value"><%= @student.course %></span>
    </div>

Na co zamienić napisy *Show*, *Edit*, *Back*, *New Student* i *Edit Student*?
Jakieś pomysły?


## Poprawiamy wygenerowany formularz

Lista wyboru: *unknown*, *red*, *green*, *blue* dla grup,
element *textarea* dla *comment*, oraz wirtualne atrybuty
*full_name* i *absences_list*

    :::rhtml app//views/students/_form.html.erb
    <%= semantic_form_for @student do |f| %>
      <%= f.inputs do %>
        <%= f.input :full_name, :as => :string %>
        <%= f.input :absences_list, :as => :string %>
        <%= f.input :id_number %>
        <%= f.input :course, :as => :select,
           :collection => ["Unknown", "Aplikacje internetowe i bazy danych", "Algorytmy i struktury danych"] %>
        <%= f.input :group, :as => :select,
           :collection => ["unknown", "red", "green", "blue"] %>
        <%= f.input :comment, :as => :text, :input_html => {:rows => 8} %>
      <% end %>
      <%= f.buttons do %>
        <%= f.commit_button %>
      <% end %>
    <% end %>


## Samo życie

Zapomniałem o linkach do repozytoriów z projektami na Githubie.

1\. Poprawki w modelu:

    :::ruby app/models/student.rb
    field :repositories, :type => String

2\. Szablonie formularza:

    :::rhtml app/views/students/_form.html.erb
    <%= f.input :repositories %>

3\. Szablon widoku *show*:

    :::rhtml app/views/students/show.html.erb
    <div class="attribute">
      <span class="name">Repository URL:</span>
      <span class="value uri"><%= @student.repositories %></span>
    </div>

I gotowe!

*TODO:* Klikalny link do repozytorium? Argumenty za? przeciw?


## Implementujemy suwak

Zaczniemy od obejrzenia demo i przejrzenia dokumentacji widgetu *Slider*
z *jQuery UI*:

* [Slider Demo](http://jqueryui.com/demos/slider/)
* [UI/API/1.8/Slider](http://docs.jquery.com/UI/Slider)

**TODO**


## Arkusz stylów

Oto obiecany powyżej arkusz stylów:

    :::css lista_obecnosci.css.scss
    a {
      color: black; }
    .red, a.red {
      color: red; }
    .green, a.green {
      color: green; }
    .blue, a.blue {
      color: blue; }
    .unknown, a.unknown {
      color: cyan; }
    .today {
      color: #E82C0C; }
    .index {
      .attribute {
         clear: both;
         .full-name, .presence, .absences {
            float: left; }
         .full-name {
            a {
              text-decoration: none; } }
         .presence {
            cursor: pointer;
            margin-right: 1em;
            a {
              text-decoration: none;
              color: #E82C0C; } }
         .absences {
            margin-left: 1em;
            position: relative;
            top: -0.1ex; }
         .links {
            float: right;
            a {
              margin-left: 0.5em;
              text-decoration: none;
              color: #E80C7A; } } } }
    .single {
      .attribute {
        .uri {
           font-style: italic; }
        .absences {
           margin-left: 2em;
           font-weight: bold; } } }
    .link {
      margin-top: 2em;
      clear: both; }
    .attribute {
      margin-top: 0.5em; }
    ul.hmenu {
      float: right;
      list-style: none;
      margin: 0 0 2em;
      padding: 0;
      li {
        padding-left: 1em;
        display: inline;
        a {
          text-decoration: none;
          color: yellow; } } }

Jakiś taki nieuporządkowany jest ten arkusz. *TODO:* uporządkować arkusz!


# OmniAuth — Github + Twitter

Zaczynamy od zarejestowania aplikacji na [Githubie](https://github.com/account/applications).
Aplikację rejstrujemy podając następujące dane:

    URL:      http://localhost:3000
    Callback: http://127.0.0.1:3000

Zamiast URL powyżej można podać na przykład taki:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb

czyli miejsce gdzie opisuję tę aplikację.

Następnie ze strony [omniauth-github](https://github.com/intridea/omniauth-github)
przeklikowujemy do pliku *github.rb* kawałek kodu, który
dostosowujemy do konwencji Rails:

    :::ruby config/initializers/github.rb
    # use OmniAuth::Builder do
    #   provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    # end
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
    end

Powyżej `GITHUB_KEY`, `GITHUB_SECRET` kopiujemy ze strony
[Your OAuth Applications](https://github.com/account/applications).
Przyjmuję, że

    GITHUB_KEY === Client ID
    GITHUB_SECRET === Client Secret

Same klucze zapisuję w pliku *github.sh*, który dla bezpieczeństwa
trzymam poza repozytorium:

    :::bash github.sh
     export GITHUB_KEY="11111111111111111111"
     export GITHUB_SECRET="1111111111111111111111111111111111111111"

Teraz przed uruchomieniem aplikacji wystarczy wykonać:

    :::bash terminal
    source github.sh

aby wartości *GITHUB_KEY*, *GITHUB_SECRET* były dostęne dla
github-strategy.

Konfiguracja OmniAuth dla *Twittera* jest analogiczna.
Aplikację rejestrujemy [tutaj](https://dev.twitter.com/apps/new):

    URL:      http://localhost:3000
    Callback: http://127.0.0.1:3000

Klucze zapisujemy w pliku *twitter.sh*, który będziemy
też trzymać poza repozytorium:

    :::bash twitter.sh
    export TWITTER_KEY="111111111111111111111"
    export TWITTER_SECRET="111111111111111111111111111111111111111111"

Do pliku konfiguracyjny dla OmniAuth wklepujemy:

    :::ruby config/initializers/twitter.rb
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    end


## Generujemy model dla użytkowników

Po pomyślnej autentykacji, dane użytkownika będziemy zapisywać w bazie:

    rails generate model User provider:string uid:string name:string email:string


## Generujemy kontroler dla sesji

…na przykład tak (używamy liczby mnogiej, chociaż bardziej poprawne
byłoby *Session*; dlaczego?):

    :::bash terminal
    rails generate controller Sessions

Dopisujemy do wygenerowanego kodu kilka metod:

    :::ruby app/controllers/sessions_controller.rb
    class SessionsController < ApplicationController
      def new
        redirect_to '/auth/github'
        # redirect_to '/auth/twitter'
      end
      def create
        raise request.env["omniauth.auth"].to_yaml
      end
      def destroy
        # session[:user_id] = nil
        reset_session
        redirect_to root_url, :notice => "User signed out!"
      end
      def failure
        redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
      end
    end

Po pomyślnej autentykacji każdy provider zwraca nieco inne
dane, na razie w metodzie **create** zgłaszamy wyjątek,
po to, by podejrzeć dane przesłane przez Github’a.


## Routing

OmniAuth ma wbudowany routing dla wspieranych dostawców (*providers*).
Dla Githuba jest to:

    /auth/github          # przekierowanie na Github
    /auth/github/callback # przekierowanie po pomyślnej autentykacji
    /auth/failure         # tutaj, w przeciwnym wypadku

Dlatego w pliku *routes.rb* wpisujemy:

    :::ruby config/routes.rb
    match '/auth/:provider/callback' => 'sessions#create'
    match '/auth/failure' => 'sessions#failure'

Metody pomocnicze *signout_path*, *signin_path* też zwiększą
czytelność kodu:

    :::ruby config/routes.rb
    match '/signout' => 'sessions#destroy', :as => :signout
    match '/signin' => 'sessions#new', :as => :signin

Przy okazji dodajemy też:

    :::ruby config/routes.rb
    root :to => 'students#index'

Teraz możemy przetestować jak to działa!
Ręcznie wpisujemy w przeglądarce następujące uri:

    http://localhost:3000/auth/github
    http://localhost:3000/auth/twitter  # 2011.11.11 – nie działa

Po pomyślnym zalogowaniu w metodzie *create* zgłaszany
jest wyjątek, a my widzimy stronę z **RuntimeError**.

Twitter zwraca masę danych. Poniżej, to tylko mały wyjątek:

    :::yaml
    ---
    provider: twitter
    uid: '52154495'
    info:
      nickname: wbzyl
      name: Wlodek Bzyl
      location: ''
      image: http://a3.twimg.com/profile_images/1272548001/mondrian_normal.png
      description: ''
      urls:
        Website: http://sigma.ug.edu.pl/~wbzyl/
        Twitter: http://twitter.com/wbzyl
    credentials:
      token: 111111111111111111111111111111111111111111111111111111
      secret: 11111111111111111111111111111111111111111
    extra:
      access_token: !ruby/object:OAuth::AccessToken

Dla odmiany Github zwraca tylko tyle:

    :::yaml
    ---
    provider: github
    uid: 8049
    info:
      nickname: wbzyl
      email: matwb@univ.gda.pl
      name: Wlodek Bzyl
      urls:
        GitHub: https://github.com/wbzyl
        Blog: !!null
    credentials:
      token: 1111111111111111111111111111111111111111
      expires: false
    extra: {}


## Zapisujemy powyższe dane w bazie MongoDB

Dodajemy metodę do modelu *User*:

    :::ruby app/models/user.rb
    class User
      include Mongoid::Document
      field :provider, :type => String
      field :uid, :type => String
      field :name, :type => String
      field :email, :type => String

      def self.create_with_omniauth(auth)
        begin
          create! do |user|
            user.provider = auth['provider']
            user.uid = auth['uid']
            if auth['info']
              # logger.info("#{auth['info'].to_json}")
              user.name = auth['info']['name'] || ""          # tylko GitHub, Twitter
              user.email = auth['info']['email'] || ""
              user.nickname = auth['info']['nickname'] || ""
            end
          end
        rescue Exception
          raise Exception, "Cannot create user record!"
        end
      end

    end

Modyfikujemy metodę *create* kontrolera:

    :::ruby app/controllers/sessions_controller.rb
    def create
      auth = request.env["omniauth.auth"]
      user = User.where(:provider => auth['provider'], :uid => auth['uid']).first ||
          User.create_with_omniauth(auth)
      session[:user_id] = user.id
      redirect_to root_url, :notice => "User #{user.name} signed in via #{user.provider}"
    end

Dodajemy wiadomości flash do widoku *index*:

    :::rhtml app/views/students/index.html.erb
    <% if notice -%>
    <div id="notice"><%= notice %></div>
    <% end -%>
    <% if alert -%>
    <div id="error"><%= alert %></div>
    <% end -%>


## Kilka zwyczajowych metod pomocniczych

Praktycznie każda implementacja autentykacji implementuje te metody:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      protect_from_forgery

      helper_method :current_user
      helper_method :correct_user?

      private
      def current_user
        begin
          @current_user ||= User.find(session[:user_id]) if session[:user_id]
        rescue Mongoid::Errors::DocumentNotFound
          nil
        end
      end
      def correct_user?                  # a to po co?
        @user = User.find(params[:id])
        unless current_user == @user
          redirect_to root_url, :alert => "Access denied!"
        end
      end
      def authenticate_user!
        if !current_user
          redirect_to root_url, :alert => 'You need to sign in for access to this page!'
        end
      end
    end


## Strona do zarządzania danymi użytkowników

Czyli coś dla administratora.
Na pierwszy ogień pójdą model i widok:

    :::bash terminal
    rails generate controller admin index

Dopisujemy w modelu:

    :::ruby models/user.rb
    default_scope asc(:nickname, :provider)

oraz w widoku:

    :::rhtml app/views/admin/index.html.erb
    <% title "Admin page" %>
    <h3>Users list</h3>
    <ol>
    <% @users.each do |user| %>
      <li><%= user.name %> <i>via</i> <%= user.provider %></li>
    <% end %>
    </ol>

Na koniec poprawiamy routing:

    :::ruby config/routes.rb
    # get "admin/index" -- zmieniamy na
    match '/admin' => 'admin#index', :as => :admin

Teraz wchodzimy na stronę:

    http://localhost:3000/admin


## Poprawiamy layout aplikacji

**TODO**

SASS:

    :::css app//assets/stylesheets/lista_obecnosci.css.scss
    ul.hmenu {
      list-style: none;
      margin: 0 0 2em;
      padding: 0;
      li {
        display: inline; } }

Nawigacja (do poprawki, HTML5):

    :::rhtml app/views/shared/_navigation.html.erb
    <% if current_user %>
      <li>Logged in <%= current_user.name %>
      <li><%= link_to('Logout', signout_path) %>
    <% else %>
      <li><%= link_to('Login (via github)', signin_path)  %>
    <% end %>

Layout (dopisujemy pod znacznikiem *header*):

    :::rhtml app/views/layouts/application.html.erb
    <header>
      <ul class="hmenu">
        <%= render 'shared/navigation' %>
      </ul>
      <%= content_tag :h1, "Lista obecności ASI, 2011/12" %>

I sprawdzamy jak wygląda nawigacja w działającej aplikacji.


## Dodajemy access control

Użyjemy autentykacji do tego, aby zalogowany użytkownik mógł obejrzeć
(**TODO** tylko) swoje wszystkie dane (tutaj używamy liczby mnogiej
**users**):

    :::bash terminal
    rails generate controller users show edit

Routing:

    :::ruby config/routes.rb
    # get "users/show"  -- wykomentowujemy
    resources :users, :only => :show

Dopisujemy w kontrolerze:

    :::ruby controllers/users_controller.rb
    before_filter :authenticate_user!
    before_filter :correct_user?

    def show
      @user = User.find(params[:id])
    end

Widok *show* (**TODO** też do poprawki):

    :::rhtml app/views/users/show.html.erb
    <% title "User Profile" %>

    <p>Name: <%= @user.name %></p>
    <p>Provider: <%= @user.provider %></p>
    <p>UID: <%= @user.uid %></p>
    <p>Email: <%= @user.email %></p>
    <p>Nickname: <%= @user.nickname %></p>

Na ostatek modyfikujemy widok *index.html.erb*:

    :::rhtml app/views/admin/index.html.erb
    <ol>
      <% @users.each do |user| %>
      <li><%= link_to user.name, user %> <i>via</i> <%= user.provider %></li>
      <% end %>
    </ol>


### Zmiana adresu email

Użytkownika bez adresu email będziemy przekierowywać
na stronę, gdzie będzie mógł go wpisać.

W tym celu zmieniamy routing:

    :::ruby config/routes.rb
    resources :users, :only => [ :show, :edit, :update ]

kontroler użytkownika:

    :::ruby controllers/users_controller.rb
    def edit
      @user = User.find(params[:id])
    end
    def update
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        redirect_to @user
      else
        render :edit
      end
    end

oraz widok *edit.html.erb*:

    :::rhtml app/views/users/edit.html.erb
    <% title "Change Email" %>
    <%= semantic_form_for @user do |f| %>
      <%= f.input :email %>
      <%= f.buttons do %>
        <%= f.commit_button %>
      <% end %>
    <% end %>

i kontroler sesji:

    :::ruby app/controllers/sessions_controller.rb
    def create
      auth = request.env["omniauth.auth"]
      user = User.where(:provider => auth['provider'], :uid => auth['uid']).first ||
          User.create_with_omniauth(auth)
      session[:user_id] = user.id
      if user.email == ""
        redirect_to edit_user_path(user), :alert => 'Please enter your email address.'
      else
        redirect_to root_url, :notice => 'Signed in!'
      end
    end

Zrobione!


# TODO

Różne rzeczy, które należałoby zaprogramować lub poprawić.

## Usuwanie baz danych aplikacji

Dopisujemy do pliku *seeds.rb*:

    :::ruby db/seeds.rb
    puts 'Empty the MongoDB database'
    Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

Teraz:

    rake db:seed

usuwa kolekcje *students* i *users* z bazy. Dziwne to!
Lepiej byłoby dodać (osobne dla każdej kolekcji) zadania dla rake.

Wrzucić *mongoimport* do *seeds.rb*?

## Progressive enhancements

JavaScript (kod umieścić tylko na stronie */students*):

    :::javascript app/assets/javascripts/students.js
    $(document).ready(function() {
        $('div[role="main"]').click(function(event) {
          var clicked_element = $(event.target);
          if (clicked_element.hasClass('presence')) {
            clicked_element.html('☻');
            var link_element = clicked_element.parent().find('a:eq(0)');
            // url = /students/4eb2f22a329855e103cdcfd0
            var date = new Date();
            var today = (date.getMonth() + 1) + '-' + date.getDate();
            $.ajax({
              url: link_element.attr('href'),
              type: 'PUT',
              data: { absent: today },
              success: function(data) {
                console.log(data);
              }
            });
          };
          // event.stopPropagation(); deactivates destroy link – bug?
        });
    });


# Misz masz do poczytania

* K. Seguin, [The MongoDB Collection](http://mongly.com/)
* K. Seguin, [Blog](http://openmymind.net/)
