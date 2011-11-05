#### {% title "Korzystamy z bazy MongoDB" %}

Przykładowa aplikacja CRUD korzystająca z bazy MongoDB,
gemów Mongoid, OmniAuth.

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

Prosta aplikacja implementująca CRUD dla listy obecności studentów.

**TODO:** Podmienić w szablonie HTML5Boilerplate na [Bootstrap, from Twitter](http://twitter.github.com/bootstrap/).

1\. Generujemy rusztowanie/szkielet aplikacji:

    :::bash terminal
    rails new lista_obecnosci -m https://raw.github.com/wbzyl/rails31-html5-boilerplates/master/html5-boilerplate.rb \
      --skip-bundle --skip-active-record --skip-test-unit

*Uwaga:* pomijamy instalację *SimpleForm*. Będziemy korzystać z *Formtastic*.

2\. Dopisujemy nowe gemy do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'formtastic'
    gem 'kaminari'

    gem 'omniauth'
    gem 'omniauth-github', :git => 'git://github.com/intridea/omniauth-github.git'
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

3\. I18N. Dodajemy do katalogu *config/initializers* plik *mongoid.rb*
w którym wpisujemy:

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

4\. Post–install:

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

5\. Replica sets, master/slave, multiple databases
– na razie pomijamy. Sharding – też.
OmniAuth zajmiemy się także później.

6\. Generujemy rusztowanie dla modelu *Student*:

    :::bash terminal
    rails generate scaffold Student last_name:String first_name:String \
      id_number:Integer course:String group:String absences:Array comment:String

Oczywiście w aplikacji „lista obecności” nie może zabraknąć
atrybutów nieobecności i uwagi.

7\. Na koniec importujemy listę studentów do bazy MongoDB:

    mongoimport --drop -d lista_obecnosci_development -c students --headerline --type csv wd.csv

Fragment pliku CSV z nagłówkiem:

    :::csv wd.csv
    last_name,first_name,id_number,course
    "Kuszelas","Jan",123123,"Aplikacje internetowe i bazy danych"
    "Klonowski","Felicjan",221321,"Algorytmy i struktury danych"
    "Korolczyk","Joga",356123,"Aplikacje internetowe i bazy danych"
    "Grabczyk","Simona",491231,"Algorytmy i struktury danych"
    "Kamińska","Irena",556123,"Aplikacje internetowe i bazy danych"
    "Jankowski","Kazimierz",628942,"Algorytmy i struktury danych"

8\. Pozostaje uruchomić serwer www:

    :::bash terminal
    rails server -p 3000

i wejść na stronę z listą obecności:

    http://localhost:3000/students


## Formtastic

1\. Użyjemy arkusza stylów Formtastic. W tym celu w pliku *application.css.sass*,
wiersz:

    :::css app/assets/stylesheets/application.css.scss
    @import "simple-scaffold.css.scss";

zamieniamy na:

    :::css app/assets/stylesheets/application.css.scss
    @import "formtastic";
    @import "formtastic_ie7";
    @import "lista_obecnosci";

## Zmieniamy widok *index.html.erb*

Fragment kodu, tylko to co zmieniamy:

    :::rhtml app/views/students/index.html.erb
    <% @students.each do |student| %>
    <article class="index">
      <div class="attribute">
        <div class="presence">☺</div>
        <div class="value full-name <%= student.group %>"><%= student.full_name %></div>
        <div class="absences"><%= bullets(student.absences) %></div>
        <div class="links">
          <%= link_to 'Show', student %> |
          <%= link_to 'Edit', edit_student_path(student) %> |
          <%= link_to 'Destroy', student, confirm: 'Are you sure?', method: :delete %>
        </div>
      </div>
    </article>
    <% end %>

Obrazek pokazujący o co nam chodzi w tym widoku:

{%= image_tag "/images/lista-obecnosci.png", :alt => "[lista obecnosci: /index]" %}


Kod użytej powyżej metody pomocniczej:

    :::ruby app/helpers/students_helper.rb
    def bullets(array)
      time = Time.new
      today = "#{time.month}-#{time.day}"

      array.to_a.map do |d|
        today == d ? "<span class='today'>●</span>" : "●"
      end.join(' ').html_safe
    end

Zmieniony nowy kod w widoku wymusza kolejne poprawki. Oto one.


### Poprawki w wygenerowanym formularzu

1\. Lista wyboru: *red*, *green*, *blue* dla grup,
element *textarea* dla *comment*, oraz wirtualne atrybuty
*full_name* i *absences_list*

    :::rhtml app//views/students/_form.html.erb
    <%= semantic_form_for @student do |f| %>
      <%= f.inputs do %>
        <%= f.input :full_name, :as => :string %>
        <%= f.input :absences_list, :as => :string %>
        <%= f.input :id_number %>
        <%= f.input :course %>
        <%= f.input :group, :as => :select, :collection => ["red", "green", "blue"] %>
        <%= f.input :comment, :as => :text, :input_html => {:rows => 4} %>
      <% end %>
      <%= f.buttons do %>
        <%= f.commit_button %>
      <% end %>
    <% end %>

2\. Dodajemy metody getter i setter dla wirtualnych atrybutów
oraz ustawiamy domyślną kolejność rekordów:

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

      # getter and setter
      def absences_list
        absences.to_a.join(', ') # .to_a handles nil attribute
      end
      def absences_list=(string)
        list = string.gsub(/[,\s]+/, ' ').split(' ')
        set(:absences, list)
      end

      default_scope asc(:group, :last_name, :first_name)
    end

### Zmiany w kontrolerze

JavaScript (TODO: kod umieścić tylko na stronie */students*):

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

Obsługa żądania ajax (PUT) w kontrolerze:

    :::ruby app/controllers/students_controller.rb
    class StudentsController < ApplicationController
      # PUT /students/1
      def update
        @student = Student.find(params[:id])

        if params[:absent]
          logger.info "☻ #{@student.full_name} absent at #{params[:absent]}"
          @student.add_to_set(:absences, params[:absent])
        else
          if @student.update_attributes(params[:student])
            redirect_to @student, notice: 'Student was successfully updated.'
          else
            render action: "edit"
          end
        end
      end

Nie zapominamy o dopisaniu do pliku *application.js*:

    :::javascript app/assets/javascripts/application.js
    //= require students.js


### Zmiany w pozostałych widokach

Aby kod Javascript zadziałał dodajemy nieco kodu do widoków
oraz tworzymy nowy widok *update.text.erb*.

*update.text.erb*:

    absences for student <%= @student.full_name %> were updated

*show.html.erb* (fragment):

    :::rhtml app/views/students/show.html.erb
    <article class="single">
      <div class="attribute">
        <span class="value <%= @student.group %>"><%= @student.full_name %></span>
        <span class="absences"><%= @student.absences_list %></span>
      </div>


### Arkusz stylów

Dodatkowe reguły:

    :::css lista_obecnosci.css.scss
    .index {
      .attribute {
         clear: both;
         .value, .presence, .absences {
            float: left; }
         .presence {
            cursor: pointer;
            margin-right: 1em; }
         .absences {
            padding-left: 1em;
            position: relative;
            top: -0.1ex; }
         .links {
            float: right; } } }
    .single {
      .attribute {
        .absences {
           margin-left: 2em;
           font-weight: bold; } } }
    .link {
      margin-top: 2em;
      clear: both; }
    .attribute {
      margin-top: 0.5em; }


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
zakładam, że

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

Klucze zapisujemy w pliku *twitter.sh*, który będziemy trzymać
poza repozytorium:

    :::bash twitter.sh
    export TWITTER_KEY="111111111111111111111"
    export TWITTER_SECRET="111111111111111111111111111111111111111111"

Plik konfiguracyjny dla middlewarwe OmniAuth, to:

    :::ruby config/initializers/twitter.rb
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    end


## Generujemy model dla użytkowników

Po pomyślnej autentykacji, dane użytkownika będziemy zapisywać w bazie:

    rails generate model User provider:string uid:string name:string email:string


## Generujemy kontroler dla sesji

…na przykład tak (poprawniejszą nazwą byłoby *Session*):

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

Ponieważ każdy provider, po pomyślnej autentykacji, zwraca inne
informacje my, na razie, w metodzie **create**
zgłaszamy wyjątek, aby podejrzeć to co przesłał Github.


## Routing

OmniAuth ma wbudowany routing dla wspieranych dostawców (*providers*),
na przykład dla Githuba są to:

    /auth/github          # przekierowanie na Github
    /auth/github/callback # przekierowanie po pomyślnej autentykacji
    /auth/failure         # tutaj, w przeciwnym wypadku

W pliku *routes.rb* wpisujemy:

    :::ruby config/routes.rb
    match '/auth/:provider/callback' => 'sessions#create'
    match '/auth/failure' => 'sessions#failure'

Przyda się kilka metod pomocniczych: *signout_path*, *signin_path*:

    :::ruby config/routes.rb
    match '/signout' => 'sessions#destroy', :as => :signout
    match '/signin' => 'sessions#new', :as => :signin

Przy okazji dodajemy też:

    :::ruby config/routes.rb
    root :to => 'students#index'

Teraz możemy przetestować jak to działa!
Ręcznie wpisujemy w przeglądarce następujące uri:

    http://localhost:3000/auth/github
    http://localhost:3000/auth/twitter

Po pomyślnym zalogowaniu w metodzie *create* zgłaszany
jest wyjątek, a my widzimy stronę z **RuntimeError** .

Twitter zwraca coś takiego (fragment):

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

A Github zwraca coś takiego (wszystko):

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
              user.name = auth['info']['name'] || "" # Twitter, GitHub
              user.email = auth['info']['email'] || ""
              user.nickname = auth['info']['nickname'] || ""
            end
            if auth['extra']['user_hash'] # Facebook -- sprawdzić
              # user.name = auth['extra']['user_hash']['name'] || ""
              # user.email = auth['extra']['user_hash']['email'] || ""
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
      helper_method :user_signed_in?
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


## Strona dla Admin do zarządzania danym użytkowników

Generator:

    rails generate controller admin index

Modyfikujemy kontroller:

    :::ruby controllers/admin_controller.rb
    def index
      @users = User.asc(:nickname)
    end

oraz widok *index*:

    :::ruby app/views/admin/index.html.erb
    <% title "Admin page" %>
    <h3>Users list</h3>

    <ol>
    <% @users.each do |user| %>
      <li><%= user.name %> <i>via</i> <%= user.provider %></li>
    <% end %>
    </ol>

Wchodzimy na stronę:

    http://localhost:3000/admin/index


## Poprawiamy layout aplikacji

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
      <li>
      Logged in as <%= current_user.name %>
      </li>
      <li>
      <%= link_to('Logout', signout_path) %>
      </li>
    <% else %>
      <li>
      <%= link_to('Login (via github)', signin_path)  %>
      </li>
    <% end %>

Layout (dopisujemy pod znacznikiem *header*):

    :::rhtml app/views/layouts/application.html.erb
    <header>
       <ul class="hmenu">
         <%= render 'shared/navigation' %>
       </ul>
       <%= content_tag :h1, "Lista obecności ASI, 2011/12" %>

I sprawdzamy jak wygląda nawigacja w działającej aplikacji.
CSS do poprawki!


## Access Controll

Użyjemy autentykacji do tego aby zalogowany użytkownik mógł
obejrzeć swoje wszystkie dane (liczba mnoga **users**):

    :::bash terminal
    rails generate controller users show

Routing:

    :::ruby config/routes.rb
    # get "users/show"  -- wykomentowujemy
    resources :users, :only => :show
    # get "admin/index" -- zmieniamy na
    match '/admin' => 'admin#index', :as => :admin

Widok *show*:

    :::rhtml app/views/users/show.html.erb
    <% title "User Profile" %>

    <p>Name: <%= @user.name %></p>
    <p>Provider: <%= @user.provider %></p>
    <p>UID: <%= @user.uid %></p>
    <p>Email: <%= @user.email %></p>
    <p>Nickname: <%= @user.nickname %></p>

Modyfikujemy widok *admin/index*:

    :::rhtml app/views/admin/index.html.erb
    <ol>
      <% @users.each do |user| %>
      <li><%= link_to user.name, user %> <i>via</i> <%= user.provider %></li>
      <% end %>
    </ol>

### Zmiana email

Zmieniamy routing:

    :::ruby config/routes.rb
    resources :users, :only => [ :show, :edit, :update ]

Kontroller:

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

Widok (TODO: zamienić na formtastic):

    :::rhtml app/views/users/edit.html.erb
    <%= form_for(@user) do |f| %>
      <p><%= f.label :email %>
      <%= f.text_field :email %></p>
      <p><%= f.submit "Sign in" %></p>
    <% end %>

Zmiany w kontrolerze sesji:

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

## Usuwanie baz danych aplikacji

**TODO:** Dopisujemy do pliku *seeds.rb*:

    :::ruby db/seeds.rb
    puts 'Empty the MongoDB database'
    Mongoid.master.collections.reject { |c| c.name =~ /^system/}.each(&:drop)

Teraz:

    rake db:seed

usuwa kolekcje *students* i *users* z bazy. Dziwne to!
Lepiej byłoby dodać (osobne dla każdej kolekcji) zadania dla rake.

Ale możnaby wrzucić *mongoimport* do *seeds.rb*.


## Ikonki dla CRUD

**TODO**


# Różny misz masz…

* K. Seguin, [The MongoDB Collection](http://mongly.com/)
* K. Seguin, [Blog](http://openmymind.net/)


## TODO

W aplikacji jest zaszyty format daty nieobecności:

    miesiąc-dzień

Do poprawki.
