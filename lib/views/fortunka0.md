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

Po kilku szybkich przykładach przyszła pora na coś nieco bardziej
skomplikowanego – aplikację korzystającą z kilku popularnych gemów
implementującą CRUD, czyli:

* ***C**reate* (*insert*) — dodanie nowych danych
* ***R**ead* (*select*) – wyświetlenie istniejących danych
* ***U**pdate* – edycję istniejących danych
* ***D**elete* — usuwanie istniejących danych.

Tą aplikacją będzie *Fortunka* w której zaimplementujemy
interfejs CRUD dla [fortunek](http://en.wikipedia.org/wiki/Fortune_(Unix\)),
czyli krótkich cytatów.


{%= image_tag "/images/dilbert-agile-programming.png", :alt => "[Agile Programming]" %}

# Fortunka krok po kroku

<!--
[Anything less than 16px is a costly mistake](http://www.smashingmagazine.com/2011/10/07/16-pixels-body-copy-anything-less-costly-mistake/) –
-->

Niektóre dane mówią, że aplikacje podobne do Fortunki
stanowią zdecydowaną większość aplikacji WWW.
Na przykład:

* [Proverb Hunter](http://proverbhunter.com/)
* …?

1\. Zaczynamy od wygenerowania rusztowania aplikacji i przejścia do
katalogu z wygenerowanym rusztowaniem:

    :::bash
    rails new my_fortune --template wbzyl-template-rails4.rb
    cd my_fortune

źródło {%= link_to "wbzyl-template-rails4.rb", "/doc/rails4/wbzyl-template-rails4.rb" %}
({%= link_to "kod", "/app_templates/wbzyl-template-rails4.rb" %}).

Teraz możemy skorzystać z generatora *bootstrap:partial*
(navbar, navbar-devise, carousel):

    :::bash
    rails generate bootstrap:partial navbar

Wygenerowany szablon częściowy dopisujemy
w elemencie *body* layoutu aplikacji:

    :::rhtml app/views/layouts/application.html.erb
    <%= render partial: 'shared/navbar' %>

Przy okazji ***poprawiamy wygenerowany layout***
(można usunąć prawą kolumnę i wstawić swoje linki).

Generujemy rusztowanie (*scaffold*) dla fortunek:

    :::bash
    rails generate scaffold fortune quotation:text source:string

Tworzymy bazę i generujemy w niej tabelkę *fortunes* –
krótko mówiąc **migrujemy**:

    rake db:create
    rake db:migrate

Zmieniamy routing i ustawiamy stronę startową aplikacji, dopisując
w pliku konfiguracyjnym *config/routes.rb*:

    :::ruby config/routes.rb
    Fortunka::Application.routes.draw do
      resources :fortunes
      root to: 'fortunes#index'

Powinniśmy jeszcze nadpisać wygenerowane szablony
szablonami korzystającymi z Bootstrapa:

    :::bash
    rails generate bootstrap:themed fortunes

*Uwaga:* Aby wykonać polecenie *rake* w trybie produkcyjnym
*poprzedzamy je napisem RAILS_ENV=production*, przykładowo:

    :::bash
    RAILS_ENV=production rake db:migrate
    RAILS_ENV=production rake db:seed

Teraz już mozna sprawdzić jak to wszystko działa, uruchamiając serwer *thin*:

    :::bash
    rails server -p 3000

i wchodząc na stronę:

    http://localhost:3000

2\. Zapełniamy bazę jakimiś danymi, dopisując do pliku *db/seeds.rb*:

    :::ruby db/seeds.rb
    Fortune.create! quotation: 'I hear and I forget. I see and I remember. I do and I understand.'
    Fortune.create! quotation: 'Everything has its beauty but not everyone sees it.'
    Fortune.create! quotation: 'It does not matter how slowly you go so long as you do not stop.'
    Fortune.create! quotation: 'Study the past if you would define the future.'

Powyższe fortunki umieszczamy w bazie, wykonujac na konsoli polecenie:

    :::bash
    rake db:seed  # load the seed data from db/seeds.rb

Powyższy kod „smells” (dlaczego?) i należy go poprawić.
Na przykład tak jak to zrobiono tutaj
{%= link_to "seeds.rb", "/database_seed/seeds-fortunes.rb" %}.

Jeśli kilka rekordów w bazie to za mało, to możemy do pliku
*db/seeds.rb* wkleić {%= link_to "taki kod", "/database_seed/seeds.rb" %}
i ponownie uruchomić powyższe polecenie.

3\. Aby poprawić nieco layout i wygląd aplikacji skorzystaliśmy
z gemu *twitter-bootstrap-rails* ułatwiającego użycie
frameworka [Twitter Bootstrap](http://twitter.github.com/bootstrap/)
w aplikacjach Rails.

Jak z niego korzystać opisano tutaj:

* [Twitter Bootstrap for Rails 3.1 Asset Pipeline](https://github.com/seyhunak/twitter-bootstrap-rails)
* [Twitter Bootstrap Basics](http://railscasts.com/episodes/328-twitter-bootstrap-basics?view=asciicast) –
  screencast
* [Customize Bootstrap](http://twitter.github.com/bootstrap/customize.html)
* [FontAwesome](http://fortawesome.github.com/Font-Awesome/) –
  the iconic font designed for use with Twitter Bootstrap

Sam framework jest napisany w Less:

* [{less}](http://lesscss.org/) – the dynamic stylesheet language

Przykładowy {%= link_to "layout aplikacji", "/bootstrap/application.html.erb" %}
korzystający z Twitter Bootstrap.

4\. Kilka propozycji zmian domyślnych ustawień.

Parametrów Bootstrapa:

    :::css app/assets/stylesheets/bootstrap_and_overrides.css.less
    @baseFontSize: 18px;
    @baseLineHeight: 24px;

    @navbarBackground: #8E001C;
    @navbarBackgroundHighlight: #8E001C;
    @navbarText: #FBF7E4;
    @navbarLinkColor: #FBF7E4;

    .navbar .brand { color: #E7E8D1; }

Szablonu formularza *SimpleForm*:

    :::rhtml _form.html.erb
    <%= f.input :quotation, :input_html => { :rows => "4", :class => "span6" } %>
    <%= f.input :source, :input_html => { :class => "span6" } %>

Na pasku *navbar* umieścimy kilka ikonek z fontu *FontAwesome*:

    :::rhtml app/views/shared/_navbar.html.erb
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <%= link_to icon("quote-left", "Fortunes"), root_path, class: "brand" %>
          <ul class="nav pull-right">
            <li><%= link_to icon("home", "Tao"), "http://tao.inf.ug.edu.pl/" %></li>
            <li><%= link_to icon("ambulance", "ASI"), "http://wbzyl.inf.ug.edu.pl/rails4/" %></li>
          </ul>
        </div>
      </div>
    </div>

Powyżej użyliśmy metody pomocniczej *icon*. Kod tej metody zapiszemy
w pliku *application_helper.rb*:

    :::ruby app/helpers/application_helper.rb
    module ApplicationHelper
      def icon(name, title="")
        raw "<i class='icon-#{name}'></i>#{title}"
      end
    end

Odstęp po ikonce ustawiamy w arkuszu *application.css*:

    :::css
    i[class^="icon-"] { padding-right: .5em; }

I już! Wersja 0.0 Fortunki jest gotowa.


## I co dalej?

1\. **Walidacja**, czyli sprawdzanie poprawności (zatwierdzanie)
danych wpisanych w formularzach. Przykład, dopisujemy w modelu:

    :::ruby app/models/fortune.rb
    validates :quotation, length: {
      minimum: 8,
      maximum: 128
    }
    validates :source, presence: true

Zobacz też samouczek
[Active Record Validations and Callbacks](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html).

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

Walidacja wirtualnych atrybutów,
zobacz [Virtual Attributes](http://railscasts.com/episodes/16-virtual-attributes-revised?view=asciicast).

3\. Tagging (**implementacja działająca z Rails 4 ma być gotowa w maju 2013**)

* Gem [acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on)
* [Tagging](http://railscasts.com/episodes/382-tagging) – \#382 RailsCasts

Przykład do przetestowania na konsoli:

    :::ruby
    book = Book.find 1
    book.tag_list

    book.tag_list = "awesome, slick, hefty"
    book.save
    book.tag_list

    Book.tagged_with "slick"
    Book.tagged_with ["slick", "hefty"]

Dodajemy listę tagów do formularza:

    :::rhtml _form.html.erb
    <%= f.input :tag_list, :label => "Tags (separated by spaces)" %>

Dopisujemy w modelu:

    :::ruby
    acts_as_taggable_on :tags

a na końcu pliku *application.rb* dopisujemy:

    :::ruby config/application.rb
    ActsAsTaggableOn.delimiter = ' ' # use space as delimiter

Pozostałe rzeczy robimy tak jak to przedstawiono w screencaście.


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


## I na koniec dwie uwagi

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

    def y(obj)
      puts obj.to_yaml
    end

    # break out of the Bundler jail
    # from https://github.com/ConradIrwin/pry-debundle/blob/master/lib/pry-debundle.rb
    if defined? Bundler
      Gem.post_reset_hooks.reject! { |hook| hook.source_location.first =~ %r{/bundler/} }
      Gem::Specification.reset
    end

    if defined? Rails
      begin
        require 'hirb'
        Hirb.enable
      rescue LoadError
      end
    end
