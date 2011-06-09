# „Blog” na dwóch modelach

Na przykładzie aplikacji „Blog” przyjrzymy się typowym zadaniom
pojawiającym się w trakcie dodawania drugiego modelu.

Kod do pobrania z repozytorium *public_git/blog* (albo *dydaktyka/rails4-blog*).

Zaczniemy od powtórki tego co było w rozdziale „Fortunka v1.0”.
Tym razem bez dodatków – paginacji, tagów, itp.

Oto plik *Gemfile* aplikacji:

    :::ruby Gemfile
    gem 'rails', '3.0.6'
    gem 'sqlite3'
    gem 'responders'
    gem 'simple_form'

    group :development do
      gem 'nifty-generators'
      gem 'faker'
      gem 'populator'
      gem 'jquery-rails'  # Rails 3.1 jest już w wersji beta1
    end

Budowę bloga zaczniemy od utworzenia modelu *Post*
z polami *title* i *content*. Następnie dodamy model
*Comment* z polami *name* i *content*.

Podsumowując, aplikacja „Blog” będzie się składać z dwóch modelów
powiązanych relacją jeden do wielu:

* *post* has many *comments*
* *comment* belongs to *post*


## The application setup

Jak zwykle po utworzeniu rusztowania aplikacji
usuwamy pliki *README* oraz *public/index.html*:

    rails new two_models
    cd two_models
    rm README public/index.html

Następnie podmieniamy kod *Gemfile*.

Instalujemy lokalnie gemy, przechodzimy na *jQuery*,
uaktywniamy *responders* i instalujemy *simple form*:

    bundle install --path=.bundle/gems
    rails generate jquery:install
    rails generate responders:install
    rails generate simple_form:install

Oczywiście będziemy korzystać z metod pomocniczych R. Batesa
z gemu *nifty-generators*:

    rails g nifty:layout

Ale nie będziemy korzystać metod pomocniczych dla formularzy:

    rm app/helpers/error_messages_helper.rb

Zamiast nich użyjemy gemu *simple_form*, który ma wbudowane *errorr messages*.

Ostatnia uwaga. Jak pokazuje przykład Fortunki, najprawdopodobniej
będziemy potrzebować następujących szablonów:

    views/
    |-- comments
    |   |-- new.html.erb
    |   |-- _comment.html.erb
    |   `-- _form.html.erb
    |-- posts
    |   |-- index.html.erb
    |   |-- new.html.erb
    |   |-- edit.html.erb
    |   |-- show.html.erb
    |   |-- _post.html.erb
    |   `-- _form.html.erb
    `-- layouts
        `-- application.html.erb


# Model *Post*

Skorzystamy z generatora:

    rails g scaffold post title:string content:text
    rake db:migrate

i zmienimy routing:

    :::ruby
    resources :posts
    root :to => "posts#index"

Dodamy trochę danych do bazy:

    :::ruby db/seeds.rb
    humorists = File.readlines(Rails.root.join('db', 'humorists.u8'), "\n%\n")
    humorists.map do |p|
      Post.create :content => p[0..-4], :title => Populator.words(2..5)
    end

W szablonie *index.html.erb* zamienimy element *table* na *article*.

W szablonie *_form.html.erb* użyjemy metody pomocniczej *simple_form_for*:

    :::ruby
    <%= simple_form_for(@post) do |f| %>
      <%= f.error_notification %>
      <div class="inputs">
        <%= f.input :title, :input_html => {:size => 60} %>
        <%= f.input :content, :input_html => {:rows => 4, :cols => 60} %>
      </div>
      <div class="actions"><%= f.button :submit %></div>
    <% end %>


## Ładniejsze formularze z *simple_form*

Poprawimy nieco domyślny wygląd formularza.

Zaczniemy od konfiguracji generowanych elementów formularza:

    :::ruby config/initializers/simple_form.rb
    config.error_tag = :div

Ustawimy inne marginesy, zwiększymy domyślną wielkość fontu:

    :::css public/stylesheets/simple_form.css
    body {
      background-color: #7BA1A4;
      font-family: Verdana, Helvetica, Arial;
      font-size: 18px;
    }

    input[type="text"], textarea {
      font: inherit;
      font-size: 100%;
    }
    label {
      display: block;
      margin: 0.5em 0 0.25em 0;
    }
    .error {
      margin: 0.25em 0;
      font-size: 80%;
      color: #FF0051;
    }
    .actions {
      margin: 1.0em 0;
    }

Na koniec, dodajemy powyższy arkusz css do layoutu aplikacji:

    :::html_rails app/views/layouts/application.html.erb
    <%= stylesheet_link_tag "application", "simple_form" %>


## Refaktoryzacja widoku *post#index*

Wycinamy pętlę z pliku *index.html.erb*, zastępując ją
szablonem częściowym:

    :::html_rails app/views/posts/index.html.erb
    <%= render :partial => 'post', :collection => @posts %>

Z wyciętego kodu tworzymy szablon częściowy *_post.html.erb*:

    :::html_rails app/views/posts/_post.html.erb
    <article>
      <h4><%= post.title %></h4>
      <div><%= post.content %></div>
      <div class="links">
        <%= link_to 'Show', post %> |
        <%= link_to 'Edit', edit_post_path(post) %> |
        <%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete %>
       </div>
    </article>


# Model Comment

Generujemy model, następnie migrujemy:

    rails g resource comment post:references content:text
    rake db:migrate

Zagnieżdzamy zasoby:

    :::ruby config/routes.rb
    Blog::Application.routes.draw do
      resources :posts do
        resources :comments
      end
      root :to => "posts#index"
    end

i sprawdzamy routing:

    rake routes

Dopisujemy do modelu *Post* powiązanie:

    :::ruby app/models/post.rb
    has_many :comments, :dependent => :destroy

Drugą część powiązania w modelu *Comment*:

    :::ruby app/models/comment.rb
    belongs_to :post

dopisał generator.


## Kontroler dla komentarzy

Na razie napiszemy tylko metodę *create*:

    :::ruby app/controllers/comments_controller.rb
    class CommentsController < ApplicationController
      before_filter do
        @post = Post.find(params[:post_id])
      end

      def create
        @comment = @post.comments.build(params[:comment])
        @comment.save
        respond_with(@post, @comment, :location => @post)
      end
    end

Czy w powyższym kodzie można się obejść bez *before_filter*?


## Poprawki w widoku *post\#show*

Komentarze dla konkretnego postu będziemy
tworzyć i wyświetlać w widoku show.
Zaczniemy od takiego kodu renderujacego listę komentarzy:

    :::ruby app/views/post/show.html.erb
    <% if @post.comments.any? %>
      <h3>Comments</h3>
      <% @post.comments.each do |comment| %>
       <div class="comment">
         <%= comment.content %>
       </div>
       <p>
         <%= link_to "Delete", [@post, comment], :confirm => 'Are you sure?', :method => :delete %>
       </p>
      <% end %>
    <% end %>

Poniżej (a może powyżej?) dopiszemy kod z formularzem dla nowego
komentarza:

    :::ruby app/views/post/show.html.erb
    <h3>Add new comment</h3>
    <%= simple_form_for [@post, @post.comments.build] do |f| %>
      <div class="inputs">
        <%= f.input :content, :input_html => {:rows => 4, :cols => 60} %>
      </div>
      <div class="actions">
        <%= f.button :submit %>
      </div>
    <% end %>


## Walidacja komentarzy

Dodajemy walidację do modelu. Dla odmiany zamiast *presence*
sprawdzamy czy wpisany tekst zawiera co najmniej cztery znaki:

    :::ruby app/models/comment.rb
    validates :content, :length => { :minimum => 4 }

Sprawdzamy jak to działa próbując utworzyć „pusty” komentarz.
Oto rezultat:

    Template is missing
    Missing template comments/new with
    {
      :handlers=>[:erb, :rjs, :builder, :rhtml, :rxml],
      :formats=>[:html],
      :locale=>[:en, :en]
    } in view paths "/home/.../blog/app/views"

Rails daje nam znać, że brakuje szablonu. Taki
szablon powinien wystarczyć aby pozbyć się tego błędu:

    :::html_rails app/views/comments/new.html.erb
    <% title "New comment" %>
    <%= render :partial => 'form' %>
    <p class="links clear"><%= link_to 'Back', @comment.post %></p>

Oczywiście musimy jeszcze utworzyć szablon częściowy *comments/_form.html.rb*.


## Refaktoryzacja widoku *posts\#show*

Z szablonu *post/show.html.erb* wycinamy formularz dla komentarzy
(kod pod nagłówkiem **Add new comment**) i zastępujemy
go szablonem częściowym:

    :::html_rails
    <%= render :partial => 'comments/form' %>

Szablon częściowy *comments/_form.html.erb* tworzymy z wyciętego kodu:

    :::html_rails app/views/comments/_form.html.erb
    <%= simple_form_for [@post, @comment] do |f| %>
      <div class="inputs">
        <%= f.input :content, :input_html => {:rows => 4, :cols => 60} %>
      </div>
      <div class="actions">
        <%= f.button :submit %>
      </div>
    <% end %>

W kodzie powyżej jest nowa zmienna *@comment* –
musimy ją zdefiniować. Definiujemy ją w metodzie *show*:

    :::ruby app/controllers/posts_controller.rb
    def show
      @post = Post.find(params[:id])
      @comment = Comment.new
      respond_with(@post)
    end

### To jeszcze nie koniec czyszczenia kodu

Przeniesiemy listę komentarzy z szablonu *posts/show.html.erb*
do widoku częściowego *comments/_comment.html.erb*.
Teraz kod dotyczący komentarzy będzie w katalogu *comments*.

Wycinamy całą pętlę (kod pod nagłówkiem **Comments**) i wklejamy
ją do szablonu częściowego *comments/_comment.html.erb*:

    :::html_rails app/views/comments/_comment.html.erb
    <div class="comment">
      <%= comment.content %>
    </div>
    <p>
      <%= link_to "Delete", [@post, comment], :confirm => 'Are you sure?', :method => :delete %>
    </p>

Zamiast wyciętego kodu użyjemy dopiero co utworzonego
szablonu częściowego::

    :::ruby app/views/post/show.html.erb
    <%= render :partial => 'comments/comment', :collection => @post.comments %>


### Rezultat

Oto jak po tych zmianach wygląda szablon *post\#show.html.erb*:

    :::html_rails app/views/posts/show.html.erb
    <h2><%= @post.title %></h2>
    <article>
      <%= @post.content %>
    </article>
    <div class="links">
      <%= link_to 'Edit', edit_post_path(@post) %> |
      <%= link_to 'Back', posts_path %>
    </div>

    <% if @post.comments.any? %>
      <h3>Comments</h3>
      <%= render :partial => 'comments/comment', :collection => @post.comments %>
    <% end %>
    <h3>Add new comment</h3>
    <%= render :partial => 'comments/form' %>


## Usuwanie komentarzy

Na tym etapie pisania kodu, kliknięcie *Delete* powoduje wypisanie
takiego komunikatu:

    Unknown action
    The action 'destroy' could not be found for CommentsController

Oznacza to, że jest do napisania metoda *destroy*. Oto jej kod:

    :::ruby app/controllers/comments_controller
    def destroy
      @comment = @post.comments.find(params[:id])
      @comment.destroy
      respond_with(@post, @comment, :location => @post)
    end

Komentarz do usunięcia wyszukujemy między komentarzami
postu do którego należy usuwany komentarz.

Taki kod też by zadziałał:

    :::ruby
    @comment = Comment.find(params[:id])

Ale nie jest to dobry pomysł. Dlaczego?


## Zawiązujemy luźne końce(?)

W zasadzie należałoby jeszcze dodać edycję komentarzy.  Ale nie
będziemy tego robić, ponieważ takie rzeczy robiliśmy w „Fortunce v1.0”.


# Coś prostego na koniec + dwa linki

Dopisać logowanie via *authenticate_or_request_with_http_basic* tak jak to jest
opisane w samouczku [Getting Started with Rails](http://edgeguides.rubyonrails.org/getting_started.html).

[Blog w mongo](http://asciicasts.com/episodes/238-mongoid), zamiast w sqlite.

* Zajaxowana Fortunka: sklonować repozytorium git *hello/rails3-ajax*.
  Jak to działa? Źródło
  [Creating a 100% ajax CRUD using rails 3 and unobtrusive javascript](http://stjhimy.com/posts/7).
* [Rails3 blog w 20 minut] [rails3 blog]
