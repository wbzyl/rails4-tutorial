#### {% title "Odpowiedzi zależne od nagłówka MIME" %}

<blockquote>
<p>
  While the scaffold generator is great for prototyping, it’s not so great for
  delivering simple code that is well-tested and works precisely the way we would
  like it to.
</p>
<p class="author">— Y. Katz, R. A. Bigg</p>
</blockquote>

Poniższe polecenie:

    :::bash
    rails generate scaffold fortune \
        quotation:text source:string

generuje kod dla zasobu (ang. *resource*) *fortune*:

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      before_action :set_fortune, only: [:show, :edit, :update, :destroy]
      # GET /fortunes
      # GET /fortunes.json
      def index
        @fortunes = Fortune.all
      end
      # GET /fortunes/1
      # GET /fortunes/1.json
      def show
      end
      # GET /fortunes/new
      def new
        @fortune = Fortune.new
      end
      # GET /fortunes/1/edit
      def edit
      end
      # POST /fortunes
      # POST /fortunes.json
      def create
        @fortune = Fortune.new(fortune_params)

        respond_to do |format|
          if @fortune.save
            format.html { redirect_to @fortune, notice: 'Fortune was successfully created.' }
            format.json { render action: 'show', status: :created, location: @fortune }
          else
            format.html { render action: 'new' }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # PATCH/PUT /fortunes/1
      # PATCH/PUT /fortunes/1.json
      def update
        respond_to do |format|
          if @fortune.update(fortune_params)
            format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: 'edit' }
            format.json { render json: @fortune.errors, status: :unprocessable_entity }
          end
        end
      end
      # DELETE /fortunes/1
      # DELETE /fortunes/1.json
      def destroy
        @fortune.destroy
        respond_to do |format|
          format.html { redirect_to fortunes_url }
          format.json { head :no_content }
        end
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

Jak widać, metody wygenrowanego kontrolera potrafią zwrócić odpowiedź
w różnych formatach, HTML i JSON:

* index:
  {%= link_to "index.html.erb", "/rails4/fortunes/index.html.erb" %},
  {%= link_to "index.json.jbuilder", "/rails4/fortunes/index.json.jbuilder" %}
* show:
  {%= link_to "show.html.erb", "/rails4/fortunes/show.html.erb" %},
  {%= link_to "show.json.jbuilder", "/rails4/fortunes/show.json.jbuilder" %}

tylko HTML:

* {%= link_to "\_form.html.erb", "/rails4/fortunes/\_form.html.erb" %}
* {%= link_to "edit.html.erb", "/rails4/fortunes/edit.html.erb" %}
* {%= link_to "new.html.erb", "/rails4/fortunes/new.html.erb" %}

Odpowiedź zależy od nagłówka MIME (tak naprawdę
od nagłówka *Accept*) przekazanego w żądaniu HTTP
lub od roszerzenia w adresie URL.

O kontrolerze wygenerowanym przez generator *scaffold*
mówimy, że jest RESTfull.


## Co to jest REST?

<blockquote>
{%= image_tag "/images/hfrails_cover.png", :alt => "[Head First Rails]" %}
<p>
  If you use REST, your teeth will be brighter,
  your life will be happier,
  and all will be goodnes and sunshine with the world.
</p>
<p class="author">– David Griffiths</p>
</blockquote>

* [How REST replaced SOAP on the Web: What it means to you](http://www.infoq.com/articles/rest-soap)

Krótka historia World Wide Web:

* 1990–91 — Tim Berners-Lee wynalazł i zaimplementował:
  URI, HTTP, HTML, pierwszy serwer WWW, pierwszą przeglądarkę
  („Nexus”), edytor WYSIWYG dla HTML.
* 1993 — Roy Fielding (ten od Apacha) zdefiniował
  *Web’s architectural style WWW*: client-serwer, cache,
  stateless, uniform interface (resources), layered system, code-on-demand
* 2000 — po pokonaniu problemów ze **skalowalnością** WWW,
  Roy Fielding użył nazwy **REST** dla *architectural style* WWW.

Kilka uwag o terminologii:

* The REST architectural style is commonly applied to the design of
  APIs for modern web services.
* Having a REST API makes a web service “RESTful.”
* A REST API consists of an assembly of interlinked resources.

W aplikacjach Rails operacje CRUD wykonujemy korzystając z REST API:

1. Dane są zasobami (ang. *resources*). Fortunka to zbiór
   cytatów, dlatego cytaty są *resources*.
2. Każdy zasób ma swój unikalny URI.

Polecenie:

    :::bash
    rake routes

wypisuje szczegóły REST API aplikacji.


## Rendering response

…czyli renderowaniem odpowiedzi HTTP zajmuje się jeden wiersz
kodu w bloku *respond_to*:

    :::ruby
    respond_to do |format|
      format.html  { redirect_to fortunes_url }
      format.json  { head :no_content }
      format.js    # use destroy.js.erb template
    end

What that says is:

1. If the client wants HTML in response to this
action, redirect and use the default template for this action
(for *index* it is *index.html.erb*).

2. If the client wants JSON, return response 204<br>
(`gem install cheat; cheat http`).

3. If the client wants JS, use the default template
for this action (for *destroy* it is *destroy.js.erb*).

Rails determines the desired response format from
the HTTP **Accept header** submitted by the client.

Klientem może być przeglądarka, ale może też być
inny program, na przykład *curl*:

    :::bash
    curl -I -X GET -H 'Accept: application/json' \
        localhost:3000/fortunes/1
    curl -H 'Accept: application/json' \
        localhost:3000/fortunes/1


## Critical Ruby On Rails Security Issue

W ostatnich wersjach Rails (zob. [Critical Ruby On Rails Issue Threatens 240,000 Websites](http://www.informationweek.com/security/vulnerabilities/critical-ruby-on-rails-issue-threatens-2/240145891)) wymagane jest przesłanie tokena CSRF
(Cross Site Request Forgery).

Token CSRF jest generowany w trakcie renderowania layotu:

    :::rhtml app/views/layouts/application.html.erb
    <%= csrf_meta_tags %>

*Uwaga:* Rails korzysta z *authenticity token* tylko w żądaniach POST,
PUT i DELETE.

Oznacza, to że polecenia z *curl* i z jednym z powyższych VERB zwrócą błąd.

Dlatego dla wygody,  w trakcie poniższych eksperymentów z programem *curl* (lub na
konsoli przeglądarki) powinniśmy wykonać jedną z trzech rzeczy:

1\. Usunąć zabezpieczenie CSRF z layoutu.<br>
**Uwaga:** Niestety to nie działa od 2013.04. Dostajemy komunikat:

    curl -I -X DELETE localhost:3000/fortunes/1.json
    HTTP/1.1 422 Unprocessable Entity

Co to oznacza?

2\. Dodać ten kod do kodu kontrolera
[ApplicationController](http://edgeapi.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html):

    :::ruby
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception
      skip_before_action :verify_authenticity_token, if: :json_request?

      protected
      def json_request?
        request.format.json?
      end
    end

Teraz poniższe polecenia powinny wykonać się bez błędów:

    :::bash
    curl    -X DELETE \
       -H 'Accept: application/json'\
       localhost:3000/fortunes/1
    curl -I -X DELETE \
       localhost:3000/fortunes/1.json
    # mało eleganckie; ale też działa
    curl -I -X DELETE \
       localhost:3000/fortunes/1

    curl -v -X POST \
      --data-urlencode "fortune[quotation]=I hear and I forget" \
      --data-urlencode "fortune[source]=unknown" \
      localhost:3000/fortunes.json
    curl    -X POST \
      -H 'Content-Type: application/json' \
      --data-urlencode "fortune[quotation]=I hear and I forget." \
      --data-urlencode "fortune[source]=unknown" \
      localhost:3000/fortunes

W powyższych poleceniach zamiast `--data-urlencode`
można użyć `--data`, lub `-d`:

    :::bash
    curl -v -X POST \
      -d "fortune[quotation]=I hear and I forget" \
      -d "fortune[source]=unknown" \
      localhost:3000/fortunes.json

Nie musimy nic zmieniać w kodzie aplikacji, aby zostały wykonane
powyższe polecenia.
Możemy je wykonać wysyłając z konsoli odpowiednio przygotowane
żądanie AJAX. Na przykład, tak usuniemy rekord z *id=6*:

    :::js
    $.ajax({
      url: 'http://localhost:3000/fortunes/6.json',
      type: 'DELETE',
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    })

(W kodzie powyżej korzystam z *jQuery*).

Ten sposób ma tę wadę, że musimy być na stronie aplikacji.
Inaczej nie odszukamy "csrf-token".
Tej wady nie ma poniższy, choć dwuetapowy, sposób.

3\. Pobieramy ciasteczko oraz odfiltrowujemy token CSRF:

    :::bash
    # zapisujemy cookie do pliku *cookie*
    curl -s localhost:3000/fortunes --cookie-jar cookie  | grep csrf

Kopiujemy token CSRF do polecenia poniżej, na przykład:

    :::bash
    curl -X DELETE -H 'X-CSRF-Token: 0Dm3mqmcWcajzHkSAzqczDnLllmhlVVaNYB5Fo1tYA0=' \
      --cookie cookie localhost:3000/fortunes/10.json

Ponieważ nie było przekierowania, możemy ponownie użyć tego samego tokenu
do usunięcia kolejnego rekordu:

    :::bash
    curl -X DELETE -H 'X-CSRF-Token: 0Dm3mqmcWcajzHkSAzqczDnLllmhlVVaNYB5Fo1tYA0=' \
      --cookie cookie localhost:3000/fortunes/11.json

Dodatkowa lektura:

* [Using cURL to automate HTTP jobs ](http://curl.haxx.se/docs/httpscripting.html);
  polskie tłumaczenie (starej wersji, niestety) – Rafał Machtyl,
  [Sztuka pisania skrypów z żądaniami HTTP przy użyciu cURL](http://asciiwhiteplayground.site88.net/curl.html)
* [Understand Rails Authenticity Token](http://stackoverflow.com/questions/941594/understand-rails-authenticity-token)
* [**cURLing with Rails’ authenticity_token**](http://robots.thoughtbot.com/post/3035393350/curling-with-rails-authenticity-token)
* [WARNING: Can’t verify CSRF token authenticity Rails](http://stackoverflow.com/questions/7203304/warning-cant-verify-csrf-token-authenticity-rails)


Linki do dokumentacji:

* [respond_to](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_to)
* [respond_with](http://api.rubyonrails.org/classes/ActionController/MimeResponds.html#method-i-respond_with),
  [ActionController::Responder](http://api.rubyonrails.org/classes/ActionController/Responder.html)


## Odpowiedź CSV generowana przez kontroler

W pliku *fortunes_controller.rb* podmieniamy kod metody
*index* na:

    :::ruby app/controllers/fortunes_controller.rb
    def index
      @fortunes = Fortune.all
      respond_to do |format|
        format.html
        format.csv { send_data @fortunes.to_csv, filename: "fortunes-#{Date.today}.csv" }
      end
    end

Dopisujemy w pliku *application.rb*:

    :::ruby config/application.rb
    require File.expand_path('../boot', __FILE__)
    require 'csv'        #<= NEW!

W kodzie modelu *Fortune* dodajemy metodę *to_csv*:

    :::ruby app/models/fortune.rb
    def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |fortune|
          csv << fortune.attributes.values_at(*column_names)
        end
      end
    end

*Uwaga:* W metodzie *to_csv* możemy podać nazwy kolumn, na przykład:

    :::ruby
    def self.to_csv
      CSV.generate do |csv|
        csv << ["last_name", "first_name"]
        all.each do |list|
          csv << list.attributes.values_at("last_name", "first_name")
        end
      end
    end

Sprawdzamy jak to działa:

    :::bash
    curl http://localhost:3000/fortunes.csv

Możemy też dodać na stronie *index.html.erb* link:

    :::rhtml
    <p>Pobierz:
      <%= link_to "Export to CSV", fortunes_path(format: "csv") %> |
    </p>

i kliknąć go.

Zobacz też:

* gem [axlsx](https://github.com/randym/axlsx) –
  xlsx generation with charts, images, automated column width,
  customizable styles and full schema validation
* [eksport do arkusza kalkulacyjnego](http://railscasts.com/episodes/362-exporting-csv-and-excel)


## Odpowiedź CSV z szablonu index.csv.ruby

W pliku *fortunes_controller.rb* podmieniamy kod metody
*index* na:

    :::ruby
    def index
      @fortunes = Fortune.all

      respond_to do |format|
        format.html
        format.csv
      end
    end

i w pliki *index.csv.ruby* wpisujemy:

    :::ruby app/views/lists/index.csv.ruby
    "hello CSV world"

Teraz sprawdzamy czy aplikacja użyje tego pliku:

    :::bash
    curl localhost:3000/fortunes.csv

Jeśli na konsoli zostanie wypisany napis `hello world`
będzie to oznaczać że kod zadziałał.

Teraz podmieniamy zawartość pliku *index.csv.ruby* na:

    :::ruby
    response.headers["Content-Disposition"] = "attachment; filename='fortunes-#{Date.today}.csv'"

    CSV.generate do |csv|
      csv << ["id", "quotation", "source"]
      @fortunes.each do |fortune|
        csv << [
          fortune.id,
          fortune.quotation,
          fortune.source
        ]
      end
    end

I jeszcze raz sprawdzamy czy to działa.


## Markdown via Ruby Template Handler

Zdefiniujemy swój program obsługi plików w formacie Markdown.
Powiążemy go z rozszerzeniami *.md* i *.markdown*.
Oznacza to, na przykład, że **zamiast** widoku *show.html.erb*
będzie można użyć widoku *show.html.md*

Program obsługi zaimplementujemy tak, aby w widokach można było użyć
wstawek ERB.

W kodzie skorzystamy z gemu *redcarpet*:

    :::ruby Gemfile
    gem "redcarpet"

Przykładowa implementacja:

    :::ruby config/initializers/markdown_template_handler.rb
    class MarkdownTemplateHandler
      def self.call(template)
        erb = ActionView::Template.registered_template_handler(:erb)
        source = erb.call(template)
        <<-SOURCE
        renderer = Redcarpet::Render::HTML.new
        options = { fenced_code_blocks: true }
        Redcarpet::Markdown.new(renderer, options).render(begin;#{source};end)
        SOURCE
      end
    end
    ActionView::Template.register_template_handler(:md, :markdown, MarkdownTemplateHandler)

Zob. [RailsCasts \#379](http://railscasts.com/episodes/379-template-handlers).

Teraz po usunięciu szablonu *show.html.erb*:

    :::bash
    rm app/views/fortunes/show.html.erb

i utworzeniu szablonu *show.html.md*, na przykład takiego:

    :::rhtml app/views/fortunes/show.html.md
    <%- model_class = Fortune -%>
    <div id="notice" class="alert alert-success" role="alert"><%= notice %></div>

    <%= @fortune.quotation %>

    *<%= @fortune.source %>*

    [Back](<%= fortunes_path %>) |
    [Edit](<%= edit_fortune_path(@fortune) %>) |
    <%= link_to 'Destroy', fortune_path(@fortune),
      method: :delete, data: { confirm: 'Are you sure?' },
      class: 'btn btn-danger' %>

zostanie on użyty zamiast usuniętego szablonu *.html.erb*.

Zobacz też José Valim, [Multipart templates with Markerb](http://blog.plataformatec.com.br/2011/06/multipart-templates-with-markerb/).
Nazwa gemu [markerb](https://github.com/plataformatec/markerb) to skrót na
„multipart templates made easy with Markdown + ERb”.
