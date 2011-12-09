#### {% title "Remote links" %}

* Co oznacza zwrot „remote links”?
* Jak implementujemy „remote links”?
  - Co to jest „Unobtrusive JavaScript” (w skrócie *UJS*)?
  - Co to są „Progressive Enhancements” (stopniowe udoskonalenia)?
* Przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links).

Zaczynamy od przypomnienia przykładów:

    :::bash
    curl -v -X GET -H 'Accept: application/json' http://localhost:3000/fortunes/44
    curl    -X GET -H 'Accept: application/json' http://localhost:3000/fortunes/45
    curl    -X DELETE -H 'Accept: application/json' http://localhost:3000/fortunes/46
    curl -v -X DELETE http://localhost:3000/fortunes/47
    curl    -X DELETE http://localhost:3000/fortunes/48.json
    curl    -X DELETE http://localhost:3000/fortunes/49
    curl -v -X POST -H 'Content-Type: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes.json
    curl    -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' \
      --data '{"quotation":"I hear and I forget."}' http://localhost:3000/fortunes


## Zabawy z przyciskiem *Destroy*

Zmieniony kod metody *destroy*, z której będziemy korzystać:

    :::ruby
    # DELETE /fortunes/1
    # DELETE /fortunes/1.json
    # DELETE /fortunes/1.js
    def destroy
      @fortune = Fortune.find(params[:id])
      @fortune.destroy

      respond_to do |format|
        format.html { redirect_to fortunes_url }
        format.json { render json: @fortune }
        format.js   # destroy.js.erb
      end
    end


### Usuwanie rekordu za pośrednictwem *format.html*

Link z *index.html.erb*:

    :::ruby
    <%= link_to 'Destroy', fortune,
       confirm: 'Are you sure?',
       method: :delete %>


Przykład wygenerowanego kodu HTML:

    :::html
    <a href="/fortunes/1"
       data-confirm="Are you sure?"
       data-method="delete"
       rel="nofollow">Destroy</a>

Jak to działa? Co oznacza kod `rel="nofollow"`?
Skąd się wzięła `1`?


### Usuwanie rekordu za pośrednictwem *format.json*

Zmieniony link z *index.html.erb*:

    :::ruby
    <%= link_to 'Destroy', fortune,
       confirm: 'Are you sure?',
       method: :delete,
       remote: true,
       data: { type: :json } %>

Wygenerowany kod HTML:

    :::html
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

Skorzystamy z gotowych efektów *jQuery UI*. Ze strony
[download](http://jqueryui.com/download) pobieramy paczkę
z efektami „explode”, „fade” i „highlight”.
Po rozpakowaniu, kopiujemy pliki do odpowiednich
katalogów w *vendor/assets*. Skopiowane pliki
dopisujemy do pliku *application.js*

    :::js app/assets/javascripts/application.js
    //= require jquery
    //= require jquery_ujs
    //= require jquery-ui-1.8.16.custom.min
    //= require_tree .

i pliku *application.css.scss*.

    :::css app/assets/stylesheets/application.css.scss
    /*
     *= require formtastic
     *= require bootstrap
     *= require jquery-ui-1.8.16.custom
     *= require_self
     */
    @import "formtastic-container-app.css.scss";
    @import "bootstrap-container-app.css.scss";

**Restartujemy aplikację** i ponownie wchodzimy na stronę główną.
Wchodzimy na konsolę Firebuga, gdzie ręcznie uruchomimy
efekt *explode* na pierwszej fortunce.

Podglądamy atrybut *href* pierwszej fortunki.
Jeśli jest to, na przykład */fortunes/4*, to na konsoli wpisujemy:

    :::js
    r = $("a[href='/fortunes/4']")
    a = r.closest("article")
    a.effect("explode")

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


### Usuwanie rekordu za pośrednictwem *format.js*

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

Cały przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links).

Skorzystamy z wtyczki Bootstrap o nazwie *Modal*.
Pobieramy plik [bootstrap-modal.js](http://twitter.github.com/bootstrap/1.4.0/bootstrap-modal.js)
i zapisujemy go katalogu *vendor/assets/javascripts* aplikacji.
Następnie dopisujemy go do pliku *application.js*:

    :::js app/assets/javascripts/application.js
    //= require jquery
    //= require jquery_ujs
    //= require jquery-ui-1.8.16.custom.min
    //= require bootstrap-modal
    //= require_tree .

Przykładowa strona z Bootstrap Modal Window:

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

Szablon EJS:

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
          // TODO: należy usunąć; nie powinniśmy implementować cacheowania!
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

Na razie przycisk *Close* nie działa. Aby go uaktywnić,
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
