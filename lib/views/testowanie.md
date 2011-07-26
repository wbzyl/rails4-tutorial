#### {% title "TDD, BDD…" %}

Zaczynamy od przykładów z katalogu *doc/testing*.

<blockquote>
  {%= image_tag "/images/rails3_in_action.jpg", :alt => "[Rails3 in Action]" %}
</blockquote>

W książce *Rails 3 in Action* autorów Yehuda Katz i Ryan A. Bigg
opisano aplikację „Ticketee” *in an Agile-like fashion*.

Kod przedstawiony w książce można pobrać z repozytorium
[The Rails 3 in Action project, on Rails 3.1](https://github.com/rails3book/ticketee):

    :::bash
    git clone git://github.com/rails3book/ticketee.git
    cd ticketee

Kod z rozdziału 3, *Developing a Real Rails Application*,
znajdziemy na gałęzi *remotes/origin/chapter_3*:

    git branch -a
    git checkout --track origin/chapter_3


## Przygotowanie aplikacji do BDD

Instalujemy Rails 3.1, następnie generujemy szkielet aplikacji:

    rails new fortunka

Następnie edytujemy plik *Gemfile*:

    :::ruby Gemfile
    source 'http://rubygems.org'

    gem 'rails', '~> 3.1.0.rc4'
    gem 'sqlite3'
    gem 'sass-rails', "~> 3.1.0.rc"
    gem 'coffee-script'
    gem 'uglifier'
    gem 'jquery-rails'

    group :test, :development do
      gem 'rspec-rails', '~> 2.5'
    end
    group :test do
      gem 'cucumber-rails'
      gem 'capybara'
      gem 'database_cleaner'
      gem 'launchy'
    end

Teraz wykonujemy polecenia:

    bundle install --binstubs
    rails generate cucumber:install
      create  config/cucumber.yml
      create  script/cucumber
       chmod  script/cucumber
      create  features/step_definitions/web_steps.rb
      create  features/support/paths.rb
      create  features/support/selectors.rb
      create  features/support/env.rb
      create  lib/tasks/cucumber.rake
        gsub  config/database.yml
    rails generate rspec:install
      create  .rspec
      create  spec
      create  spec/spec_helper.rb

Najwyższa pora aby wykonać:

    git add .
    git commit -m "Ran the cucumber and rspec generators."
    git push

Cytat z książki: „Whilst *RSpec* and *Test::Unit* are great for **unit
testing** (testing a single part), *Cucumber* is mostly used for
**testing the entire integration stack**.”


# Zwinna Fortunka

Fortunkę zaczynamy tworzyć od napisania „feature” (opisu, funkcji, aspektu)
i pierwszego powiązanego z nim „scenario” (scenariusza):

    :::text features/creating_fortunes.feature
    Feature: Tworzenie fortunek
      Chciałbym gromadzić ciekawe fortunki
      Jako użytkownik
      Chciałbym je prosto tworzyć

      Scenario: Tworzymy fortunkę
        Given I am on the homepage
        When I follow "New Fortune"
        And I fill in "Body" with "The best defense against logic is ignorance."
        And I press "Create Fortune"
        Then I should see "Fortune has been created"

Uruchamiamy opis:

    rake cucumber:ok
      .../fortunka/db/schema.rb doesn't exist yet.
      Run "rake db:migrate" to create it then try again.
      If you do not intend to use a database, you should instead alter
      .../fortunka/config/application.rb to limit the frameworks that will be loaded

    rake db:migrate
    rake cucumber:ok

    ~/.rvm/rubies/ruby-1.9.2-p180/bin/ruby -S bundle exec cucumber  --profile default
    Using the default profile...
    Feature: Tworzenie fortunek
      Chciałbym gromadzić ciekawe fortunki
      Jako użytkownik
      Chciałbym je prosto tworzyć

      Scenario: Tworzymy fortunkę                       # features/creating_fortunes.feature:6
        Given I am on the homepage                      # features/step_definitions/web_steps.rb:44
        When I follow "New Fortune"                     # features/step_definitions/web_steps.rb:56
          no link with title, id or text 'New Fortune' found (Capybara::ElementNotFound)
          (eval):2:in `click_link'
          ./features/step_definitions/web_steps.rb:57:in `/^(?:|I )follow "([^"]*)"$/'
          features/creating_fortunes.feature:8:in `When I follow "New Fortune"'
        And I fill in "Body" with "The best defense..." # features/step_definitions/web_steps.rb:60
        And I press "Create Fortune"                    # features/step_definitions/web_steps.rb:52
        Then I should see "Fortune has been created"    # features/step_definitions/web_steps.rb:105

    Failing Scenarios:
    cucumber features/creating_fortunes.feature:6 # Scenario: Tworzymy fortunkę

    1 scenario (1 failed)
    5 steps (1 failed, 3 skipped, 1 passed)
    0m1.844s

Jeden *step* (krok) mamy zaliczony. Dlaczego?
