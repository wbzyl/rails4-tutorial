#### {% title "Remote links" %}

* Co oznacza zwrot „remote links”?
* Jak implementujemy „remote links”?
* Co to jest „Unobtrusive JavaScript” (w skrócie *UJS*)?
* Co to są „Progressive Enhancements” (stopniowe udoskonalenia)?



<!-- * Przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links). -->

Do eksperymentów z *remote links* użyjemy aplikacji
[Fortunka](http://sharp-ocean-6085.herokuapp.com/) wdrożonej
na Heroku na poprzednim wykładzie:

    :::bash
    git clone git@heroku.com:sharp-ocean-6085.git
    cd sharp-ocean-6085
    rake db:create
    rake db:migrate # aplikacja korzysta z bazy PostgreSQL; podmienić na SQLite?
    rake db:seed

Kod aplikacji jest też w moim publicznym repo na GitHubie, tutaj –
[sharp-ocean-6085](https://github.com/wbzyl/sharp-ocean-6085).

Eksperymenty z *remote links* będą ciekawsze jeśli
użyjemy biblioteki [jQuery UI](http://jqueryui.com/).
Wykorzystamy efekty [„explode”, „fade” i „highlight”](http://jqueryui.com/demos/effect/).

Po zaznajomieniu się z tymi efektami, zabieramy się do instalacji jQuery UI.
Ze strony [download](http://jqueryui.com/download) pobieramy paczkę
z*theme* (skórką?) **Start** ze wszystkimi efektami (tak będzie wygodniej).

Pobrane archiwum rozpakowujemy:

    :::bash
    unzip jquery-ui-1.8.18.custom.zip

Następnie kopiujemy pliki do odpowiednich katalogów w *vendor/assets*.

    :::bash
    cp  css/start  sharp-ocean-6085/vendor/assets/stylesheets/
    cp  js/jquery-ui-1.8.18.custom.min.js  sharp-ocean-6085/vendor/assets/javascripts/

Skopiowane pliki dopisujemy do pliku *application.js*

    :::js app/assets/javascripts/application.js
    //= require jquery
    //= require jquery_ujs
    //= require twitter/bootstrap
    //= require jquery-ui-1.8.18.custom.min

oraz do pliku *application.css.less*:

    :::css app/assets/stylesheets/application.css.less
    @import "twitter/bootstrap";
    @import "fontawesome";
    @import "digg_pagination";
    @import "start/jquery-ui-1.8.18.custom.css";

Sprawdzamy, czy plik te są wczytywane:

    :::bash
    curl localhost:3000/assets/jquery-ui-1.8.18.custom.min.js
    curl localhost:3000/assets/start/jquery-ui-1.8.18.custom.css
    http://localhost:3000/assets/start/images/ui-bg_inset-hard_100_fcfdfd_1x100.png

Jeśli wszystko działa, to dla rozruszania wykonujemy kilka poleceń
z programem *curl*:

    :::bash
    curl -v -X GET -H 'Accept: application/json' localhost:3000/fortunes/44
    curl    -X GET -H 'Accept: application/json' localhost:3000/fortunes/45
    curl -v -X DELETE localhost:3000/fortunes/2         # wpisujemy numery istniejących fortunek
    curl    -X DELETE localhost:3000/fortunes/3         # jw (już wspomniane)
    curl -v -X DELETE localhost:3000/fortunes/4.json    # jw
    curl -v -X DELETE -H 'Accept: application/json' localhost:3000/fortunes/5

<!--
   te polecenia (ten fragment) / których (który)
   takiej pracy / o jakiej wcześniej rozmawiał (jakie zastępuje przymiotniki)
-->

Po wykonaniu których poleceń na konsolę jest wypisywane:

    :::html
    <html><body>You are being <a href="http://localhost:3000/fortunes">redirected</a>.</body></html>

Dodajemy fortunkę do bazy:

    :::bash
    curl -v -X POST -H 'Content-Type: application/json' \
      --data '{"quotation":"I hear and I forget."}' localhost:3000/fortunes.json
    curl    -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' \
      --data '{"quotation":"I hear and I forget."}' localhost:3000/fortunes

**Uwaga:** W trakcie eksperymentów, cały czas podglądamy co się dzieje
na konsoli przeglądarki (zakładki *Sieć*, *XHR*).


## Zabawy z przyciskiem *Destroy*

Na początek zmienimy nieco kod metody *destroy*:

    :::ruby
    # DELETE /fortunes/1
    # DELETE /fortunes/1.json
    # DELETE /fortunes/1.js
    def destroy
      @fortune = Fortune.find(params[:id])
      @fortune.destroy

      respond_to do |format|
        format.html { redirect_to fortunes_url }
        format.json { head :no_content }         //=? { render json: @fortune }
        format.js   # destroy.js.erb
      end
    end

Po usunięciu fortunki, wykonywana jest
jedna linijka kodu w bloku *respond*:

* *format.html*
* *format.json*
* *format.js*


### Usuwanie rekordu z *format.html*

Wygenerowany przez scaffold link z *index.html.erb*:

    :::rhtml
    <%= link_to 'Destroy', fortune,
       confirm: 'Are you sure?',
       method: :delete %>


Przykład wygenerowanego kodu HTML:

    :::rhtml
    <a href="/fortunes/1"
       data-confirm="Are you sure?"
       data-method="delete"
       rel="nofollow">Destroy</a>

Jak to działa? Co oznacza kod `rel="nofollow"`?
Skąd się wzięła liczba `1`?


### Usuwanie rekordu z *format.json*

Zmienimay kod linku w  pliku *index.html.erb* na:

    :::rhtml
    <%= link_to 'Destroy', fortune,
       confirm: 'Are you sure?',
       method: :delete,
       remote: true,
       data: { type: :json } %>

Wygenerowany kod HTML:

    :::rhtml
    <a href="/fortunes/1"
       data-confirm="Are you sure?"
       data-method="delete"
       data-remote="true"
       data-type="json"
       rel="nofollow">Destroy</a>

Jak to działa? Firefoks, Firebug, zakładka Sieć / XHR, gdzie sprawdzamy
nagłówki zapytania i odpowiedzi.

Po kliknięciu przycisku „Destroy” rekord na który wskazuje atrybut
*href* zostaje usunięty z bazy. Następnie renderowana jest odpowiedź,
przesyłana jako JSON do przeglądarki:

    :::json
    {
      "created_at":"2011-11-25T14:19:04Z",
      "id":9,
      "quotation": "Distrust all those who love you...",
      "source": "Lord Chesterfield",
      "updated_at":"2011-11-25T14:19:04Z"
    }

Cały czas jesteśmy na stronie głównej, która się nie zmienia.
Fortunka usunięta z tabeli jest nadal na stronie.
Powinniśmy ją usunąć. Jak to zrobić?


**Restartujemy aplikację** i ponownie wchodzimy na stronę główną.
Wchodzimy na konsolę Firebuga, gdzie ręcznie uruchomimy
efekt *explode* na pierwszej fortunce.

Podglądamy atrybut *href* pierwszej fortunki na stronie.
Jeśli jest to, na przykład */fortunes/4*, to na konsoli wpisujemy:

    :::js
    r = $("a[href='/fortunes/4']")
    a = r.closest("article")
    a.effect("explode")  // ew. a.effect("explode", "slow")

Wybrana fortunka powinna eksplodować i zniknąć ze strony.

Ten sam efekt powinniśmy uzyskać po wklepaniu następującego kodu
do pliku *fortunes.js* (wcześniej usuwamy plik *fortunes.js.coffee*):

    :::js app/assets/javascripts/fortunes.js
    $(function() {
      $('a[data-type=\"json\"]').bind('ajax:success', function(event, data, status, xhr) {
        $(this).closest('article').effect('explode');
      });
      // $('a[data-type=\"json\"]').bind('ajax:complete', function(event, xhr, status) {
      //   alert('Complete. Record was deleted.')
      // });
    });

*Uwaga:* dopisujemy plik *fortunes.js* do *application.js*.

Oczywiście, w powyższym kodzie nie korzystamy z przesłanych danych.
Ale gdybyśmy zapragnęli umieścić właśnie usuniętą fortunkę na marginesie,
po prawej stronie (element *div[class="span4"]*)…

**Uwaga:** na stronie wiki
[Custom events fired during "data-remote" requests](https://github.com/rails/jquery-ujs/wiki/ajax)
jest podana inna kolejność argumentów dla *ajax-success*.


☕☕ Przechodzimy na *CoffeeScript* ☕☕ Usuwamy plik *fortunes.js*.
Zamiast niego wstawiamy plik *fortunes.js.coffee* o zawartości:

    :::js app/assets/javascripts/fortunes.js.coffee
    jQuery ->
      $('a[data-type="json"]').bind 'ajax:success', (event, data, status, xhr) ->
        $(this).closest('article').effect('explode')


### Usuwanie rekordu z *format.js*

Zmieniony link z *index.html.erb*:

    :::ruby
    <%= link_to 'Destroy', fortune,
       method: :delete,
       remote: true %>

Wygenerowany kod HTML:

    :::html
    <a href="/fortunes/25"
       data-method="delete"
       data-remote="true"
       rel="nofollow">Destroy</a>

Jak to działa? Po kliknięciu przycisku „Destroy” nic się nie dzieje.
Ale na konsoli Rails (i na konsoli Firebuga) pojawia się tak komunikat:

    Template is missing
    Missing template fortunes/destroy, application/destroy with
      {:handlers=>[:erb, :builder, :coffee],
       :formats=>[:js, :html], :locale=>[:en, :en]}.
    Searched in: * "...rails31-remote-links/app/views"

Oznacza to, że w katalogu *app/views* brakuje szablonu *fortunes/destroy.js.erb*.
Tworzymy taki szablon. Na razie, aby sprawdzić czy tak jest naprawdę,
 wpisujemy tylko funkcję *alert*:

    :::js app/views/fortunes/destroy.js.erb
    alert("AJAX: usunięto jakąś fortunkę")

Sprawdzamy, czy to działa. Klikamy przycisk „Destroy” i powinniśmy
zobaczyć w okienku alert zobaczyć powyższy komunikat.

Zamieniamy kod na:

    :::js app/views/fortunes/destroy.js.erb
    $('a[href="<%= fortune_path(@fortune) %>"]').closest('article').effect('explode');


## Remote modal show/new/edit pages

<!-- Cały przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links).-->

Aby było efektownie, skorzystamy z wtyczki Bootstrap o nazwie *Modal*.
Bibliotekę *modal.js* już zainstalowaliśmy.
Możemy to sprawdzić przeklikujac do przegladarki uri poniżej:

    http://localhost:3000/assets/twitter/bootstrap/modal.js

Co to są *modal windows*? Oto przykładowa strona
z Bootstrap Modal Window:

    :::html
    <!doctype html>
    <html>
      <head>
        <meta charset=utf-8>
        <link rel="stylesheet" href="bootstrap.css">
        <script src="http://code.jquery.com/jquery.js"></script>
        <script src="bootstrap-modal.js"></script>
        <title>Bootstrap Modal Windows</title>
      </head>
      <body>
        <a class="btn danger"
          data-controls-modal="my-modal"
          data-backdrop="static" data-keyboard="true">Launch Modal</a>

        <article id="my-modal" class="modal hide fade in">
          <div class="modal-header">
            <div class="close">×</div>
            <h3>Modal Heading</h3>
          </div>
          <div class="modal-body">
            <p>One fine body…</p>
          </div>
        </article>
      </body>
    </html>

Przeanalizować [ten przykład](https://gist.github.com/1450706)
z przyciskiem i funkcją obsługi zdarzenia *onclick* tego przycisku.


### Remote Show

Skorzystamy z szablonów [EJS](https://github.com/sstephenson/ruby-ejs).
Do *Gemfile* dopisujemy i instalujemy ten gem:

    :::ruby Gemfile
    gem 'ejs'

Oto szablon EJS dla *show*:

    :::rhtml app/assets/javascripts/templates/show.jst.ejs
    <article id="<%= modal %>" class="modal hide fade in">
      <div class="modal-header">
        <div class="close">×</div>
        <h3>Fortune #<%= id %></h3>
      </div>
      <div class="modal-body">
        <p><%= quotation %></p>
        <p class="source"><%= source %></p>
      </div>
      <div class="modal-footer">
        <div class="btn default">Close</div>
      </div>
    </article>

W oknie modalnym przycisk *Back* nie ma sensu. Zamienimy go na
przycisk *Close* i dodamy przycisk *Edit*.

Po kliknięciu przycisku *Show*, pobieramy z bazy za pomocą żądania AJAX
JSON-a z danymi. Następnie skorzystamy szablonu EJS do wygenerowania
kodu HTML okna, który po dodaniu do strony, pokazujemy (**TODO**):

    :::js
    $(function() {
      $('.show').bind('click', function() { // show dodano w index.html.erb
        var href = $(this).attr('href');
        var id = href.slice(1).split('/').join('-');  // np. fortune-31
        $.ajax({
          url: href,
          dataType: "json"
        }).done(function(data) {
          // TODO: należy usunąć; sami nie powinniśmy implementować cache!
          if ($('#' + id).length == 0) { // modal is not present
            // use EJS template
            $(".page-header").append(JST["templates/show"]({
              modal: id,
              id: data.id,
              quotation: data.quotation,
              source: data.source }));
          };
          // pokaż okno modalne
          $('#' + id).modal({backdrop: "static", keyboard: true, show: true});
        });
        return false;
      });
    });

**TODO:** Na razie przycisk *Close* nie działa. Aby go uaktywnić,
można dopisać do elementu klasę *close*. Niestety do tej klasy przypisany jest CSS
psujący wygląd przycisku. Dlatego postąpimy tak:


    :::js
    if ($('#' + id).length == 0) { // modal is not present
      // use EJS template
      $(".page-header").append(JST["templates/show"]({
        modal: id,
        id: data.id,
        quotation: data.quotation,
        source: data.source }));
        $(".page-header .default").bind('click', function() {
          $('#' + id).modal('hide');
        });
    };

I to już w zasadzie koniec zabaw z „remote links”.


## Remote Edit

Na początek przerobimy formularz na „remote”, co oznacza że po kliknięciu przycisku
submit będzie wysyłane żądanie AJAX do bazy.

**TODO:** Przykłady są z **Formtastic**.
Kod dla *Simple Form* jest nieco inny. Poprawić!

Przeróbka jest trywialna. Wystarczy dopisać `remote: true` do *semantic_form_for*:

    :::rhtml _form.html.erb
    <%= semantic_form_for @fortune, remote: true do |f| %>

Oto kod HTML wygenerowany z szablonu *_form.html.erb* fortunki:

    :::rhtml
    <div class="form edit">
    <form accept-charset="UTF-8" action="/fortunes/54" class="formtastic fortune" data-remote="true"
          id="edit_fortune_54" method="post" novalidate="novalidate">
        <div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" />
        <input name="_method" type="hidden" value="put" />
        <input name="authenticity_token" type="hidden" value="Ps++PiFakL52X1UuxGHtNsPb3OgNyqOfpqhXyZWT1jE=" /></div>
        ...
        <fieldset class="buttons"><ol>
          <li class="commit button"><input class="update" name="commit" type="submit" value="Update Fortune" /></li>
        </ol>
        ...
      </form>
      <div class="link">
        <a href="/fortunes/55" class="btn primary">Show</a>
        <a href="/fortunes" class="btn primary">Back</a>
      </div>
    </div>

Jak widać, w szablonie skorzystano z wielu metod pomocniczych *Rails* i *Formtastic*.
Wobec tego przepisanie *_form.html.erb* na EJS nie ma większego sensu.

Dlatego postąpimy tak. Wygenerujemy cały formularz na serwerze.
Skorzystamy z takiego szablonu:

    :::rhtml edit.text.html
    <%= render('form') %>

via metoda *edit* z dodanym formatem tekstowym:

    :::ruby
    # GET /fortunes/1/edit
    def edit
      @fortune = Fortune.find(params[:id])

      respond_to do |format|
        format.html # edit.html.erb
        format.text # edit.text.erb
      end
    end

**Dziwne?** Musiałem jeszcze zrobić coś takiego:

    :::bash
    ln -s _form.html.erb _form.text.erb

Inaczej zgłaszany był błąd z powodu brakującego szablonu.

Wyrenderowany(?) kod HTML formularza pobierzemy via AJAX
i wstawimy go do szablonu EJS:

    :::js app/assets/javascripts/application.js
    $('.edit').bind('click', function() {
      var href = $(this).attr('href');
      var id = href.slice(1).split('/').join('-');  // ex. fortune-31-edit

      $.ajax({
        url: href,
        dataType: "text"  // tak wymuszamy format tekstowy
      }).done(function(data) {
        $('#' + id).detach(); // usuwamy okno modalne z DOM
        $(".page-header").append(JST["templates/edit"]({
          modal: id,
          form: data }));

        $("#" + id + " .default").bind('click', function() {
          $('#' + id).modal('hide');  // albo detach?
        });

        $('#' + id).bind('ajax:success', function(event, data, status, xhr) {
          $('#' + id).modal('hide');  // a może detach?
        });
        // TODO: failure

        $('#' + id).modal({backdrop: "static", keyboard: true, show: true});
      });
      return false;
    });

A to użyty powyżej szablon EJS:

    :::rhtml templates/show.jst.ejs
    <article id="<%= modal %>" class="modal hide fade in">
      <div class="modal-header">
        <div class="close">×</div>
        <h3>Edit Fortune</h3>
      </div>
      <div class="modal-body">
        <%= form %>
      </div>
      <div class="modal-footer">
        <div class="btn default">Close</div>
      </div>
    </article>

Do kodu metody *update* musiałem dopisać wiersz z *format.js*:

    :::ruby
    # PUT /fortunes/1
    # PUT /fortunes/1.json
    def update
      @fortune = Fortune.find(params[:id])

      respond_to do |format|
        if @fortune.update_attributes(params[:fortune])
          format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }
          format.json { head :ok }
          format.js { render nothing: true }
        ...

Bez *format.js* renderowane było (Firebug jest wielki ♬♬♬):

    :::ruby
    format.html { redirect_to @fortune, notice: 'Fortune was successfully updated.' }

**Bug?** A powinien być zgłaszany błąd o brakującym szablonie *update.js.erb*.

**Uwaga:** W kodzie powyżej powtarza się ten sam schemat: `# + id` v. `id`.
Coś trzeba z tym zrobić.

Pozostaje przygotować szablon EJS, do którego wstawimy pobrany formularz.
Na koniec całość dodamy do okna modalnego – podobnie jak to zrobiliśmy
w wypadku *show*.


### Nieco CSS

Poprawiamy nieco wygląd widoków:

    :::css app/assets/stylesheets/bootstrap-container-app.css.scss
    .modal {
      padding: 1em;
      h3 {
        font-size: 20px; }
      p {
        font-size: 18px; }
      .source {
        padding-top: 0.5em;
        font-style: italic; }
      .close {
        cursor: pointer;
        padding: 1ex; }
    }


### Dokumentacja

* [Sprockets](http://rubydoc.info/gems/sprockets/2.1.2/file/README.md) – *RubyDoc*
* [Sprocekts](https://github.com/sstephenson/sprockets) – *Github*
* [CSS Cursors](http://www.w3schools.com/cssref/playit.asp?filename=playcss_cursor&preval=default)
* [Humane JS](https://github.com/wavded/humane-js) –
  a simple, modern, browser notification system

Embedded CoffeeScript templates:

* [Eco](https://github.com/sstephenson/eco) –
  embedded CoffeeScript templates
* [Ruby Eco](https://github.com/sstephenson/ruby-eco) –
  a bridge to the official Eco compiler for embedded CoffeeScript templates.

Instalacja:

    :::bash
    gem install coffee-script execjs therubyracer # zależności
    gem install --pre eco-source
    gem install eco
