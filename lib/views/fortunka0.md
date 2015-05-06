#### {% title "Fortunka v0.0" %}

<blockquote>
 {%= image_tag "/images/ken-arnold.jpg", :alt => "[Ken Arnold]" %}
 <p>
  Fortunka (Unix) to program „which will display quotes or
  witticisms. Fun-loving system administrators can add fortune to users’
  <i>.login</i> files, so that the users get their dose of wisdom each time
  they log in.”
 </p>
 <p>Autorem najczęściej instalowanej wersji jest Ken Arnold.
 </p>
</blockquote>

Napisanie za pomocą Ruby on Rails prostej aplikacji CRUD jest proste.
Poniżej zademonstruję to na przykładzie aplikacji *Fortunka*,
w której zaimplementujemy interfejs CRUD dla
[fortunek](http://en.wikipedia.org/wiki/Fortune_(Unix\)),
czyli krótkich cytatów:

- **Create** (*insert*) — dodawanie
- **Read** (*select*) – wyświetlanie
- **Update** – edycja
- **Delete** — usuwanie

{%= image_tag "/images/dilbert-agile-programming.png", :alt => "[Agile Programming]" %}

# Fortunka krok po kroku

Pierwsza wersja takiej aplikacji to [Proverb Hunter](http://proverbhunter.com/).
Teraz ta aplikacja rozrosła się do „English Learning Resources”.

Chrome, czyli wygląd, naszej Fortunki przygotujemy korzystając z
[LessCSS](http://lesscss.org/),gemu
[less-rails](https://github.com/metaskills/less-rails),
frameworka [Bootstrap](http://getbootstrap.com/),
[less-rails-bootstrap](https://github.com/metaskills/less-rails-bootstrap) oraz
[rails-bootstrap-form](https://github.com/bootstrap-ruby/rails-bootstrap-forms).

1\. Zaczynamy od wygenerowania rusztowania aplikacji i przejścia do
katalogu z wygenerowanym rusztowaniem:

    :::bash
    rails new my_fortune --skip-bundle --skip-test-unit
    cd my_fortune

2\. Dopisujemy te gemy do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'therubyracer', '~> 0.12.2'
    gem 'less-rails', '~> 2.7.0'
    gem 'less-rails-bootstrap', '~> 3.3.4'
    gem 'bootstrap_form', '~> 2.3.0'

    gem 'faker', '~> 1.4.3'
    gem 'quiet_assets', '~> 1.1.0'

i usuwamy z niego gem *sass-rails*.

Instalujemy gemy i tak jak to opisano
w [README](https://github.com/metaskills/less-rails-bootstrap) uruchamiamy
generator *less_rails_bootstrap:custom_bootstrap*:

    rails generate less_rails_bootstrap:custom_bootstrap
      create  app/assets/stylesheets/custom_bootstrap/custom_bootstrap.less
      create  app/assets/stylesheets/custom_bootstrap/variables.less
      create  app/assets/stylesheets/custom_bootstrap/mixins.less

i przeklikujemy do plików *application.css* i *application.js*
linijki z *require* z pliku *README* powyżej oraz
pliku *README* z gemu *bootstrap_form*.

Przykładowo do pliku *application.css* dopisujemy:

    :::css
    *= require custom_bootstrap/custom_bootstrap
    *= require rails_bootstrap_forms

3\. Dopiero teraz generujemy szablon aplikacji CRUD dla fortunek:

    rails generate scaffold fortune quotation:text source:string
    rake db:migrate

4\. Zmieniamy wygenerowany layout na layout korzystający
z frameworka Bootstrap. Skorzystamy
z [szablonu](http://getbootstrap.com/getting-started/#examples)
o nazwie [starter template](http://getbootstrap.com/examples/starter-template/).

W szablonie aplikacji *application.html.erb* wymieniamy zawartość
elementu *body* na:

    :::rhtml app/views/layouts/application.html.erb
    <%= render partial: 'shared/navbar' %>
    <div class="container">
      <div class="starter-template">
        <%= yield %>
      </div>
    </div>

Następnie tworzymy katalog *app/views/shared/* w którym
tworzymy szablon częściowy o zawartości:

    :::rhtml app/views/shared/_navbar.html.erb
    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle"
              data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="/">My Fortune</a>
        </div>
        <div class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="http://inf.ug.edu.pl">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul>
        </div>
      </div>
    </div>

Na koniec dopisujemy na końcu pliku *application.css* dwie reguły:

    :::css app/assets/stylesheets/application.css
    body {
      padding-top: 50px;
    }
    .starter-template {
      padding: 40px 15px;
    }

5\. [Typografia](http://getbootstrap.com/css/#less-variables).
Kilka poprawek, które zapisujemy w pliku *variables.less*:

    :::css app/assets/stylesheets/custom_bootstrap/variables.less
    @text-color: black;
    @font-family-sans-serif:  "DejaVu Sans", sans-serif;
    @font-family-serif:       "DejaVu Serif", serif;
    @font-family-monospace:   "DejaVu Sans Mono", monospace;
    @font-family-base:        @font-family-serif;
    @font-size-base:          18px;
    @line-height-base:        1.44444; // 26/18

gdzie powyżej zwiększamy rozmiar fontu w akapitach, zgodnie z sugestią,
że [Anything less than 16px is a costly mistake](http://www.smashingmagazine.com/2011/10/07/16-pixels-body-copy-anything-less-costly-mistake/).

6\. Zapełniamy bazę jakimiś danymi, dopisując do pliku *db/seeds.rb*:

    :::ruby db/seeds.rb
    Fortune.create! quotation: 'I hear and I forget. I see and I remember. I do and I understand.'
    Fortune.create! quotation: 'Everything has its beauty but not everyone sees it.'
    Fortune.create! quotation: 'It does not matter how slowly you go so long as you do not stop.'
    Fortune.create! quotation: 'Study the past if you would define the future.'

Powyższe fortunki umieszczamy w bazie, wykonujac na konsoli polecenie:

    :::bash
    rake db:seed  # load the seed data from db/seeds.rb

*Uwaga:* Aby wykonać polecenie *rake* w trybie produkcyjnym
*poprzedzamy je napisem RAILS_ENV=production*, przykładowo:

    :::bash
    RAILS_ENV=production rake db:migrate
    RAILS_ENV=production rake db:seed

Powyższy kod „smells” (dlaczego?) i należy go poprawić.
Na przykład tak jak to zrobiono tutaj
{%= link_to "seeds.rb", "/database_seed/seeds-fortunes.rb" %}.

Jeśli kilka rekordów w bazie to za mało, to możemy do pliku
*db/seeds.rb* wkleić {%= link_to "taki kod", "/database_seed/seeds.rb" %}
i ponownie uruchomić powyższe polecenie.

7\. Poprawiamy widok *index.html.erb*. Dopisujemy klasę *table*
do elementu *table*, klasy *btn* do odsyłaczy i ustalamy
szerokości dwóch pierwszych kolumn tabeli:

    :::rhtml
    <table class="table">
      <thead>
        <tr>
          <th class="col-md-7">Quotation</th>
          <th class="col-md-2">Source</th>
          <th></th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <% @fortunes.each do |fortune| %>
        <tr>
          <td><%= fortune.quotation %></td>
          <td><%= fortune.source %></td>
          <td><%= link_to 'Show', fortune, class: "btn btn-default btn-sm" %></td>
          <td><%= link_to 'Edit', edit_fortune_path(fortune), class: "btn btn-default btn-sm"  %></td>
          <td><%= link_to 'Destroy', fortune, method: :delete, data: { confirm: 'Are you sure?' },
                  class: "btn btn-danger btn-sm" %></td>
        </tr>
        <% end %>
      </tbody>
    </table>
    <p><%= link_to 'New Fortune', new_fortune_path, class: "btn btn-primary btn-lg" %></p>

8\. Zmieniamy widok częściowy *_form.html.erb*:

    :::rhtml
    <%= bootstrap_form_for(@fortune, layout: :horizontal) do |f| %>
      <%= f.text_area :quotation %>
      <%= f.text_field :source %>
      <%= f.form_group do %>
        <%= f.submit %>
      <% end %>
    <% end %>

9\. Zmieniamy routing. Ustawiamy stronę startową aplikacji, dopisując
w pliku konfiguracyjnym *config/routes.rb*:

    :::ruby config/routes.rb
    Fortunka::Application.routes.draw do
      resources :fortunes
      root to: 'fortunes#index'

## Co dalej?

Oczywiście należy poprawić pozostałe widoki.

1\. **Walidacja**, czyli sprawdzanie poprawności (zatwierdzanie)
danych wpisanych w formularzach. Przykład, dopisujemy w modelu:

    :::ruby app/models/fortune.rb
    validates :quotation, length: {
      minimum: 8,
      maximum: 256
    }
    validates :source, presence: true

Zobacz też samouczek
[Active Record Validations](http://edgeguides.rubyonrails.org/active_record_validations.html).

2\. **Wirtualne Atrybuty.**  Przykład: cenę książki pamiętamy
w bazie w groszach, ale chcemy ją wypisywać i edytować w złotówkach.

Załóżmy taką schema:

    :::ruby schema.rb
    create_table "books", :force => true do |t|
      t.string   "author"
      t.string   "title"
      t.string   "isbn"
      t.integer  "price"
    end

Do modelu dopisujemy dwie metody („getter” i „setter”):

    :::ruby book.rb
    class Book < ActiveRecord::Base
      def price_pln
        price.to_d / 100 if price
      end
      def price_pln=(pln)
        self.price = pln.to_d * 100 if pln.present?
      end
    end

Zamieniamy we wszystkich widokach *price* na *price_pln*, przykładowo:

    :::rhtml _form.html.erb
    <%= f.input :price_pln %>

i zamieniamy *price* na *price_pln* w definicji metody
*book_params* w kontrolerze *books_controller.rb*.

Walidacja wirtualnych atrybutów,
zobacz [Virtual Attributes](http://railscasts.com/episodes/16-virtual-attributes-revised?view=asciicast).

3\. Tagowanie książek.

* Gem [acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)

Instalujemy gem *acts-as-taggable-on* i instalujemy migracje:

    rake acts_as_taggable_on_engine:install:migrations
    rake db:migrate

Dopisujemy do modelu *Book*:

    :::ruby app/models/book.rb
    class Book < ActiveRecord::Base
      acts_as_taggable

Przykład do przetestowania na konsoli:

    :::ruby
    book = Book.find 1
    book.tag_list

    book.tag_list.add("awesome, slick, hefty")
    book.tag_list.remove("awesome")
    book.tag_list
    book.tag_list.add("awesomer, slicker", parse: true)

    book.save

    Book.tagged_with "slick"
    Book.tagged_with ["slick", "hefty"]

Dodajemy listę tagów do formularza:

    :::rhtml _form.html.erb
    <%= f.input :tag_list, :label => "Tags (separated by spaces)" %>

a na końcu pliku *application.rb* dopisujemy:

    :::ruby config/application.rb
    ActsAsTaggableOn.delimiter = ' ' # use space as delimiter


## Zapisywanie przykładowych danych w bazie

Tutaj przećwiczymy proste zastosowanie gemów *Faker*
i *Populator* (o ile już działa z Rails 4).

Zaczynamy od wygenerowania rusztowania dla zasobu Friend:

    :::bash
    rails g scaffold friend last_name:string first_name:string phone:string motto:text
    rake db:migrate

i od „monkey patching” kodu gemu *Faker*:

    :::ruby faker_pl.rb
    module Faker
      class PhoneNumber
        SIMPLE_FORMATS  = ['+48 58-###-###-###', '(58) ### ### ###']
        MOBILE_FORMATS  = ['(+48) ###-###-###', '###-###-###']

        def self.pl_phone_number(kind = :simple)
          Faker::Base.numerify const_get("#{kind.to_s.upcase}_FORMATS").sample
        end
      end
    end

(zob. też [ten gist](https://gist.github.com/165751)).

Sprawdzamy jak to działa na konsoli:

    :::bash
    irb

gdzie wpisujemy:

    :::ruby
    require 'faker'
    require './faker_pl'
    Faker::PhoneNumber.pl_phone_number :mobile
    Faker::Name.first_name
    Faker::Name.last_name

Jeśli wszystko działa tak jak powinno, to w pliku *db/seeds.rb*
możemy wpisać:

    :::ruby db/seeds.rb
    require Rails.root.join('db', 'faker_pl')

    Friend.populate(100..200) do |friend|
      friend.first_name = Faker::Name.first_name
      friend.last_name = Faker::Name.last_name
      friend.phone = Faker::PhoneNumber.pl_phone_number :mobile
      friend.motto = Populator.sentences(1..2)
    end

Teraz wykonujemy:

    :::bash
    rake db:seed

zapełniając tabelę *friends* danymi testowymi.

Chociaż przydałoby się dodać do powyższego kodu coś w stylu:

    :::ruby
    Friend.populate(1000..5000) do |friend|
      # passing array of values will randomly select one
      friend.motto = ["akapity", "z kilku", "fajnych książek"]
    end


## Na koniec dwie uwagi

1\. Potrzebne nam gemy wyszukujemy na [The Ruby Toolbox](https://www.ruby-toolbox.com/).
Tam też sprawdzamy, czy gem jest aktywnie rozwijany,
czy będzie działał z innymi gemami i wersjami Ruby, itp.

2\. Modyfikujemy domyślne ustawienia konsoli Ruby
(i równocześnie konsoli Rails):

    :::ruby ~/.irbrc
    require 'irb/completion'
    require 'irb/ext/save-history'

    IRB.conf[:SAVE_HISTORY] = 1000
    IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
    IRB.conf[:PROMPT_MODE] = :SIMPLE

    # remove the SQL logging
    # ActiveRecord::Base.logger.level = 1 if defined? ActiveRecord::Base

    # add hirb gem to Gemfile
    if defined? Rails
      begin
        require 'hirb'
        Hirb.enable
      rescue LoadError
      end
    end
