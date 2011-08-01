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
który musimy najpierw zainstalować:

    gem install heroku

**Uwaga:** przeczytać
[Deploying to Heroku with Rails 3.1](http://railsapps.github.com/rails-heroku-tutorial.html).

Zanim umieścimy swoją aplikację na *heroku.com*, musimy mieć tam konto (tzw. „free plan”).
Zakładamy je, przeglądamy [dokumentację](http://devcenter.heroku.com/) i dopiero
teraz generujemy aplikację Rails:

    rails new foo

Aplikację *foo* na heroku wdrożymy w trzech krokach:

1\. Zakładamy repozytorium Git dla kodu aplikacji:

    cd foo
    git init
    git add .
    git commit -m "pierwsza wersja"

Następnie wymyślamy unikalną nazwę dla naszej aplikacji, na przykład *foo-xxx*:

    heroku create foo

Odpowiedź Heroku powinna być taka:

    Creating foo.... done
    http://foo.heroku.com/ | git@heroku.com:foo-xxx.git
    Git remote heroku added

**Uwaga:** jeśli na Heroku istnieje już aplikacja o takiej
nazwie, to musimy wymyśleć nową nazwę.

2\. Dodajemy klucz publiczny do swojego konta na Heroku
i wdrażamy aplikację *foo*:

    heroku keys:add ~/.ssh/id_rsa.pub
    git push heroku master

Stosujemy się do sugestii Heroku:

    bundle install --path=$HOME/.gems
    git add .
    git commit -m "dodano Gemfile.lock"
    git push heroku master

3\. Pozostałe rzeczy, to utworzenie bazy danych:

    heroku rake db:create

A te polecenia zostawiamy sobie na potem:

    heroku addons:add something?
    heroku rake db:migrate  # na razie chyba zbędne
    heroku db:push          # to też


**Uwaga:** Jeśli gem heroku nie jest zainstalowany, to dopisujemu
go do pliku *Gemfile* i instalujemy lokalnie, na przykład tak:

    bundle install --path=$HOME/.gems

Teraz zamiast polecenia:

    heroku ...

wykonujemy polecenie:

    bundle exec heroku ...


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
