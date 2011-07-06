#### {% title "Szablony aplikacji Rails" %}

Szablon aplikacji Rails, to plik zawierający kod Ruby
modyfikujący nowo wygenrowaną aplikację Rails.
Na przykład, dodający nowe pliki, gemy, wtyczki,
modyfikujący routing itp. W kodzie korzystamy
z wygodnego DSL (*Domain Specific Language*) gemu *Thor*.

Czym jest
[Thor](http://rdoc.info/github/wycats/thor/master/file/README.md)?
„Thor is a simple and efficient tool for building self-documenting
command line utilities.”

Kilka linków na początek:

* [RailsWizard](https://github.com/intridea/rails_wizard) –
 the gem and recipe collection for [railswizard.org](http://railswizard.org/)
* [Cooking Up A Custom Rails 3 Template](http://blog.madebydna.com/all/code/2010/10/11/cooking-up-a-custom-rails3-template.html):
  - [Actions](http://api.rubyonrails.org/classes/Rails/Generators/Actions.html)
  - [Thor::Actions](http://rdoc.info/github/wycats/thor/master/Thor/Actions.html)
  - [Thor::Shell](http://rdoc.info/github/wycats/thor/master/Thor/Shell)


## Hello Rails templates

Oto prosty i użyteczny przykład:

    :::ruby rails-template.rb
    remove_file 'README'

    create_file "README.md" do
      "# Fortunka\n\nTODO"
    end

    remove_file "public/index.html"

    gem "simple_form"
    generate "simple_form:install"

    generate :scaffold, "fortune body:text"
    rake "db:migrate"

    route "resources :fortunes"
    route "root :to => 'fortunes#index'"

    append_to_file 'app/assets/stylesheets/scaffolds.css.scss' do
      background_color = ask("What is your preferred CSS background color?")
    <<CSS
    html {
      background-color: #{background_color};
    }
    body {
      margin: 1em auto;
      padding: 1em 1em 2em 1em;
      width: 640px;
      border: 1px solid black;
      font-size: 16px;
      line-height: 22px;
    }
    CSS
    end

A tak skorzystamy z tego szablonu:

    rails new fortunka -m rails-template.rb -j -f

Powyższy szablon ma kilka wad. Po usunięciu wad, poprawiony szablon
umieściłem [tutaj](https://gist.github.com/1068461):

    https://gist.github.com/1068461

Ponieważ zamiast ścieżki do pliku możemy podać uri szablonu, więc
nie ma problemu z skorzystaniem z tego szablonu. Musimy
tylko pamietać, aby podać uri do wersji „raw” kodu:

    rails new fortunka -j -f \
      -m https://raw.github.com/gist/1068461/ab1f125cd0fac4c497a5356ff78ef0592e971721/rails3-template.rb

Jakie są zmiany? Dlaczego?


**TODO**

Omówić przykład z Mongo + Devise. Użyć w przykładzie podobnym do
screencastu [Mongoid](http://railscasts.com/episodes/238-mongoid).
