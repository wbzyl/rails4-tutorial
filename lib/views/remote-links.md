#### {% title "Remote links" %}

* Co oznacza zwrot „remote links”?
* Jak implementujemy „remote links”?
  - Co to jest „Unobtrusive JavaScript” (w skrócie *UJS*)?
  - Co to są „Progressive Enhancements” (stopniowe udoskonalenia)?
* Przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links).

Zaczynamy od przypomnienia przykładów:

    :::bash
    curl -I -X GET -H 'Accept: application/json' http://localhost:3000/fortunes/1
    curl    -X DELETE -H 'Accept: application/json' http://localhost:3000/fortunes/1
    curl -I -X DELETE http://localhost:3000/fortunes/1.json
    curl    -X DELETE http://localhost:3000/fortunes/1
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


### Usuwanie rekordu za pośrednictwem *format.js*

Zmieniony link z *index.html.erb*:

    :::ruby
    <%= link_to 'Destroy', fortune,
       method: :delete,
       remote: true,
       class: "btn danger" %>

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

**TODO**
