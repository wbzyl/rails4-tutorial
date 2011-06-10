#### {% title "Autentykacja z Authlogic" %}

# Autentykacja z Authlogic

Różnice do Rails2:

    rails g nifty:scaffold fortune quotation:text

Konfiguracja routingu:

    root :to => "fortunes#index

Do Gemfile dopisujemy:

    gem "authlogic"

Teraz:

    rm db/migrate/20100903194327_create_users.rb
    rm db/development*
    rails g migration CreateUsers

Zamienimay migrację:

    :::ruby
    def self.up
      create_table :users do |t|
        t.string :username, :null => false
        t.string :email, :null => false
        t.string :crypted_password, :null => false
        t.string :password_salt, :null => false
        t.string :persistence_token, :null => false      
        t.integer :login_count, :default => 0, :null => false
        t.datetime :last_request_at
        t.datetime :last_login_at
        t.datetime :current_login_at
        t.string :last_login_ip
        t.string :current_login_ip
      
        t.timestamps
      end
      add_index :users, :username
      add_index :users, :email
    end
    def self.down
      drop_table :users
    end

Model *User*:

    :::ruby
    class User < ActiveRecord::Base
      # a tak zmieniamy domyślne ustawienia walidacji w Authlogic
      acts_as_authentic do |c|
        c.validates_length_of_password_field_options= {:within => 2..4}
        c.validates_length_of_password_confirmation_field_options= {:within => 2..4}    
      end
      
      attr_accessible :username, :email, :password, :password_confirmation
      attr_accessible :crypted_password, :password_salt, :persistence_token,
        :login_count, :last_request_at, :last_login_at,
        :current_login_at, :last_login_ip, :current_login_ip,
        :created_at, :updated_at
     end

Routing:

    :::ruby
    Mailit::Application.routes.draw do
      match 'signup' => 'users#new',             :as => :signup
      match 'login'  => 'user_sessions#new',     :as => :login
      match 'logout' => 'user_sessions#destroy', :as => :logout
      
      resources :fortunes
      
      resources :user_sessions
      resources :users
 
Widok aplikacji:

    :::html_rails
    <div id="user_nav">
      <% if logged_in? %>
        Welcome <%= current_user.username %>! Not you?
        <%= link_to "Logout", logout_path %> |
        <%= link_to "Edit Profile", edit_user_path(current_user.id) %>
      <% else %>
        <%= link_to "Register", signup_path %> |
        <%= link_to "Login", login_path %>
      <% end %>
    </div>

Dopiero teraz generujemy pseudo-model *UserSessions*:

    rails g nifty:scaffold user_session username:string password:string new destroy --skip-model

Czy wygenerowany widok *app/views/user_sessions/new.html.erb*
będzie kiedykolwiek użyty? Czy można ten plik usunąć?

Tworzymy **pseudo-model** *UserSession*:

    :::ruby app/models/user_session.rb
    class UserSession < Authlogic::Session::Base
    end

Dlatego mówimy, że *Authlogic* jest **model based**.

Domieszkujemy moduł *Authentication* do klasy *ApplicationController*

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      include Authentication
      protect_from_forgery
    end

Moduł *Authentication* zawiera definicje metod pomocniczych
użytych powyżej.

    :::ruby lib/authentication.rb
    # You can also restrict unregistered users from accessing a controller using
    # a before filter. For example.
    # 
    #   before_filter :login_required, :except => [:index, :show]
    #
    module Authentication
      def self.included(controller)
        controller.send :helper_method, 
          :current_user, :logged_in?, 
          :login_required, :logout_required,
          :redirect_to_target_or_default
      end
      
      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end
      
      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.record
      end
      
      def logged_in?
        current_user
      end
      
      def login_required
        unless logged_in?
          flash[:error] = "You must first log in or sign up before accessing this page."
          store_target_location
          redirect_to login_url
        end
      end
      
      def logout_required
        if logged_in?
          store_target_location
          flash[:notice] = "You must be logged out before accessing this page."
          redirect_to root_url
          return false
        end
      end
      
      def redirect_to_target_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end
      
      private
      
      def store_target_location
        session[:return_to] = request.fullpath
      end
    end

Jeszcze musimy poprawić kod tak aby działał routing 
generowny przez *Edit Profile*:

    /users/wlodek/edit

W tym celu konieczne są poprawki w kodzie kontrolera
*UsersController*:

    :::ruby
    def edit
      #@user = User.find(params[:id])
      @user = current_user
      ...
    end
    def update
      #@user = User.find(params[:id])
      @user = current_user
      ...

Pytanie: dlaczego po tych poprawkach routing działa?
Czy poprawki te są konieczne?


## Le Grande Finale: ograniczamy dostęp 

Jak zapewnić sobie, aby **tylko** zalogowany użytkownik mógł 
dodawać nowe cytaty oraz edytować i usuwać już istniejące cytaty?

Częściowe rozwiązanie: dopisujemy w kontrolerze
*FortunesController*:

    :::ruby
    before_filter :login_required, :except => [:index, :show]

Dlaczego to rozwiązanie jest częściowe?


## Jak zmienić zapomniane hasło?

Zaczynamy od konfiguracji *Mail* (*ActionMailer*).
Zrobione w rozdziale „Majlujemy”.

Jak to jest zaimplementowane w *Authlogic*:

1. A user requests a password reset.
2. An email is sent to them with a link to reset their password.
3. The user verifies their identity be using the link we emailed them
4. They are presented with a basic form to change their password.
5. After they change their password we log them in, redirect them to
   their account, and expire the URL we just sent them.

Przesłany mail będzie zawierał tekst z linkiem zawierającym napis
podobny do:

    4LiXF7FiGUppIPubBPey

Nazywamy go **perishable_token**. Takie napisy są pamiętane w polu
*perishable_token* tabeli *users*.

*Authlogic* zarządza tym tokenem w następujący sposób:

* The token gets set to a unique value before validation, 
  which constantly changes the token.
* After a session is successfully saved (aka logged in) 
  the the token will be reset. 

Pytanie: Co to daje?

Tworzymy migrację, która doda token to tabeli:

    rails g migration add_users_password_reset_fields

i modyfikujemy ją w następujący sposób:

    :::ruby
    class AddUsersPasswordResetFields < ActiveRecord::Migration  
      def self.up  
        add_column :users, :perishable_token, :string, :default => "", :null => false
        add_index :users, :perishable_token
      end  
      def self.down  
        remove_column :users, :perishable_token  
      end  
    end  

Po tych zmianach migrujemy:

    rake db:migrate


### Zmiana hasła na sposób REST

Tworzymy resource/zasób o nazwie *password resets* 
i dopisujemy go do routingu:

    :::ruby
    resources :password_resets

generujemy pusty kontroler:

    rails generate controller password_resets

i wklejamy gotowca (na razie tylko tyle):

    :::ruby app/controllers/password_resets_controller.rb
    class PasswordResetsController < ApplicationController
      before_filter :load_user_using_perishable_token, :only => [:edit, :update]

      # make sure the user is logged out when accessing these methods
      before_filter :logout_required

      def new
        render
      end

      private

      def load_user_using_perishable_token
        @user = User.find_using_perishable_token(params[:id])
        unless @user
          flash[:notice] = "We're sorry, but we could not locate your account." +
            "If you are having issues try copying and pasting the URL " +
            "from your email into your browser or restarting the " +
            "reset password process."
          redirect_to root_url
        end
      end
    end

Metodę *logout_required* dopisujemy w pliku *lib/authentication.rb*
do *controler.send* (definicję już wpisaliśmy wcześniej):

    :::ruby lib/authentication.rb
    module Authentication
      def self.included(controller)
        # dopisujemy :logout_required
        controller.send :helper_method, :current_user, :logged_in?, 
            :redirect_to_target_or_default, :logout_required
      end

Method *find_using_perishable_token* is a special in *Authlogic*. 
Here is what it does for extra security:

* Ignores blank tokens
* Only finds records that match the token and have an updated_at (if
  present) value that is not older than 10 minutes. This way, if
  someone gets the data in your database any valid perishable tokens
  will expire in 10 minutes. Chances are they will expire quicker
  because the token is changing during user activity as well.

Widok *new.html.erb* dla tego kontrolera:

    :::html
    <h1>Forgot Password</h1>
    <p>Fill out the form below and instructions 
       to reset your password will be emailed to you:
    </p>
    <% form_tag password_resets_path do %>
      <label>Email:</label><br />
      <%= text_field_tag "email" %><br />
      <br />
      <%= submit_tag "Reset my password" %>
    <% end %>

Kilknięcie na przycisk "Reset my password" powoduje wywołanie metody
*create* kontrolera:

    :::ruby app/controllers/password_resets_controller.rb
    def create
      @user = User.find_by_email(params[:email])
      if @user
        # tutaj wstawiamy kod wysyłający Email – implementacja poniżej
        @user.deliver_password_reset_instructions!
        flash[:notice] = "Instructions to reset your password have been emailed to you. " +
          "Please check your email."
        redirect_to root_url
      else
        flash[:notice] = "No user was found with that email address"
        render :action => :new
      end
    end

Zanim zajmiemy się wysyłaniem maila, podczepimy link do „Forgot password?”.

Dopisujemy link do "Forgot password?" (i kilka innych rzeczy)
do elementu *div#user_nav*

    :::html app/views/layouts/application.html.erb
    <div id="user_nav">
      <% if logged_in? %>
        Welcome <%= current_user.username %>! Not you?
        <%= link_to "Logout", logout_path %> |
        <%= link_to "Edit Profile", edit_user_path(current_user.username) %> 
      <% else %>
        <%= link_to "Register", signup_path %> |
        <%= link_to "Login", login_path %> |
        <%= link_to "Forgot password?", new_password_reset_path %>
      <% end %>
    </div>


### Email z linkiem do zmiany hasła 

Za wysłanie maila z linkiem będzie odpowiedzialna metoda
*deliver_password_reset_instructions!*:

    :::ruby app/models/user.rb
    class User < ActiveRecord::Base
      ...
      def deliver_password_reset_instructions!
        reset_perishable_token!
        Notifier.password_reset_instructions(self).deliver
      end

Uwagi: 

* metoda *reset\_perishable\_token!* jest zdefiniowana w *Authlogic*;
  metoda ta zmienia wartość pola *perishable_token* w tabelce *users*
  na nową przypadkową wartość
* jak widać za wysłanie odpowiedzialna jest klasa *Notifier*

Teraz zajmiemy się wygenerowaniem gotowca dla *Notifier*:

    rails g mailer Notifier
    
      create  app/mailers/notifier.rb
      invoke  erb
      create    app/views/notifier

Zmieniamy wygenerowany kod na:

    :::ruby app/mailers/notifier.rb
    class Notifier < ActionMailer::Base
      default :from => "matwb@ug.edu.pl"

      def password_reset_instructions(user)
        @user = user 
        mail(:to => user.email, :subject => "Pasword reset instructions")
      end  
    end

I dodajemy szablon tekstowy dla tego maila:

    :::html_rails app/views/notifier/password_reset_instructions.text.erb
    A request to reset your password has been made. 
    If you did not make this request, simply ignore this email. 
    If you did make this request just click the link below:

      <%= edit_password_reset_url(@user.perishable_token, :host => MAIL_CONFIG[:host]) %>

    If the above URL does not work try copying and pasting 
    it into your browser. If you continue to have problem 
    please feel free to contact us.
 

### Użytkownik kilka na link w emailu

Link który użytkownik ma kliknąć w emailu będzie wyglądał jakoś tak:

    http://sigma.ug.edu.pl:3000/password_resets/6th8mSFwxvG-v2IbbRdY/edit    

Po kliknięciu wykonana zostanie metoda *edit* klasy *PasswordResetsController*:

    :::ruby app/controllers/password_resets_controller.rb
    def edit
      render
    end

Powiązany z nią widok jest taki:
    
    :::ruby app/views/password_resets/edit.html.erb
    <h1>Change My Password</h1>
    
    <%= form_for @user, :url => password_reset_path, :method => :put do |f| %>
      <%= f.error_messages %>
      <%= f.label :password %><br />
      <%= f.password_field :password %><br />
      <br />
      <%= f.label :password_confirmation %><br />
      <%= f.password_field :password_confirmation %><br />
      <br />
      <%= f.submit "Update my password and log me in" %>
    <% end %>

Wyrenderowany formularz wygląda mniej więcej tak
(gdzie "RgfuGYh4yU6qbQIsIeiE" poniżej, to *perishable_token*):

    :::html
    <form action="/password_resets/RgfuGYh4yU6qbQIsIeiE" id="edit_user_1" method="put">
    <input id="user_password" name="user[password]" size="30" type="password" />
    <input id="user_password_confirmation" name="user[password_confirmation]" size="30" type="password" />

Oznacza to, że po kliknięciu na przycisk submit zostanie wywołana
metoda *update* klasy *PasswordResetsConttoller* (dopisujemy ją):

    :::ruby app/controllers/password_resets_controller.rb
    def update
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        flash[:notice] = "Password successfully updated"
        redirect_to root_url
      else
        render :action => :edit
      end
    end

## TODO

Pozostało pozmieniać napisy na przyciskach oraz tytuły niektórych
stron. Na przykład, napis na przycisku „New User Session” na „Zaloguj”
a tytuł „New User Session” na „Logowanie” itp.

Na stronie „Edit User” możemy wypisać zawartość pozostałych
pól tabelki *users*.

Czy zostało coś jeszcze do zrobienia?
