# Autoryzacja z CanCan

<blockquote>
  <p>{%= image_tag "/images/ryan-bates.png", :alt => "[Ryan Bates]" %}</p>
  <p class="center">Ryan Bates</p>
</blockquote>

**CanCan is a simple authorization plugin that offers a lot of flexibility.**
Zamierzam to sprawdzić, dodając autoryzację do aplikacji
„Blog + Devise”.

* [Authorization with CanCan](http://railscasts.com/episodes/192-authorization-with-cancan)
  ([ASCIIcast](http://asciicasts.com/episodes/192-authorization-with-cancan))
* [CanCan](http://github.com/ryanb/cancan) –
  simple authorization for Rails.

Zaczynamy od sklonowania repozytorium:

    git clone git://sigma.ug.edu.pl/~wbzyl/rails4-blog.git

Teraz zmieniamy katalog:

    cd rails4-blog

tworzymy tzw. *tracking branch*:

    git checkout --track origin/devise

instalujemy gemy, migrujemy, zapełniamy bazę danymi testowymi:

    bundle install --path=.bundle/gems
    rake db:migrate
    rake db:seed

Dalej, tak jak to opisałem w „Autentykacja z Devise“ konfigurujemy program pocztowy.

Teraz jesteśmy w miejscu w którym zakończyliśmy
implementację autentykacji w Blogu z Devise.


### Git zwyczaje

Autoryzację będziemy implementować na gałęzi **cancan**:

    git checkout -b cancan

Na koniec instalujemy gem *CanCan*:

    :::ruby Gemfile
    gem 'cancan'

i zmieniamy tytuł aplikacji.


### I18N

Komunikaty wypisywane przez CanCan trzeba będzie kiedyś przetłumaczyć na język polski.
Wszystkie komunikaty znajdziemy w dokumentacji
[ControllerAdditions](http://rubydoc.info/github/ryanb/cancan/master/CanCan/ControllerAdditions):

    :::yaml config/locales/cancan.en.yml
    en:
      unauthorized:
        manage:
          all: "Not authorized to %{action} %{subject}!"
          user: "Not allowed to manage other user accounts!"
        update:
          project: "Not allowed to update this project!"


## Dodajemy powiązania między modelami

Ponieważ każdy użytkownik może utworzyć wiele postów (i komentarzy),
więc między *User* a *Post* (i *Comment*) mamy powiązania **jeden do wielu**:

    :::ruby
    class Post < ActiveRecord::Base
      belongs_to :user
      has_many :comments, :dependent => :destroy

    class Comment < ActiveRecord::Base
      belongs_to :user
      belongs_to :post

    class User < ActiveRecord::Base
      has_many :posts, :dependent => :destroy
      has_many :comments, :dependent => :destroy

<!--
Łatwiej nam będzie odwoływać się do migracji w notatkach:

    :::ruby config/application.rb
    config.active_record.timestamped_migrations = false
-->

Pozostaje dodać w tabelach pole *user_id:integer*:

    rails g migration add_user_id_to_post user_id:integer
    rails g migration add_user_id_to_comment user_id:integer
    rake db:migrate


## Autoryzacja na podstawie roli

Wykorzystamy gem *CanCan* do dodania trzech ról do aplikacji.
Dopuszczamy sytuację, że użytkownik może być przypisany do kilku ról.

* admin — może wszystko
* moderator — może  edytować i usuwać **każdą** fortunkę
* author — może dodawać, edytować i usuwać **swoje** fortunki
* banned – nic nie może

Będziemy korzystać z gemu *role_model*. Dlaczego? Wyjaśni się to za chwilę.

    :::ruby Gemfile
    gem 'role_model'

Więcej o „role based authorization” można poczytać na
[CanCan Wiki](http://github.com/ryanb/cancan/wiki/Role-Based-Authorization).

### Zmiany w tabeli *users*

Informację o rolach będziemy zapisywać w tabeli *users*.
W tym celu dodamy do tabeli nową kolumnę *roles_mask:integer*.

    rails g migration add_rolesmask_to_user roles_mask:integer
    rake db:migrate

Następnie w modelu *User* dopisujemy trochę kodu z README
gemu *role_model*.

    :::ruby
    class User < ActiveRecord::Base
      include RoleModel

      attr_accessible :roles

      # optionally set the integer attribute to store the roles in,
      # :roles_mask is the default
      roles_attribute :roles_mask

      # declare the valid roles -- do not change the order if you add more
      # roles later, always append them at the end!
      roles :admin, :moderator, :author, :banned

Przyjrzymy się rolom na konsoli przerabiając przykłady
z [README](http://github.com/martinrehfeld/role_model):

    rails console --sandbox

Zaczynamy od utworzenia nowego użytkownika:

    :::ruby
    u = User.new

role assignment:

    :::ruby
    u.roles = [:admin]  # ['admin'] works as well
    => [:admin]

adding roles:

    :::ruby
    u.roles << :moderator

querying roles: get all valid roles that have been declared:

    :::ruby
    User.valid_roles

retrieve all assigned roles:

    :::ruby
    u.roles # aliased to role_symbols for DeclarativeAuthorization

check for individual roles:

    :::ruby
    u.has_role? :author  # has_role? is also aliased to is?

check for multiple roles:

    :::ruby
    u.has_any_role? :author, :moderator   # has_any_role? is also aliased to is_any_of?
    u.has_all_roles? :author, :moderator  # has_all_roles? is also aliased to is?

see the internal bitmask representation (3 = 0b0011):

    :::ruby
    u.roles_mask

## Umieszczamy przykładowe dane w bazie

Zaczynamy od:

    rake db:drop
    rake db:migrate

Następnie w pliku *seed.rb* wpisujemy kilku użytkowników:

    :::ruby db/seed.rb
    User.create :email => 'matwb@ug.edu.pl',
      :password=> '123456', :password_confirmation => '123456',
      :roles => [:admin]
    User.create :email => 'renia@somewhere.com',
      :password=> '123456', :password_confirmation => '123456',
      :roles => [:moderator]
    User.create :email => 'bazylek@cats.com',
      :password=> '123456', :password_confirmation => '123456',
      :roles => [:author]
    User.create :email => 'devil@hell.com',
      :password=> '123456', :password_confirmation => '123456',
      :roles => [:banned]

    user_count = User.count

Dodajemy też sporo (197 dokładnie) postów:

    :::ruby
    humorists = File.readlines(Rails.root.join('db', 'humorists.u8'), "\n%\n")

    humorists.map do |p|
      Post.create :content => p[0..-4], :title => Populator.words(2..5), :user_id => (1 + rand(user_count))
    end

Dane z pliku *db/seeds.rb* „załadujemy” do bazy za pomocą *rake*:

    rake db:seed

Na konsoli sprawdzamy, czy coś poszło nie tak:

    :::ruby
    User.all
    Post.all
    User.find(1).has_role? :admin
    User.find(1).has_role? :banned


## Scope it out

Zanim zabierzemy się za autoryzację musimy jeszcze dopisać kod, który
spowoduje że zalogowany użytkownik będzie autorem swoich postów
i swoich komentarzy.
Zwyczajowo, określa się to co robi taki kod zwrotem **scope it out**.

W tym celu zmieniamy metodę *create* w *PostsController*:

    :::ruby app/controllers/posts_controller.rb
    def create
      # klasyczne scoping out
      @post = current_user.posts.build(params[:post])
      @post.save
      respond_with(@post)
    end

oraz w *CommentsController*:

    :::ruby app/controllers/comments_controller.rb
    def create
      # scoping out
      params[:comment][:user_id] = current_user.id
      @comment = @post.comments.build(params[:comment])
      @comment.save
      respond_with(@post, @comment, :location => @post)
    end



## Wybór roli w formularzach rejestracji

Zaczynamy od widoku częściowego *_roles.erb*:

    :::rhtml app/views/devise/shared/_roles.erb
    <p><%= f.label :roles %><br>
    <% for role in User.valid_roles %>
      <%= check_box_tag "user[roles][]", role, @user.roles.include?(role) %>
      <%= role.to_s.humanize %>
    <% end %></p>

który dodajemy do widoków rejestracji, *new.html.erb*:

    :::rhtml app/views/devise/registrations/new.html.erb
    <%= render :partial => "devise/shared/roles", :locals => {:f => f} %>

oraz *edit.html.erb*:

    :::rhtml app/views/devise/registrations/edit.html.erb
    <%= render :partial => "devise/shared/roles", :locals => {:f => f} %>

*Uwaga do widoku edit:*
„Think about a profile page, where the user can edit all of
their information, including changing their password. If they do not
want to change their password they just leave the fields blank. This
will try to set the password to a blank value, in which case is
incorrect behavior.” W tej sprawie nic nie musimy robić.
Devise zrobi to za nas!


## Poprawki w widoku *posts#show*

W szablonie *show.html.erb* dopiszemy email autora postu,
oraz email autora każdego komentarza:

    :::rhtml app/views/posts/show.html.erb
    <p><b>added by</b>
      <em><%= @post.user.email %></em>
    </p>

Widok *posts#index* zostawiamy bez zmian. Dlaczego?


## Zmiany w edycji postów

Do widoku częściowego dodamy możliwość edycji
użytkownika (użyjemy listy rozwijanej), który dodał cytat.

    :::rhtml app/views/posts/_form.html.erb
    <%= simple_form_for(@post) do |f| %>
      <%= f.error_notification %>
      <div class="inputs">
        <%= f.input :title, :input_html => {:size => 60} %>
        <%= f.input :content, :input_html => {:rows => 4, :cols => 60} %>
        <p>
          <%= f.collection_select :user_id, User.all, :id, :email %>
          (select the author of this post)
        </p>
      </div>
      <div class="actions"><%= f.button :submit %></div>
    <% end %>

Po co to robimy? Przecież teraz każdy zalogowany użytkownik może
dodawany przez siebie cytat przypisać innemu użytkownikowi –
a to nie ma sensu.

Ale po dodaniu autoryzacji, ograniczymy możliwość edycji
użytkownika do admina i moderatora, usuwając element
z *collection_select* – a to ma sens (chociaż moglibyśmy
dopisać ten kod później).


# Implementujemy autoryzację

<blockquote>
  {%= image_tag "/images/authorization.jpg", :alt => "[Autoryzacja]" %}
</blockquote>

Tyle przygotowań i poprawek w aplikacji. Dopiero po wprowadzeniu tych
poprawek możemy zabrać się za implementację autoryzacji. Dlaczego?
Powinno się to za chwilę wyjaśnić.

Uprawnienia użytkowników (**autoryzację**) definiujemy
w klasie *Ability*. Uruchamiamy generator:

    rails generate cancan:ability
      create  app/models/ability.rb

i zaglądamy do wygenerowanego kodu:

    :::ruby app/models/ability.rb
    class Ability
      include CanCan::Ability

      def initialize(user)
      # Define abilities for the passed in user here. For example:
      #   user ||= User.new # guest user (not logged in)
      #   if user.admin?
      #     can :manage, :all
      #   else
      #     can :read, :all
      #   end
      # The first argument to `can` is the action you are giving the user permission to do.
      # If you pass :manage it will apply to every action. Other common actions here are
      # :read, :create, :update and :destroy.
      # The second argument is the resource the user can perform the action on. If you pass
      # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
      # The third argument is an optional hash of conditions to further filter the objects.
      # For example, here the user can only update published articles.
      #   can :update, Article, :published => true
      #
      # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
      end
    end

gdzie do metody *initialize* przekazywany jest obiekt *user*.
W metodzie **initialize** określamy, to co może *user*.


## Guest users

Autoryzację będziemy implementować małymi kroczkami.
Zaczniemy od umożliwienia każdemu użytkownikowi
(*guest user*)
wykonania akcji *index* oraz *show* dla zasobu *Post*:

    :::ruby app/models/ability.rb
    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new  # guest user

        # every user
        can :read, Post
      end
    end

Co oznacza `:read` powyżej?
Wiersz ten moglibyśmy wymienić na:

    :::ruby
    can [:index, :show], Post

Ale kod ten jest mniej czytelny. Dlatego CanCan definiuje kilka
użytecznych aliasów:

    :::ruby
    alias_action :index, :show, :to => :read
    alias_action :new, :to => :create
    alias_action :edit, :to => :update

Alias `:manage` użyty z skrótem `:all` też jest bardziej zrozumiałe:

    :::ruby
    can :manage, :all              # has permission to do anything to any model

Autoryzację dla modelu *Post* uaktywniamy dopisując do kodu
*PostController*:

    :::ruby app/controllers/posts_controller.rb
    class PostsController < ApplicationController
      load_and_authorize_resource

CanCan jest kontrolerem napisanym w stylu RESTful, co oznacza że możemy
usunąć z kodu kontrolera wszystkie linjki zaczynające się od
(**tylko liczba pojedyncza**):

    :::ruby
    @post = ...

ponieważ „resource is already loaded and authorized”.

Teraz możemy sprawdzić jak to działa. Logujemy się
i próbujemy wyedytować jakiś cytat. Po kliknieciu w link *Edit*
powinnismy zobaczyć coś takiego:

    CanCan::AccessDenied in PostsController#edit
    Not authorized to edit post!

Oczywiście, taki wyjątek powinnismy jakoś obsłużyć.
Zrobimy tak jak to opisano [3. Handle Unauthorized Access](https://github.com/ryanb/cancan/)
dopiszemy w pliku *application_controller.rb*:

    :::ruby app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      rescue_from CanCan::AccessDenied do |exception|
        redirect_to root_url, :alert => exception.message
      end
    end

I sprawdzamy jak to działa klikając ponownie link *Edit*.
Jest lepiej?


### Comments

Każdy użytkownik może też przeglądać komentarze.
Tak jak powyżej dopisujemy do *CommentsController*

    :::ruby app/controllers/comments_controller.rb
    class CommentsController < ApplicationController
      load_and_authorize_resource

oraz w klasie *Ability* zamieniamy wiersz:

    :::ruby
    can :read, Post

na

    :::ruby
    can :read, [Post, Comment]

restartujemy aplikację i sprawdzamy jak to wszystko działa.
Klikamy w jakiś link *Show* i próbujemy usunąć
lub dodać jakiś komentarz. Powinno się to zakończyć
przekierowaniem na stronę główną aplikacji
z wiadomością flash:

    Not authorized to create comment!


### Niepotrzebne linki

Następną rzeczą, którą zrobimy będzie ukrycie linków *Edit*
i *Destroy* przed guest users. Nie mają oni uprawnień do edycji
i usuwania postów i komentarzy więc nic im po takich linkach.

W kodzie poniżej będziemy korzystać z metod *can?* i *cannot?*,
a zaczniemy od zmian w widoku *posts/index.html.erb*:

    :::rhtml app/views/posts/index.html.erb
    <h1>Listing posts</h1>
    <%= render :partial => 'post', :collection => @posts %>
    <% if can? :create, Post %>
      <p class="links bottom"><%= link_to 'New Post', new_post_path %></p>
    <% end %>

oraz w widoku częściowym *posts/_post.html.erb*:

    :::rhtml app/views/posts/_post.html.erb
    <article>
      <h4><%= post.title %></h4>
      <div><%= post.content %></div>
      <div class="links">
        <%= link_to 'Show', post %>
        <% if can? :update, post %>
          | <%= link_to 'Edit', edit_post_path(post) %>
        <% end %>
        <% if can? :destroy, post %>
          | <%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete %>
        <% end %>
       </div>
    </article>

Następnie w pliku *posts/show.html.erb* poprawiamy akapit:

    :::rhtml app/views/posts/show.html.erb
    <h2><%= @post.title %></h2>
    ...
    <div class="links">
      <% if can? :update, @post %>
        <%= link_to 'Edit', edit_post_path(@post) %> |
      <% end %>
      <%= link_to 'Back', posts_path %>
    </div>

    <% if @post.comments.any? %>
    <h3>Comments</h3>
    <article>
      <%= render :partial => 'comments/comment', :collection => @post.comments %>
    </article>
    <% end %>
    <% if can? :create, Comment %>
      <h3>Add new comment</h3>
      <%= render :partial => 'comments/form' %>
    <% end %>

Z kodu powyżej widać, że pozostał jeszcze do poprawki widok częściowy
*comments/_comment.html.erb*:

    :::rhtml app/views/comments/_comment.html.erb
    <article>
      <div class="comment"><%= comment.content %></div>
      <div class="email"><b>added by</b>
        <em><%= comment.user.email %></em>
      </div>
    </article>
    <% if can? :destroy, comment %>
      <p><%= link_to "Delete", [@post, comment], :confirm => 'Are you sure?', :method => :delete %></p>
    <% end %>


## Doprecyzowujemy *Abilities*

Teraz zabierzemy się za doprecyzowanie *abilities* korzystając
z ról, które dodaliśmy w trakcie wstępnych przygotowań.

Zaczyniemy od admina.

    :::ruby
    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new    # guest user
        if user.has_role? :admin
          can :manage, :all
        else
          can :read, Fortune
        end
      end
    end

Sprawdzamy, jak to działa logując się jako admin (*wlodek* jest adminem)
i jako zwykły użytkownik (*bazylek*).

Teraz zabieramy się za autora.
Autor może dodawać, edytować i usuwać swoje cytaty:

    :::ruby
    class Ability
      include CanCan::Ability

      def initialize(user)
        user ||= User.new

        if user.has_role? :admin
          can :manage, :all
        elsif user.has_role? :author
          can :read, Fortune
          can :create, Fortune
          can [:update, :destroy], Fortune, :user_id => user.id
        else
          can :read, Fortune
        end
      end
    end

Na koniec zostawiliśmy rolę *moderatora*, który może tylko edytować
i usuwać cytaty.

    :::ruby
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :author
      can :read, Fortune
      can :create, Fortune
      can [:update, :destroy], Fortune, :user_id => user.id
    elsif user.has_role? :moderator
      can :read, Fortune
      can [:update, :destroy], Fortune
    else
      can :read, Fortune
    end


## TODO

Powinniśmy jeszcze zadbać o to, aby *autor* nie mógł przypisać nowej
fortunki innemu użytkownikowi.

Niestety, nie wystarczy ukryć rozwijalnej listy „Zmień użytkownika”
przed autorami. Użytkownik może przechwycić wysyłany formularz, na
przykład za pomocą rozszerzenia *Web Developer* lub *Tamper Data*
przeglądarki Firefox, i zmienić wysyłane dane.

Wydaje się, że najprostszym rozwiązaniem będzie zignorowanie
przesyłanego id użytkownika w *params[:fortune]* w metodach *update*
i *create*. Zamiast tego ustawimy dane użytkownika na *current_user*:

    :::ruby
    def update
      if current_user.role? :author
        # to samo co params[:fortune][:user_id] = current_user.id
        @fortune.user = current_user
      end
      if @fortune.update_attributes(params[:fortune])

    def create
      @fortune = Fortune.new(params[:fortune])
      @fortune.user = current_user  # przebijamy ustawienia z przesłanego formularza
      ...

Zanim ukryjemy rozwijalną listę select przed autorami, jeszcze jedna
poprawka w kodzie kontrolera:

    :::ruby
    def new
      @fortune.user = current_user  # ustaw użytkownika na liście select
    end

Sprawdzamy, czy wszystko działa. Jesli tak, to ukrywamy listę
rozwijaną przed autorami (ale nie adminami i moderatorami). W widoku
*fortunes/_form.html.erb* podmieniamy akapit z „Zmień użytkownika…” na:

    :::rhtml
    <% if !current_user.role?(:author) %>
    <p>
      Zmień użytkownika: <%= f.collection_select :user_id, User.all, :id, :login %>
    </p>
    <% end %>


## TODO: Kosmetyka widoków

Dwie rzeczy należałoby zmienić w widoku *fortunes/index.html.erb*:

1. Autorzy powinni po zalogowaniu widzieć tylko swoje cytaty.
2. Admini i moderatorzy powinni po zalogowaniu widzieć kto dodał cytat.

Dlaczego?

Na stronie [Upgrading 1.1 – cancan](http://wiki.github.com/ryanb/cancan/upgrading-to-11)
w sekcji **Fetching Records** jest przykład pokazujący jak
zaprogramować punkt 1. powyżej. W *fortunes_controller.rb* w metodzie
*indeks* podmieniamy:

    :::ruby
    @fortunes = Fortunes.accessible_by(current_ability)

Ale powyższy kod zwraca to samo co *Fortunes.all* — czyli nie działa (bug?).

Zamiast tego metodę indeks zaprogramujemy tak:

    :::ruby
    def index
      @fortunes = current_user.fortunes
    end

co po uwzględnieniu adminów, moderatorów oraz niezalogowanych
użytkowników daje:

    :::ruby
    def index
      if current_user && current_user.role?(:author)
        @fortunes = current_user.fortunes
      else
        @fortunes = Fortune.all
      end
    end

Czy ten kod jest równoważny z rozwiązaniem korzystającym z *accessible_by*
ze strony gemu CanCan?


Pozostaje punkt 2. Można to zrobić tak:

    :::rhtml
    <% for fortune in @fortunes %>
      <p>
        <%=h fortune.quotation %>
        <% if logged_in? && (current_user.role?(:admin) || current_user.role?(:moderator)) %>
          (added by <em><%= fortune.user.login %></em>)
        <% end %>
      </p>
