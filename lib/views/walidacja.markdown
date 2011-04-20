#### {% title "Walidacja" %}

# Walidacja

Walidacja jest mechanizmem Rails, którego używamy aby zagwarantować
sobie, że do bazy zostaną dodane tylko poprawne dane.

W modelu *Fortune* włączymy walidację w taki sposób:

    :::ruby app/models/fortune.rb
    class Fortune < ActiveRecord::Base
      validates_length_of :body, :minimum => 8
    end

Zobacz *http://plasmarails.org/*, zakładka *ActiveModel/Validations*.


## Błędy

Coś wygenerowanego przez generator *scaffold*:
 
    :::html_rails
    <%= form_for(@fortune) do |f| %>
      <% if @fortune.errors.any? %>
        <div id="error_explanation">
          <h2><%= pluralize(@fortune.errors.count, "error") %> 
              prohibited this fortune from being saved:</h2>
          <ul>
          <% @fortune.errors.full_messages.each do |msg| %>
            <li><%= msg %></li>
          <% end %>
          </ul>
        </div>
      <% end %>

Uwaga: gotowy CSS jest w wygenerowanym pliku *scaffold.css*.


## Kontroler + Widok

Poprawki metody *create*:

    :::ruby app/controllers/fortunes_controller.rb
    def create
      @fortune = Fortune.new(params[:fortune])
      if @fortune.save
        redirect_to fortunes_path, :notice => 'Fortune was successfully created.'
      else
        render 'new'
      end
    end

Teraz *invalid records* będą w czerwonej ramce.
Jeśli chcemy zobaczyć szczegóły, to dopisujemy do szablonu
z formularzem:

    :::html_rails app/views/fortunes/_form.html.erb
    <%= form_for @fortune do |f| %>
    <%= f.error_messages %>
    ...
    <% end %>

Aha, dodajemy arkusz stylów *scaffold.css* do layoutu aplikacji:

    :::html_rails public/stylesheets/scaffold.css
    <%= stylesheet_link_tag "application", "scaffold" %>

W *application.css* nie została zdefiniowana czerwona ramka
wokół nieprawidłowo wypełnionych pól formularza.
**Pluskwa?**

Podobne zmiany powinniśmy zrobić w kodzie metody *update*:

    :::ruby app/controllers/fortunes_controller.rb
    def update
      @fortune = Fortune.find_by_id(params[:id])
      if @fortune.update_attributes(params[:fortune])
        redirect_to fortunes_path, :notice => 'Fortune was successfully updated.'
      else
        render 'edit'
      end
    end

Więcej o walidacji można przeczytać w Rails Guides,
[Active Record Validations and Callbacks](http://guides.rails.info/active_record_validations_callbacks.html).
