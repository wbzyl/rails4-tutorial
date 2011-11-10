#### {% title "Fortunka v1.0" %}

Jednym ze sprawdzonych sposobów kontynuacji projektu jest
rozpoczęcie go od nowa. Tym razem nie skorzystamy z generatora
„scaffold”. Dlaczego?

Ale rusztowanie aplikacji wygenerujemy korzystając z gotowego szablonu
aplikacji Rails:

    rails new fortunki -m https://raw.github.com/wbzyl/rails31-html5-boilerplates/master/html5-boilerplate.rb

Formularze będziemy tworzyć korzystając z metod pomocniczych
z gemu *simple_form*. Dlaczego? Najlepiej wyjaśnili to autorzy:
„SimpleForm aims to be as flexible as possible while helping you with
powerful components to create your forms. The basic goal of simple
form is to not touch your way of defining the layout, letting you find
the better design for your eyes.”


<blockquote>
 <p>
  {%= image_tag "/images/new-project.jpg", :alt => "[nowy projekt]" %}
 </p>
 <p class="author"><a href="http://www.eyefetch.com/image.aspx?ID=901780">New project car</a></p>
</blockquote>

### Robótki ręczne…

Zanim zaczniemy pisać fortunkę, przyjrzymy się bliżej
rusztowaniom generowanym przez generatory:

* scaffold
* responders

Do wygenerowanego pliku *Gemfile* dopisujemy kilka nowych gemów:

    :::ruby Gemfile
    gem 'simple_form'

    gem 'responders'
    gem 'kaminari'

    group :development do
      gem 'wirble'
      gem 'hirb'
      gem 'faker'
      gem 'populator'
    end

Będziemy z nich korzystać budując Fortunkę v1.0.

Instalujemy gemy i wykonujemy procedurę *post-install*:

    rails g simple_form:install
    rails generate responders:install


## Scaffold v. Responders

Dla przypomnienia, *resource controller* musi definiować
następujące metody (razem siedem sztuk):

* *index*, *show*
* *new*, *create*
* *edit*, *update*
* *destroy*


<blockquote>
 <h2>TODO: Scaffold</h2>
 <p>Kontroller:
   {%= link_to "fortunes_controller.rb", "/rails3/scaffold/controllers/fortunes_controller.rb" %}.
 </p>
 <p>Widoki:
   {%= link_to "index", "/rails3/scaffold/fortunes/index.html.erb" %},
   {%= link_to "edit", "/rails3/scaffold/fortunes/edit.html.erb" %},
   {%= link_to "show", "/rails3/scaffold/fortunes/show.html.erb" %},
   {%= link_to "new", "/rails3/scaffold/fortunes/new.html.erb" %},
   {%= link_to "form", "/rails3/scaffold/fortunes/_form.html.erb" %}.
 </p>
 <p>CSS:
   {%= link_to "scaffold.css", "/rails3/scaffold/scaffold.css" %}.
 </p>
</blockquote>

Zaczynamy przyjrzenia się generatorowi scaffold (bez testów i migracji):

    rails g scaffold fortune source:string quotation:text
      invoke  active_record
      create    app/models/fortune.rb
       route  resources :fortunes
      invoke  responders_controller
      create    app/controllers/fortunes_controller.rb
      invoke    erb
      create      app/views/fortunes
      create      app/views/fortunes/index.html.erb
      create      app/views/fortunes/edit.html.erb
      create      app/views/fortunes/show.html.erb
      create      app/views/fortunes/new.html.erb
      create      app/views/fortunes/_form.html.erb
      invoke    helper
      create      app/helpers/fortunes_helper.rb
      invoke  stylesheets
      create    public/stylesheets/scaffold.css

<blockquote>
 <h2>TODO: Responders</h2>
 <p>Kontroller:
   {%= link_to "fortunes_controller.rb", "/rails3/nifty-generators/controllers/fortunes_controller.rb" %}.
 </p>
 <p>
 <p>Widoki:
   {%= link_to "index", "/rails3/nifty-generators/fortunes/index.html.erb" %},
   {%= link_to "edit", "/rails3/nifty-generators/fortunes/edit.html.erb" %},
   {%= link_to "show", "/rails3/nifty-generators/fortunes/show.html.erb" %},
   {%= link_to "new", "/rails3/nifty-generators/fortunes/new.html.erb" %},
   {%= link_to "form", "/rails3/nifty-generators/fortunes/_form.html.erb" %}.
 </p>
 <p>Nifty layout:
   {%= link_to "layout_helper.rb", "/rails3/nifty-generators/layout_helper.rb" %},
   {%= link_to "application.html.erb", "/rails3/nifty-generators/application.html.erb" %}.
 </p>
 <p>Metody pomocnicze:
   {%= link_to "error_messages_helper.rb", "/rails3/nifty-generators/error_messages_helper.rb" %}.
 </p>
 <p>CSS:
   {%= link_to "application.css", "/rails3/nifty-generators/application.css" %}.
 </p>
</blockquote>

Więcej informacji o **respond_with** (oraz **respond_to**):

* [Controllers in Rails 3](http://asciicasts.com/episodes/224-controllers-in-rails-3)
* [ActionController::Responder](http://github.com/rails/rails/blob/master/actionpack/lib/action_controller/metal/responder.rb)
* [One in Three: Inherited Resources, Has Scope and Responders](http://blog.plataformatec.com.br/tag/respond_with/)
  – zawiera opis *FlashResponder* (korzysta z **I18N**) oraz *HttpCacheResponder*

Zapisujemy w bazie trochę danych testowych,
zmieniamy routing, tak aby uri

    http://localhost:3000

przekierowywał na

    http://localhost:3000/fortunes

**Na razie zezwalamy tylko na renderowanie *html**.
Później to będziemy zmieniać.


## Wchodzimy na stronę startową aplikacji (*index*)

…i od razu widzimy, że coś jest nie tak!
Wszystkie cytaty na jednej stronie? Przydałaby się jakaś
paginacja. W tym celu skorzystamy z gemu *kaminari*.

Instalacja *kaminari* jest typowa. Dopisujemy gem do pliku *Gemfile*
i wykonujemy polecenie *bundle*.

Następnie, przeglądamy tutorial i dokumentację gemu:

* [Pagination with Kaminari](http://asciicasts.com/episodes/254-pagination-with-kaminari)
* [Kaminari](https://github.com/amatsuda/kaminari)

### Podstawowa instalacja

1\. W kontrolerze *FortunesController* w metodzie *index* zmieniamy
wywołanie *Fortune.all* na:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      def index
        @fortunes = Fortune.order(:source).page(params[:page]).per(8)
        respond_with(@fortunes)
      end

2\. W widoku *index* tego kontrolera dopisujemy wywołanie metody
pomocniczej *paginate*, np. u dołu strony:

    :::rhtml app/views/fortunes/index.html.erb
    <%= paginate @fortunes %>

I już możemy sprawdzić jak działa paginacja. Paginacja jest
renderowana w elemencie **nav**.  Poprawiamy nieco jego wygląd:

    :::css public/stylesheets/applications.css
    nav.pagination {
      display: block;
      margin: 2em 0;
    }
    nav.pagination a, nav.pagination .page.current {
      padding: 4px;
      text-decoration: none;
      font-weight: bold;
    }
    nav.pagination .page.current {
      color: red;
    }

Musimy jeszcze pozbyć się wielokropków po prawej `…`.
Zrobimy to za chwilę.


### I18n paginacji

Zaczniemy od zmiany wyświetlanych tekstów.

W pliku *application.rb* odkomentowujemy i zmieniamy wiersz:

    :::ruby config/application.rb
    config.i18n.default_locale = :en

a w pliku *en.yml* dopisujemy:

    :::yaml config/locales/en.yml
    en:
      views:
        pagination:
          previous: "&#x21d0; Previous"
          next: "Next &#x21d2;"
          truncate: ""

(*U+21d0* to `⇐`, a *U+21d2* – `⇒`.)

Domyślnie *truncate* jest tłumaczone na wielokropek `…`.  Kasujemy go.

Wkrótce zajmiemy się i18n Fortunki. Ale już teraz dodamy
tłumaczenia *previous*, *next* i *truncate*.
W nowym pliku *pl.yml* wklejamy:

    :::yaml config/locales/pl.yml
    pl:
      views:
        pagination:
          previous: "&#x21d0;"
          next: "&#x21d2;"
          truncate: ""

*Uwaga:* Ponieważ nie każdy font zawiera strzałki `⇐` i `⇒`,
bezpieczniej byłoby użyć cudzysłowów `«` i `»`.

**Uwaga:** Kaminari jest zaprogramowane jako tzw. *Rails Engine*.
Engine zawiera widoki, które możemy sami modyfikować, zmieniając
wygląd paginacji. Albo generując paginację na wzór Google:

    rails g kaminari:views google

Ale Google to Google, dlatego:

    rails destroy kaminari:views google


## Engines are back in Rails… 3.1

Engine to miniaturowa aplikacja, gem albo wtyczka.
Zazwyczaj za pomocą engine dodajemy dodatkową funkcjonalność
do całej aplikacji Rails. Na przykład
autentykację (Devise), paginację (Kaminari).

Engines dla Rails wymyślił [James Adams](https://github.com/lazyatom/engines).
Z engines był jeden problem. Nie było gwarancji, że nowa wersja Rails
będzie będzie działać ze starymi engines. Wersja Rails 3.1 ma to zmienić.

Nieco Railsowej archeologii:

* [Guide: Things You Shouldn't Be Doing In Rails](http://glu.ttono.us/articles/2006/08/30/guide-things-you-shouldnt-be-doing-in-rails) –
 artykuł z 2005 roku
* [Odpowiedź J. Adamsa](http://article.gmane.org/gmane.comp.lang.ruby.rails/29166)


{%= image_tag "/images/head-element.png", :alt => "[source: http://diveintohtml5.org/]" %}<br>
(źródło M. Pilgrim. <a href="http://diveintohtml5.org/">Dive into HTML5</a>)


## Google Analytics

Google Analytics zajmiemy się przy wdrażaniu aplikacji na Heroku.


## Walidacja

Do czego jest nam potrzebna walidacja wyjaśniono w samouczku
[Active Record Validations and Callbacks](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html).

Baza powinna zawsze zawierać prawidłowe dane.
Zanim zapiszemy coś w bazie powinniśmy sprawdzić
czy dane które chcemy umieścić w bazie są poprawne.
Gdzie to sprawdzenie najlepiej wykonać?
W przeglądarce? W aplikacji Rails?
Lepiej w kontrolerze, czy modelu? Dlaczego?
Może lepiej walidację zostawić to serwerowi bazy?

Dopisujemy walidację do modelu *Fortune*:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      # atrybut: quotation
      validates :quotation, :presence => true
      # validates_presence_of :quotation
      validates_length_of :quotation, :in => 2..128
      # validates_length_of :quotation, :minimum => 2, :maximum => 128
      validates_uniqueness_of :quotation, :case_sensitive => false

      # atrybut: source
      validates :source, :in => 4..64, :allow_blank => true
    end

Sprawdzamy na konsoli Rails jak to działa:

    f = Fortune.new
    f.valid?
     => false
    f.errors
     => {:quotation=>["can't be blank"]}
    f.errors[:quotation].any?
     => true
    f.save
     => false
    f.source = "X"
    f.valid?
    f.errors
    f.source = ""
    f.valid?
    f.errors

Pozostałe rzeczy: *validates_with*, *validates_each*, walidacja warunkowa,
walidacja dla powiązanego modelu *validates_associated*.

**Ważne:** Powinniśmy sprawdzić jak działa walidacja w przeglądarce.
Sama konsola to za mało!

Dodatkowa lektura:

* [validates :rails_3, :awesome => true](http://lindsaar.net/2010/1/31/validates_rails_3_awesome_is_true)
* [Creating Custom Validation Methods](http://edgeguides.rubyonrails.org/active_record_validations_callbacks.html#creating-custom-validation-methods)
* [Building Rails 3 custom validators](http://www.perfectline.ee/blog/building-ruby-on-rails-3-custom-validators)
* [Sexy Validation in Rails3](http://thelucid.com/2010/01/08/sexy-validation-in-edge-rails-rails-3/)


## Formularze z *simple_form*

Jak pisać formularze w aplikacjach Rails opisano w samouczku
[Rails Form helpers](http://edgeguides.rubyonrails.org/form_helpers.html).
Po lekturze tego samouczka jedna sprawa jest jasna: formularze nie
są „easy”.
Za to autorzy [simple_form](https://github.com/plataformatec/simple_form)
obiecują, że z ich gemem „forms are easy!”.

Sprawdźmy to!

    rails generate simple_form:install
      create  config/initializers/simple_form.rb
      create  config/locales/simple_form.en.yml
      create  lib/templates/erb/scaffold/_form.html.erb

Dostępne opcje konfigurujemy w pliku *simple_form.rb*, dla przykładu
możemy zmienić generowane znaczniki HTML:

    :::ruby config/initializers/simple_form.rb
    # Default tag used on errors.
    # config.error_tag = :span
    # You can wrap all inputs in a pre-defined tag.
    # config.wrapper_tag = :div
    # When false, do not use translations for labels, hints or placeholders.
    # config.translate = true

Ustawiamy walidację HTML5 na *false*:

    :::ruby config/initializers/simple_form.rb
    # Tell browsers whether to use default HTML5 validations.
    config.disable_browser_validations = false

    # Determines whether HTML5 types (:email, :url, :search, :tel) and attributes
    # (e.g. required) are used or not. True by default.
    # Having this on in non-HTML5 compliant sites can cause odd behavior in HTML5-aware browsers such as Chrome.
    # config.use_html5 = true
    config.use_html5 = false

Dlaczego? jest wyjaśnione powyżej oraz w *README*:
„In many cases it can break existing UI’s.”

Łatwo będzie można wymienić wypisywane komunikaty.
Wszystkie są pobierane z pliku *simple_form.en.yml*.
Wystarczy je zmienić.

    :::yaml
    en:
      simple_form:
        "yes": 'Yes'
        "no": 'No'
        required:
          text: 'required'
          mark: '*'
          # You can uncomment the line below if you need to overwrite the whole required html.
          # When using html, text and mark won't be used.
          # html: '<abbr title="required">*</abbr>'
        error_notification:
          default_message: "Some errors were found, please take a look:"
        # Labels and hints examples
        # labels:
        #   password: 'Password'
        #   user:
        #     new:
        #       email: 'E-mail para efetuar o sign in.'
        #     edit:
        #       email: 'E-mail.'
        # hints:
        #   username: 'User name to sign in.'
        #   password: 'No special characters, please.'
        labels:
          fortune:
            source: 'source'
            quotation: 'said'
        hints:
          fortune:
            source: '(optional)'
            quotation: '(maximum 128 characters)'
        placeholders:
          fortune:
            source: 'source or blank'
            quotation: 'no special chars, please'

Po przejrzeniu pliku *README*, formularz dla fortunki wpisujemy tak:

    :::rhtml
    <%= simple_form_for @fortune do |f| %>
      <%= f.input :source, :input_html => {:size => 40}, :required => false %>
      <%= f.input :quotation, :input_html => {:rows => 4, :cols => 40} %>
      <%= f.button :submit %>
    <% end %>

Kod ten generuje taki HTML (usunąłem znacznik *div* z elementami *hidden*):
    :::html
    <form accept-charset="UTF-8" action="/fortunes" class="simple_form fortune" id="new_fortune" method="post">
      <div class="input string optional">
        <label class="string optional" for="fortune_source"> source</label>
        <input class="string optional" id="fortune_source" maxlength="255" name="fortune[source]" placeholder="source or blank" size="40" type="text" />
        <span class="hint">(optional)</span>
      </div>
      <div class="input text required">
        <label class="text required" for="fortune_quotation"><abbr title="required">*</abbr> said</label>
        <textarea class="text required" cols="40" id="fortune_quotation" name="fortune[quotation]" placeholder="no special chars, please" required="required" rows="4">
        </textarea>
        <span class="hint">(maximum 128 characters)</span>
      </div>
      <input class="button" id="fortune_submit" name="commit" type="submit" value="Create Fortune" />
    </form>

Zaczynamy od ustawienia takiego samego fontu dla elementów *input[type=text]* oraz *textarea*:

    :::css public/stylesheets/applications.css
    input[type="text"], textarea {
      font: inherit;
    }

Inaczej, elementy te przy takiej samej liczbie kolumn, bądą miały różną szerokość.
(Albo można ustawić *width* dla elementów *input* oraz *textarea*.)

Włączamy pływanie:

    :::css public/stylesheets/applications.css
    div.input, input, textarea, label {
      float: left;
    }
    div.input {
      width: 100%;
    }

I już! Zostaje tylko wyrównanie w pionie oraz dodanie marginesów.


<blockquote>
  {%= image_tag "/images/fraunhofer-lines.jpg", :alt => "[Fraunhofer lines]" %}
  <p>
    [Herschel do Babbage’a, kiedy ten nie był w stanie dojrzeć ciemnych
    linii Fraunhofera]
    Często nie widzimy czegoś dlatego, że
    <b>nie wiemy jak to zobaczyć</b>, a nie na skutek
    jakichś braków w organie widzenia…
    Nauczę cię jak je dostrzec.
  </p>
</blockquote>


## Responders

Google podpowiada, że *responder* to hiszpańskie słowo na odpowiadać / odezwać / odczytać.
Zapoznawanie się z tą biblioteką zaczynamy od lektury
[README](https://github.com/plataformatec/responders),
gdzie dowiadujemy się, że mamy do dyspozycji trzy prekonfigurowane respondery:

* *FlashResponder* (i18n dla komunikatów flash)
* *HttpCacheResponder* (dodaje do żądania nagłówek Last-Modified)
* *CollectionResponder* (po uaktualnieniu lub zapisaniu rekordu w bazie jesteśmu przekierowywani na index)

Co więcej, możemy pisać swoje responders oraz używać ich w zestawach.
Czego nie będziemy robić. Ale za to zainstalujemy powyższe responders
i skonfigurujemy Fortunkę tak aby z nich korzystała:

    rails generate responders:install
      create  lib/application_responder.rb
     prepend  app/controllers/application_controller.rb
      insert  app/controllers/application_controller.rb
      create  config/locales/responders.en.yml

Generator ten tworzy plik locales:

    :::yaml config/locales/responders.en.yml
    en:
      flash:
        actions:
          create:
            notice: '%{resource_name} was successfully created.'
          update:
            notice: '%{resource_name} was successfully updated.'
          destroy:
            notice: '%{resource_name} was successfully destroyed.'
            alert: '%{resource_name} could not be destroyed.'

modyfikuje plik *application_controller.rb*:

    :::ruby app/controllers/application_controller.rb
    require "application_responder"
    class ApplicationController < ActionController::Base
      self.responder = ApplicationResponder
      respond_to :html, :js
      protect_from_forgery
    end

tworzy plik *application_responder.rb*

    :::ruby lib/application_responder.rb
    class ApplicationResponder < ActionController::Responder
      include Responders::FlashResponder
      include Responders::HttpCacheResponder

      # Uncomment this responder if you want your resources to redirect to the collection
      # path (index action) instead of the resource path for POST/PUT/DELETE requests.
      # include Responders::CollectionResponder
    end

Jak widać, generator zostawił nam do konfiguracji tylko locales.

Zaglądamy do pliku z kontrolerem:

    :::ruby app/controllers/fortunes_controller.rb
    def create
      @fortune = Fortune.new(params[:fortune])
      flash[:notice] = 'Fortune was successfully created.' if @fortune.save
      respond_with(@fortune)
    end
    def update
      @fortune = Fortune.find(params[:id])
      flash[:notice] = 'Fortune was successfully updated.' if @fortune.update_attributes(params[:fortune])
      respond_with(@fortune)
    end

Jak widać możemy usunąć zbędne już wiadomości flash:

    :::ruby app/controllers/fortunes_controller.rb
    def create
      @fortune = Fortune.new(params[:fortune])
      @fortune.save
      respond_with(@fortune)
    end
    def update
      @fortune = Fortune.find(params[:id])
      @fortune.update_attributes(params[:fortune])
      respond_with(@fortune)
    end

Dopiero teraz możemy powiedzieć, że naprawdę **osuszyliśmy**
kod kontrolera.

Dodajemy nowe, krótsze, komunikaty dla Fortunki:

    :::yaml config/locales/responders.en.yml
    flash:
      fortunes:
        create:
          notice: '%{resource_name} was added.'
        update:
          notice: '%{resource_name} was changed.'
        destroy:
          notice: '%{resource_name} was removed.'

Dopisujemy do pliku z layoutem aplikacji element *div*
na wiadomości flash:

    :::rhtml
    <% flash.each do |name, msg| %>
      <%= content_tag :div, msg, :id => "#{name}" %>
    <% end %>

(Pamiętamy, aby usunąć wiadomość flash z widoku *show.html.erb*.)
Dopiero teraz sprawdzamy jak to działa!
No tak, nie wygląda to ładnie! Na razie, trochę
takiego CSS:

    :::css
    #notice, #alert {
      padding: 5px 8px;
      margin: 10px 0;
    }
    #notice {
      background-color: #CFC;
      border: solid 1px #6C6;
    }
    #alert {
      background-color: #FCC;
      border: solid 1px #C66;
    }

Teraz flash powinien wyglądać tak jak to było w Rails 2.


## Łączymy luźne końce – widoki new, edit, index

Cały czas widoki nie są prawidłowe, na przykład
przycisk *submit* nachodzi na linki.
Trzeba będzie to kiedyś poprawić.

Na razie poprawimy tytuły. W taki oto sposób:

    :::rhtml app/views/fortunes/new.html.erb
    <%= title "New fortune" %>
    <%= render :partial => 'form' %>
    <p class="clear"><%= link_to 'Back', fortunes_path %></p>

Powyżej korzystamy z metody pomocniczej *title* z *nifty:layout*.

W kodzie stosujemy się zawsze do zasady DRY, co oznacza „Don’t Repeat Yourself”.
Refaktoryzacja, to też sposób na „osuszanie” kodu.
Pomaga zachować separację części systemu, daje czystą strukturę.

### Refaktoryzacja *index.html.erb*

Przejdziemy z tabelki na inne znaczniki oraz skorzystamy
z *implicit loop*. Zaczynamy od kodu:

    :::rhtml app/views/fortunes/index.html.erb
    <table>
      <tr>
        <th>Source</th><th>Quotation</th><th></th><th></th><th></th>
      </tr>
      <% @fortunes.each do |fortune| %>
       <tr>
        <td><%= fortune.source %></td><td><%= fortune.quotation %></td>
        <td><%= link_to 'Show', fortune %></td>
        <td><%= link_to 'Edit', edit_fortune_path(fortune) %></td>
        <td><%= link_to 'Destroy', fortune, :confirm => t('helpers.data.sure'), :method => :delete %></td>
      </tr>
    <% end %>
    </table>

Po refaktoryzacji, zamiast tabelki wpisujemy:

    :::rhtml app/views/fortunes/index.html.erb
    <div id="fortunes">
      <%= render :partial => 'fortune', :collection => @fortunes %>
    </div>
    <p><%= link_to "New Fortune", new_fortune_path %></p>

Szablon częściowy *_fortune.html.erb* renderowany jest wielokrotnie,
w pętli po zmiennej *fortune* (konwencja *@fortunes* → *fortune*):

    :::rhtml app/views/fortunes/_fortune.html.erb
    <p>
     <b><%= fortune.quotation %></b><br><%= fortune.source %>
    </p>
    <p class="links">
     <%= link_to "Show", fortune_path(fortune) %> |
     <%= link_to "Edit", edit_fortune_path(fortune) %> |
     <%= link_to "Delete", fortune_path(fortune), :confirm => "Are you sure?", :method => :delete %>
    </p>

Po co wkładamy fortunki do pojemnika *div*? Przyda się to przy stylizacji.

Aha, przy okazji zmienimmy napisy na przyciskach *submit*
oraz zlokalizujemy napis „Are you sure?”:

    :::yaml config/locales/en.yml
    helpers:
      submit:
        create: "Create %{model}"
        update: "Change %{model}"
      data:
        sure: "What are you going to do! Are you sure?"

Musimy jeszcze użyć *i18n.translate* w widoku:

    :::rhtml app/views/fortunes/index.html.erb
    <td><%= link_to 'Destroy', fortune, :confirm => t('helpers.data.sure'), :method => :delete %></td>


## Atom

Dopisujemy do kontrolera (z formatu :js skorzystamy go później):

    respond_to :html, :atom, :js

Widok:

    :::ruby app/views/fortunes/index.atom.builder
    atom_feed do |feed|
      feed.title "Moje Fortunki"
      feed.updated @fortunes.first.updated_at
      @fortunes.each do |fortune|
        feed.entry(fortune) do |entry|
          entry.content fortune.quotation, :type => "html"
        end
      end
    end

W layout dopisujemy w znaczniku *head*:

    :::rhtml app/views/layouts/application.html.erb
    <%= auto_discovery_link_tag(:atom, fortunes_path(:atom)) %>


# Dodajemy wyszukiwanie do Fortunek

Na stronie z listą fortunek dodamy formularz, który będzie filtrował dane po polu *quotation*:

    :::rhtml app/views/fortunes/index.html.erb
    <%= form_tag fortunes_path, :method => :get, :id => "fortunes_search" do %>
      <p>
        <%= text_field_tag :search, params[:search] %>
        <%= submit_tag "Search", :name => nil %>
      </p>
    <% end %>

Aby odfiltrować zbędne rekordy, musimy w *FortunesController*
w metodzie *index* przekazać tekst, który wpisano w formularzu
(użyjemy metody *search*, refaktoryzacja):

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.search(params[:search]).order(:source).page(params[:page]).per(4)
      respond_with(@fortunes)
    end

kod metody wpisujemy w klasie *Fortune*:

    :::ruby app/models/fortune.rb
    def self.search(search)
      if search
        where('quotation LIKE ?', "%#{search}%")
      else
        scoped
      end
    end

Metoda *search* jest wykonywana zawsze po wejściu na stronę *index*,
nawet jak nic nie wyszukujemy. (Prześledzić jak ona wtedy działa?
Co to jest *scoped*?)

Dodatkowa lektura:

* Aaron Patterson.
  [Texticle](https://github.com/tenderlove/texticle) –
  full text search capabilities from PostgreSQL
* Florian R. Hanke.
  [Picky](https://github.com/floere/picky) –
  easy to use and fast Ruby semantic search engine.
  Przykłady: [twixtel](http://www.twixtel.ch/),
  [picky simple example](http://picky-simple-example.heroku.com/)


## Ajaxujemy filtrowanie

Trzeba wykonać kilka nieoczywistych rzeczy. Wszystkie szczegóły opisano
w [Search, Sort, Paginate with AJAX](http://asciicasts.com/episodes/240).
Niestety, niektóre rzeczy tam opisane są zbędne albo już nieaktualne
(bo, na przykład, dotyczą *will_paginate*). Ale jest za to opisane
jak dodać **sortowanie**.

Wyszukane fortunki umieścimy w elemencie *div* z id *fortunes*,
a paginator w elemencie *div* z id *paginator*
(po co? zob. kod szablonu poniżej).
Podstawowa rzecz: „To make the paging work with AJAX we need
**to modify the pagination links** so that they make an AJAX
request when clicked instead of linking to another page.”:

    :::rhtml app/views/fortunes/index.html.erb
    <div id="paginator">
      <%= paginate @fortunes, :remote => true %>
    </div>

Żądanie AJAX korzystają z szablonu **index.js.erb**:

    :::jquery_javascript app/views/fortunes/index.js.erb
    // render _fortune.html.erb partial
    $("#fortunes").html("<%= escape_javascript(render(@fortunes)) %>");
    // modify pagination links
    $('#paginator').html('<%= escape_javascript(paginate(@fortunes, :remote => true).to_s) %>');

Sam „search” formularz też należy zajaxować:

    :::rhtml app/views/fortunes/index.html.erb
    <%= form_tag fortunes_path, :remote => true, :method => :get, :id => "fortunes_search" do %>


# Tagowanie

Tagowanie dodamy, korzystając z gemu
[acts-as-taggable-on](http://github.com/mbleigh/acts-as-taggable-on).
Po instalacji gemu, zgodnie z tym o co napisano w *README* wykonujemy
polecenia:

    rails generate acts_as_taggable_on:migration
    rake db:migrate

Warto przyjrzeć się wygenerowanej migracji:

    :::ruby
    class ActsAsTaggableOnMigration < ActiveRecord::Migration
      def self.up
        create_table :tags do |t|
          t.string :name
        end
        create_table :taggings do |t|
          t.references :tag

          # You should make sure that the column created is
          # long enough to store the required class names.
          t.references :taggable, :polymorphic => true
          t.references :tagger, :polymorphic => true

          t.string :context
          t.datetime :created_at
        end
        add_index :taggings, :tag_id
        add_index :taggings, [:taggable_id, :taggable_type, :context]
      end

      def self.down
        drop_table :taggings
        drop_table :tags
      end
    end

<blockquote>
 <p>
  A little inaccuracy saves a world of explanation.
 </p>
</blockquote>

[Polimorficzne powiązanie](http://edgeguides.rubyonrails.org/association_basics.html#polymorphic-associations)
oznacza, że jeden model może być w relacji *belongs_to*
do więcej niż jednego modelu:

    :::ruby
    t.references :taggable, :polymorphic => true

co tłumaczy się na:

    :::ruby
    t.integer :taggable_id
    t.string  :taggable_type

Innymi słowy mamy następujące powiązania między modelami:

* *Tagging* belongs to *Fortune*
* *Fortune* has many *Taggings*

Na konsoli wygląda to tak:

    :::ruby
    f = Fortune.find 1
    f.tag_list = "everything nothing always"            # proxy
    # f.tag_list = ['everything', 'nothing', 'always']  # tak też można
    f.save
    f.tags
    f.taggings


### Dodajemy losowe tagi do fortunek

Poprawiamy *seeds.rb*:

    :::ruby db/seeds.rb
    platitudes = File.readlines(Rails.root.join('db', 'platitudes.u8'), "\n%\n")
    tags = ['always', 'always', 'sometimes', 'never', 'maybe', 'ouch', 'wow', 'nice', 'wonderful']
    platitudes.map do |p|
      reg = /\t?(.+)\n\t\t--\s*(.*)\n%\n/m
      m = p.match(reg)
      if m
        f = Fortune.new :quotation => m[1], :source => m[2]
      else
        f = Fortune.new :quotation => p[0..-4], :source => Faker::Name.name
      end
      f.tag_list = tags.sample(rand(tags.size - 3))
      f.save
    end

Teraz, kasujemy bazę i wrzucamy jeszcze raz cytaty, ale tym razem
z tagami:

    rake db:drop
    rake db:migrate
    rake db:seed


## Zmiany w kodzie modelu

Dopisujemy do modelu:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      acts_as_taggable_on :tags
      ActsAsTaggableOn::TagList.delimiter = " "

Przy okazji, zmieniliśmy domyślny znak do oddzielania tagów z przecinka
na spację.

W widoku częściowym *_form.html.erb* dopisujemy:

    :::rhtml app/views/fortunes/_form.html.erb
    <%= f.input :tag_list, :input_html => {:size => 40} %>

w widoku częściowym *_fortune.html.erb* (część widoku *index.html.erb*),
oraz w widoku *show.html.erb* (2 razy):

    :::rhtml app/views/fortunes/_fortune.html.erb
    <p><i>Tags:</i> <%= @fortune.tag_list %></p>


## Chmurka tagów

Aby utworzyć chmurkę tagów, niestety nie tak ładną jak ta poniżej:

{%= image_tag "/images/wordly.png", :alt => "[chmurka tagów]" %}

dopisujemy do widoku *index*:

    :::rhtml app/views/fortunes/index.html.erb
    <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
      <%= link_to tag.name, LINK_DO_CZEGO?, :class => css_class %>
    <% end %>

Aby ten kod zadziałał musimy zdefiniować zmienną *@tags*, wczytać kod
metody pomocniczej *tag_cloud*, wystylizować chmurkę tagów oraz
podmienić *LINK_DO_CZEGO?* na coś sensownego.

Zaczniemy od zmiennej *@tags*:

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.search(params[:search]).order(:source).page(params[:page]).per(4)
      @tags = Fortune.tag_counts
      respond_with(@fortunes)
    end

Teraz spróbujemy przyjrzeć się bliżej, debugging, zmiennej *tag*:

    :::rhtml
    <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
      <%= link_to tag.name, fortunes_path, :class => css_class %>
      <%= debug(tag.class) %>
      <%= debug(tag) %>
    <% end %>

Po ponownym wczytaniu strony *fortunes\#index* widzimy, że
zmienna *tag*, to obiekt klasy:

    :::ruby
    ActsAsTaggableOn::Tag(id: integer, name: string)

na przykład:

    :::yaml
    attributes:
      id: 1
      name: sometimes
      count: 151

a wygenrowany link, to:

    :::html
    <a href="/fortunes" class="css3">sometimes</a>

Nie jest to to o co nam chodzi.
Później zamienimy ten link na link do tagów.

Tagi powinny mieć wielkość zależną od częstości występowania:

    :::css public/stylesheets/application.css
    .css1 { font-size: 1.0em; }
    .css2 { font-size: 1.2em; }
    .css3 { font-size: 1.4em; }
    .css4 { font-size: 1.6em; }

Tyle debuggowania – usuwamy zbędny kod z *debug*. Opakowujemy *tag_cloud*
elementem *div\#tag_cloud*, ustawiamy jego szerokość, powiedzmy na
250px i pozycjonujemy abolutnie w prawym górnym rogu, gdzie jest
trochę wolnego miejsca:

    :::css public/stylesheets/application.css
    quotation {
      position: relative;
    }
    #tag_cloud {
      background-color: #E1F5C4; /* jasnozielony */
      padding: 1em;
      width: 250px;
      position: absolute;
      right: 1em;
      top: 1em;
    }

I już możemy obejrzeć rezultaty naszej pracy!


## Dodajemy własną akcję do REST

Mając chmurkę z tagami, wypadałoby olinkować tagi tak, aby
po kliknięciu na nazwę wyświetliły się fortunki otagowane
tą nazwą.

Zaczniemy od zmian w routingu. Usuwamy
wiersz z `resources :fortunes`. Zamiast niego wklejamy:

    :::ruby config/routes.rb
    resources :fortunes do
      collection do
        get :tags
      end
    end

Sprawdzamy routing:

    rake routes

i widzimy, że mamy **jeden** dodatkowy uri:

    tags_fortunes GET /fortunes/tags(.:format) {:action=>"tags", :controller=>"fortunes"}

Na koniec, zamieniamy link w chmurce tagów na:

    :::ruby
    <%= link_to tag.name, tags_fortunes_path(:name=>tag.name), :class => css_class %>

Pozostała refaktoryzacja *@tags*, oraz napisanie metody *tags*:

    :::ruby app/controllers/fortunes_controller.rb
    before_filter :only => [:index, :tags] do
      @tags = Fortune.tag_counts
    end

    def index
      @fortunes = Fortune.search(params[:search]).order(:source).page(params[:page]).per(4)
      respond_with(@fortunes)
    end

    # respond_with nic nie wie o tags
    def tags
      @fortunes = Fortune.tagged_with(params[:name]).order(:source).page(params[:page]).per(4)
      respond_with(@fortunes) do |format|
        format.html { render :action => 'index' }
        format.js   { render :action => 'index' }
      end
    end

Gotowe! Przyjrzeć się jak to działa.


<blockquote>
 <p>
  {%= image_tag "/images/surgery.jpg", :alt => "[surgery.com]" %}
 </p>
 <p>Software is invisible and <b>unvisualizable</b>. Geometric abstractions are
  powerful tools. The floor plan of a building helps both architect and
  client evaluate spaces, traffic flows, views. Contradictions and
  omissions become obvious.</p>
 <p>In spite of progress in restricting and simplifying the structures of
  software, they remain inherently unvisualizable, and thus do not
  permit the mind to use some of its most powerful conceptual
  tools. This lack not only impedes the process of design within one
  mind, it severely hinders communication among minds.</p>
 <p class="author">— Frederick P. Brooks, Jr.</p>
</blockquote>

# Fortunki z komentarzami

W widoku *show.html.erb* fortunki powinna być możliwość dopisywania
własnych komentarzy, dodawania obrazków kojarzących się nam
z fortunką. Na początek zabierzemy się za komentarze.

Przygotujemy sobie też stronę ze wszystkimi komentarzami.
Przyda się adminowi przy usuwaniu, edycji komentarzy.

Będziemy pracować na nowej gałęzi:

    git checkout -b comments

Dopiero po sprawdzeniu, że wszystkie zmiany są OK,
wykonamy rebase na master.

Zaczynamy od wygenerowania rusztowania dla zasobu *Comment*:

    rails g resource Comment fortune:references \
        author:string quotation:string

Zagnieżdżamy zasoby i sprawdzamy jak wygląda teraz routing:

    :::ruby
    resources :fortunes do
      resources :comments
      collection do
        get :tags
      end
    end

Po tej zmianie polecenie

    rake routes

wypisuje nowy routing:

                         GET    /fortunes/:fortune_id/comments          {:action=>"index",   :controller=>"comments"}
        fortune_comments POST   /fortunes/:fortune_id/comments          {:action=>"create",  :controller=>"comments"}
     new_fortune_comment GET    /fortunes/:fortune_id/comments/new      {:action=>"new",     :controller=>"comments"}
                         GET    /fortunes/:fortune_id/comments/:id      {:action=>"show",    :controller=>"comments"}
                         PUT    /fortunes/:fortune_id/comments/:id      {:action=>"update",  :controller=>"comments"}
         fortune_comment DELETE /fortunes/:fortune_id/comments/:id      {:action=>"destroy", :controller=>"comments"}
    edit_fortune_comment GET    /fortunes/:fortune_id/comments/:id/edit {:action=>"edit",    :controller=>"comments"}


oraz stary routing, który też obowiązuje:

    tags_fortunes GET    /fortunes/tags     {:action=>"tags",    :controller=>"fortunes"}
                  GET    /fortunes          {:action=>"index",   :controller=>"fortunes"}
         fortunes POST   /fortunes          {:action=>"create",  :controller=>"fortunes"}
      new_fortune GET    /fortunes/new      {:action=>"new",     :controller=>"fortunes"}
                  GET    /fortunes/:id      {:action=>"show",    :controller=>"fortunes"}
                  PUT    /fortunes/:id      {:action=>"update",  :controller=>"fortunes"}
          fortune DELETE /fortunes/:id      {:action=>"destroy", :controller=>"fortunes"}
     edit_fortune GET    /fortunes/:id/edit {:action=>"edit",    :controller=>"fortunes"}

             root        /                  {:controller=>"fortunes", :action=>"index"}

Przechodzimy do modelu *Comment*, gdzie znajdujemy dopisane
przez generator powiązanie:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
    end

Przechodzimy do modelu *Fortune*, gdzie sami dopisujemy drugą stronę powiązania:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      has_many :comments, :dependent => :destroy
      ...

Nie zapominamy o migracji:

    rake db:migrate

Teraz wykonanie na konsoli:

    :::ruby
    Fortune.first.comments  #=> []

pokazuje, że komentarze pierwszej fortunki tworzą pustą tablicę.
Aby dodać komentarz możemy postąpić tak:

    :::ruby
    Fortune.first.comments << Comment.new(:author=>"Ja", :quotation=>"Fajne!")
    Comment.all


### Gdzie będziemy wyświetlać komentarze?

Komentarze dla konkretnej fortunki wypiszemy w jej widoku *show*:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
      <h2>Comments</h2>
      <% @fortune.comments.each do |comment| %>
       <p>Autor:<br><%= comment.author %></p>
       <div class="comment">
         <b>Quotation:</b> <%= comment.quotation %>
       </div>
       <p>
         <%= link_to "Delete", [@fortune, comment], :confirm => t('helpers.data.sure'), :method => :delete %>
       </p>
      <% end %>
    <% end %>

**Jakie nowe rzeczy pojawiły się powyższym kodzie?**


### Gdzie będziemy dodawać nowe komentarze?

Najwygodniej byłoby dodać też formularz do widoku *show*:

    :::rhtml app/views/fortunes/show.html.erb
    <h2>Add new comment</h2>
    <%= simple_form_for [@fortune, @fortune.comments.build] do |f| %>
      <%= f.input :author, :input_html => {:size => 40} %>
      <%= f.input :quotation, :input_html => {:rows => 4, :cols => 40} %>
      <%= f.button :submit %>
    <% end %>

**Nowe rzeczy w kodzie?**
Dlaczego kod ten jest taki pokrętny: **@fortune.comments.build** ?
Czy samo *Comment.new* nie wystarczyłoby?


## Kontroler dla komentarzy

W pustym kontrolerze utworzonym przez generator **uważnie** wpisujemy:

    :::ruby app/controllers/comments_controller.rb
    class CommentsController < ApplicationController
      before_filter do
        @fortune = Fortune.find(params[:fortune_id])
      end

      def create
        @comment = @fortune.comments.build(params[:comment])
        @comment.save
        respond_with(@fortune, @comment, :location => @fortune)
      end

      def destroy
        @comment = @fortune.comments.find(params[:id])
        @comment.destroy
        respond_with(@fortune, @comment, :location => @fortune)
      end
    end

W powyższym kodzie wymuszamy za pomocą konstrukcji z *location*,
przeładowanie strony z fortunką po zapisaniu w bazie
nowej fortunki lub jej usunięciu.

To jeszcze nie wszystko! Musimy napisać metody *edit* oraz *update*.
Należy pomyślić też o widoku do edycji komentarzy!

Ale teraz zabierzemy się za refaktoryzację kodu.


## Refaktoryzacja widoku „show”

Usuwamy kod formularza pod znacznikiem *h2\#Add new comments* powyżej.
Tworzymy z usuniętego kodu szablon częściowy *comments/_form.html.erb*:

    :::rhtml app/views/comments/_form.html.erb
    <%= simple_form_for [@fortune, @comment] do |f| %>
      <%= f.input :author, :input_html => {:size => 40} %>
      <%= f.input :quotation, :input_html => {:rows => 4, :cols => 40} %>
      <%= f.button :submit %>
    <% end %>

**Uwaga:** W usuniętym kodzie należy fragment *@fortune.comments.build*
zamienić na *@comment*, a zmienną *@comment* – zdefiniować
w metodzie *show* kontrolera *FortunesController*:

    :::ruby app/controllers/fortunes_controller.rb
    def show
      @fortune = Fortune.find(params[:id])
      @comment = Comment.new
      respond_with(@fortune)
    end

Następnie usuwamy pętlę pod *h2\#Comments* powyżej. Z ciała tej
pętli tworzymy drugi szablon częściowy *comments/_comment.html.erb*:

    :::rhtml app/views/comments/_comment.html.erb
    <p><i>Autor:</i> <%= comment.author %></p>
    <div class="comment"><i>Quotation:</i>
      <%= comment.body %>
    </div>
    <p>
      <%= link_to "Delete", [@fortune, comment], :confirm => t('helpers.data.sure'), :method => :delete %>
    </p>

Na koniec poprawiamy kod widoku *show*, wstawiając nowe szablony częściowe:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
      <h2>Comments</h2>
      <%= render :partial => 'comments/comment', :collection => @fortune.comments %>
    <% end %>

    <h2>Add new comment</h2>
    <%= render :partial => 'comments/form' %>


## Reszta obiecanego kodu

…czyli metody *edit* oraz *update*:

    :::ruby app/controllers/comments_controller.rb
    def edit
      @comment = @fortune.comments.find(params[:id])
    end

    def update
      @comment = @fortune.comments.find(params[:id])
      @comment.update_attributes(params[:comment])
      respond_with(@fortune, @comment, :location => @fortune)
    end

oraz brakujący link do edycji fortunki:

    :::rhtml app/views/comments/_comment.html.erb
    <%= link_to 'Edit', edit_fortune_comment_path(@fortune, comment) %>

no i szablon widoku – *comments/edit.html.erb*:

    :::rhtml app/views/comments/edit.html.erb
    <% title "Editing comment" %>
    <%= render :partial => 'form' %>
    <p class="links clear">
      <%= link_to 'Show Fortune', @comment.fortune %>
    </p>


## Walidacja komentarzy

Będziemy wymagać aby każde pole było niepuste:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
      validates :author, :presence => true
      validates :body, :presence => true
    end

Musimy też utworzyć widok *comments/new.html.erb*:

    :::rhtml app/views/comments/new.html.erb
    <% title "New comment" %>
    <%= render :partial => 'form' %>
    <p class="links clear"><%= link_to 'Back', @comment.fortune %></p>

Będziemy go potrzebować jak użytkownik kilknie przycisk
„Create Comment” przy jednym z pól pustym.

**BUG:** W Chromie ten kod nie działa. Zamiast Railsów
poprawność danych sprawdza Chrome –
uaktywnia sprawdzanie zawartości pól formularza.

Pojawia się też komunikat po angielsku:

    Please fill out this field.

Często nie w tym polu co trzeba. Gdzie się tłumaczy te komunikaty?
Jak to wyłączyć?


# TODO

* Obrazki w fortunkach: skorzystać z gemu
  [CarrierWave](https://github.com/jnicklas/carrierwave/)
  (zob. też Trevor Turk,
  [A Gentle Introduction to CarrierWave](http://www.engineyard.com/blog/2011/a-gentle-introduction-to-carrierwave/)).
* [Multiple files upload with carrierwave and nested_form](http://lucapette.com/rails/multiple-files-upload-with-carrierwave-and-nested_form/)
