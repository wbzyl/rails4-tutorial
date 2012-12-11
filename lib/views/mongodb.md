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

Przykładowa aplikacja CRUD listy obecności studentów. Aplikacja
korzysta z bazy MongoDB i gemu Mongoid.
Autentykacja OmniAuth ze strategią *omniauth-github*.
Kod gotowej aplikacji:

* [lista-obecności-2013](https://bitbucket.org/wbzyl/lista-obecnosci-2013) –
  repozytorium Git na Bitbucket
  

## Zaczynamy…

Zaczynamy od skopiowania szablonu aplikacji *mongoid+omniauth-twitter*
(Bitbucket).

Po skopiowaniu zmieniamy wartości stałych w plikach:

* *secret_token.rb*
* *session_store.rb*


### Konfiguracja bazy MongoDB

Podmieniamy plik *mongoid.yml* na plik o takiej zawartości:

    :::yaml config/mongoid.yml
    development:
      sessions:
        default:
          database: dziennik_lekcyjny_2013_development
          hosts:
            - localhost:27017
    production:
      sessions:
        default:
          database: dziennik_lekcyjny_2013_production
          hosts:
            - localhost:27017
    test:
      sessions:
        default:
          database: dziennik_lekcyjny_2013_test
          hosts:
            - localhost:27017
          options:
            consistency: :strong
            # In the test environment we lower the retries and retry interval to
            # low amounts for fast failures.
            max_retries: 1
            retry_interval: 0


### OmniAuth + Github

* [OmniAuth GitHub](https://github.com/intridea/omniauth-github)

W pliku *Gemfile* wykomentowujemy gem *omniauth-twitter* oraz dodajemy
gem *omniauth-github* i po tych zmianach instalujemy gemy:

    :::bash
    bundle install

W kontrolerze *SessionsControllers* w metodzie `new` podmieniamy
`/auth/twitter` na `/auth/github`:

    :::ruby
    class SessionsController < ApplicationController
      def new
        redirect_to '/auth/github'
      end

Teraz rejestrujemy aplikację na [GitHubie](https://github.com/account/applications).

Jeśli aplikacja będzie działać na *localhost:3000*, to w formularzu wpisujemy:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb
    Callback: http://localhost:3000

(Oczywiście, powyżej podajemy jakiś swój URL.)

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

Powyżej podstawiamy, że

    omniauth_provider_key     <==  Client ID
    omniauth_provider_secret  <==  Client Secret

W pliku *seeds.rb* zostawiamy tylko dwie role: *admin* i *student*:

    rake db:reseed

Rola pierwszego zalogowanego użytkownika to Admin. Rola
następnych – Student

    :::ruby app/controllers/sessions_controller.rb
    if User.count == 1        # make the first user an admin
      user.add_role :admin
    else
      user.add_role :student
    end


### Więcej informacji o zalogowanym użytkowniku

[OmniAuth](https://github.com/intridea/omniauth) is a library that
standardizes multi-provider authentication for web applications. […]
Once the user has authenticated OmniAuth simply sets a special hash
called the *Authentication Hash* on the Rack environment:

    :::ruby
    request.env['omniauth.auth']

This information is meant to be as normalized as possible.
Some fields will **always** be present:

* **provider** – the provider with which the user authenticated
  (e.g. 'twitter' or 'facebook')
* **uid** – an identifier unique to the given provider, such as a
  Twitter user ID. Should be stored as a string
* **info** – a hash containing information about the user
* **name** - The best display name known to the strategy. Usually a
  concatenation of first and last name, but may also be an arbitrary
  designator or nickname for some strategies
* **email** (optional) – The email of the authenticating user. Should
  be provided if at all possible (but some sites such as Twitter do
  not provide this information)

Pozostałe pola –
[Auth Hash Schema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema).


### LESS

W pliku *application.css.less* podmienaimy linie kodu z *require* na:

    :::js
    *= require_self
    *= require bootstrap_and_overrides.css

dodajemy pusty plik *app/assets/stylesheets/dziennik_lekcyjny.less*.
Na końcu pliku *bootstrap_and_overrides.css.less* dopisujemy:

    :::css app/assets/stylesheets/bootstrap_and_overrides.css.less
    @import "dziennik_lekcyjny";

LESS zmieniający wygląd aplikacji będziemy wpisywać w *dziennik_lekcyjny*.
Na początek zmienimy kilka kolorów:

    :::css
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


## Dodajemy model Student

Generujemy rusztowanie dla modelu *Student*.
Oczywiście w aplikacji *Dziennik Lekcyjny* nie może zabraknąć
atrybutów obecność i uwagi:

    :::bash terminal
    rails generate scaffold Student \
      first_name:String last_name:String login:String \
      presences:Array class_name:String group:String \
      comments:String \
      uid:Integer
    rm app/assets/stylesheets/scaffolds.css.less

Od razu dopisujemy wartości domyślne atrybutów do modelu:

    :::ruby app/models/student.rb
    class Student
    include Mongoid::Document

    include Mongoid::Timestamps

    field :first_name, type: String
    field :last_name, type: String
    field :login, type: String
    field :presences, type: Array
    field :class_name, type: String, default: "unallocated"
    field :group, type: String, default: "unallocated"
    field :comments, type: String
    field :uid, type: Integer

Na razie zapełnimy kolekcję *students* tymi przykładowymi danymi:

    :::ruby seeds.rb
    Student.destroy_all

    Student.create! last_name: "Kuszelas", first_name: "Jan",
      login: "jkuszelas", class_name: "nosql"
    Student.create! last_name: "Klonowski", first_name: "Felicjan",
      login: "fklonowski", class_name: "nosql"
    Student.create! last_name: "Korolczyk", first_name: "Joga",
      login: "jkorolczyk", class_name: "semianrium"
    Student.create! last_name: "Grabczyk", first_name: "Simona",
      login: "sgrabczyk", class_name: "nosql"
    Student.create! last_name: "Kamińska",  first_name: "Irena",
      login: "ikaminska", class_name: "asi"
    Student.create! last_name: "Jankowski", first_name: "Kazimierz",
      login: "kjankowski", class_name: "asi"
    Student.create! last_name: "Bzyl", first_name: "Włodzimierz",
      login: "wbzyl", class_name: "asi", uid: 8049
    Student.create! last_name: "Raj", first_name: "Renia",
      login: "rraj", class_name: "asi", uid: 1198062

Import z pliku CSV do kolekcji MongoDB, nie nada wartości atrybutom *created_at*
i *updated_at*:

    :::bash terminal
    mongoimport --drop \
      -d dziennik_lekcyjny_2013_development -c students \
      --headerline --type csv wd.csv

Strony wygenerowana z scaffold nie korzystają z Twitter Bootstrap.
Aby to zmienić, nadpisujemy wszystkie wygenerowane widoki:

    :::bash
    rails g bootstrap:themed students


### Routing

W pliku *routes.rb* ustawiamy stronę główna na `students#index`:

    :::ruby
    root :to => "students#index"


## Strona z listą studentów

Informacje o studentach roku zostaną umieszczone
w widoku *index.html.erb*. Gotowy widok jest pokazany na obrazku poniżej.

{%= image_tag "/images/lista-obecnosci-2013.png", :alt => "[Lista obecności, 12/13]" %}

Po imieniu, w nawiasie, wypisywana jest liczba obecności na zajęciach.
Kliknięcie przycisku umieszczonego przed nazwiskiem zwiększa o jeden
liczbę obecności studenta.

W widoku będziemy korzystać z tych metod pomocniczych:

    :::ruby app/models/student.rb
    def full_name
      [last_name, first_name].join(' ')
    end
    def full_name=(name)
      split = name.split(' ', 2)
      self.last_name = split.first
      self.first_name = split.last
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

Dokumenty z kolekcji *students* będziemy wypisywać w takim porządku:

    :::ruby app/models/student.rb
    default_scope asc(:group, :last_name, :first_name)

A to poprawiony widok:

    :::rhtml app/views/students/index.html.erb
    <%- model_class = Student -%>
    <div class="page-header">
      <h3><%=t '.title', :default => model_class.model_name.human %>
        <%= link_to t('.new', :default => t("helpers.links.new")),
                new_student_path,
                :class => 'btn btn-primary' %>
      </h3>
    </div>
    <table class="table table-striped">
      <tbody>
        <% @students.each do |student| %>
          <tr>
            <td><%= link_to "<i class='icon-user icon-large'></i>".html_safe,
                      present_student_path(student), method: :put,
                      class: 'btn btn-mini btn-primary' %></td>
            <td><%= link_to student.full_name, student_path(student) %>
                      (<%= student.presences_length %>)</td>
            <td><%= student.login %></td>
            <td><%= student.class_name %></td>
            <td><%= student.uid %></td>
            <td>
              <%= link_to t('.edit', :default => t("helpers.links.edit")),
                      edit_student_path(student),
                      :class => 'btn btn-mini' %>
              <%= link_to t('.destroy', :default => t("helpers.links.destroy")),
                      student_path(student),
                      :method => :delete,
                      :data => {
                         :confirm =>
                            t('.confirm', :default => t("helpers.links.confirm",
                                          :default => 'Are you sure?'))
                      },
                      :class => 'btn btn-mini btn-danger' %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>


## Widok częściowy – _form.html.erb

Też do poprawy:

    :::rhtml app/views/students/_form.html.erb
    <%= simple_form_for @student, :html => { :class => 'form-horizontal' } do |f| %>
      <%= f.input :first_name %>
      <%= f.input :last_name %>
      <%= f.input :login %>
      <%= f.input :presences_list, label: "Presences (m-d)" %>
      <%= f.input :class_name, as: :select,
              collection: { "nieprzydzielony" => "unallocated",
                            "języki programowania" => "jp",
                            "technologie nosql" => "nosql",
                            "techniki internetowe" => "ti",
                            "architektura serwisów internetowych" => "asi" },
              input_html: { class: "span8", disabled: false } %>
      <%= f.input :group %>
      <%= f.input :comments, as: :text, input_html: { class: "span8" }  %>
      <%= f.input :uid %>
      <div class="form-actions">
        <%= f.button :submit, :class => 'btn-primary' %>
        <%= link_to t('.cancel', :default => t("helpers.links.cancel")),
                    students_path, :class => 'btn' %>
      </div>
    <% end %>

Do poprawy pozostało jeszcze w widokach: zamiana *presences* na
*presences_list*, pole *comments* zamienić z *text field* na *text area*,
wybór nazwy grupy zamienić z *text field* na *collection select* itp.


## Google Gauges na stronie głównej

Strona główna z listą obecności z wygenerowanego rusztowania
pozostawia wiele do życzenia…
dlatego spróbujemy czegoś niesztampowego. Użyjemy
[Gauges](https://developers.google.com/chart/interactive/docs/gallery/gauge)
z [Google Chart Tools](https://developers.google.com/chart/).

{%= image_tag "/images/gauges-2013.png", :alt => "[Lista obecności, 12/13]" %}

Zaczniemy od wygenerowania nowego kontrolera z metodą index:

    :::bash
    rails g controller gauges index





## TODO: Samo życie

Zapomniałem o linkach do repozytoriów z projektami na Githubie.
Brakuje też bieżącego rankingu.

Aha, jeszcze dodałbym rok i semestr: zima, lato.

1\. Poprawki w modelu:

    :::ruby app/models/student.rb
    field :repositories, type: String

2\. Poprawki w szablonie formularza:

    :::rhtml app/views/students/_form.html.erb
    <%= f.input :repositories, :input_html => { class: "span10" } %>

3\. Poprawki w szablonie widoku:

    :::rhtml app/views/students/show.html.erb
      <div class="attribute">
        <span class="name">Repo URL:</span>
        <span class="value uri"><%= @student.repositories %></span>
      </div>

*Pytanie:* Czy link do repozytorium wstawić do elementu anchor (a)?
Argumenty za? przeciw?

Gotowe. Można żyć bez migracji. Odjazd!


## Zmiany w widoku New

Musimy tylko przerobić link *Back* na przycisk.

    :::rhtml app/views/students/show.html.erb
    <div class="links">
      <%= link_to 'Back', students_path, class: "btn primary" %>
    </div>


## Usuwanie danych

Tak jak to było obiecane, dodamy widok *admin*, gdzie będzie można
usunąć dane studenta z bazy.

Routing:

    :::ruby config/routes.rb
    resources :students do
      put 'not_present', :on => :member
      get 'admin', :on => :collection
    end

Kontroler:

    :::ruby app/controllers/students_controller.rb
    # GET /students/admin
    def admin
      @students = Student.all
    end

    def destroy
      @student = Student.find(params[:id])
      @student.destroy

      respond_to do |format|
        format.html { redirect_to admin_students_url, notice: 'Student was successfully destroyed' }
        format.json { head :no_content }
      end
    end

Widok:

    :::html app/views/students/admin.html.erb
    <h1>Admin page</h1>

    <% @students.each do |student| %>
    <article class="delete">
      <div class="student clearfix">
        <div class="link">
          <%= link_to '✖ Destroy', student, confirm: 'Are you sure?',
                class: "btn danger small", method: :delete %>
        </div>
        <% group = student.group %>
        <div class="full-name"><%= link_to student.full_name, student, class: group, target: "_new" %></div>
        <div class="absences"><%= bullets(student.absences) %></div>
      </div>
    </article>
    <% end %>


## Wyszukiwanie grup studentów

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