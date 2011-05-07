#### {% title "Wysyłanie poczty", false %}

# Wysyłanie poczty w Ruby

Wysyłając pocztę musimy programowi pocztowemu podać swoje dane: login
i hasło. Jeśli pocztę wysyłamy z aplikacji Rails, to musimy wcześniej
nasze dane umieścić gdzieś w kodzie. Jeśli kod trzymamy w repozytorium,
to musimy zadbać, aby nasze dane nie znalazły się gdzieś w chmurze,
na przykład na Githubie.

W przykładach poniżej swoje dane będę czytał z pliku *smtp.yml*,
który umieszczę poza repozytorium
w katalogu *$HOME/.credentials/* albo (dla aplikacji Rails)
nazwę pliku dodam do pliku *.gitignore*, a sam plik skopiuję
do katalogu *config/initializers/*.

Do wysyłania poczty użyję programu *sendmail*.

Oto przykładowy plik z danymi (w formacie [YAML](http://www.yaml.org/)),
dla konta pocztowego na *gmail.com* i konta – na *sigmie*):

    :::yaml smtp.yml
    development:
      address: smtp.gmail.com
      domain: gmail.com
      port: 587
      user_name: ‹login›
      password: ‹hasło›
      authentication: plain
      host: localhost:3000

    production:
      address: inf.ug.edu.pl
      domain: ug.edu.pl
      port: 25
      user_name: ‹login›
      password: ‹hasło›
      authentication: login
      host: sigma.ug.edu.pl:3000

Do wysłania poczty, możemy użyć takiego skryptu:

    :::ruby gmail.rb
    # -*- coding: utf-8 -*-
    require 'mail'
    require 'yaml'

    # konfigurujemy SMTP
    raw_config = File.read("#{ENV['HOME']}/.credentials/smtp.yml")
    SMTP_CONFIG = YAML.load(raw_config)['development']

    Mail.defaults do
      delivery_method :smtp, {
        :address => SMTP_CONFIG['address'],
        :port => SMTP_CONFIG['port'],
        :domain => SMTP_CONFIG['domain'],
        :user_name => SMTP_CONFIG['user_name'],
        :password => SMTP_CONFIG['password'],
        :authentication => SMTP_CONFIG['authentication'],
        :enable_starttls_auto => true
      }
    end

    # wysyłamy email
    mail = Mail.new do
      to 'matwb@ug.edu.pl'
      from 'wlodek.bzyl@gmail.com'
      subject 'Tę wiadomość wysłano z Gmail'
      body File.read('body.txt')
      add_file :filename => 'butterfly.jpg', :content => File.read('images/butterfly.jpg')
    end

    mail.deliver!

**Uwaga:** Jeśli na *localhost* działa *sendmail*,
to zazwyczaj możemy pominąć całą konfigurację SMTP
(zob. {%= link_to "localhost.rb", "/mail/localhost.rb" %}).


# Wysyłanie poczty w Rails

Zaczynamy od wygenerowania rusztowania dla aplikacji Rails:

    rails new mailit
    cd mailit

W aplikacji „Mail it” użyjemy pliku *Gemfile* z Fortunki v1.0.

Teraz wykonujemy kolejno polecenia:

    bundle install --path=.bundle/gems
    rails g jquery:install
    rails g nifty:layout
    rails g simple_form:install
    rails g scaffold user username:string email:string password:string password_confirmation:string
    rake db:migrate

Poprawiamy layout formularzy, tak jak to opisano w rozdziale
„Ładniejsze formularze z *simple_form*”
(z wykładu „»Blog« na dwóch modelach”).

Sprawdzamy, czy coś poszło nie tak. Wchodzimy na stronę:

    http://localhost:3000/users/new

gdzie dodajemy nowego użytkownika.

Teraz pora na walidację:

    :::ruby app/models/user.rb
    class User < ActiveRecord::Base
      validates :username, :length => {:in => 2..12}, :allow_blank => true
      validates :email, :format => /\A[-@.a-z0-9]\z/, :uniqueness => true
      validates :password,  :length => {:in => 2..12}, :confirmation => true
    end


## Co chcemy osiągnąć?

Po wejściu na stronę

    http://localhost:3000/users/new

wpisaniu danych do formularza, kliknięciu przycisku „Create User”
i walidacji wpisanych danych, aplikacja „Mail it” ma wysłać
na wpisany adres email wiadomość z potwierdzeniem rejestracji.


## Konfiguracja programu pocztowego

Zaczynamy od konfiguracji programu pocztowego. Będziemy korzystać
z SMTP. Na początek coś na ukrycie loginu i hasła
do programu pocztowego (ja korzystam z *Gmail*):

    rails g nifty:config smtp
      create  config/initializers/load_smtp_config.rb
      create  config/smtp_config.yml

Plik, w którym wpiszemy swoje dane dopisujemy do pliku *.gitignore*:

    config/smtp_config.yml

Dopiero teraz wpisujemy do niego swoje dane.

Teraz konfiguracja SMTP wyglada tak:

    :::ruby config/initializers/load_smtp_config.rb
    raw_config = File.read("#{Rails.root}/config/smtp_config.yml")
    SMTP_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

    ActionMailer::Base.smtp_settings = {
      :address => SMTP_CONFIG[:address],
      :port => SMTP_CONFIG[:port],
      :domain => SMTP_CONFIG[:domain],
      :user_name => SMTP_CONFIG[:user_name],
      :password => SMTP_CONFIG[:password],
      :authentication => SMTP_CONFIG[:authentication],
      :enable_starttls_auto => true
    }

Z powodów, które wyjaśnią się za chwilę, musimy jeszcze podać
uri aplikacji z autentykacją:

    :::ruby config/environments/development.rb
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = {
      :host => '127.0.0.1',
      :port => 3000
    }

(Konfiguracja *production.rb* – później.)


## Stub out a new mailer and its views

*Stub out* wygląda tak:

    rails generate mailer user_mailer
      create  app/mailers/user_mailer.rb
       invoke  erb
       create  app/views/user_mailer

Wygenerowany kod:

    :::ruby app/mailers/user_mailer.rb
    class UserMailer < ActionMailer::Base
      default :from => "from@example.com"
    end

zmieniamy na:

    :::ruby app/mailers/user_mailer.rb
    class UserMailer < ActionMailer::Base
      default :from => "wbzyl@inf.ug.edu.pl"

      def registration_confirmation(user)
        @user = user # zmiennej instancji użyjemy w szablonie emaila
        attachments["rails.png"] = File.read("#{Rails.root}/public/images/rails.png")
        mail(:to => user.email, :subject => "Registered")
      end
    end

a do metody *registration_confirmation* piszemy powiązany z nią widok:

    :::html_rails app/views/user_mailer/registration_confirmation.text.erb
    <%= @user.username %>,
    Thank you for registering!

Z tego widoku renderowany jest email, który aplikacja powinna wysłać
po zapisaniu danych nowego użytkownika w bazie. Oto kod który to robi:

    :::ruby
    UserMailer.registration_confirmation(@user).deliver

Należy go wstawić do metody *create* kontrolera *UsersController*:

    :::ruby app/controllers/users_controller.rb
    def create
      @user = User.new(params[:user])
      if @user.save
        UserMailer.registration_confirmation(@user).deliver
        flash[:notice] = 'User was successfully created.'
      end
      respond_with(@user)
    end

O co chodzi w tym kodzie (cytaty Rails Guides)?

„Instead of rendering a view and sending out the HTTP protocol, we
are just sending it out through the Email protocols instead. Due to
this, it makes sense to just have your controller tell the mailer to
send an email when a user is successfully created.”

Na co trzeba zwrócić uwagę?

„Sending out one email should only take a fraction of a second, if you
are planning on sending out many emails, or you have a slow domain
resolution service, you might want to investigate using a background
process like delayed job.”



## Przechodzimy na wysyłanie wiadomości HTML

To jest proste! Piszemy szablon HTML:

    :::html_rails app/views/user_mailer/registration_confirmation.html.erb
    <h3><%= @user.username %></h3>
    <p>Thank you for registering!</p>
    <p>Edit Profile:
      <%= link_to "Click me!", edit_user_url(@user, :host => MAIL_CONFIG[:host]) %>
    </p>

i usuwamy szablon tekstowy:

    rm app/views/user_mailer/registration_confirmation.text.erb

(Albo go zostawiamy. Wtedy *ActionMailer* automatycznie wyśle
post *multipart/alternative*.)

Dlaczego w metodzie pomocniczej *edit_user_url* użyto *host*?
„Unlike controllers, the mailer instance doesn’t have any context about
the incoming request so you’ll need to provide the *:host*, *:controller*,
and *:action*.”
Innymi słowy, wysyłanie poczty jest *decoupled* od kodu aplikacji.
Dlatego, musimy jakoś powiedzieć metodzie pomocniczej *edit_user_url*
na jakim hoście działa nasza aplikacja.

W zasadzie, jeśli opiekujemy się kilkoma aplikacjami Rails, to
autentykację moglibyśmy napisać raz. Na przykład coś w stylu *simple
omniauth*. Jeśli tak by było, to zmienna *host* powinna wskazywać na
tę aplikację.


## Mail interceptors & observers

Intercepting mail messages before they’re delivered.
Co to oznacza? Jakiś hook? Coś innego? Co?

Do czego może się przydać taki przechwytywacz poczty? Na przykład,
w trybie development możemy wysyłanym emailom podmienić
adres na adres swojej skrzynki pocztowej.
Dlaczego takie zachowanie aplikacji może być użyteczne?

Interceptor „must implement the *delivering_email* method which
will be called before the email is sent, allowing you to make
modifications to the email before it hits the delivery agents”:

    :::ruby config/initializers/setup_mail.rb
    class DevelopmentMailInterceptor
      def self.delivering_email(message)
        message.subject = "[#{message.to}] #{message.subject}"
        message.to = "matwb@ug.edu.pl"
      end
    end

    ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?


Observer też się przyda – „*delivered_email* method is called once for
every email sent after the email has been sent.”:

    :::ruby config/initializers/setup_mail.rb
    class DevelopmentMailObserver
      def self.delivered_email(message)
        Rails.logger.info("====>>>> #{Time.now}: message send to #{message.to}")
      end
    end

    ActionMailer::Base.register_observer(DevelopmentMailObserver) if Rails.env.development?

Jakiś lepszy przykład zastosowania dla obserwatora wysłanej poczty?


## Kilka linków

* [ActionMailer::Base](http://apidock.com/rails/ActionMailer/Base)
* R. Batesa [Action Mailer in Rails 3](http://railscasts.com/episodes/206-action-mailer-in-rails-3).
