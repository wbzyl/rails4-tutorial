#### {% title "Fortunka v1.0" %}

<blockquote>
 <p>
  {%= image_tag "/images/new-project.jpg", :alt => "[nowy projekt]" %}
 </p>
 <p class="author"><a href="http://www.eyefetch.com/image.aspx?ID=901780">New project car</a></p>
</blockquote>

Jednym ze sprawdzonych sposobów kontynuacji projektu jest rozpoczęcie
go od nowa.

Tym razem nie użyjemy generatora „scaffold”. Skorzystamy z generatora
*responders_controller* z gemu *responders*.

Co na tym zyskujemy opisano tutaj:

* [respond_with, respond_to](http://edgeapi.rubyonrails.org/)
* [Responders](https://github.com/plataformatec/responders)

Ale rusztowanie aplikacji wygenerujemy za pomocą szablonu aplikacji Rails:

    :::bash
    rails new fortune-responders-4.x \
      -m https://raw.github.com/wbzyl/rails4-tutorial/master/lib/doc/app_templates/wbzyl-template-rails4.rb

Link do repozytorium z kodem fortunki
[fortune-responders-4.x](https://github.com/wbzyl/fortune-responders-4.x).


## Robótki ręczne…

Dopisujemy gemy *responders* i *will_paginate* do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'responders', git: 'git://github.com/plataformatec/responders.git'
    gem 'will_paginate', git: 'git://github.com/mislav/will_paginate.git'

Korzystamy z ostatnich wersji gemów z repozytoriów.
Te wersje powinny działać z Rails 4.0.0.rc1.


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

## Instalacja i instalacja następcza

… czyli *install* i *post install*:

    :::bash
    bundle install
    rails generate responders:install
      create  lib/application_responder.rb
     prepend  app/controllers/application_controller.rb
      insert  app/controllers/application_controller.rb
      create  config/locales/responders.en.yml

Jak widać powyżej, generator *responders:install* dodał kilka plików
i dopisał coś do pliku *application_controller.rb*.

*application_responder.rb*:

    :::ruby lib/application_responder.rb
    class ApplicationResponder < ActionController::Responder
      include Responders::FlashResponder
      include Responders::HttpCacheResponder
      # Uncomment this responder if you want your resources to redirect to the collection
      # path (index action) instead of the resource path for POST/PUT/DELETE requests.
      # include Responders::CollectionResponder
    end

Google podpowiada, że *responder* to hiszpańskie słowo na odpowiadać / odezwać / odczytać.
Jak widać w kodzie powyżej mamy do dyspozycji trzy respondery:

* *FlashResponder* (i18n dla komunikatów flash)
* *HttpCacheResponder* (dodaje do żądania nagłówek Last-Modified)
* *CollectionResponder* (po uaktualnieniu lub zapisaniu rekordu w bazie jesteśmu przekierowywani na index)

*app/controllers/application_controller.rb*:

    :::ruby app/controllers/application_controller.rb
    require "application_responder"
    class ApplicationController < ActionController::Base
      self.responder = ApplicationResponder
      respond_to :html
      # Prevent CSRF attacks by raising an exception.
      # For APIs, you may want to use :null_session instead.
      protect_from_forgery with: :exception
    end

*responders.en.yml*:

    :::yaml config/locales/responders.en.yml
    en:
      flash:
        actions:
          create:
            notice: '%{resource_name} was successfully created.'
            # alert: '%{resource_name} could not be created.'
          update:
            notice: '%{resource_name} was successfully updated.'
            # alert: '%{resource_name} could not be updated.'
          destroy:
            notice: '%{resource_name} was successfully destroyed.'
            alert: '%{resource_name} could not be destroyed.'

Generujemy *navbar*:

    :::bash
    rails generate bootstrap:partial navbar
        create  app/views/shared/_navbar.html.erb

dodajemy go do layoutu aplikacji i przy okazji poprawiamy go.


## Co to jest *responders controller*?

Oto odpowiedź:

    :::bash
    rails generate responders_controller
    Usage:
      rails generate responders_controller NAME [field:type field:type] [options]
      ...
    Description:
        Stubs out a scaffolded controller and its views. Different from rails
        scaffold_controller, it uses respond_with instead of respond_to blocks.
        Pass the model name, either CamelCased or under_scored. The controller
        name is retrieved as a pluralized version of the model name.

Generujemy kontroler:

    :::bash
    rails generate responders_controller Fortune quotation:text source:string
      create  app/controllers/fortunes_controller.rb
      invoke  erb
      create    app/views/fortunes
      create    app/views/fortunes/index.html.erb
      create    app/views/fortunes/edit.html.erb
      create    app/views/fortunes/show.html.erb
      create    app/views/fortunes/new.html.erb
      create    app/views/fortunes/_form.html.erb
      ...

*responder controller* definiuje siedem metod:

* *index*, *show*
* *new*, *create*
* *edit*, *update*
* *destroy*

Oto kod wygenerowanego kontrolera:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      def index
        @fortunes = Fortune.all
        respond_with(@fortunes)
      end
      def show
        @fortune = Fortune.find(params[:id])
        respond_with(@fortune)
      end
      def new
        @fortune = Fortune.new
        respond_with(@fortune)
      end
      def edit
        @fortune = Fortune.find(params[:id])
      end
      def create
        @fortune = Fortune.new(params[:fortune])
        @fortune.save
        respond_with(@fortune)
      end
      def update
        @fortune = Fortune.find(params[:id])
        @fortune.update(params[:fortune])
        respond_with(@fortune)
      end
      def destroy
        @fortune = Fortune.find(params[:id])
        @fortune.destroy
        respond_with(@fortune)
      end
    end

Jak widać wygenerowany kontroler nie korzysta ze *strong parameters*.
Dopisujemy brakujący kod i poprawiamy co trzeba. Oto kod po poprawkach:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      before_action :set_fortune, only: [:show, :edit, :update, :destroy]
      def index
        @fortunes = Fortune.all
        respond_with(@fortunes)
      end
      def show
        respond_with(@fortune)
      end
      def new
        @fortune = Fortune.new
        respond_with(@fortune)
      end
      def edit
      end
      def create
        @fortune = Fortune.new(fortune_params)
        @fortune.save
        respond_with(@fortune)
      end
      def update
        @fortune.update(fortune_params)
        respond_with(@fortune)
      end
      def destroy
        @fortune.destroy
        respond_with(@fortune)
      end
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_fortune
        @fortune = Fortune.find(params[:id])
      end
      # Never trust parameters from the scary internet, only allow the white list through.
      def fortune_params
        params.require(:fortune).permit(:quotation, :source)
      end
    end

Pozostał wygenerować model *Fortune*, migracja modelu:

    :::bash
    rails generate model Fortune quotation:text source:string
    rake db:migrate

i zapisanie w bazie jakiś danych testowych:

    rake db:seed

Tagujemy tę wersję:

    git tag v0.1


# Dochodząc do v1.0

Zaczynamy od najłatwiejszej rzeczy – paginacji.
Przeglądają gemy na stronie [Ruby Toolbox](https://www.ruby-toolbox.com/search?utf8=%E2%9C%93&q=pagination)
widzimy, że tak naprawdę mamy tylko jedną opcję:

* [will_paginate](https://github.com/mislav/will_paginate)
* [samples of pagination styles for will_paginate](http://mislav.uniqpath.com/will_paginate/)

Zmiany w kodzie będziemy wprowadzać na osobnej gałęzi:

    :::bash
    git checkout -b pagination

Podmieniamy w kodzie metody *index* kontrolera *FortunesController*:

    :::ruby
    @fortunes = Fortune.order('created_at DESC').page(params[:page]).per_page(4)

Dopisujemy do widoku *index*:

    :::rhtml app/views/fortunes/index.html.erb
    <div class="digg_pagination">
      <div class="page_info">
        <%= page_entries_info @fortunes %>
      </div>
      <%= will_paginate @fortunes, :container => false %>
    </div>

Stylizacja. Korzystamy z gotowego kodu:

* [digg-style, extra content](https://github.com/wbzyl/rat/blob/master/less/digg_pagination.less)

Pobieramy plik i zapisujemy go w katalogu: *app/assets/stylesheets*.
Dopisujemy go do manifestu *application.css.less*:

    :::css
    @import "twitter/bootstrap";
    @import "digg_pagination";

Zrobione? Zrobione!

Zabieramy się za i18n:

* [Translating will_paginate output (i18n)](https://github.com/mislav/will_paginate/wiki/I18n)

Dopisujemy do pliku *en.yml*:

    :::yaml
    en:
      will_paginate:
        previous_label: "«"
        next_label: "»"
        page_gap: "…"
        page_entries_info:
          single_page:
            zero:  "No %{model} found"
            one:   "Displaying 1 %{model}"
            other: "Displaying all %{count} %{model}"
          single_page_html:
            zero:  "No %{model} found"
            one:   "Displaying <b>1</b> %{model}"
            other: "Displaying <b>all&nbsp;%{count}</b> %{model}"
          multi_page: "Displaying %{model} %{from} - %{to} of %{count} in total"
          multi_page_html: "Displaying %{model} <b>%{from} – %{to}</b> of <b>%{count}</b> in total"

(Zamieniam previous, next i page na «, » i …, odpowiednio.)

Wykonujemy commit i na gałęzi master scalamy zmiany i tagujemy tę wersję:

    :::bash
    git merge pagination
    git tag v0.2


## Walidacja

Do czego jest nam potrzebna walidacja wyjaśniono w samouczku
[Active Record Validations](http://edgeguides.rubyonrails.org/active_record_validations.html):

* Baza powinna zawsze zawierać prawidłowe dane.
* Zanim zapiszemy coś w bazie powinniśmy sprawdzić
  czy dane które chcemy umieścić w bazie są poprawne.
* Gdzie to sprawdzenie najlepiej wykonać?
  W przeglądarce? W aplikacji Rails?
  Lepiej w kontrolerze, czy modelu? Dlaczego?
  Może lepiej walidację zostawić serwerowi bazy danych?

Przy okazji warto też przejrzeć samouczek
[Active Record Callbacks](http://edgeguides.rubyonrails.org/active_record_callbacks.html).

Dopisujemy walidację do modelu *Fortune*:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      validates :quotation, presence: true
      validates :quotation, length: { maximum: 256 }
      validates :quotation, uniqueness: { case_sensitive: false }

      validates :source, length: { in: 3..64 }, allow_blank: true
    end

Sprawdzamy na konsoli Rails jak działa walidacja:

    :::ruby
    f = Fortune.new
    f.valid?                   #=> false
    f.errors.messages          #=> {:quotation=>["can't be blank"]}
    f.errors[:quotation].any?  #=> true
    f.save                     #=> false
    f.source = "a"
    f.valid?
    f.errors.messages
    f.source = ""
    f.valid?
    f.errors

Pozostałe rzeczy: *validates_with*, *validates_each*, walidacja warunkowa,
walidacja dla powiązanego modelu *validates_associated*, opcja `:on` –
kiedy walidować (`:create`, `:update`, `:save` itd.)
wyjaśniono w samouczkach.


## TODO: Grand refactoring

W widoku *index* skorzystamy z ***implicit loop***.  Wycinamy kod
z pętlą po *@fortunes* z pliku *index.html.erb*, a ciało pętli:

    :::rhtml app/views/fortunes/index.html.erb
    <article class="index">
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.fortune.quotation" %></span>
        <span class="value"><%= fortune.quotation %></span>
      </div>
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.fortune.source" %></span>
        <span class="value"><%= fortune.source %></span>
      </div>
    <div class="form-actions">
      <%= link_to 'Show', fortune, class: 'btn btn-mini'%>
      <%= link_to 'Edit', edit_fortune_path(fortune), class: 'btn btn-mini'%>
      <%= link_to 'Destroy', fortune, confirm: 'Are you sure?', method: :delete, class: 'btn btn-mini btn-danger'%>
    </div>
    </article>

wklejamy do nowego pliku *_fortune.html.erb* (liczba pojedyncza!)

Podmieniamy zawartość pliku *index.html.erb* na:

    :::rhtml app/views/fortunes/index.html.erb
    ... tytuł i digg pagination bez zmian ...

    <%= render partial: 'fortune', collection: @fortunes %>

    ... div.form-actions ... bez zmian

Szablon częściowy *_fortune.html.erb* renderowany jest wielokrotnie,
w pętli po zmiennej *fortune* (konwencja *@fortunes* → *fortune*):


## Wyszukiwanie w fortunkach

Na stronie z listą fortunek dodamy formularz, który będzie filtrował
dane po polu *quotation*:

    :::rhtml app/views/fortunes/index.html.erb
    <%= form_tag fortunes_path, method: :get, id: "fortunes_search", class: "form-inline" do %>
      <%= text_field_tag :query, params[:query] %>
      <%= submit_tag "Search", name: nil, class: "btn" %>
    <% end %>

Poprawiamy wygląd formularza:

    :::css
    #fortunes_search {
      margin-top: 1em;
      margin-bottom: 2em;
    }
    #query {
      width: 30%;
    }

Aby odfiltrować zbędne rekordy, musimy w *FortunesController*
w metodzie *index* przekazać tekst, który wpisano w formularzu
(użyjemy metody *search*, mała refaktoryzacja):

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.order('created_at DESC')
        .text_search(params[:query])
        .page(params[:page]).per_page(4)
      respond_with(@fortunes)
    end

kod metody wpisujemy w klasie *Fortune*:

    :::ruby app/models/fortune.rb
    def self.text_search(query)
      if query.present?
        # SQLite
        where('quotation like ?', "%#{query}%")
        # PostgreSQL; i – ignore case
        # where("quotation ilike :q or source ilike :q", q: "%#{query}%")
      else
        scoped
      end
    end

Metoda *text_search* jest wykonywana zawsze po wejściu na stronę *index*,
nawet jak nic nie wyszukujemy. Prześledzić działanie *search*? Jak?
Co oznacza *scoped*?

### Nowe idee w wyszukiwaniu

* Florian R. Hanke.
  [Picky](https://github.com/floere/picky) –
  easy to use and fast Ruby semantic search engine.
  Przykłady:
  - [twixtel](http://www.twixtel.ch/),
  - [gemsearch](http://gemsearch.heroku.com/)


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

# Komentarze do fortunek

**TODO (PG_search):** Dodać wyszukiwanie we wszystkich modelach: Fortune, Comment…

W widoku *show.html.erb* fortunki powinna być możliwość dopisywania
własnych komentarzy.

Przygotujemy sobie też stronę ze wszystkimi komentarzami.
Przyda się adminowi przy usuwaniu i edycji komentarzy.

Jak zwykle nowy kod będziemy wpisywać na nowej gałęzi:

    git checkout -b comments

Dopiero po sprawdzeniu, że kod jet OK, przeniesiemy go na gałąź master.

Zaczynamy od wygenerowania rusztowania dla zasobu *Comment*:

    rails g resource Comment fortune:references \
        body:string author:string
    rake db:migrate

Ponieważ do fortunka może mieć wiele komentarzy, zagnieżdżamy
zasoby w tej kolejności:

    :::ruby
    resources :fortunes do
      resources :comments
      collection do
        get :tags
      end
    en

i sprawdzamy jak wygląda routing po tej zmianie:

    :::bash
    rake routes

wypisuje nowy routing:


        fortune_comments GET    /fortunes/:fortune_id/comments(.:format)          comments#index
                         POST   /fortunes/:fortune_id/comments(.:format)          comments#create
     new_fortune_comment GET    /fortunes/:fortune_id/comments/new(.:format)      comments#new
    edit_fortune_comment GET    /fortunes/:fortune_id/comments/:id/edit(.:format) comments#edit
         fortune_comment GET    /fortunes/:fortune_id/comments/:id(.:format)      comments#show
                         PUT    /fortunes/:fortune_id/comments/:id(.:format)      comments#update
                         DELETE /fortunes/:fortune_id/comments/:id(.:format)      comments#destroy


oraz stary routing:

    tags_fortunes GET    /fortunes/tags(.:format)     fortunes#tags
         fortunes GET    /fortunes(.:format)          fortunes#index
                  POST   /fortunes(.:format)          fortunes#create
      new_fortune GET    /fortunes/new(.:format)      fortunes#new
     edit_fortune GET    /fortunes/:id/edit(.:format) fortunes#edit
          fortune GET    /fortunes/:id(.:format)      fortunes#show
                  PUT    /fortunes/:id(.:format)      fortunes#update
                  DELETE /fortunes/:id(.:format)      fortunes#destroy
             root        /                            fortunes#index


Przechodzimy do modelu *Comment*, gdzie znajdujemy dopisane
przez generator powiązanie:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
      attr_accessible :author, :body
    end

Przechodzimy do modelu *Fortune*, gdzie sami dopisujemy drugą stronę powiązania:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      has_many :comments, dependent: :destroy
      ...

Nie zapominamy o migracji:

    rake db:migrate

Wchodzimy na konsolę Rails (*sandbox*):

    :::bash
    rails console --sandbox

Na konsoli wykonujemy:

    :::ruby
    Fortune.first.comments  #=> []

czyli komentarze pierwszej fortunki tworzą pustą tablicę.
Aby dodać komentarz możemy postąpić tak:

    :::ruby
    Fortune.first.comments << Comment.new(author: "Ja", body: "Fajne!")
    Comment.all


### Gdzie będziemy wypisywać komentarze?

Nie ma większego sensu wypisywanie wszystkich komentarzy. Dlatego,
będziemy wypisywać tylko komentarze dla konkretnej fortunki.
Wypiszemy je w widoku *fortunes/show*:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
    <h2>Comments</h2>
      <% @fortune.comments.each do |comment| %>
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.comment.body" %></span>
        <span class="value"><%= comment.body %></span>
      </div>
      <div class="attribute">
        <span class="name"><%= t "simple_form.labels.comment.author" %></span>
        <span class="value"><%= comment.author %></span>
      </div>

      <div class="form-actions">
        <%= link_to 'Destroy', [@fortune, comment], method: :delete, class: 'btn-mini btn-danger'%>
      </div>
      <% end %>
    <% end %>

W taki sposób:

    :::ruby
    link_to 'Destroy', [@fortune, comment]

tworzymy link do zagnieżdżonego zasobu *comments*:

    DELETE /fortunes/:fortune_id/comments/:id    comments#destroy


### Gdzie będziemy dodawać nowe komentarze?

Chyba najwygodniej będzie dodawać komentarze też widoku *show*:

    :::rhtml app/views/fortunes/show.html.erb
    <h2>Add new comment</h2>
    <%= simple_form_for [@fortune, @comment], :html => { :class => 'form-horizontal' } do |f| %>
    <% if f.error_notification %>
    <div class="alert alert-error fade in">
      <a class="close" data-dismiss="alert" href="#">&times;</a>
      <%= f.error_notification %>
    </div>
    <% end %>
    <div class="form-inputs">
      <%= f.input :author %>
      <%= f.input :body %>
    </div>
    <div class="form-actions">
      <%= f.button :submit %>
    </div>
    <% end %>

Musimy jeszcze dopisać w kontrolerze *FortunesController*
definicję *comment* do kodu metody *destroy*:

    :::ruby app/controllers/fortunes_controller.rb
    def show
      @fortune = Fortune.find(params[:id])
      @comment = Comment.new
      respond_with(@fortune)
    end


## Kontroler dla komentarzy

W utworzonym przez generator pustym kontrolerze *CommentsController*
wklepujemy poniższy kod:

    :::ruby app/controllers/comments_controller.rb
    class CommentsController < ApplicationController
      before_filter do
        @fortune = Fortune.find(params[:fortune_id])
      end

      # POST /fortunes/:fortune_id/comments
      def create
        @comment = @fortune.comments.build(params[:comment])
        @comment.save
        respond_with(@fortune, @comment, location: @fortune)
      end

      # DELETE /fortunes/:fortune_id/comments/:id
      def destroy
        @comment = @fortune.comments.find(params[:id])
        @comment.destroy
        respond_with(@fortune, @comment, location: @fortune)
      end
    end

W powyższym kodzie wymuszamy za pomocą konstrukcji z *location*,
przeładowanie strony. Po zapisaniu w bazie nowej fortunki lub po jej
usunięciu będziemy przekierowywanie do widoku *show* dla fortunki
a nie do widoku *show* (którego nie ma) dla komentarzy!

To jeszcze nie wszystko. Musimy napisać metody *edit* oraz *update*.
Być może powinniśmy napisać też widok do edycji komentarzy!

Ale to zrobimy później. Teraz zabierzemy się za refaktoryzację kodu.


## Refaktoryzacja widoku „show”

Usuwamy kod formularza wpisany pod znacznikiem *Add new comment*.
Z usuniętego kodu tworzymy szablon częściowy *comments/_form.html.erb*:

    :::rhtml app/views/comments/_form.html.erb
    <%= simple_form_for [@fortune, @comment], :html => { :class => 'form-horizontal' } do |f| %>
    <% if f.error_notification %>
    <div class="alert alert-error fade in">
      <a class="close" data-dismiss="alert" href="#">&times;</a>
      <%= f.error_notification %>
    </div>
    <% end %>
    <div class="form-inputs">
      <%= f.input :author %>
      <%= f.input :body %>
    </div>
    <div class="form-actions">
      <%= f.button :submit %>
    </div>
    <% end %>

W widoku, zamiast usuniętego kodu wpisujemy:

    :::rhtml app/views/fortunes/show.html.erb
    <h2>Add new comment</h2>
    <%= render partial: 'comments/form' %>

Następnie usuwamy z widoku pętlę pod *Comments*. Z ciała pętli tworzymy
drugi szablon częściowy *comments/_comment.html.erb*:

    :::rhtml app/views/comments/_comment.html.erb
    <div class="attribute">
      <span class="name"><%= t "simple_form.labels.comment.body" %></span>
      <span class="value"><%= comment.body %></span>
    </div>
    <div class="attribute">
      <span class="name"><%= t "simple_form.labels.comment.author" %></span>
      <span class="value"><%= comment.author %></span>
    </div>

    <div class="form-actions">
      <%= link_to 'Destroy', [@fortune, comment], method: :delete, class: 'btn-mini btn-danger'%>
    </div>
    <% end %>

W widoku, zamiast usuniętego kodu wpisujemy:

    :::rhtml app/views/fortunes/show.html.erb
    <% if @fortune.comments.any? %>
    <h2>Comments</h2>
    <%= render partial: 'comments/comment', collection: @fortune.comments %>
    <% end %>



## Reszta obiecanego kodu

…czyli kod metod *edit* i *update*:

    :::ruby app/controllers/comments_controller.rb
    # GET /fortunes/:fortune_id/comments/:id/edit
    def edit
      @comment = @fortune.comments.find(params[:id])
    end

    # PUT /fortunes/:fortune_id/comments/:id
    def update
      @comment = @fortune.comments.find(params[:id])
      @comment.update_attributes(params[:comment])
      respond_with(@fortune, @comment, location: @fortune)
    end

oraz brakujący link do edycji fortunki w widoku *comments/_comment*:

    :::rhtml app/views/comments/_comment.html.erb
    <%= link_to 'Edit', edit_fortune_comment_path(@fortune, comment), class: 'btn-mini' %>

no i szablon widoku – *comments/edit.html.erb*:

    :::rhtml app/views/comments/edit.html.erb
    <% title "Editing comment" %>
    <%= render :partial => 'form' %>
    <div class="form-actions">
      <%= link_to 'Show Fortune', @comment.fortune, class: 'btn' %>
    </div>


## Walidacja komentarzy

Będziemy wymagać, aby każde pole było niepuste:

    :::ruby app/models/comment.rb
    class Comment < ActiveRecord::Base
      belongs_to :fortune
      validates :author, presence: true
      validates :body, presence: true
    end

Musimy też utworzyć widok *comments/new.html.erb*:

    :::rhtml app/views/comments/new.html.erb
    <% title "New comment" %>
    <%= render partial: 'form' %>
    <div class="form-actions">
      <%= link_to 'Back to Fortune', @comment.fortune, class: 'btn' %>
    </div>

Będziemy go potrzebować jak użytkownik kilknie przycisk
„Create Comment” przy jednym z pól pustym.


# Engines are back in Rails… 3.1

Engines to aplikacje Rails, zazwyczajowo zaprogramowana jako gem albo wtyczka.
Na przykład gem *Devise* implementuje autentykację, a – *Kaminari* paginację.

Engines dla Rails wymyślił [James Adams](https://github.com/lazyatom/engines).
Z engines był jeden problem. Nie było gwarancji, że nowa wersja Rails
będzie będzie działać z engines napisanymi dla wcześniejszych wersji Rails.
Wersja Rails 3.1 to zmienia.

Nieco Railsowej archeologii:

* [Guide: Things You Shouldn't Be Doing In Rails](http://glu.ttono.us/articles/2006/08/30/guide-things-you-shouldnt-be-doing-in-rails) –
 artykuł z 2005 roku
* [Odpowiedź J. Adamsa](http://article.gmane.org/gmane.comp.lang.ruby.rails/29166)

Korzystając z engine *Devise* dodać autentykację do Fortunki.

{%= image_tag "/images/head-element.png", :alt => "[source: http://diveintohtml5.org/]" %}<br>
(źródło M. Pilgrim. <a href="http://diveintohtml5.info">Dive into HTML5</a>)


# TODO – [przykład](https://github.com/wbzyl/library-carrierwave)

<blockquote>
<p><a href="http://blog.bigbinary.com/2012/05/10/csrf-and-rails.html">CSRF and Rails</a></p>
<p><a href="http://blog.bigbinary.com/2012/05/10/xss-and-rails.html">XSS and Rails</a></p>
<p class="author">— Neeraj Singh<p>
</blockquote>

Atrakcyjność Fortunki możemy zwiększyć implementując coś rzeczy
wypisanych poniżej:

Zmieniając widok strony głównej aplikacji, na przykład tak:

*  [Isotope](http://isotope.metafizzy.co/)

Dodając obrazki do fortunek,
coś w stylu [Demotywatorów](http://demotywatory.pl/) lub [Kwejka](http://kwejk.pl/).

Możemy skorzystać z gemu *Carrierwave*:

* [home](https://github.com/jnicklas/carrierwave) –
  classier solution for file uploads for Rails, Sinatra and other Ruby web frameworks
* [wiki](https://github.com/jnicklas/carrierwave/wiki)
* [application](https://github.com/jnicklas/carrierwave-example-app/blob/master/app/views/users/_form.html.erb) –
  an example
* [carrierwave-mongoid](https://github.com/jnicklas/carrierwave-mongoid) –
  [Mongoid](http://mongoid.org/en/mongoid/index.html) support for CarrierWave
* [cropping images](http://railscasts.com/episodes/182-cropping-images-revised?view=asciicast) –
  RailsCasts \#182
* Trevor Turk,
  [A Gentle Introduction to CarrierWave](http://www.engineyard.com/blog/2011/a-gentle-introduction-to-carrierwave/)

albo z gemu *Paperclip*:

* [Paperclip](https://github.com/thoughtbot/paperclip)




# TODO: Tagowanie

Tagowanie dodamy, korzystając z gemu
[acts-as-taggable-on](http://github.com/mbleigh/acts-as-taggable-on).
Po dopisaniu gemu do pliku *Gemfile*:

    :::ruby Gemfile
    gem 'acts-as-taggable-on', '~> 2.2.2'

instalujemy go i dalej postępujemy zgodnie z instrukcją z *README*:

    :::bash
    bundle install
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
          # limit is created to prevent mysql error o index lenght for myisam table type.
          # http://bit.ly/vgW2Ql
          t.string :context, :limit => 128
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

co rozwija się do takiego kodu:

    :::ruby
    t.integer :taggable_id
    t.string  :taggable_type

który możemy tak zinterpretować:

* *Tagging* belongs to *Fortune*
* *Fortune* has many *Taggings*


## Zmiany w kodzie modelu

Dopisujemy do modelu:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      acts_as_taggable_on :tags
      ActsAsTaggableOn::TagList.delimiter = " "

Przy okazji, zmieniamy z przecinka na spację domyślny znak
oddzielający tagi.

Po tych zmianach przyjrzymy się bliżej polimorfizowi na konsoli:

    :::ruby
    f = Fortune.find 1
    f.tag_list = "everything nothing always"            # proxy
    # f.tag_list = ['everything', 'nothing', 'always']  # tak też można
    f.save
    f.tags
    f.taggings

W widoku częściowym *_form.html.erb* dopisujemy:

    :::rhtml app/views/fortunes/_form.html.erb
    <%= f.input :tag_list, :input_html => {:size => 40} %>

A w widoku częściowym *_fortune.html.erb* oraz w widoku *show.html.erb* (2 razy)
dopisujemy:

    :::rhtml app/views/fortunes/_fortune.html.erb
    <p><i>Tags:</i> <%= @fortune.tag_list %></p>


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

Teraz, kasujemy bazę i wrzucamy jeszcze raz cytaty, ale tym razem z tagami:

    rake db:drop
    rake db:setup


## Chmurka tagów

Jak samemu wygenerować chmurkę tagów opisał
Jason Davies, [Word Cloud Generator](http://www.jasondavies.com/wordcloud/).

Aby wyrenderować chmurkę tagów – niestety nie tak ładną jak ta:

{%= image_tag "/images/wordly.png", :alt => "[chmurka tagów]" %}

postępujemy tak jak to opisano
w [README](https://github.com/mbleigh/acts-as-taggable-on/blob/master/README.rdoc)
w sekcji „Tag cloud calculations”:

    :::rhtml app/views/fortunes/index.html.erb
    <% tag_cloud(@tags, %w(css1 css2 css3 css4)) do |tag, css_class| %>
      <%= link_to tag.name, LINK_DO_CZEGO?, :class => css_class %>
    <% end %>

Aby ten kod zadziałał musimy zdefiniować zmienną *@tags*, wczytać kod
metody pomocniczej *tag_cloud*, wystylizować chmurkę tagów oraz
podmienić *LINK_DO_CZEGO?* na coś sensownego.

Zaczniemy od zdefiniowania zmiennej *@tags*:

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = ... bez zmian ...
      @tags = Fortune.tag_counts
      respond_with(@fortunes)
    end

Teraz spróbujemy przyjrzeć się bliżej zmiennej *tag*. W tym celu skorzystamy
z metody pomocniczej *debug* (na razie zamiast *LINK_DO_CZEGO?* wpiszemy *fortunes_path*:

    :::rhtml app/views/fortunes/index.html.erb
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

Tagi powinny mieć wielkość zależną od częstości ich występowania:

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
    #tag-cloud {
      background-color: #E1F5C4; /* jasnozielony */
      margin-top: 1em;
      margin-bottom: 1em;
      padding: 1em;
      width: 100%;
    }

I już możemy obejrzeć rezultaty naszej pracy!

Powinniśmy jeszcze dopisać do widoku częściowego *_fortune.html.erb*
kod wypisujący tagi:

    :::rhtml app/views/fortunes/_fortune.html.erb
    <div class="attribute">
      <span class="name"><%= t "simple_form.labels.fortune.source" %></span>
      <span class="value tags"><%= fortune.tag_list.join(", ") %>
      </span>
    </div>


<blockquote>
 {%= image_tag "/images/word-cloud.png", :alt => "[word cloud: REST on wikipedia]" %}
</blockquote>

## Dodajemy własną akcję do REST

Mając chmurkę z tagami, wypadałoby olinkować tagi tak, aby
po kliknięciu na nazwę wyświetliły się fortunki otagowane
tą nazwą.

Zaczniemy od zmian w routingu. Usuwamy wiersz:

    :::ruby config/routes.rb
    resources :fortunes

Zamiast niego wklejamy:

    :::ruby config/routes.rb
    resources :fortunes do
      collection do
        get :tags
      end
    end

Sprawdzamy co się zmieniło w routingu:

    :::bash
    rake routes

i widzimy, że mamy **jeden** dodatkowy uri:

    tags_fortunes GET /fortunes/tags(.:format) {:action=>"tags", :controller=>"fortunes"}

Na koniec, zamieniamy link *fortunes_path* w chmurce tagów na:

    :::rhtml
    <%= link_to tag.name, tags_fortunes_path(name: tag.name), class: css_class %>

Pozostała refaktoryzacja *@tags*, oraz napisanie metody *tags*:

    :::ruby app/controllers/fortunes_controller.rb
    before_filter only: [:index, :tags] do
      @tags = Fortune.tag_counts
    end

    # respond_with nic nie wie o tags
    def tags
      @fortunes = Fortune.tagged_with(params[:name])
        .page(params[:page]).per_page(4)
      respond_with(@fortunes) do |format|
        format.html { render action: 'index' }
      end
    end

    def index
      @fortunes = Fortune.text_search(params[:query])
        .page(params[:page]).per_page(4)
      respond_with(@fortunes)
    end

Zrobione!

    :::bash
    ... interactive rebase ...
    git tag v0.0.4
