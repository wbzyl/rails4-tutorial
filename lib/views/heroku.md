#### {% title "Krok po kroku odkrywamy Heroku" %}

<blockquote>
 <p>
  {%= image_tag "/images/heroku-handles-headache.jpg", :alt => "[heroku handles headache]" %}
 </p>
 <p class="author">źródło: <a href="http://robots.thoughtbot.com/post/159805997/heroku-wearing-suspenders">Heroku handles headache</a></p>
</blockquote>

**Migracja działających i wdrożonych przed 2012 roku aplikacji:**
„The Cedar stack is the default runtime stack on Heroku and is the
successor to Aspen and Bamboo. It includes support for multiple
languages, flexible process types, HTTP 1.1, and substantially less
code injection. While there is no automation available to migrate to
Cedar from a previous stack this article outlines the steps and
consideration required when performing a manual migration.”

* [Migrating to the Celadon Cedar Stack](https://devcenter.heroku.com/articles/cedar-migration)
* [Tales from upgrading to Ruby 1.9.2 – character encoding](http://www.samanage.com/blog/2011/09/tales-from-upgrading-to-ruby-1-9-2-character-encoding/)


[Heroku](http://heroku.com/) (pronounced her-OH-koo) is a cloud application platform for
Ruby – a new way of building and deploying web apps.
Swoje aplikacje Rails będziemy wdrażać na Heroku za pomocą skryptu *heroku*,
który musimy najpierw zainstalować:

    :::bash
    gem install heroku

Jeśli jeszcze nie umieściliśmy swojego klucza publicznego na Heroku,
to robimy to teraz, tak:

    :::bash
    heroku keys:add

albo podając ścieżkę do klucza:

    heroku keys:add ~/.ssh/id_rsa.pub

Zanim umieścimy swoją aplikację na *heroku.com*, musimy mieć tam konto (tzw. „free plan”).
Zakładamy je, przeglądamy [dokumentację](http://devcenter.heroku.com/) i dopiero
teraz generujemy aplikację Rails:

    rails new foo

W pliku *Gemfile* zamieniamy wiersz z *sqlite3* na:

    :::ruby Gemfile
    gem 'sqlite3', :group => :development
    gem 'pg', :group => :production
    gem 'thin'

W katalogu głównym aplikacji tworzymy plik *Procfile* o zawartości:

    web: bundle exec thin start -p $PORT -e $RACK_ENV/$RAILS_ENV

Aplikację *foo* na heroku wdrażamy w czterech krokach.

1\. Zakładamy repozytorium Git dla kodu aplikacji:

    cd foo
    git init
    git add .
    git commit -m "pierwsza wersja"

2\. Tworzymy nową aplikację na Heroku, wybieramy wersję
[Celadon Cedar Stack](http://devcenter.heroku.com/articles/cedar):

    :::bash
    heroku create --stack cedar
      Creating deep-sunrise-8008... done, stack is cedar
      http://deep-sunrise-8008.herokuapp.com/ | git@heroku.com:deep-sunrise-8008.git
      Git remote heroku added

3\. Wdrażamy naszą aplikację na Heroku:

    :::bash
    git push heroku master

4\. Pozostałe rzeczy, to utworzenie bazy danych, migrowanie:

    :::bash
    heroku run rake db:create
    heroku run rake db:migrate

Przy okazji możemy też zmienić wygenerowaną nazwę aplikacji
z *deep-sunrise-8008* na jakąś inną:

    :::bash
    heroku rename colllor

Odpowiedź Heroku powinna być taka:

    Creating foo.... done
    http://colllor.herokuapp.com/  |  git@heroku.com:collor.git
    Git remote heroku added

**Uwaga:** jeśli na Heroku istnieje już aplikacja o takiej
nazwie, to będziemy musieli wymyśleć inną unikalną nazwę.


### SQLite ⇄ PostgreSQL

Jak? [Push and Pull Databases To and From Heroku](http://blog.heroku.com/archives/2009/3/18/push_and_pull_databases_to_and_from_heroku/):

    :::bash
    gem install taps
    heroku db:push sqlite://db/development.sqlite3 --confirm APP-NAME-ON-HEROKU
    heroku db:pull sqlite://db/production.sqlite3

Do trzech razy sztuka??


<!--

# TODO

## Kilka kont na heroku (newsletter, 01.2011)

Many of us have multiple Heroku accounts - one for personal projects,
one for work (or for each client, in some cases). Our very own David
Dollar wrote the
[heroku-accounts](https://github.com/ddollar/heroku-accounts)
plugin to help ease switching between them. No more shell scripts to
switch symbolic links! (What, you didn't do that? Guess it was just
me, then.)


# Bardziej realistyczny przykład „workflow”

Dla przykładowej aplikacji Rails o nazwie „Znajomi” rozważmy taki scenariusz:


{%= image_tag "/images/development-production.png", :alt => "[Heroku handles production]" %}

Nowa aplikacja:

    rails new znajomi
    cd znajomi
    ... edycja Gemfile – development: nifty-generators ...
    bundle install --path=HOME/.gems
    rails generate nifty:layout
    rails generate nifty:scaffold connection login:string github:string www:string
    bundle install  # mocha
    rake db:migrate
    rm public/index.html
    ... edycja config/routes.rb – ustawiamy :root na connections#index ...
    rails server -p 3000

Jeśli wszystko działa, to:

    git init
    git add .
    git commit -m "pierwsza wrzutka"
    cd ..
    git clone --bare znajomi znajomi.git
    cd znajomi.git ; git gc ; cd ..
    scp -r znajomi.git wbzyl@sigma.ug.edu.pl:public_git/
    rm -r znajomi znajomi.git       # dla początkujących mv ..gdzieś tam na przechowanie
    git clone wbzyl@sigma.ug.edu.pl:public_git/znajomi.git
    cd znajomi
    ... bundler, migracja ...
    git tag v1.0
    git checkout -b production
    git checkout master           # w zasadzie niepotrzebne
    git push
    git push origin production

Zmieniamy kolor tła na gałęziach:

    git checkout production
    ... edycja public/stylesheets/application.css – zielony #97d077 ...
    git add .
    git commit -m "production: zielony kolor tła"
    git push
    git checkout master
    ... edycja public/stylesheets/application.css – żółty #ffe599 ...
    git add .
    git commit -m "production: żółty kolor tła"
    git push

Heroku – production:

    heroku create znajomi
    Creating znajomi... done
    http://znajomi.heroku.com/ | git@heroku.com:znajomi.git
    ? Git remote heroku added

Od razu poprawiamy w *.git/config*, to co zostało dopisane przez to polecenie:

    [remote "heroku"]
	url = git@heroku.com:znajomi.git
	fetch = +refs/heads/*:refs/remotes/heroku/*

na:

    [remote "production"]
	url = git@heroku.com:znajomi.git
	fetch = +refs/heads/*:refs/remotes/heroku/*

Wdrażamy gałąź production na *http://znajomi.heroku.com*:

    git push production production:master

Zobacz też [Deploying with Git](http://devcenter.heroku.com/articles/git).

Migrujemy:

    heroku rake db:migrate --app znajomi

Sprawdzamy jak to działa na heroku:

    http://znajomi.heroku.com


## Istotna uwaga!

Powyżej przyjęliśmy pewne konwencje. Teraz powinniśmy się jakoś
zabezpieczyć przed błędem omyłkowego wdrożenia kodu
z gałęzi master na Heroku.

Pomocne może być przygotowanie dwóch zadań rake:

    rake sigma:push
    rake heroku:push

i używanie ich zamiast poleceń git.

W tym celu dopiszemy do pliku *Rakefile*:

    :::ruby
    namespace "sigma" do
      desc "Push zmiany w repo na Sigmę"
      task "push" do
        system("git", "push")
      end
    end

    namespace "heroku" do
      desc "Push zmiany na gałęzi production na Heroku"
      task "push" do
        system("git", "push", "production", "production:master")
      end
    end

-->

## Lektura

* [Deploying to Heroku with Rails 3.1](http://railsapps.github.com/rails-heroku-tutorial.html).
* [Sinatra + Heroku = Super Fast Deployment](http://rubysource.com/sinatra-heroku-super-fast-deployment/)
