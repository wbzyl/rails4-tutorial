#### {% title "Template" %}


Wykorzystać przy dodaniu drugiego modelu!

Zwyczajowo *index* kojarzymy z kompletną listą zasobów.

Uruchamiamy serwer WWW i wchodzimy na stronę z fortunkami:

    http://localhost:3000/

Co powinno się wydarzyć?

    Unknown action
    The action 'index' could not be found for FortunesController

Oznacza to, że powinniśmy napisać metodę *index*.

    :::ruby app/controllers/fortunes_controller.rb
    class FortunesController < ApplicationController
      respond_to :html
      def index
        @fortunes = Fortune.order("created_at desc")
        respond_with @fortunes
      end
    end

Odświeżamy stronę:

    http://localhost:3000/fortunes

Teraz serwer zgłasza wyjątek i odpowiada (*response*) komunikatem
o błędzie:

    Action Controller: Exception caught

    Template is missing
    Missing template fortunes/index with
      {:locale=>[:en, :en], :handlers=>[:builder, :rjs, :erb, :rhtml, :rxml],
      :formats=>[:html]} in view paths ".../app/views"

Nie pozostaje nam nic innego jak utworzyć szablon **powiązany**
z metodą *index*:

    :::rhtml app/views/fortunes/index.html.erb
    <h1>Fortunki</h1>
    <% @fortunes.each do |fortune| %>
    <p><%= fortune.body %></p>
    <% end %>

Jeszcze raz wchodzimy na stronę *index*. Teraz powinniśmy zobaczyć
widok wygenerowany z powyższego szablonu.

Powyżej mamy przykład szablonu *ERB* (ang. *embeded ruby*).

Co może oznaczać zwrot: **convention over configuration**?
Co to jest **ORM** – mapowanie obiektów na relacje
i relacji na obiekty?


### Tworzymy szablon „new” i metodę „new”

Jest obojętne czy najpierw utworzymy szablon, a później
metodę metodę powiązaną z tym szablonem czy odwrotnie.

Teraz, dla przykładu zaczniemy od szablonu *new.html.erb*.
Szablon powinien zawierać formularz umożliwiający
wpisanie nowej fortunki.

    :::rhtml app/views/fortunes/new.html.erb
    <h1>Nowa fortunka</h1>
    <%= form_for(Fortune.new) do |form| %>
    <p>
      <%= form.text_area :body %><br/>
      <%= form.submit %>
    <p>
    <% end %>

Powyżej korzystamy z **metody pomocniczej** (ang. *helper method*)
o nazwie *form_for*.

Ponieważ korzystamy z routingu REST, więc aby utworzyć
nową fortunkę wchodzimy na następujący url:

    http://localhost:3000/fortunes/new

Widzimy stronę z formularzem. Kilkamy przycisk *Create Fortune*.
Daje to następujący błąd:

    Unknown action
    The action 'create' could not be found for FortunesController

**Oczywiście** oznacza to, że powinniśmy zaimplementować metodę
*create*:

    :::ruby app/controllers/fortunes_controller.rb
    def create
      @fortune = Fortune.create(params[:fortune])
      respond_with @fortune # odpowiadamy polimorficznie
    end

Dlaczego wykonujemy *redirect_to*? Co oznacza tutaj *polimorficznie*?

Na razie zakładamy, że użytkownik nie oszukuje i wpisuje w formularz
to co jest proszony, a nie na przykład złośliwy kod.
Walidacją tego co wpisuje użytkownik zajmiemy się później.

Po kliknięciu przycisku „Create Fortune”, nowa fortunka
jest zapisywana w tabeli, a my zostajemy przekierowani na stronę
*show*, której nie ma:

    Unknown action
    The action 'show' could not be found for FortunesController

Nie napisaliśmy też metody *show*. Robimy to teraz.

Czytamy to co zostało wypisane na konsoli i piszemy metodę *show*:

    :::ruby app/controllers/fortunes_controller.rb
    def show
      @product = Product.find(params[:id])
      respond_with @product # odpowiadamy polimorficznie
    end

Szablon też piszemy „od ręki”:

    :::rhtml app/views/fortunes/show.html.erb
    <p>
      <b>Body:</b>
      <%= @fortune.body %>
    </p>
