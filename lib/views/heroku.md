#### {% title "Krok po kroku odkrywamy Heroku" %}

<blockquote>
 <p>
  {%= image_tag "/images/heroku-handles-headache.jpg", :alt => "[heroku handles headache]" %}
 </p>
 <p class="author">źródło: <a href="http://robots.thoughtbot.com/post/159805997/heroku-wearing-suspenders">Heroku handles headache</a></p>
</blockquote>

[Heroku](http://heroku.com/) (pronounced her-OH-koo) is a cloud application platform for
Ruby – a new way of building and deploying web apps.

Swoje aplikacje Rails będziemy wdrażać na Heroku za pomocą programu *heroku*,
który musimy najpierw zainstalować. W tym celu wchodzimy
na stronę

    https://toolbelt.heroku.com/

z której pobieramy paczkę z programem.

Następnie zakładamy na Heroku konto (tzw. „free plan”),
przesyłamy swój klucz publiczny na Heroku
i logujemy się na swoim koncie:

    :::bash
    heroku keys:add
    heroku login


## Tworzymy aplikację Rails 4.x

Tworzymy rusztowanie aplikacji korzystając z generatora *new*:

    rails new foo

Podmieniamy plik *Gemfile* na taki:

    :::ruby Gemfile
    source 'https://rubygems.org'
    ruby '2.0.0'

    gem 'rails', '4.0.0.beta1'
    gem 'turbolinks', '1.0.0'
    gem 'jquery-rails', '2.2.1'
    gem 'jbuilder', '1.0.2'

    gem 'thin', '1.5.1'

    group :development do
      gem 'sqlite3', '1.3.7'
      gem 'quiet_assets'
    end
    group :assets do
      gem 'coffee-rails', '4.0.0.beta1'
      gem 'uglifier', '1.3.0'
    end
    group :production do
      gem 'pg', '0.14.1'
    end
    group :heroku do
      gem 'rails_log_stdout',           github: 'heroku/rails_log_stdout'
      gem 'rails3_serve_static_assets', github: 'heroku/rails3_serve_static_assets'
    end

dodajemy swoje gemy i instalujemy je.

Następnie wykonujemy opoprawki w wygenerowanym kodzie opisane
[tutaj](https://github.com/wbzyl/my_gists).


## Wdrażanie aplikacji

Aplikację *foo* wdrażamy w czterech krokach.

1\. Tworzymy repozytorium Git z kodem aplikacji:

    cd foo
    git init
    git add .
    git commit -m "pierwsza wersja"

2\. Tworzymy nową aplikację na Heroku:

    :::bash
    heroku create

      Creating afternoon-tor-6637... done, stack is cedar
      http://afternoon-tor-6637.herokuapp.com/ | git@heroku.com:afternoon-tor-6637.git
      Git remote heroku added

3\. Wdrażamy naszą aplikację z gałęzi **master** na Heroku:

    :::bash
    git push heroku master

4\. Pozostałe rzeczy, to utworzenie bazy danych, migrowanie:

    :::bash
    heroku run bin/rake db:migrate

Przy okazji możemy też zmienić wygenerowaną nazwę aplikacji
z *afternoon-tor-6637* na jakąś inną:

    :::bash
    heroku rename piece

Odpowiedź Heroku powinna być taka:

    Renaming afternoon-tor-6637 to piece... done
    http://piece.herokuapp.com/ | git@heroku.com:piece.git
    Git remote heroku updated

**Uwaga:** jeśli na Heroku istnieje już aplikacja o takiej
nazwie, to będziemy musieli wymyśleć inną unikalną nazwę.


## Podręczna dokumentacja

* [DevCenter](http://devcenter.heroku.com/)
* [Getting Started with Heroku](https://devcenter.heroku.com/articles/quickstart)
* [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/ruby)


## SQLite ⇄ PostgreSQL

Jak? [Push and Pull Databases To and From Heroku](http://blog.heroku.com/archives/2009/3/18/push_and_pull_databases_to_and_from_heroku/):

    :::bash
    gem install taps
    heroku db:push sqlite://db/development.sqlite3 --confirm APP-NAME-ON-HEROKU
    heroku db:pull sqlite://db/production.sqlite3

Do trzech razy sztuka??


## Rails Environment Variables

Artykuł o tym „Keeping Environment Variables Private”. Na przykład
klucze aplikacji zarejestrowanej na Twitterze, Githubie, Facebooku…

* Taylor Mock i Daniel Kehoe,
  [Rails Environment Variables](http://railsapps.github.com/rails-environment-variables.html)

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
