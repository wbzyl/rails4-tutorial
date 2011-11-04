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


# Lista obecności

Prosta aplikacja implementująca CRUD dla listy obecności studentów.


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

    mongoimport -d lista_obecnosci_development -c students --headerline --type csv asi2011.csv

Fragment pliku CSV z nagłówkiem:

    last_name,first_name,id_number,course
    "Nowak","Jan",123456,"Algorytmy i struktury danych"
    "Kowalski","Łukasz",789012,"Aplikacje internetowe i bazy danych"

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
            console.log(clicked_element);
            clicked_element.html('☻');
            //console.log(clicked_element.parent().find('a:eq(0)'));
            var link_element = clicked_element.parent().find('a:eq(0)');
            // url = /students/4eb2f22a329855e103cdcfd0
            var date = new Date();
            var absent = (date.getMonth() + 1) + '-' + date.getDate();
            $.ajax({
              url: link_element.attr('href'),
              type: 'PUT',
              data: { absent: absent },
              success: function(data) {
                console.log(data);
              }
            });
          };
          event.stopPropagation();
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


# OmniAuth v1.0




## Różny misz masz…

* K. Seguin, [The MongoDB Collection](http://mongly.com/)
* K. Seguin, [Blog](http://openmymind.net/)


## TODO

W aplikacji jest zaszyty format daty nieobecności:

    miesiąc-dzień

Do poprawki.
