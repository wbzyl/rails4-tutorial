#### {% title "Dwa modele" %}

# Dwa modele

Na przykładzie aplikacji „2models* przyjrzymy się typowym problemom
pojawiającym się w trakcie dodawania drugiego modelu.

Będziemy korzystać z gemu [responders](https://github.com/plataformatec/responders).
Gem ten zawiera generator *responders_controller* który tworzy rusztowanie
z blokami *respond_with* zamiast zwyczajowych *respond_to*.
Według autorów tego gemu takie podejście **dry up your
application**.

Rusztowanie dla drugiego modelu utworzymy „ręcznie” wzorując się na
kodzie wygenerowanym przez *responders_controller*.

Skorzystamy też z responderów: collection, flash i http_cache
(dlaczego? co one oferują?).

Zaczniemy od utworzenia modelu *Task* z nazwami zadań nad którymi
pracujemy. Do każdego zadania będziemy dopisywać *Todo*, rzeczy do
zrobienia, które pojawiają się w trakcie realizacji konkretnego
zadania.

Podsumowując, na aplikację „2models” składają się modele:

* *Task* – has many *todos*
* *Todo* – belongs to *task*


## The application setup

Tworzymy rusztowanie aplikacji, usuwamy pliki *README* oraz *public/index.html*.

    rails new two_models
    cd two_models
    rm README public/index.html

Podmieniamy kod *Gemfile* na:

    :::ruby
    source 'http://rubygems.org'

    gem 'rails'  #, '3.0.3'
    gem 'sqlite3-ruby', :require => 'sqlite3'

    gem 'thin'
    gem 'responders', :git => 'git://github.com/plataformatec/responders.git'
    group :development, :test do
      gem 'wirble'
      gem 'hirb'
      gem 'nifty-generators'
      gem 'jquery-rails'
    end

Instalujemy gemy i przechodzimy na *jQuery*:

    bundle install
    rails generate jquery:install

Uaktywniamy *responders*:

    rails generate responders:install
       create  lib/application_responder.rb
      prepend  app/controllers/application_controller.rb
       inject  app/controllers/application_controller.rb
       create  config/locales/responders.en.yml

Dodajemy katalog *lib* do autloload paths:

    :::ruby
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)

Uaktywniamy *Responders::CollectionResponder* odkomentowując wiersz
w pliku *lib/application_responder.rb*:

    # Uncomment this responder if you want your resources to redirect to the collection
    # path (index action) instead of the resource path for POST/PUT/DELETE requests.
    include Responders::CollectionResponder

Dlaczego to robimy? Odpowiedź w komentarzu powyżej.

Następnie korzystamy z metod pomocniczych nifty layout:

    rails g nifty:layout
     conflict  app/views/layouts/application.html.erb
        force  app/views/layouts/application.html.erb
       create  public/stylesheets/application.css
       create  app/helpers/layout_helper.rb
       create  app/helpers/error_messages_helper.rb

Ale nie będziemy korzystać z metod pomocniczych dla formularzy:

    rm app/helpers/error_messages_helper.rb


# Model *Task*

Korzystamy z generatorów:

    rails g model task name:string
    rake db:migrate
    rails g responders_controller task

Dopisujemy do routingu:

    :::ruby
    resources :tasks
    root :to => "tasks#index"

Dopisujemy nieco kodu do szablonów, *index.html.erb*:

    :::ruby
    <table>
      <tr>
        <th>Nazwa</th>
        ...
      <tr>
        <td><%= task.name %></td>
        ...

*_form.html.erb*:

    :::ruby
    <%= f.label :name %><%= f.text_field :name %>

**Uwaga:** Powinniśmy oba elementy otoczyć elementem *p*.
Niestety, railsowy *FormBuilder* nie widzi akapitu
otaczającego oba elementy i wypadku błędów walidacji
przenosi oba elementy poza akapit, zostawiając za sobą
pusty element *p*.

*show.html.erb*:

    :::ruby
    <h2><%= @task.name %></h2>

W pliku *db/seed.rb* dopisujemy kilka zadań:

    :::ruby
    Task.create(:name => 'Ajax')
    Task.create(:name => 'I18N')
    Task.create(:name => 'FormBuilder')
    Task.create(:name => 'Responders')

Zadania te zapisujemy w bazie korzystając z zadania rake:

    :::ruby
    rake db:seed

Na koniec, przeglądamy kod wygenerowanego kontrolera.


## Żądania XML, JSON, JS…

Dodajemy obsługę żądań XML, JSON, JS:

    :::ruby app/controllers/application_controller.rb
    respond_to :html, :xml, :json, :js

Przykłady takich żądań umieściłem w pliku *README* aplikacji
**rails4-2models**.


## Zmieniamy UI dla modelu Task

Do widoku *index* przenosimy formularz do tworzenia nowych zadań.

Aby, formularz nie generował błędu musimy dopisać
jeden wiersz w kodzie metody *index*:

    :::ruby
    def index
      @tasks = Task.all
      @task = Task.new
      respond_with(@tasks)
    end

Uaktualnianie tasks pozostawiamy w widoku *edit*.

W następnym etapie dodamy model *Todo*. Nowe todo będziemy dodawać na
stronie *tasks/show*. Dlatego nie ruszamy kodu metody *show*.

Sprawdzamy jak to działa, notujemy wszystkie rzeczy wymagajace
poprawek.


## Walidacja

Dodajemy walidację do modelu:

    :::ruby
    validates :name, :presence => true
    validates :name, :length => { :minimum => 4 }

Sprawdzamy jak to działa próbując utworzyć kilka „pustych” tasks.

Korzystając zrozszerzenia Firebug podglądamy żądania i odpowiedzi HTTP
kiedy wykonujemy operacje CRUD na modelu.


## Refaktoryzacja szablonów

Z kodu szablonu *tasks\#index* wydzielamy szablon częściowy
*_task.html.erb*:

    :::rhtml
    <tr>
      <td><%= task.name %></td>
      <td><%= link_to 'Show', task_path(task) %></td>
      <td><%= link_to 'Edit', edit_task_path(task) %></td>
      <td><%= link_to 'Destroy', task, :confirm => 'Are you sure?', :method => :delete %></td>
    </tr>

którym zastępujemy pętlę wypisującą wszystkie zadania
w szablonie *index.html.erb*:

    :::rhtml
    <table>
      <tr>
        <th>Nazwa</th>
        <th></th>
        <th></th>
        <th></th>
      </tr>
      <%= render @tasks %>
    </table>

Korzystamy z konwencji nazewniczej *@tasks – task* oraz domyślnej pętli.


# Model Todo

Modelu *Todo* użyjemy go do zapamiętywania listy rzeczy do
zrobienia dla zadań.

Formularz dla nowych todo umieścimy na stronie **task\#show**.
Tutaj też wypiszemy wszystkie *todos* powiązane z wyświetlanym
*task* oraz dodamy linki do *todo#edit* oraz *todo#destroy*.

Niewalidujące się todo będziemy poprawiać na stronie **todo\#edit**.

Dlaczego taki UI?

Zaczynamy tak jak zwykle, od wygenerowania modelu i migracji:

    rails generate model todo name:string task:references  # liczba pojedyncza
    rake db:migrate

Póki pamiętamy dopisujemy do modelu *Task* drugą część powiązania:

    has_many :todos


## Życie bez scaffoldingu

Od tego miejsca będziemy postępować inaczej.
Wygenerujemy **pusty** kontroler dla zadań:

    rails generate controller todos new edit               # liczba mnoga

a resztę kodu napiszemy samodzielnie.

Zaczynamy od zmiany routingu na:

    :::ruby routes.rb
    resources :tasks do
      resources :todos
    end
    root :to => "tasks#index"

I podglądamy jak on wygląda:

    rake routes


## todo\#new i todo\#index wędrują do tasks\#show

Wzorując się na szablonie *tasks\#_form* dopisujemy do szablonu
**task\#show** formularz dla *todo*:

    :::rhtml
    <h3>New todo</h3>
    <%= form_for([@task, @todo]) do |f| %>
      <% if @todo.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@todo.errors.count, "error") %> prohibited this todo from being saved</h2>
          <p>There were problems with the following fields:</p>
          <ul>
          <% @todo.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>
      <p><%= f.label :name %><%= f.text_field :name %></p>
      <div class="actions">
        <%= f.submit %>
      </div>
    <% end %>

oraz szablon generujący listę todo składających się na dane task:

    :::rhtml
    <% if @task.todos.any? %>
    <h2>Listing todos</h2>
    <ol>
      <% @task.todos.each do |todo| %>
        <li><%= todo.name %></li>
      <% end %>
    </ol>
    <% end %>

Do metody *show* kontrolera *TasksController* musimy dopisać jeden wiersz kodu:

    :::ruby
    def show
      @task = Task.find(params[:id])
      @todo = Todo.new                # NEW
      respond_with(@task)
    end

Dlaczego?


## Walidacja Todo

Dodajemy walidację do modelu:

    :::ruby
    validates :name, :presence => true
    validates :name, :length => { :minimum => 4 }

Na pewno będziemy chcieli zmienić HTML generowany dla niewalidujących
się todo. Dlaczego?

Co będziemy zmieniać oraz przykład jtz opisano
w [Displaying Validation Errors in the View](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html#displaying-validation-errors-in-the-view).


## Oprogramowujemy przycisk *Create Todo*

Kliknięcie przycisku *Create Todo* daje błąd, ponieważ
nie ma kodu który obsłuży */tasks/:id/todos*.
Polecenie *rake routes* pokazuje, że:

    task_todos POST /tasks/:task_id/todos(.:format) {:action=>"create", :controller=>"todos"}

Oznacza to, że powinniśmy napisać *todos#create*:

    :::ruby
    def create
      @task = Task.find(params[:task_id])
      @todo = @task.todos.build(params[:todo])
      @todo.save
      respond_with(@task, @todo, :location => task_url(@task))
    end

**Uwaga:** argumentami *respond_with* są *@task* i *@todo*, a nie
jak to jest w wypadku *link_to*, tablica **[@task, @todo]**.


### Podwojone flash messages

Usuwamy kod wypisujący wiadomości flash z widoku *tasks\#show*.


## CONT.

W widoku *tasks\#show* dodajemy linki do usuwania i edycji todo:

    :::rhtml
    <li>
      <%= todo.name %> (<%= link_to 'Edit', edit_task_todo_path(@task, todo) %> |
      <%= link_to 'Destroy', [@task, todo], :confirm => 'Are you sure?', :method => :delete %>)
    </li>

Aby linki dzialały, w kontrolerze *todo\#edit* dopisujemy:

    :::ruby
    def edit
      @task = Task.find(params[:task_id])
      @todo = @task.todos.find(params[:id])
    end

    def update
      @task = Task.find(params[:task_id])
      @todo = @task.todos.find(params[:id])
      @todo.update_attributes(params[:todo])
      respond_with(@task, @todo, :location => task_url(@task))
    end

    def destroy
      @task = Task.find(params[:task_id])
      @todo = @task.todos.find(params[:id])
      @todo.destroy
      respond_with(@task, @todo, :location => task_url(@task))
    end

Edycja nie działa – brak szablonu.

Najwyższa pora na trochę refaktoryzacji.


## Refaktoryzacja widoku *tasks\#show*

Tworzymy dwa widoki częściowe w widoku *tasks\#show*:

    :::rhtml
    <h2><%= @task.name %></h2>
    <%= link_to 'Edit', edit_task_path(@task) %> |
    <%= link_to 'Back', tasks_path %>

    <% if @task.todos.any? %>
    <h2>Listing todos</h2>
    <ol>
       <%= render @task.todos %>
    </ol>
    <% end %>

    <h3>New Todo</h3>
    <%= render 'todos/form' %>

Drugi szablon częściowy *todos/_form.html.erb* jest prawie taki sam
jak szablon dla formularza dla modelu *Task*::

    :::rhtml
    <%= form_for([@task, @todo]) do |f| %>
      <% if @todo.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@todo.errors.count, "error") %> prohibited this todo from being saved</h2>
          <p>There were problems with the following fields:</p>
          <ul>
          <% @todo.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>
      <p><%= f.label :name %><%= f.text_field :name %></p>
      <div class="actions">
        <%= f.submit %>
      </div>
    <% end %>

Szablon częściowy *todo/_todo.html.erb* zastępuje pętlę po *todo*:

    :::rhtml
    <li>
      <%= todo.name %>
      (<%= link_to 'Edit', edit_task_todo_path(@task, todo) %> |
       <%= link_to 'Destroy', [@task, todo], :confirm => 'Are you sure?', :method => :delete %>)
    </li>


## Refaktoryzacja obu kontrolerów

Dopisujemy do *TodosController*:

    :::ruby
    before_filter do
      @task = Task.find(params[:task_id])
    end

oraz do *TasksController*:

    :::ruby
    before_filter :only => [:show, :edit, :update, :destroy] do
      @task = Task.find(params[:id])
    end

i usuwamy z metod zbędny kod.


## Brakujący szablon *todos\#edit*

Coś takiego powinno wystarczyć(?):

    :::rhtml
    <h1>Editing todo</h1>
    <%= render 'form' %>
    <p><%= link_to 'Back', task_path(@task) %></p>


## Brakujący szablon dla todos\#new

Oto on. Ale czy jest potrzebny?

    :::rhtml
    <h1>New todo</h1>
    <%= render 'form' %>
    <p><%= link_to 'Back', task_path(@task) %></p>


## Ostatnie poprawki w kodzie

W pliku *lib/application_reponder.rb* usuwamy wiersz:

    :::ruby
    include Responders::CollectionResponder

W kontolerach dopisujemy, *tasks_controller.rb*:

    :::ruby
    responders :flash, :http_cache, :collection

oraz w *todo_controller.rb*:

    :::ruby
    responders :flash, :http_cache

Po tych zmianach kod klasy *TodosController* jest taki:

    :::ruby
    class TodosController < ApplicationController

      responders :flash, :http_cache

      before_filter do
        @task = Task.find(params[:task_id])
      end

      def edit
        @todo = @task.todos.find(params[:id])
      end

      def update
        @todo = @task.todos.find(params[:id])
        @todo.update_attributes(params[:todo])
        respond_with(@task, @todo, :location => task_url(@task))
      end

      def create
        @todo = @task.todos.build(params[:todo])
        @todo.save
        respond_with(@task, @todo, :location => task_url(@task))
      end

      def destroy
        @todo = @task.todos.find(params[:id])
        @todo.destroy
        respond_with(@task, @todo, :location => task_url(@task))
      end

    end

Wydaje się, że kod jest naprawdę DRY!
