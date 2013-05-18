#### {% title "Autentykacja z Devise" %}

Dlaczego autentykacja z Devise. Jest wiele argumentów za. Wszystkie
są wymienione w [README](https://github.com/plataformatec/devise)
projektu.

R. Bates przedstawił instalację w dwóch screencastach:

* [Introducing Devise](http://asciicasts.com/episodes/209-introducing-devise),
  [revised](http://railscasts.com/episodes/209-devise-revised).
* [Customizing Devise](http://asciicasts.com/episodes/210-customizing-devise).

<blockquote>
  <p>{%= image_tag "/images/linux-from-scratch.jpg", :alt => "[linux from scratch]" %}</p>
</blockquote>

# Autentykacja od zera

Zgodnie z sugestią autorów gemu Devise powinniśmy
zacząć od samodzielnego napisania od zera prostej autentykacji.
I tak zrobimy.

Dodamy autentykację do aplikacji
[Fortunka v1.0](https://github.com/wbzyl/fortune-responders-4.x).
Skorzystamy z kodu aplikacji
[Authentication from Scratch](http://asciicasts.com/episodes/250-authentication-from-scratch)  ([revised](http://railscasts.com/episodes/250-authentication-from-scratch-revised), [źródło](https://github.com/railscasts/250-authentication-from-scratch-revised)).


<blockquote>
  <p><b>Terminologia:</b>
   Login, czy Log in. Logout, czy Log out;
   a może Log off. Inne opcje: Sign in, Sign out</p>
   <p class="author"><a href="http://stackoverflow.com/questions/406016/ui-terminology-logon-vs-login">[dyskusja
   na Stack Overflow]</a></p>
</blockquote>

## Rejestracja

Model:

    :::bash
    rails g resource user email password_digest

    # ???
    rails g model user \
      email:string password_hash:string password_salt:string

    rake db:migrate

Kontroler:

    :::ruby app/controllers/users_controller.rb
    class UsersController < ApplicationController
      def new
        @user = User.new
      end

      def create
        @user = User.new(params[:user])
        if @user.save
          redirect_to root_url, :notice => "Registered!"
        else
          render "new"
        end
      end
    end

Widok:

    :::ruby app/views/users/new.html.erb
    <h1>Register</h1>

    <%= simple_form_for @user do |f| %>
      <div class="inputs">
        <%= f.input :email %>
        <%= f.input :password %>
        <%= f.input :password_confirmation %>
       </div>
       <div class="actions"><%= f.submit %></div>
    <% end %>

Model *User* nie ma zdefiniowanych atrybutów:
*password* i *password_confirmation*. Coś z tym trzeba będzie zrobić.

Zmieniamy wygenerowany routing na bardziej przyjazny:

    :::ruby config/routes.rb
    get "register" => "users#new", :as => "register"
    # to trzeba będzie zmienić; teraz tak będzie wygodnie
    root :to => "users#new"
    resources :users

Uruchomiamy serwer i wchodzimy na dowolny z poniższych uri:

    http://localhost:3000/
    http://localhost:3000/register
    http://localhost:3000/users/new

Kończy się to następującym komunikatem o błędzie:

    undefined method `password' for #<User:0x0000...>

Dodajemy do modelu *User* brakującą metodę i przy okazji – walidację
oraz trochę kodu:

    :::ruby app/models/user.rb
    class User < ActiveRecord::Base
      attr_accessible :password, :password_confirmation, :email

      validates_confirmation_of :password
      validates_presence_of :password, :on => :create
      validates_presence_of :email
      validates_uniqueness_of :email

      before_save :encrypt_password

      private
      def encrypt_password
        if password.present?
          self.password_salt = BCrypt::Engine.generate_salt
          self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
        end
      end
    end

Powyżej do zakodowania hasła użyliśmy gemu *bcrypt-ruby*.
Instalujemy go w aplikacji:

    :::ruby Gemfile
    gem 'bcrypt-ruby', :require => 'bcrypt'

Dopiero teraz rejestrujemy się. Po rejestracji
sprawdzamy na konsoli co zostało zapisane w bazie w tabeli *users*:

    :::ruby
    User.all
    wbzyl@sigma.ug.edu.pl|$2a$10$pZSeY.CDAPCoLdO0kTWu8em...|$2a$10$pZSeY.CDAPCo...

OK! Jesteśmy w połowie drogi. Przystępujemy do kodowania drugiej połowy.


## Logowanie, czyli *Logging in*

Informację o zalogowaniu użytkownika będziemy zapisywać w sesji.
Kod umieścimy w kontrolerze o mało odkrywczej nazwie *SessionsController*:

    rails g controller sessions new

Dodajemy do routingu skróty ukrywające przed użytkownikiem technologię
REST z której będziemy korzystać. Użytkownik nie musi
wiedzieć/domyślać się jak działa logowanie albo rejestracja.


    :::ruby config/routes.rb
    get "register" => "users#new",    :as => "register"
    get "login"    => "sessions#new", :as => "login"

    root :to => "users#new"  # to trzeba będzie zmienić

    resources :users
    resources :sessions

Logowanie to REST **bez modelu**. Oznacza to, że
z walidacją będzie problem.
I nie będziemy mogli też użyć *simple_form_for* w widoku
*sessions#new*.

Ale jakoś sobie z tym poradzimy! Teraz zajmiemy się formularzem dla
*sessions#new*:

    :::rhtml app/views/sessions/new.html.erb
    <h1>Log in</h1>
    <%= form_tag sessions_path do %>
      <div class="inputs">
        <div class="input">
          <%= label_tag :email %>
          <%= text_field_tag :email, params[:email] %>
        </div>
        <div class="input">
          <%= label_tag :password %>
          <%= password_field_tag :password %>
        </div>
      <div class="actions"><%= submit_tag %></div>
    <% end %>

Po wypełnieniu formularza, kilkamy przycisk „Save changes” i zostajemy
przekierowani (ponieważ działa routing REST) do metody *create*:

    :::ruby app/controllers/sessions_controller.rb
    class SessionsController < ApplicationController
      def new
      end

      def create
        user = User.authenticate(params[:email], params[:password])
        if user
          session[:user_id] = user.id
          redirect_to root_url, :notice => "Logged in!"
        else
          flash.now.alert = "Invalid email or password"
          render "new"
        end
      end
    end

Pytanie. Dlaczego jeśli zamienimy powyżej dwa wiersze
kodu po *else* na:

    :::ruby
    render "new", :alert => "Invalid email or password"

to nigdy nie zobaczymy tej wiadomości? Kto to wie?

Zanim będziemy mogli się przyjrzeć jak to działa,
musimy jeszcze napisać metodę *authenticate*:

    :::ruby app/models/user.rb
    def self.authenticate(email, password)
      user = find_by_email(email)
      if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
        user
      else
        nil
      end
    end

I już możemy się logować do aplikacji!


## Wylogowywanie się z aplikacji

To jest proste! O ile w naszej aplikacji jest jakaś
strona na którą można będzie przekierować
wylogowanego użytkownika.

Zaczynamy od routingu:

    :::ruby config/routes.rb
    get "register" => "users#new",    :as => "register"

    get "login"    => "sessions#new", :as => "login"
    get "logout"   => "sessions#destroy", :as => "logout"

W metodzie *destroy* zakładamy, że wejście
na *root_url* nie wymaga logowania:

    :::ruby app/controllers/sessions_controller.rb
    def destroy
      session[:user_id] = nil
      redirect_to root_url, :notice => "Logged out!"
    end

Jak widać wylogowywanie polega na wpisaniu do sesji
pod *:user_id* wartości *nil*.


## Dodajemy linki

Oczywiście, nie będziemy zmuszać użytkownika do wpisywania
w przeglądarce: *register*, *login*, *logout*. Wpisywanie zastąpimy
klikaniem. W tym celu dodamy do layoutu aplikacji odpowiednie linki:

    :::rhtml app/views/layouts/application.html.erb
    <nav id="authentication">
      <% if current_user %>
        Welcome <%= current_user.email %>!
        <%= link_to "Log out", logout_path %>
      <% else %>
        <%= link_to "Register", register_path %> or
        <%= link_to "Log in", login_path %>
      <% end %>
    </nav>

Powyżej korzystamy z metody pomocniczej o zwyczajowej nazwie
*current_user*:

    :::ruby app/controllers/application_controller.rb
    helper_method :current_user # make it visible in views

    private
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end

Nie powinniśmy też zapomnieć o zabezpieczeniu się przed „mass assignment”:

    :::ruby app/models/user.rb
    class User < ActiveRecord::Base
      attr_accessible :email, :password, :password_confirmation
      attr_accessor :password

oraz zmianie domyślnej strony aplikacji z powrotem na *posts#index*:

    :::ruby
    root :to => "posts#index"

Na koniec poprawki w CSS:

    :::css public/stylesheets/application.css
    #authentication {
      width: 75%;
      margin: 0 auto;
      padding: 20px 40px;
      text-align: right;
      background-color: #EBE54D;
    }

    #container {
      width: 75%;
      margin: 0 auto;
      background-color: #FFF;
      padding: 20px 40px;
    }


## To jeszcze nie koniec…

Oczwiście sam mechanizm do niczego nie jest przydatny!
Do dopiero początek w przydzielaniu i ograniczaniu uprawnień do
części naszej aplikacji.

Takie rzeczy to już *autoryzacja* a nie *autentykacja*.
Obecnie najpopularniejszym gemem wspomagajacym tworzenie kodu dla
*autoryzacji* jest [CanCan](https://github.com/ryanb/cancan).

W CanCanie uprawnienia użytkowników
[definiujemy w klasie Ability](https://github.com/ryanb/cancan/wiki/defining-abilities).

Ale jeśli chcemy tylkoa, aby dodawanie postów i komentarzy ograniczyć
do zalogowanych użytkowników, to autoryzację możemy zaimpelentować
samemu. Jest to bardzoa łatwe. Wystarczy w kontrolerach dopisać:

    :::ruby
    class PostsController < ApplicationController
      before_filter :login_required, :except => [:index, :show]

    class CommentsController < ApplicationController
      before_filter :login_required

oraz do *ApplicationController* dodać metodę *login_required*:

    :::ruby
    private
    def login_required
      unless current_user
        flash[:alert] = "You must first log in or register before accessing this page."
        redirect_to login_url
      end
    end


<blockquote>
  <p>{%= image_tag "/images/free_sign.png", :alt => "[its free]" %}</p>
  <p class="author"><a href="http://www.tonyamoyal.com/2010/07/28/rails-authentication-with-devise-and-cancan-customizing-devise-controllers/">[Read more]</a></p>
</blockquote>


# Autentykacja z Devise

Wchodzimy jeszcze raz na stronę projektu
[Devise](https://github.com/plataformatec/devise) aby
dokończyć lekturę *README*.

Na początek instalacja. Dopisujemy gem *devise* do *Gemfile*.
Po instalacji, uruchamiamy generator:

    rails generate devise:install
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml

    Some setup you must do manually if you haven't yet:

      1. Setup default url options for your specific environment. Here is an
         example of development environment:

           config.action_mailer.default_url_options = { :host => 'localhost:3000' }

         This is a required Rails configuration. In production it must be the
         actual host of your application

      2. Ensure you have defined root_url to *something* in your config/routes.rb.
         For example:

           root :to => "home#index"

      3. Ensure you have flash messages in app/views/layouts/application.html.erb.
         For example:

           <p class="notice"><%= notice %></p>
           <p class="alert"><%= alert %></p>

Czekają nas ręczne robótki:

    :::ruby config/environments/development.rb
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = { :host => 'localhost:3000' }

Na moim komputerze działa SMTP i wysyłanie poczty. Nic więcej
nie muszę konfigurować.
Ale w wersji produkcyjnej należy skonfigurować pocztę tak jak
opisałem w „Wysyłanie poczty w Ruby”.

Domyślna strona aplikacji jest ustawiona na:

    :::ruby config/routes.rb
    root :to => "posts#index"

Zostawiamy jak jest.

W kodzie wypisujący wiadomości flash usuwam w *id*
elementu *div* prefiks *flash_*:

    :::rhtml app/views/layouts/application.html.erb
    <% flash.each do |name, msg| %>
      <%= content_tag :div, msg, :id => "#{name}" %>
    <% end %>

i to samo w selektorach w *public/stylesheets/application.css*:

Zgodnie z sugestią przeglądamy opcje konfiguracji
w pliku {%= link_to "config/initializers/devise.rb", "/devise/devise.rb" %}.
Jest tego sporo! Ale do poprawki jest tylko *mailer_sender*:

    :::ruby config/initializers/devise.rb
    config.mailer_sender = "wbzyl@sigma.ug.edu.pl"
    #   ciekawość to pierwszy… domyślna wartość jest taka
    # config.email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
    #   użyteczna informacja
    # Configure the default scope given to Warden. By default it's the first
    # devise role declared in your routes (usually :user).
    # config.default_scope = :user


## Creating a devise User Model

Po konfiguracji, musimy się zdecydować jak nazwiemy model
do obsługi autentykacji. Zwyczajowo wybieramy nazwę *User*:

    rails generate devise User
        invoke   active_record
        create     app/models/user.rb
        create     db/migrate/20110415163428_devise_create_users.rb
        insert     app/models/user.rb
         route   devise_for :users

Sprawdzamy wygenerowany model:

    :::ruby
    class User < ActiveRecord::Base
      # Include default devise modules. Others available are:
      # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :trackable, :validatable

      # Setup accessible (or protected) attributes for your model
      attr_accessible :email, :password, :password_confirmation, :remember_me
    end

Zostawiamy go bez zmian. Dlatego migracji też nie musimy zmieniać.
Pora na migrację:

    rake db:drop
    rake db:migrate
    rake db:seed

Od razu poprawiamy routing, na bardziej zrozumiały
[rdoc](http://rdoc.info/github/plataformatec/devise/master/ActionDispatch/Routing/Mapper#devise_for-instance_method):

    :::ruby config/routes.rb
    devise_for :users, :path_names => {
      :sign_in =>  "login",
      :sign_up =>  "register",
      :sign_out => "logout"
    }

(Nawet zawodowi programiści Rails nazwy z prefiksem **sign_** używają w różnych znaczeniach;
na przykład ten rozdział zaczyna się od *sign_in* – *register*, a w Devise – *login*.)

Sprawdzamy nowy routing:

    rake routes
            new_user_session GET    /users/login          {:action=>"new", :controller=>"devise/sessions"}
                user_session POST   /users/login          {:action=>"create", :controller=>"devise/sessions"}
        destroy_user_session GET    /users/logout         {:action=>"destroy", :controller=>"devise/sessions"}
               user_password POST   /users/password       {:action=>"create", :controller=>"devise/passwords"}
           new_user_password GET    /users/password/new   {:action=>"new", :controller=>"devise/passwords"}
          edit_user_password GET    /users/password/edit  {:action=>"edit", :controller=>"devise/passwords"}
                             PUT    /users/password       {:action=>"update", :controller=>"devise/passwords"}
    cancel_user_registration GET    /users/cancel         {:action=>"cancel", :controller=>"devise/registrations"}
           user_registration POST   /users                {:action=>"create", :controller=>"devise/registrations"}
       new_user_registration GET    /users/register       {:action=>"new", :controller=>"devise/registrations"}
      edit_user_registration GET    /users/edit           {:action=>"edit", :controller=>"devise/registrations"}
                             PUT    /users                {:action=>"update", :controller=>"devise/registrations"}
                             DELETE /users                {:action=>"destroy", :controller=>"devise/registrations"}

Wchodzimy na przykład na stronę:

    http://localhost:3000/users/register

i widzimy napis „Sign up” zamiast „Register”. Layout i widoki są do poprawki.
Nie mamy wyjścia, wykonujemy:

    rails generate devise:views
     create  app/views/devise
      create  app/views/devise/confirmations/new.html.erb
      create  app/views/devise/mailer/confirmation_instructions.html.erb
      create  app/views/devise/mailer/reset_password_instructions.html.erb
      create  app/views/devise/mailer/unlock_instructions.html.erb
      create  app/views/devise/passwords/edit.html.erb
      create  app/views/devise/passwords/new.html.erb
      create  app/views/devise/registrations/edit.html.erb
      create  app/views/devise/registrations/new.html.erb
      create  app/views/devise/sessions/new.html.erb
      create  app/views/devise/shared/_links.erb
      create  app/views/devise/unlocks/new.html.erb

Na razie zmieniamy w szablonie *registrations/new.html.erb*
tylko nagłówek i napis na przycisku. Jeszcze raz sprawdzamy
jak to wygląda po tych poprawkach.

Może być! Po zarejestrowaniu się w aplikacji wyświetlana jest
wiadomość flash: „Welcome! You have **signed up** successfully.”
Flash też do poprawki. Wszystkie komunikaty są w pliku
{%= link_to "config/locales/devise.en.yml", "/devise/devise.en.yml" %}.


## Linki – register, log in, log out

Do layoutu aplikacji musimy dodać linki do autentykacji:

    :::rhtml app/views/layouts/application.html.erb
    <nav id="authentication">
      <% if user_signed_in? %>
        Logged as <%= current_user.email %>. Not you?
        <%= link_to "Logout", destroy_user_session_path %>
      <% else %>
        <%= link_to "Register", new_user_registration_path %> or
        <%= link_to "Login", new_user_session_path %>
      <% end %>
    </nav>

oraz odrobinę CSS:

    :::css public/stylesheets/application.css
    #authentication {
      width: 75%;
      margin: 0 auto;
      padding: 20px 40px;
      text-align: right;
      background-color: #EBE54D;
    }

    #container {
      width: 75%;
      margin: 0 auto;
      background-color: #FFF;
      padding: 20px 40px;
    }

i zmienić generowane komunikaty flash w pliku *config/locales/devise.en.yml*.


## Jak działa przypominanie hasła

Zaczynamy od konfiguracji programu pocztowego:

    rails g nifty:config smtp

I dalej postępujemy tak jak do opisano w notatkach „Wysyłanie poczty”.

**Uwaga:** W wersji 1.3.0 Devise nie działa przypominanie hasła.
Po kliknięciu „Change my password” pojawia się komunikat:

    Reset password token is invalid.

W wersji 1.2.1 nie ma tego problemu.
Ustawiamy wersję gemu w *Gemfile*:

    gem 'devise' , '= 1.2.1'
