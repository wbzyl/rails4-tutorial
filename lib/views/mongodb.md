#### {% title "Mongoid + OmniAuth via GitHub" %}

☸ Mongo links:

* Ryan Bates, [Mongoid](http://railscasts.com/episodes/238-mongoid?view=asciicast) – asciicast
* Durran Jordan, [Mongoid](http://mongoid.org/docs.html) – dokumentacja gemu
* Karl Seguin.
  - [The MongoDB Interactive Tutorial](http://tutorial.mongly.com/tutorial/index)
  - [MongoDB Geospatial Interactive Tutorial](http://tutorial.mongly.com/geo/index)
  - [The Little MongoDB Book](http://openmymind.net/mongodb.pdf)

☸ Formtastic:

* [Github Home](https://github.com/justinfrench/formtastic)
* [Flexible Formtastic styling with Sass](https://github.com/activestylus/formtastic-sass/blob/master/_formtastic_base.sass)
  – not longer supported
* [Formtastic without ActiveRecord](http://dondoh.tumblr.com/post/4142258573/formtastic-without-activerecord)

☸ OmniAuth:

* [Demo App](http://www.omniauth.org/), [kod aplikacji](https://github.com/intridea/omniauth.org)
* [Github Home](https://github.com/intridea/omniauth)
* [Wiki](https://github.com/intridea/omniauth/wiki)
* [OmniAuth Github strategy](https://github.com/intridea/omniauth-github)
* [OmniAuth Identity strategy](https://github.com/intridea/omniauth-identity)
* [Rails 3.1 with Mongoid and OmniAuth](https://github.com/railsapps/rails3-mongoid-omniauth/wiki/Tutorial)
  – na razie nieaktualne

☸ Hosting:

* [Cloud Hosted MongoDB](https://mongolab.com/home)
  ([{blog: mongolab}](http://blog.mongolab.com/))
* [Node.js + MongoDB = Love: Guest Post from MongoLab](http://joyeur.com/2011/10/26/node-js-mongodb-love-guest-post-from-mongolab/?utm_source=NoSQL+Weekly+Newsletter&utm_campaign=4ed79d28a1-NoSQL_Weekly_Issue_49_November_3_2011&utm_medium=email)

☺☕♥ ⟵ kody takich znaczków odszuka za nas [Shapecatcher](http://shapecatcher.com/)
Benjamina Milde. My musimy je naszkicować.


# Dziennik lekcyjny

Przykładowa aplikacja CRUD listy obecności studentów.  W aplikacji
dane będziemy przechowywać w bazie MongoDB.  Skorzystamy z gemów
Mongoid i OmniAuth ze strategią *github*.

1\. Tak jak to opisano
{%= link_to "Wyszukiwanie ElasticSearch", "/rails4/elasticsearch" %}
tworzymy rusztowanie aplikacji korzystające z framweorka Bootstrap Twitter.

    :::bash terminal
    rails new dziennik-lekcyjny --skip-bundle --skip-active-record --skip-test-unit
    rm dziennik-lekcyjny/public/index.html

Dopisujemy gemy do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'bootstrap-sass', group: :assets

    gem 'formtastic'
    gem 'formtastic-bootstrap'

    gem 'omniauth'
    gem 'omniauth-github'

    gem 'mongoid'
    gem 'bson_ext'

    gem 'jbuilder'

i instalujemy je lokalnie:

    :::bash terminal
    cd dziennik-lekcyjny
    bundle install --path=$HOME/.gems --binstubs

**Uwaga:** Gem OmniAuth zostanie opisany później.

Dalej postępujemy, tak jak to opisano poprzednio.
Zmienimy tylko paletę kolorów:

* niebieski: \#7CD7FF
* żółty: \#FFD91C
* pomarańczowy: \#FD6300
* brązowy: \#94190D
* fioletowy: \#451327 = rgb(69, 19, 39)

Tworzymy szablon aplikacji wzorowany na *ContainerApp*
z Twitter Bootstrap, dopisujemy metode *title* klasy
*ApplicationHelper*:

* [application.html.erb](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/views/layouts/application.html.erb)
* [application_helper.erb](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/helpers/application_helper.rb)


2\. Dokończenie instalacji:

    :::bash terminal
    rails g mongoid:config
    rails g formtastic:install

Oto wygenerowany plik konfiguracyjny Mongoid:

    :::yaml config/mongoid.yml
    development:
      host: localhost
      database: dziennik_lekcyjny_development

    test:
      host: localhost
      database: dziennik_lekcyjny_test

    # set these environment variables on your prod server
    production:
      host: localhost
      database: dziennik_lekcyjny
      # host: <%= ENV['MONGOID_HOST'] %>
      # port: <%= ENV['MONGOID_PORT'] %>
      # username: <%= ENV['MONGOID_USERNAME'] %>
      # password: <%= ENV['MONGOID_PASSWORD'] %>
      # database: <%= ENV['MONGOID_DATABASE'] %>
      # slaves:
      #   - host: slave1.local
      #     port: 27018
      #   - host: slave2.local
      #     port: 27019

Taki plik konfiguracyjny wymaga, aby przed uruchomieniem aplikacji w trybie
produkcyjnym były zdefiniowane w środowisku powyższe zmienne
(ale zmienne te są wykomentowane).
Oznacza to, że przed uruchomieniem aplikacji powinniśmy wykonać:

    :::bash terminal
    export MONGOID_HOST=localhost
    export MONGOID_PORT=27017
    export MONGOID_DATABASE=dziennik_lekcyjny_production

Najwygodniej jest zapisać wszystkie te polecenia w pliku,
np. o nazwie *dziennik-lekcyjny.sh*.
Teraz przed uruchomieniem aplikacji w trybie produkcyjnym wystarczy wykonać:

    :::bash
    source dziennik-lekcyjny.sh

**Uwaga**: Takie podejście jest wygodne, o ile zamierzamy wdrożyć
aplikację na Heroku. Dlaczego?

Dokończenie instalacji *formtastic* i *formtastic-bootstrap*.

Initializers:

    :::ruby config/initializers/formtastic.rb
    Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
    # Set the default text area height when input is a text. Default is 20.
    Formtastic::FormBuilder.default_text_area_height = 8

CSS (ostatnie dwa pliki dodajem przy okazji teraz):

    :::css app/assets/stylesheets/application.css
    *= require_self
    *= require formtastic-bootstrap
    *= require formtastic-form
    *= require dziennik-lekcyjny
    *= require students

**Uwaga**: Domyślnie, w trybie produkcyjnym, aplikacja korzysta ze
skopilowanych *assets*:

    :::bash
    bin/rake assets:precompile   # Compile all the assets named in config.assets.precompile

Po przejściu do trybu development, powinniśmy usunąć skopilowane pliki:

    :::bash
    bin/rake assets:clean

Jeśli tego nie zrobimy, to zmiany w plikach JavaScript i CSS nie zostaną użyte.

Importowane pliki należy dopisać do listy *config.assets.precompile*, na przykład

    :::ruby config/environments/production.rb
    # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
    config.assets.precompile += %w( dziennik-lekcyjny )

**i18n**: Dodajemy do katalogu *config/initializers* plik *mongoid.rb*
w którym wpisujemy (*i18n*):

    :::ruby config/initializers/mongoid.rb
    Mongoid.add_language("pl")

Od razu zmieniamy domyślne locale na polskie (co to znaczy?):

    :::ruby config/application.rb
    config.i18n.default_locale = :pl

Replica sets, master/slave, multiple databases – na razie
pomijamy. Sharding – też.


3\. Generujemy rusztowanie dla modelu *Student*.
Oczywiście w aplikacji *Dziennik Lekcyjny* nie może zabraknąć
atrybutów nieobecność i uwagi:

    :::bash terminal
    rails generate scaffold Student last_name:String first_name:String \
      id_number:Integer nickname:String absences:Array comments:String \
      class_name:String group:String uid:Integer
    rm app/assets/stylesheets/scaffolds.css.scss

4\. Importujemy listę studentów (otrzymaną z sekretatriatu II)
do bazy MongoDB:

    :::bash terminal
    mongoimport --drop -d dziennik_lekcyjny -c students --headerline --type csv wd.csv

Oto fragment pliku CSV z nagłówkiem:

    :::csv wd.csv
    last_name,first_name,id_number,year,semester
    "Kuszelas","Jan",123123,2011,summer
    "Klonowski","Felicjan",221321,2011,summer
    "Korolczyk","Joga",356123,2011,summer
    "Grabczyk","Simona",491231,2011,summer
    "Kamińska","Irena",556123,2011,summer
    "Jankowski","Kazimierz",628942,2011,summer

5\. Kilka uwag o robieniu kopii zapasowych danych z bazy MongoDB.

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

6\. Pozostaje uruchomić serwer WWW:

    :::bash terminal
    rails server -p 3000

i wejść na stronę z listą obecności:

    http://localhost:3000/students

Jeśli aplikacja działa, dodajemy do routingu:

    :::ruby config/routes.rb
    root :to => 'students#index'

i przechodzimy do następnego punktu.

7\. Teraz możemy dodać podstawową autentykację do aplikacji:

    :::ruby app/controllers/students_controller.rb
    http_basic_authenticate_with :name => ENV['LO_NAME'], :password => ENV['LO_PASSWORD']

„Tajne dane” dopiszemy do pliku *dziennik-lekcyjny.sh*:

    :::bash
    export LO_NAME="admin"
    export LO_PASSWORD="sekret"

Teraz przed pierwszym uruchomieniem aplikacji będziemy musieli wykonać:
do środowiska powłoki:

    :::bash terminal
    source dziennik-config.sh


## Model Student

Co to są wirtualne atrybuty?
[More on Virtual Attributes](http://railscasts.com/episodes/167-more-on-virtual-attributes?view=asciicast).

Inne podejście do tablic:

* [Array of hashes form builder](http://stackoverflow.com/questions/8887016/array-of-hashes-form-builder)
z [Mongoid + filtering result set(?)](http://mongoid.org/docs/querying/scopes.html).

Dodajemy metody getter i setter dla **wirtualnych atrybutów**
*full_name* i *absences_list* oraz ustawiamy domyślne sortowanie
rekordów:

    :::ruby app/models/student.rb
    class Student
      include Mongoid::Document
      include Mongoid::MultiParameterAttributes # zob. Formtastic FAQ

      field :last_name, type: String
      field :first_name, type: String
      field :id_number, type: Integer
      field :nickname, type: String
      field :uid, type: Integer         # uid z GitHub, http://caius.github.com/github_id/
      field :absences, type: Array
      field :comments, type: String
      field :class_name, type: String, default: "unallocated"
      field :group, type: String, default: "unallocated"

      # getter and setter
      def full_name
        [last_name, first_name].join(' ')
      end

      def full_name=(name)
        split = name.split(/\s+/, 2)
        self.last_name = split.first
        self.first_name = split.last
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

Informacje o wszystkich studentach z jednego roku zostaną umieszczone
na jednej stronie.

Dane studentów z tej samej grupy zostaną wypisane tym samym kolorem.
Na obrazku poniżej wypisne są informacje
dla studentów z trzech grup: niebieskiej, zielonej i czerwonej.

{%= image_tag "/images/dziennik-lekcyjny.png", :alt => "[dziennik lekcyjny]" %}

Kliknięcie w śmieszek po lewej stronie dopisuje do dokumentu studenta
nieobecność, przeładowuje stronę na której zostaje wypisana
pomarańczowa kropka przy nazwisku. Liczba kropek po prawej stronie nazwiska
to liczba nieobecności.

Na tej stronie prowadzący będzie mógł uaktualniać dane studenta.
Student, będzie mógł podejrzeć swoje dane oraz dopisać
coś w polu komentarze.
Usunąć dane studenta będzie mial prawo tylko Admin.
Do usuwania danych studenta przygotuję osobną stronę.

Do generowania kropek używamy metody pomocniczej *bullets*. Element
*progress* wskazuje na „progress” (w procentach) studenta,
czyli liczbę punktów zdobytych na zajęciach.

Kodowanie nowych rzeczy zaczniemy od dodania do routingu metody
*not_present*:

    :::ruby config/routes.rb
    resources :students do
      put 'not_present', :on => :member
    end

Następnie podmienimy szablon strony głównej:

    :::rhtml app/views/students/index.html.erb
    <% @students.each do |student| %>
    <article class="index">
      <div class="student clearfix">
        <div class="presence"><%= link_to '☺', not_present_student_path(student), method: :put %></div>
        <% group = student.group %>
        <div class="full-name"><%= link_to student.full_name, student, class: group, target: "_new" %></div>
        <div class="absences"><%= bullets(student.absences) %></div>
        <div class="links">
          <%= link_to '✎ Edit', edit_student_path(student), class: "btn small" %>
        </div>
      </div>
    </article>
    <% end %>

    <div class="link"><%= link_to 'New Student', new_student_path, class: "btn" %></div>

W jakim celu dodano atrybut `target:"_new"` powyżej? Podpowiedź: UI.

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

metody *today_absence*:

    :::ruby app/controllers/application_controller.rb
    helper_method :today_absence

    def today_absence
      time = Time.new
      "#{time.month}-#{time.day}"
    end

metody *not_present*:

    :::ruby app/controllers/students_controller.rb
    # PUT /students/1/not_present
    def not_present
      @student = Student.find(params[:id])
      @student.add_to_set(:absences, today_absence)
      redirect_to students_url
    end

Po zapisaniu zmian w bazie przechodzimy na stronę *show* (default?):

    :::ruby app/controllers/students_controller.rb
    # PUT /students/1
    def update
      @student = Student.find(params[:id])

      if @student.update_attributes(params[:student])
        redirect_to student_url(@student), notice: 'Student was successfully updated'
      else
        render action: "edit"
      end
    end


### Od SASSa do CSS

[2012.02.08] Połączenie Bootstrap + SASS nie było dobrym pomysłem.
Należało użyć **Bootstrap + LESS**, tak jak to opisano
w podsekcji {%= link_to "Aplikacja EST", "/elasticsearch" %}.

Wygenerowany HTML musimy jakoś wystylizować.
Konieczne poprawki dopisuję na bieżąco do plików:
*dziennik-lekcyjny.css.scss* i *students.css.scss*.

Wersje tych plików dla ostatniej wersji aplikacji można
podejrzeć na repo na GitHubie:

* [dziennik-lekcyjny.css.scss](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/assets/stylesheets/dziennik-lekcyjny.css.scss)
* [students.css.scss](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/assets/stylesheets/students.css.scss)


### Zmiany w pozostałych widokach

Zmiany w *show.html.erb*:

    :::rhtml app/views/students/show.html.erb
    <% title @student.full_name, false %>

    <article class="show">
      <h2>
        <span><%= @student.full_name %></span>
        <span class="absences"><%= @student.absences_list %></span>
      </h2>
      <div class="attribute">
        <span class="name">Nickname:</span>
        <span class="value"><%= @student.nickname %></span>
      </div>
      <div class="attribute">
        <span class="name">Id:</span>
        <span class="value"><%= @student.id_number %></span>
      </div>
      <div class="attribute">
        <span class="name">Course:</span>
        <span class="value"><%= @student.class_name %></span>
      </div>
      <div class="attribute">
        <div class="name">Comments:</div>
        <div class="value comments"><%= @student.comments %></div>
      </div>
      <div class="links">
        <%= link_to 'Back', students_path, class: "btn primary" %>
        <%= link_to 'Edit', edit_student_path(@student), class: "btn" %>
      </div>
    </article>

Zamiany w *edit.html.erb*:

    :::rhtml app/views/students/edit.html.erb
    <% title @student.full_name, false %>

    <h1>Editing student</h1>

    <%= render 'form' %>

    <div class="link">
      <%= link_to 'Back', students_path, class: "btn primary" %>
      <%= link_to 'Show', student_path(@student), class: "btn primary" %>
    </div>


## Poprawiamy wygenerowany formularz

Lista wyboru: *nieprzydzielony*, *red*, *green*, *blue* dla grup,
element *textarea* dla *comment*, oraz wirtualne atrybuty
*full_name* i *absences_list*

    :::rhtml app//views/students/_form.html.erb
    <%= semantic_form_for @student do |f| %>
      <%= f.inputs do %>
        <%= f.input :full_name, :input_html => { class: "span10", placeholder: "Nazwisko Imię" } %>
        <%= f.input :id_number, :input_html => { class: "span10" } %>
        <%= f.input :nickname, :input_html => { class: "span10" } %>
        <%= f.input :uid,
              :hint => "<a href='http://caius.github.com/github_id/'>check it here</a>".html_safe,
              :input_html => { class: "span8" } %>

        <%= f.input :absences, :input_html => { class: "span10" } %>
        <%= f.input :comments, as: :text, :input_html => { class: "span10" } %>
        <%= f.input :class_name, :as => :select,
              :collection => {"nieprzydzielony" => "unknown",
                              "języki programowania" => "jp",
                              "technologie nosql" => "nosql" },
              :input_html => { class: "span10" } %>
        <%= f.input :group,:as => :select,
              :collection => {"nieprzydzielony" => "unknown",
                              "niebieska" => "blue",
                              "zielona" => "green",
                              "czerwona" => "red"},
              :input_html => { class: "span10" } %>
      <% end %>
      <%= f.buttons do %>
        <%= f.commit_button %>
      <% end %>
    <% end %>


## Samo życie

Zapomniałem o linkach do repozytoriów z projektami na Githubie.
Brakuje też bieżącego rankingu.

Aha, jeszcze dodałbym rok i semestr: zima, lato.

1\. Poprawki w modelu:

    :::ruby app/models/student.rb
    field :repositories, type: String
    field :rank, type: Integer
    field :year, type: Integer
    field :semester, type: String

2\. Poprawki w szablonie formularza:

    :::rhtml app/views/students/_form.html.erb
    <%= f.input :rank, :input_html => { class: "span10" } %>
    <%= f.input :repositories, :input_html => { class: "span10" } %>
    <%= f.input :semester, :as => :check_boxes, :collection => { "zima" => "winter", "lato" => "summer" } %>
    <%= f.input :year, :as => :radio, :collection => ["2011", "2012"] %>

3\. Poprawki w szablonie widoku:

    :::rhtml app/views/students/show.html.erb
    <article class="show">
      <h2>
        <span id="rank"><%= progress(@student.rank) %></span><span><%= @student.full_name %></span>
        <span class="absences"><%= @student.absences_list %></span>
      </h2>
      <div class="attribute">
        <span class="name">Repo URL:</span>
        <span class="value uri"><%= @student.repositories %></span>
      </div>

Kod użytej powyżej metody pomocniczej *progress*:

    :::ruby app/helpers/students_helper.rb
    module StudentsHelper
      def progress(n)
        if n.blank?
          "\#0"
        else
          "\##{@student.rank}"
        end
      end
    end

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


# Dodajemy progress bar

Do pokazania na stronie głównej wartości atrybutu *rank* wykorzystamy
element *progress*.

Kilka uwag o tym elemencie:

* [HTML5 Please](http://html5please.us/),
  Lea Verou, [HTML5-Progress-polyfill](https://github.com/LeaVerou/HTML5-Progress-polyfill)
* [Bootstrap v2.0, from Twitter](http://markdotto.com/bs2/docs/index.html),
  [Progress bars](http://markdotto.com/bs2/docs/components.html#progress)

Na razie element ten wystylizujemy korzystając ze wskazówek z bloga
Mounir Lamour, [The HTML progress element in Firefox](http://blog.oldworld.fr/index.php?post/2011/07/The-HTML5-progress-element-in-Firefox).

Zaczniemy od dopisania widoku *index*, po elemencie *div.absences*
elementu *progress*:

    :::rhtml app/views/students/index.html.erb
    <div class="rank"><progress value='<%= student.rank/100.0 || 0.0 %>'>
       <i>Your browser does not support the progress element!</i></progress>
    </div>

Trochę SASSa [students.css.scss](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/assets/stylesheets/students.css.scss#L104)
i [formtastic-form.css.scss](https://github.com/wbzyl/dziennik-lekcyjny/blob/master/app/assets/stylesheets/formtastic-form.css.scss#L17)
oraz trochę kodu JavaScript załatwia kolorowanie postępów w nauce:

    :::js app/assets/javascripts/students.js
    $(document).ready(function() {
      $('.index progress').map(function () {
        var progress = $(this).attr('value');

        switch(true) {
        case (progress <= .4):
          $(this).addClass('ndst');
          break;
        case (progress <= .6):
          $(this).addClass('dst');
          break;
        case (progress <= .8):
          $(this).addClass('db');
          break;
        case (progress <= 1):
          $(this).addClass('bdb');
          break;
        }
      });
    });


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
      # logger.info "☻ request query parameters: #{request.query_parameters}"

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


## Dodawanie nieobecności

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


# OmniAuth + Github

Zaczynamy od zarejestowania aplikacji na [Githubie](https://github.com/account/applications).

Jeśli aplikacja będzie działać na *localhost*, rejstrujemy ją wpisując:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb
    Callback: http://localhost:3000

(Oczywiście, powyżej podajemy jakiś swój URL.)

Jeśli — na *sigma.ug.edu.pl*, to wpisujemy:

    URL:      http://wbzyl.inf.ug.edu.pl/rails4/mongodb
    Callback: http://sigma.ug.edu.pl:3000

Zamiast portu *3000* podajemy port na którym będzie działać nasza
aplikacja na Sigmie.

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

Klucze `GITHUB_KEY`, `GITHUB_SECRET` przeklikujemy ze strony
[Your OAuth Applications](https://github.com/account/applications).
do pliku *dziennik-config.sh*, który dla bezpieczeństwa
trzymam poza repozytorium:

    :::bash github.sh
     export GITHUB_KEY="11111111111111111111"
     export GITHUB_SECRET="1111111111111111111111111111111111111111"

Powyżej przyjmujemy, że

    GITHUB_KEY === Client ID
    GITHUB_SECRET === Client Secret

Teraz przed uruchomieniem aplikacji wystarczy wykonać:

    :::bash terminal
    source dziennik-config.sh

aby wartości *GITHUB_KEY*, *GITHUB_SECRET* były dostępne dla
*github-strategy*.


### To samo z *Foremanem*

Instalujemy gem [Foreman](https://github.com/ddollar/foreman),
czytamu [Introducing Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html).

Heroku, Newsletter, November 2011:

*Foreman offers a feature very similar to config vars, but for local
development. Create a .env file in the root of your app with your
local config values, for example:*

    DATABASE_URL=postgres://localhost/myapp
    SESSION_SECRET=foobarbaz

*Now when you run your app with **foreman start**, it will load these
config vars into your local environment. Be sure to add .env to your
*.gitignore* so that it does not get added to your repo.*

Zobacz też Heroku,
[Configuration and Config Vars](http://devcenter.heroku.com/articles/config-vars).


### Nginx + Passenger

Powyższe podejście nie działa jeśli aplikację uruchomimy
za pomocą *Nginx + Passenger*.

W tym przypadku postępuję tak.
Moje prywatne dane trzymam poza repozytorium
w katalogu *$HOME/.credentials*. Dane są zapisane
w formacie YAML:

    :::yaml HOME/.credentials/services.yml
    github:
      key: 11111111111111111111
      secret: 1111111111111111111111111111111111111111

Dodaję do aplikacj plik inicjujący:

    :::ruby config/initializers/github.rb
    raw_config = File.read("#{ENV['HOME']}/.credentials/services.yml")

    github = YAML.load(raw_config)['github']

    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :github, github['key'], github['secret']
    end


## Omniauth + Twitter (info, nie korzystamy)

Konfiguracja OmniAuth dla *Twittera* jest analogiczna.
Aplikację rejestrujemy [tutaj](https://dev.twitter.com/apps/new):

    URL:      http://tao.inf.ug.edu.pl
    Callback: http://localhost:3000

(Oczywiście, powyżej podajemy jakiś swój URL.)

Klucze zapisujemy w pliku *twitter.sh*, który będziemy
też trzymać poza repozytorium:

    :::bash twitter.sh
    export TWITTER_KEY="111111111111111111111"
    export TWITTER_SECRET="111111111111111111111111111111111111111111"

Do pliku konfiguracyjnego OmniAuth wklepujemy:

    :::ruby config/initializers/twitter.rb
    Rails.application.config.middleware.use OmniAuth::Builder do
      provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    end


## Generujemy kontroler dla sesji

…oczywiście skorzystamy z generatora:

    :::bash terminal
    rails generate controller Session

Dopisujemy do wygenerowanego kodu kilka metod:

    :::ruby app/controllers/sessions_controller.rb
    class SessionController < ApplicationController
      def new
        redirect_to '/auth/github'
      end

      def create
        raise request.env["omniauth.auth"].to_yaml
      end

      def destroy
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
Zob. opis routing poniżej.


## Routing

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

Teraz możemy przetestować jak to działa!
Ręcznie wpisujemy w przeglądarce następujące uri:

    http://localhost:3000/signin
    # http://localhost:3000/auth/github

Po pomyślnym zalogowaniu w metodzie *create* zgłaszany
jest wyjątek, a my widzimy stronę z **RuntimeError**.

Github zwraca tylko tyle:

    :::yaml
    ---
    provider: github
    uid: 8049
    info:
      nickname: wbzyl
      email: ...
      name: Wlodek Bzyl
      urls:
        GitHub: https://github.com/wbzyl
        Blog: !!null
    credentials:
      token: ...
      expires: false
    extra:
      raw_info:
        total_private_repos: 0
        html_url: https://github.com/wbzyl
        type: User
        location: ''
        owned_private_repos: 0
        public_repos: 76
        company: Instytut Informatyki, UG
        followers: 99
        created_at: '2008-04-21T08:24:47Z'
        email: ...
        disk_usage: ...
        avatar_url: ...
        gravatar_id: ...
        collaborators: 0
        plan:
          private_repos: 0
          space: ...
          collaborators: 0
          name: free
        public_gists: 33
        hireable: false
        following: 0
        name: Wlodek Bzyl
        login: wbzyl
        private_gists: 2
        bio: !!null
        url: https://api.github.com/users/wbzyl
        id: 8049
        blog: !!null

Dla odmiany, Twitter zwraca masę danych. Poniżej mały wyjątek:

    :::yaml
    ---
    provider: twitter
    uid: '52154495'
    info:
      nickname: wbzyl
      name: Wlodek Bzyl
      location: ''
      image: http://a3.twimg.com/profile_images/.../mondrian_normal.png
      description: ''
      urls:
        Website: http://sigma.ug.edu.pl/~wbzyl/
        Twitter: http://twitter.com/wbzyl
    credentials:
      token: ...
      secret: ...
    extra:
      access_token: !ruby/object:OAuth::AccessToken


## Tworzymy model User

Po pomyślnej autentykacji, dane użytkownika będziemy zapisywać
w kolekcji *users*:

    :::bash terminal
    rails generate model User provider:string uid:integer name:string email:string url:string

Dlaczego tak? Jaki zrobimy z tego użytek?


## Zapisujemy powyższe dane w bazie MongoDB

Dodajemy metodę do modelu *User*:

    :::ruby app/models/user.rb
    class User
      include Mongoid::Document
      field :provider, :type => String
      field :uid, :type => Integer
      field :name, :type => String
      field :email, :type => String
      field :nickname, :type => String
      field :url, :type => String

      def self.from_omniauth(auth)
        where(:provider => auth['provider'], :uid => auth['uid']).first || create_with_omniauth(auth)
      end

      def self.create_with_omniauth(auth)
        create! do |user|
          user.provider = auth["provider"]
          user.uid = auth["uid"]

          user.nickname = auth['info']['nickname']
          user.email = auth['info']['email']
          user.name = auth['info']['name']
          user.url = auth['info']['urls']['GitHub']
        end
      end
    end

Modyfikujemy metodę *create* kontrolera.
Po autentykacji na Githubie, sprawdzamy czy dane użytkownika są
już zapisane w kolekcji *users*. Jeśli nie to zapisujemy
dane pobrane z Githuba w kolekcji.

    :::ruby app/controllers/sessions_controller.rb
    def create
      user = User.from_omniauth(env["omniauth.auth"])
      session[:user_id] = user.id

      redirect_to root_url, :notice => "User #{user.name} signed in through #{user.provider}"
    end

Jeszcze raz się logujemy:

     http://localhost:3000/signin

i podglądamy log aplikacji. Na koniec sprawdzamy na konsoli co się
zapisało w kolekcji *users*:

    :::ruby
    User.count
    User.first
    User.all.each { |user| y user }


## Dodajemy widok index dla modelu User

Po co to robimy?

Korzystamy z generatora:

    :::bash
    rails g controller users index

Dodajemy *Users* do menu (dopisujemy pod "Admin"):

    :::rhtml app/views/common/_menu.html.erb
    <li><%= link_to "Admin", admin_students_path %>
    <li><%= link_to "Users", users_index_path %>

W kontrolerze dodajemy tylko metodę *index*:

    :::ruby app/controllers/users_controller.rb
    class UsersController < ApplicationController
      def index
        @users = User.all
      end
    end

Piszemy prosty widok:

    :::rhtml app/views/users/index.html.erb
    <h1>GitHub Users</h1>

    <% @users.each do |student| %>
    <article class="users">
      <div class="user">
        <div class="uid"><span class="span2">UID:</span> <%= student.uid %></div>
        <div class="name"><span class="span2">Name:</span> <%= student.name %></div>
        <div class="email"><span class="span2">Email:</span> <%= student.email %></div>
        <div class="nickname"><span class="span2">Nickname:</span> <%= student.nickname %></div>
        <div class="url"><span class="span2">URL:</span> <%= link_to student.url, student.url %></div>
      </div>
    </article>
    <% end %>

Dodajemy trochę CSS. I już!

Paginacją zajmiemy się później.


# Autoryzacja

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


# Misz masz do poczytania

* K. Seguin, [The MongoDB Collection](http://mongly.com/)
* K. Seguin, [Blog](http://openmymind.net/)
