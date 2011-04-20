#### {% title "Ajax & jQuery" %}

# TODO: Ajax & jQuery

**[2011.04] Sporo się zmieniło przez ostatnich kilka miesięcy.**

W aplikacji „2models” dodawanie nowego i usuwanie **task**
zaimplementujemy korzystając z Ajaxa.

W kodzie skorzystamy z funkcji bilioteki jquery.

TODO: [Deleting a record using ajax](http://railsdog.com/blog/2011/02/28/callbacks-in-jquery-ujs-in-rails3/).


## Rails & Ajax

W katalogu *public/javascripts* znajdziemy plik *rails.js*.
Implementuje on następujące funkcje zwrotne (16.12.2010):

- *ajax:beforeSend*  — is executed before firing ajax call
- *ajax:success*     — is executed when status is success
- *ajax:complete*    — is executed when the request finishes, whether in failure or success.
- *ajax:error*       — is execute in case of error

Sygnatury funkcji zwrotnych:

    :::jquery_javascript
    var el    = this,
    method    = el.attr('method') || el.attr('data-method') || 'GET',
    url       = el.attr('action') || el.attr('href'),
    dataType  = el.attr('data-type')  || ($.ajaxSettings && $.ajaxSettings.dataType);
    ...
    $.ajax({
        url: url,
        data: data,
        dataType: dataType,
        type: method.toUpperCase(),
        beforeSend: function (xhr) {
            xhr.setRequestHeader("Accept", "text/javascript");
            if ($this.triggerHandler('ajax:beforeSend') === false) {
              return false;
            }
        },
        success: function (data, status, xhr) {
            // status: success or notmodified (data is undefined)
            el.trigger('ajax:success', [data, status, xhr]);
        },
        complete: function (xhr) {
            // bug? missing status argument
            el.trigger('ajax:complete', xhr);
        },
        error: function (xhr, status, error) {
            el.trigger('ajax:error', [xhr, status, error]);
        }
    });


**Uwagi:**

1\. Argument *status* jest napisem opisującym stan żądania:

- "success", "notmodified" (zdarzenie *success*)
- "error", "timeout", "parsererror" (zdarzenie *error*)

2\. Argument *data* jest dołączany do url dla żądań GET.

Pozostałe szczegóły opisano w [jQuery.ajax() API](http://api.jquery.com/jQuery.ajax/).


## Ajaxujemy formularz nowych zadań

Samo zajaxowanie formularza jest proste.  Wystarczy dopisać *remote =>
true* w argumentach metody pomocniczej *form_for*:

    :::html_rails
    <%= form_for(@task, :remote => true) do |f| %>

Mały problem jest tylko z dodaniem zdarzeń do elementów strony.
Musimy te elementy jakoś wyróżnić.
Wtedy łatwiej nam będzie do nich się odwołać z kodu Javascript.

Element *form* wygenerowanego formularza:

    :::html
    <form accept-charset="UTF-8" action="/tasks" class="new_task" id="new_task" method="post">

zawiera identyfikator **new_task**. Skorzystamy z tego identyfikatora.

Do tablicy z listą *tasks* sami dodamy identyikator:

    :::html
    <table id="tasks_list">


### Robótki pomocnicze

Przeorganizowujemy *layout/application.html.erb*.

Zamiast pętli po widomościach flash wstawimy:

    :::html_rails
    <div id="container">
      <%= content_tag :div, "", :id => "flash_notice" %>
      <%= content_tag :div, "", :id => "flash_error" %>

Elementy te nie powinny być widoczne po wczytaniu strony.
Dlatego w pliku *application.js* wpiszemy:

    :::jquery_javascript
    $(document).ready(function() {
        $("#flash_notice").hide();
        $("#flash_error").hide();
    });


## Sprawdzamy jak to działa

Po tych zmianach, kliknięcie przycisku „Create Task”, na konsoli rails
dostajemy:

    ActionView::MissingTemplate (Missing template tasks/create with
      {:handlers=>[:erb, :rjs, :builder, :rhtml, :rxml],
       :formats=>[:js, :html], :locale=>[:en, :en]}
       in view paths ".../rails4-ajax-and-jquery/app/views"):
       app/controllers/tasks_controller.rb:40:in `create'

Oznacza to, że musimy napisać szablon **views/tasks/create.js.erb**:

    :::html_rails
    $("#flash_notice")
      .html("<%= escape_javascript(flash[:notice])%>")
      .show();
    $("#tasks_list")
      .append("<%= escape_javascript(render @task) %>");

Dlaczego szablon *.js.erb* a nie *.html.erb*?
Po wskazówki przeglądamy *Request Headers* na konsoli Firebuga.

Powyżej korzystamy szablonu częściowego *_task.erb.html*:

    :::html_rails
    <tr>
      <td><%= task.name %></td>
      <td><%= link_to 'Show', task_path(task) %></td>
      <td><%= link_to 'Edit', edit_task_path(task) %></td>
      <td><%= link_to 'Destroy', task, :confirm => 'Are you sure?', :method => :delete %></td>
    </tr>

który powstał w trakcie jednej refaktoryzacji aplikacji „2models”.

Teraz, po ponownym kliknięciu przycisku nowe zadanie powinno się
pojawić na liście zadań.


### Kilka uwag dotyczących zdarzeń i szablonów Javascript

1\. Może się zdarzyć, że dane z *create.js.erb* wysłane z aplikacji
zagubią się gdzieś w sieci. Dlatego do formularza powinniśmy
dodać obsługę zdarzenia *ajax::error*:

    :::jquery_javascript  public/javascripts/application.js
    $('#new_task')
      .live("ajax:error", function(evt, xhr, status, error) {
        ...
      })

oraz zdarzenia *ajax:complete*, które powinno posprzątać
po innych zdarzeniach podczepionych do formularza:

    :::jquery_javascript  public/javascripts/application.js
      .live("ajax:complete", function(evt, xhr) {
        ...
      });

2\. Funkcje zwrotne powiązane ze zdarzeniami *ajax:success* i *ajax:error*,
a nie aplikacja, powinny wypisywać komunikaty *flash[:notice]* i *flash[:error]*.

Ale, treść tych komunikatów jest znana aplikacji. Kod Javascript
nie ma o nich pojęcia. Dlatego przeniesienie wypisywania komunikatów
*flash* z aplikacji do kodu Javascript wiązałaby się poszerzeniem
I18N+L10N o Javascript. A to, chyba, nie jest takie proste.


## Usuwanie zadań

Tak jak w wypadku dodawania dopisujemy *remote => true*.
Ale tym razem przy linku „Destroy” w *link_to*:

    :::html_rails views/tasks/_task.html.erb
    <td><%= link_to 'Destroy', task, :confirm=>'Are you sure?', :remote=>true, :method=>:delete %></td>

Po tej zmianie, kliknięcie linku „Destroy” daje błąd (konsola Rails):

    ActionView::MissingTemplate (Missing template tasks/destroy with
      {:handlers=>[:erb, :rjs, :builder, :rhtml, :rxml],
       :formats=>[:js, :html], :locale=>[:en, :en]}
       in view paths ".../app/views"):
       app/controllers/tasks_controller.rb:54:in `destroy'

Na konsoli Javascript, w zakładce XHR, jest więcej szczegółów:

    Request Headers:   Accept  text/javascript
    Response Headers:  500 Internal Server Error

Oznacza to, że brakuje szablonu **views/tasks/destroy.js.erb**.
Co ten szablon miałby zawierać?

Czy coś takiego to jest to o co chodzi?

    :::jquery_javascript
    $("#flash_notice")
      .html("<%= escape_javascript(flash[:notice])%>")
      .show();

Czy pusty plik *destroy.js.erb* byłby OK?

Teraz mamy taki stan rzeczy:

* kliknięty element został usunięty z tabelki w bazie
* kliknięty i usunięty z bazy element jest widoczny na liście.

Problem: **Jak usunąć usunięty element z listy zadań?**

Można ten problem obejść wyciągając listę zadań tabeli w bazie
i ponownie renderując całą tabelę.

Ale my postąpimy ekonomicznie. Usuniemy tylko usunięty element.

Aby usunąć usunięty element zaczniemy od podczepienia następującego
zdarzenia do tabelki z listą zadań:

    :::jquery_javascript public/javascripts/application.js
    $(document).ready(function() {
      ...
      $('#tasks_list')
        .bind("ajax:success", function(evt, data, status, xhr) {
          console.log(evt);
        });
      ...
    });

Teraz na konsoli przeglądarki *Firefox* podglądamy to zdarzenie
w zakładce **Console**:

    DELETE http://localhost:3000/tasks/8 200 OK
    Object { type="ajax:success", timeStamp=1292535498023, more...}

Klikamy na **more** i przyglądamy się własności *target*:

    target    a /tasks/8

Czyli *evt.target* to kliknięty link, a wiersz tabeli do usunięcia, to

    :::jquery_javascript
    $(evt.target).closest('tr')

Element *tr* usuniemy z tabeli, korzystając z funkcji

    :::jquery_javascript public/javascripts/application.js
    $('#tasks_list')
      .bind("ajax:success", function(evt, data, status, xhr) {
        $(evt.target).closest('tr').remove();
      });

Sprawdzamy na konsoli Firebuga czy element został naprawdę
usunięty z listy.. Działa! Uff, to było trudne zadanie!


### Uwaga dotycząca zdarzeń i szablonów Javascript

Powinniśmy, podobnie jak przy szablonie *create.js.erb*,
do listy zadań dowiązać zdarzenia *ajax:error* i *ajax:complete*.


## Walidacja Tasks

Zaczniemy od próby utworzenia „pustego” zadania:

    Started POST "/tasks" for 127.0.0.1 at ...
      Processing by TasksController#create as JS
      Parameters: {"utf8"=>"✓", "task"=>{"name"=>""}}
    Rendered tasks/_task.html.erb
    Rendered tasks/create.js.erb

    ActionView::Template::Error (No route matches
      {:action=>"show", :controller=>"tasks",
       :id=>#<Task id: nil, name: "", created_at: nil, updated_at: nil>}):
        1: <tr>
        2:   <td><%= task.name %></td>
        3:   <td><%= link_to 'Show', task_path(task) %></td>
        4:   <td><%= link_to 'Edit', edit_task_path(task) %></td>
        5:   <td><%= link_to 'Destroy', task, :confirm => 'Are you sure?', :remote => true, :method => :delete %></td>
        6: </tr>

Na konsoli Firebuga, w Response znajdziemy jeszcze taką informację:

    Extracted source (around line #3):

Oznacza to, że błąd jest w wierszu oznaczonym *\#3* powyżej, czyli
poniższy kod z szablonu *create.js.erb*:

    :::jquery_javascript
    $("#tasks_list")
      .append("<%= escape_javascript(render @task) %>");

został użyty ze zmienną *@task* w której jest zapisany obiekt *Task*
z *id* równym *nil*. Dla takiej zmiennej, *task_path(task)* nie ma sensu.

Poprawimy to zmieniając *create.js.erb*:

    :::html_rails
    <% if @task.valid? %>
      $("#flash_notice")
        .html("<%= escape_javascript(flash[:notice])%>")
        .show();
      $("#tasks_list")
        .append("<%= escape_javascript(render @task) %>");
    <% else %>
      $("#new_task")
        .replaceWith("<%= escape_javascript(render 'form') %>")
    <% end %>


## Szlifowanie widoków

Musimy jeszcze w kilku miejscach dopisać kasowanie niepotrzebnych komunikatów:
notice, error, błędów walidacji oraz wczyścić pola formularza.

Cały kod zaprowadzający porządek w widokach umieścimy
w funkcji zwrotnej zdarzenia *ajax:complete*:

    :::jquery_javascript public/javascripts/application.js
    $(document).ready(function() {
      ...
      $('#new_task')
        .live('ajax:complete', function(evt, xhr) {
          var that = $(this);
          that.find(':input:not(input[type=submit])').val('')
          that.find('#error_explanation').remove();
          that.find('label, input').unwrap();
        });
      ...
    });


## Edycja zadania

Edycja zadania, chyba bez remote:

    :::ruby
    module TasksHelper
      def remote_form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        options[:remote] = true if ['index', 'create'].include?(controller.action_name)
        form_for(record_or_name_or_array, *(args << options), &proc)
      end
    end

I w *_form.html.erb* zamiast *form_for* z *remote* wpisujemy:

    :::html_rails
    <%= remote_form_for(@task) do |f| %>


## Ajax i dodawanie Todo

**Zadanie.** Zajaxować dodawanie nowych *todo* na stronie *tasks\#show*.


## Search, Sort, Paginate with AJAX

Zobacz screencast R. Batesa,
[Search, Sort, Paginate with AJAX](http://railscasts.com/episodes/240-search-sort-paginate-with-ajax).


## Linki

Tutaj zaglądałem:

* [What's New in Edge Rails: Default RESTful Rendering](http://ryandaigle.com/articles/2009/8/10/what-s-new-in-edge-rails-default-restful-rendering)
* [What's New in Edge Rails: Cleaner RESTful Controllers w/ respond_with](http://www.simonecarletti.com/blog/2010/06/unobtrusive-javascript-in-rails-3/)
* [Creating a 100% ajax CRUD using rails 3 and unobtrusive javascript](http://www.stjhimy.com/posts/7)
* [Rails 3 Remote Links and Forms: A Definitive Guide](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)


## Inne podejście do Ajaxa…

Zwalić całą robotę na Javascript. Na przykład jakoś tak:

    :::jquery_javascript
    $('#form-for-remote')
      .bind("ajax:success", function(evt, data, status, xhr){
        // debugging
        console.log(evt);
        console.log(data);
        console.log(xhr);

        var form = $(this);
        // parsujemy xhr.responseText,
        // przekształcamy na html (przydałyby się jakieś szablony)
        // umieszczamy html na stronie

      })
      .bind("ajax:failure", function(evt, xhr, status, error){
        var form = $(this),
            errors,
            errorText;
        // jakoś tak: http://www.alfajango.com/blog/rails-3-remote-links-and-forms/
        try {
          // populate errorText with the comment errors
          errors = $.parseJSON(xhr.responseText);
        } catch(err) {
          // if the responseText is not valid JSON (like if a 500 exception was thrown),
          // populate errors with a generic error message.
          errors = {message: "Please reload the page and try again"};
        }
        // build an unordered list from the list of errors
        // przydałyby się jakieś szablony
        errorText = "There were errors with the submission: \n<ul>";
        for (error in errors) {
          errorText += "<li>" + error + ': ' + errors[error] + "</li> ";
        }
        errorText += "</ul>";
        // insert error list into form
        form.find('div.validation-error').html(errorText);
      });

    });

Powyższy kod zależy od tego jakie dane zostaną przesłane. Ułatwimy
sobie zadanie, „ładnie opakowując” dane przed wysłaniem oraz
odpowiednio oznaczając elementy w których umieścimy wypakowane dane.
