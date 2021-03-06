#### {% title "Remote links ☯" %}

* Co oznacza zwrot „remote links”?
* Jak implementujemy „remote links”?
* Co to jest „Unobtrusive JavaScript” (w skrócie *UJS*)?
* Co to są „Progressive Enhancements” (stopniowe udoskonalenia)?

<!-- * Przykład jest [tutaj](https://github.com/wbzyl/rails31-remote-links). -->

Do eksperymentów z *remote links* użyjemy aplikacji
[Fortunka v0.0](https://github.com/rails4/my_fortune0) wdrożonej
na Heroku na jednym z poprzednich wykładów:

    :::bash
    git clone git@github.com:rails4/my_fortune0.git
    cd my_fortune0
    rake db:create
    rake db:migrate # aplikacja korzysta z bazy SQLite
    rake db:seed

Eksperymenty przeprowadzimy na osobnej gałęzi:

    :::bash
    git checkout mime_types
    git checkout remote_links
    git push origin remote_links

Eksperymenty na konsoli będą przyjemniejsze jeśli usuniemy
zabezpieczenie CSRF. Można tego nie robić, ale wtedy zamiast jednego
polecenia na konsoli trzeba będzie ich wykonać kilka.

## ☯ program curl jest cool

Zaczniemy, dla przypomnienia, od wykonania tych poleceń:

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


## Instalujemy jQuery UI

Eksperymenty z *remote links* będą ciekawsze jeśli
użyjemy biblioteki [jQuery UI](http://jqueryui.com/).
W przykładach poniżej skorzystamy z efektów
[„explode”, „fade” i „highlight”](http://jqueryui.com/demos/effect/).

Instalacja jQuery UI na skróty:

* [jquery-ui-rails](https://github.com/joliss/jquery-ui-rails)


## ☢ Obsługa przycisku *Destroy*

Zaczniemy od dopisania do metody *destroy* kodu obsługującego format
JavaScript:

    :::ruby
    # DELETE /fortunes/1
    # DELETE /fortunes/1.json
    # DELETE /fortunes/1.js
    def destroy
      @fortune = Fortune.find(params[:id])
      @fortune.destroy

      respond_to do |format|
        format.html { redirect_to fortunes_url }
        format.json { head :no_content }
        format.js   # use the default template: destroy.js.erb
      end
    end

Kiedy usuwamy fortunkę, wykonywana jest jedna linijka kodu w bloku *respond*:

* *format.html*
* *format.json*
* *format.js*

Która jest to linijka kodu? Zależy to od nagłówków żądania, bądź od zapytania
(zob. `rake routes`).


## ☢ Usuwanie rekordu via *format.html*

Wygenerowany przez scaffold link z pliku *index.html.erb*:

    :::rhtml
    <%= link_to 'Destroy', fortune,
      method: :delete,
      data: { confirm: 'Are you sure?' } %>

i wyrenderowany z niego kod HTML:

    :::rhtml
    <a data-confirm="Are you sure?"
      rel="nofollow"
      data-method="delete"
      href="/posts/1">Destroy</a>

Jak to działa? Co oznacza `rel="nofollow"`?
I skąd się wzięła liczba `1`?


## ☢ Usuwanie rekordu via *format.json*

Zmieniamy argumenty wywołania `link_to` powyżej na:

    :::rhtml
    <%= link_to 'Destroy', fortune,
      method: :delete,
      data: {
        confirm: 'Are you sure?',
        type: :json
      },
      remote: true %>

Po wyrenderowaniu otrzymujemy taki kod HTML:

    :::rhtml
    <a href="/fortunes/1"
       data-method="delete"
       data-confirm="Are you sure?"
       data-type="json"
       data-remote="true"
       rel="nofollow">Destroy</a>

**Uwaga:** Po dodaniu `remote: true` usuwanie rekordów
za pomocą przycisku *Destroy* nie będzie działać.
Dlaczego? Podpowiedzi szukamy w zakładce Sieć / XHR
rozszerzenia Firebug dla przegladarki Firefoks.

Po kliknięciu w przycisk **Destroy** powinniśmy być ciągle na tej samej,
stronie (*index.html.erb*), a usunięta przed chwilą fortunka
nadal powinna być wyświetlana.

Oczywiście, powinniśmy ją usunąć ze strony. Ale jak to zrobić?


## Ręczna symulacja efektów na konsoli

Do usunięcia fortunki ze strony użyjemy efektu *explode*.
W tym celu wchodzimy na stronę główną aplikacji, gdzie otwieramy okno z konsolą
JavaScript (Chrome – Shift+Ctrl+J, Firefox+Firebug – F12).

Podglądamy id pierwszej na stronie fortunki.
Jeśli jest to, na przykład */fortunes/4*, to na konsoli wpisujemy:

    :::js
    r = $("a[href='/fortunes/4']")
    a = r.closest("tr")
    a.effect("explode")  // ew. a.effect("explode", "slow")

Wybrana fortunka powinna zniknąć ze strony,
ale z bazy nie zostanie usunięta.

<blockquote>
  <h2>Ściąga ze zdarzeń</h2>
<ul>
 <li>obsługa zdarzeń:
  zdarzenie może obsłużyć dowolna funkcja JavaScript;
  funkcję obsługującą zdarzenie można przypisać do dowolnego
  elementu html, może być uruchamiane po załadowaniem strony, itd;
  zdarzenia można też definiować samemu, np. <i>ajax:success</i>
 <li>przykładowe zdarzenia obsługiwane przez przeglądarkę:
  onclick, onmouseover, onsubmit, onload…
 <li>kiedy zachodzi jakieś zdarzenie do którego przypisano
  jakieś funkcje to zostaną one wszystkie wykonane;
  jeśli takich funkcji nie przypisano – nic się nie dzieje
 <li><a href="http://www.quirksmode.org/js/events_order.html">co to jest bubbling</a>?
 <li>jak przypisać funkcję obsługującą zdarzenie?
  jak powiązać jakieś zdarzenie z funkcją?
  najwygodniej jest skorzystać z funkcji zdefiniowanych w jQuery
</ul>
  {%= image_tag "/images/bubbles.jpg", :alt => "[Save the Bubbles!]" %}
</blockquote>

Ten sam efekt uzyskamy po wklejeniu poniższego kodu do pliku
*application.js*:

    :::js app/assets/javascripts/application.js
    $(function() {
      $('a[data-type=\"json\"]').on('ajax:success',
         function(event, data, status, xhr) {
           $(this).closest('tr').effect('explode', 1000);
         }
      );
    });

Jednak tym razem kliknięta fortunka zostanie usunięta z bazy.

<!--
  * opóźnienia i interwały
  * setTimeout  – wykonać kod **za** jakiś czas
  * setInterval – wykonać kod **co** jakiś czas
-->

Powyżej korzystamy ze zdarzenia *ajax:success* zdefiniowanego
w [jQuery Rails](https://github.com/rails/jquery-ujs)
(*unobtrusive scripting adapter for jQuery*).
Na stronie wiki [Custom events fired during „data-remote” requests](https://github.com/rails/jquery-ujs/wiki/ajax)
znajdziemy opis pozostałych zdarzeń.

### ☕☕ Przechodzimy na *CoffeeScript*

☕☕ Usuwamy plik *fortunes.js*.
Zamiast niego wstawiamy plik *fortunes.js.coffee* o zawartości:

    :::js app/assets/javascripts/fortunes.js.coffee
    jQuery ->
      $('a[data-type="json"]').bind 'ajax:success',
        (event, data, status, xhr) ->
          $(this).closest('tr').effect('explode', 1000)

i nazwę tego pliku dopisujemy do *application.js*.


## Usuwanie rekordu via *format.js*

Zmieniony link z *index.html.erb* (z usuniętym atrybutem *data-confirm*):

    :::rhtml
    <%= link_to 'Destroy', fortune,
       method: :delete,
       remote: true %>

Wygenerowany kod HTML:

    :::html
    <a href="/fortunes/25"
       data-method="delete"
       data-remote="true"
       rel="nofollow">Destroy</a>

Jak to działa? Po tych zmianach i odświeżeniu zawartości strony,
kliknięcie przycisku „Destroy” nie daje widocznego efektu.
Ale na konsoli JavaScript pojawia się komunikat:

    DELETE http://localhost:3000/fortunes/8 500 (Internal Server Error)

a w logach aplikacji znajdujemy:

    ActionView::MissingTemplate
    (Missing template fortunes/destroy, application/destroy with
       {:locale=>[:en], :formats=>[:js, :html], :handlers=>[:erb, :builder, :coffee]}.
    Searched in: * ".../sharp-ocean-6085/app/views"):
    app/controllers/fortunes_controller.rb:78:in destroy

Oznacza to, że w katalogu *app/views* brakuje szablonu *fortunes/destroy.js.erb*.
Tworzymy taki szablon. Na razie, aby sprawdzić czy dobrze
rozszyfrowaliśmy te komunikaty, wpisujemy w nim funkcję *alert*:

    :::js app/views/fortunes/destroy.js.erb
    alert("SUCCESS: usunięto fortunkę");

Sprawdzamy, czy *alert* działa. Klikamy przycisk „Destroy”.
Powinno się pojawić okienko alert.

Jeśli wszystko działa, wymieniamy kod na taki:

    :::js app/views/fortunes/destroy.js.erb
    $('a[href="<%= fortune_path(@fortune) %>"]').closest('tr').effect('explode');

gdzie zmienną *@fortune_path* zdefiniowaliśmy w kontrolerze:

    :::ruby
    def destroy
      # @fortune = Fortune.find(params[:id])
      @fortune.destroy
      respond_to do |format|
        format.html { redirect_to fortunes_url }
        format.json { head :no_content }          #=? { render json: @fortune }
        format.js   # destroy.js.erb
      end
    end

Zobacz też dyskusję na *stack**overflow***,
[Can Rails Routing Helpers (i.e. mymodel_path(model)) be Used in Models?](http://stackoverflow.com/questions/341143/can-rails-routing-helpers-i-e-mymodel-pathmodel-be-used-in-models).


## Modal window for show method

*Uwaga:* Analogicznie możemy przygotować strony dla metod *new* i *edit*.

Co to są *modals*? Opis i demo znajdziemy w dokumentacji
[JavaScript plugins](http://getbootstrap.com/javascript/#modals).

Spróbujemy użyć *modal windows* do uproszczenia interfejsu — Show+New+Edit.

Bibliotekę *modal.js* powinna być już zainstalowana.
Możemy to sprawdzić przeklikujac do przegladarki uri poniżej:

    http://localhost:3000/assets/twitter/bootstrap/modal.js

Powinien się pojwić kod wtyczki.

Zaczniemy od bliższego przyjrzenia się okienkom modalnym
frameworka Bootstrap:

    :::bash
    rails g controller Modals index

W pliku *index.html.erb* podmieniamy wygenerowany kod na:

    :::html
    <button type="button" class="btn btn-primary btn-lg" data-toggle="modal" data-target="#myModal">
      Trigger Modal
    </button>
    <div id="myModal" class="modal fade">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">Modal title</h4>
          </div>
          <div class="modal-body">
            <p>One fine body…</p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary">Save changes</button>
          </div>
        </div><!-- /.modal-content -->
      </div><!-- /.modal-dialog -->
    </div><!-- /.modal -->

Zmieniamy wygenerowany routing na:

    :::ruby
    get "modals", to: "modals#index"

Oknem modalnym możemy też manipulować z konsoli JavaScript,
na przykład tak:

    :::js
    $('#myModal').modal('show')
    $('#myModal').modal('hide')
    $('#myModal').modal('toggle')
    $('#myModal').modal('toggle')

Możemy też przy okazji wykonywania show/hide/toggle wykonać
dowolny kod JavaScript:

    :::js app/assets/javascripts/application.js
    $(function() {
      console.log("wire up the buttons to dismiss the modal when shown");

      $("#myModal").bind("show.bs.modal", function() {
        console.log("#myModal was shown");
        $("#myModal button").click(function(e) {
          // do something whenever one of the buttons is clicked
          // for demo purposes write to console the content of h4 element
          console.log("h4 content: " + $(this).html());
          // and hide the modal window
          $("#myModal").modal('hide');
        });
      });

      // remove the event listeners when the modal window is hidden
      $("#myModal").bind("hide.bs.modal", function() {
        console.log("remove event listeners on the buttons");
        $("#myModal button").unbind();
      });
    });


## Remote Show + EJS

*EJS* to skrót od [Embedded JavaScript Template](http://www.embeddedjs.com).
Szablony EJS kompilowane są do kodu JavaScript.
W naszej aplikacji użyjemy kompilatora
[EJS](https://github.com/sstephenson/ruby-ejs)
napisanego w języku Ruby przez Sama Stephenson.

Kompilator instalujemy dopisując gem *ejs* do pliku *Gemfile*

    :::ruby
    gem 'ejs', '~> 1.1.1'

Oto szablon EJS dla *show*:

    :::rhtml app/assets/javascripts/templates/show.jst.ejs
    <article id="<%= modal %>" class="modal hide fade">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h3 class="modal-title">Fortune #<%= id %></h3>
          </div>
          <div class="modal-body">
            <p><%= quotation %></p>
            <p class="source"><%= source %></p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </article>

*Uwaga:*
Jak przekazywane są zmienne do szablonu jest pokazane w jednym
z przykładów poniżej.

Ścieżkę do szablonu dopisujemy do pliku *application.js*:

    :::js app/assets/javascripts/application.js
    //= require jquery
    //= require jquery_ujs
    //= require twitter/bootstrap
    //= require templates/show

W oknie modalnym dla *Show* usunąłem przycisk *Back*.
W tym kontekście nie ma on sensu. Dlaczego?

Jeśli dodamy tylko *remote* do przycisku z *Show*, to kod nie
będzie rozróżniał przycisków *Show* i *Destroy*.
Dlatego do listy wartości atrybutu *class* dopiszemy **show**:

    :::rhtml app/views/fortunes/index.html.erb
    <%= link_to 'Show', fortune,
          remote: true,
          data: { type: :json },
          class: "show btn btn-default btn-sm" %>

Dopisujemy do listy *class* `show`, tak aby odróżnić przycisk *Show*
od pozostałych przycisków, np. *Edit*.  

Sprawdzamy jak działa takie remote. W tym celu wklejamy
do *application.js* poniższy kod
([CSS3: Attribute selectors](http://www.css3.info/preview/attribute-selectors/)):

    :::js app/assets/javascripts/application.js
    $(function() {
      $('a[class^=show]').bind('ajax:success',
            function(event, data, status, xhr) {
        console.log('show button clicked');
        console.log(data);
      });
    });

Czy ten kod działa sprawdzamy na konsoli przeglądarki.
Po kliknięciu w przycisk *Show* powinniśmy zobaczyć wypisany JSON
z wpisaną klikniętą fortunką.

Jeśli powyższy kod działa, to możemy zabrać się za podłączanie okna modalnego:

    :::js app/assets/javascripts/application.js
    $(function() {
      $('a[class^=show]').bind('ajax:success', function(event, data, status, xhr) {
        $('body').append(JST["templates/show"]({
          modal: 'fortune-modal',  // jakiś unikalny identyfikator
          id: data.id,
          quotation: data.quotation,
          source: data.source }));
        $('#fortune-modal').on('hidden.bs.modal', function() {
          $('.modal').remove();  // remove modal window from DOM
        });
        $('#fortune-modal').modal('show');
      });

      // $('a[class^=destroy]').bind('ajax:success', function(event, data, status, xhr) {
      //   $(this).closest('article').effect('explode');
      // });
    });


<blockquote>
  <p>A little inaccuracy saves a world of explanation.</p>
</blockquote>

## Remote show + HTE

Remarks:

- *HTE* to mój skrót na *HTML Template Element*.
- To sanitize fortunes input by users use the ES6 Template Strings:
  - [Getting Literal With ES6 Template Strings](http://updates.html5rocks.com/2015/01/ES6-Template-Strings)
  - [ES6 template strings compiled to ES5](https://github.com/esnext/es6-templates)

Template Element to jedna z czterech technologii składających się na
[WebComponents](http://webcomponents.org/):

- [The template element](https://html.spec.whatwg.org/multipage/scripting.html#the-template-element)

Do pliku *index.html.erb* wklejamy taki element *template*:

    :::html
    <template id="modal-show">
      <article id="" class="modal fade">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h3 class="modal-title">Fortune #<span></span></h3>
            </div>
            <div class="modal-body">
              <p></p>
              <p class="source"></p>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
          </div>
        </div>
      </article>
    </template>

Teraz sprawdzimy, na konsoli naszej przeglądarki,
jak działa taki element.

Zaczniemy od wpisania i uruchomienia tego kodu:

    :::js
    'content' in document.createElement('template')

Jeśli wynikiem jest `true`, to nasza przeglądarka obsługuje element *template*.
W przeciwnym wypadku powinniśmy zmienić przeglądarkę 9-).
Ewentualnie możemy użyć jakiegoś polyfilla.

Ręcznie wstawiamy zawartość *template* na stronę:

    :::js
    var template = document.querySelector('#modal-show');

    // get document fragment with article element
    var clone = template.content.cloneNode(true);

    // populate document fragment at runtime
    clone.querySelector('article').id = 'fortune-modal';
    // is it possible to use below the object+array destructuring from ES6
    // see https://leanpub.com/understandinges6/read
    var p = clone.querySelectorAll('p');
    p[0].textContent = 'A day without sunshine is like night.';
    p[1].textContent = 'Anonymous';
    var h3 = clone.querySelector('h3');
    h3.textContent = 'Fortune #44';

    // Bootstrap depends on jQuery, so we can use it

    // activate the template
    $('body').prepend(clone);

    $('#fortune-modal').modal('show');

Jeśli wszystko działa, to dalej postępujemy podobnie jak w przykładzie z EJS.
Przycisk *Show* zamieniamy na *remote*:

    :::ruby app/views/fortunes/index.html.erb
    <%= link_to 'Show', fortune,
          remote: true,
          data: { type: :json },
          class: "show btn btn-default btn-sm" %>

i podpinamy do niego zdarzenie *ajax:success*:

    :::js
    $(function() {
      // use delegated event
      $(document).on('ajax:success', 'a[class^=show]',
            function(event, data, status, xhr) {
        var template = document.querySelector('#modal-show');
        var clone = template.content.cloneNode(true); // get document fragment

        // populate document fragment at runtime
        var p = clone.querySelectorAll('p');
        p[0].textContent = data.quotation;
        p[1].textContent = data.source;

        // destructured assignments; introduces p0, p1 into global context
        // [p0, p1] = clone.querySelectorAll('p');
        // [p0.textContent, p1.textContent] = [data.quotation, data.source];

        var h3 = clone.querySelector('h3');
        h3.textContent = 'Fortune ' + data.id;

        var modal_id = 'fortune-modal';

        clone.querySelector('article').id = modal_id;

        // activate the template
        $('body').prepend(clone);

        // clicking Close removes modal window from DOM
        $('#' + modal_id).on('hidden.bs.modal', function() {
          $('.modal').remove();
        });
        $('#fortune-modal').modal('show');
      });
    });


## Sortable List w Rails 3.2

*TODO:* Sortable lists powinny też działać w Rails 4. Sprawdzić to!

Nieco uproszczony przykład z [Sortable List in Ruby on Rails 3 – Unobtrusive jQuery](http://webtempest.com/sortable-list-in-ruby-on-rails-3-almost-unobtrusive-jquery/).

**Uwaga:** skorzystamy z aplikacji *sharp-ocean-6085*:

    :::bash
    rails g scaffold Todo name:string
    rails g migration add_position_to_todos position:integer
    rake db:migrate

dodajemy dane testowe:

    :::ruby db/seed.rb
    Todo.create([{:name => 'Blender'}, {:name => 'ABC Linux'}, {:name => 'CSS3, szybki start'}])

i migrujemy:

    :::bash
    rake db:seed

Poniżej będziemy korzystać z *sortable* z jQuery UI –
demo [Sortable](http://jqueryui.com/demos/sortable/).

Javascript do *index.html.erb*:

    :::rhtml index.html.erb
    <h1>Listing todos</h1>
    <ul id="todos">
    <% @todos.each do |todo| %>
      <li id="todo_<%= todo.id %>"><span class="handle">[drag]</span><%= todo.name %></li>
    <% end %>
    </ul>
    <br>
    <%= link_to 'New Todo', new_todo_path %>

    <% content_for :javascript do %>
      <%= javascript_tag do %>
        $('#todos').sortable({
            axis: 'y',
            dropOnEmpty: false,
            handle: '.handle',
            cursor: 'crosshair',
            items: 'li',
            opacity: 0.4,
            scroll: true,
            update: function() {
                $.ajax({
                    type: 'post',
                    data: $('#todos').sortable('serialize'),
                    dataType: 'script',
                    complete: function(request){
                        $('#todos').effect('highlight');
                    },
                    url: '/todos/sort'})
            }
        });
      <% end %>
    <% end %>

Do pliku *app/views/layouts/application.html.erb* dopisujemy
zaraz przed zamykającym znacznikem */body*:

    :::rhtml
    <%= yield :javascript %>

Kontroler:

    :::ruby
    class TodosController < ApplicationController
      def index
        @todos = Todo.order('todos.position ASC')
      end

      def sort
        @todos = Todo.scoped
        @todos.each do |todo|
          todo.position = params['todo'].index(todo.id.to_s)
          todo.save
        end
        render :nothing => true
      end

Jeszcze poprawki w CSS:

    :::css /app/assets/stylesheets/application.css
    .handle:hover {
      cursor: move;
    }

oraz w routingu:

    :::ruby config/routes.rb
    resources :todos do
      post :sort, :on => :collection
    end
    root to: "todos#index"

Jak to działa? Na konsoli wypisywane są parametry:

    Parameters: {"todo"=>["3", "1", "2"]}

gdzie

    3, 1, 2

to kolejność wyświetlanych na stronie elementów *li*.
Oznacza to, że todo z:

    id = 3 jest wyświetlane pierwsze (position = 0)
    id = 1 jest wyświetlane drugie   (position = 1)
    id = 2 jest wyświetlane trzecie  (position = 2)

Dlatego, taki kod ustawi właściwą kolejność *position*
wyświetlania:

    :::ruby
    todo[1].position = ["3", "1", "2"].index("1") = 2
    todo[2].position = ["3", "1", "2"].index("2") = 3
    todo[3].position = ["3", "1", "2"].index("3") = 1

Proste? Nie? Podejrzeć na konsoli Javascript, w zakładce Sieć,
nagłówki w wysyłanych żądaniach.

Nowe rekordy nie mają ustawionego atrybutu *position*.
Dlatego są wyświetlanie na końcu listy.
Możemy to zmienić, na przykład w taki sposób:

    :::ruby
    class Todo < ActiveRecord::Base
      before_create :add_to_list_bottom

      private

      def add_to_list_bottom
        bottom_position_in_list = Todo.maximum(:position)
        self.position = bottom_position_in_list.to_i + 1
      end
    end

Teraz nowe elementy pojawią się u dołu wyświetlanej listy.
Niestety, ten kod działa tylko z *ActiveRecord* (?, sprawdzić to).


<!--

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

-->

## Dokumentacja

* [Sprockets](http://rubydoc.info/gems/sprockets/2.1.2/file/README.md) – *RubyDoc*
* [Sprockets](https://github.com/sstephenson/sprockets) – *Github*
* [CSS Cursors](http://www.w3schools.com/cssref/playit.asp?filename=playcss_cursor&preval=default)
* [Humane JS](https://github.com/wavded/humane-js) –
  a simple, modern, browser notification system

<!--

### Instalacja ze źródeł

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

-->
