#### {% title "TDD, BDD…" %}

Zaczynamy od przykładów z katalogu *doc/testing*.

<blockquote>
  {%= image_tag "/images/rails3_in_action.jpg", :alt => "[Rails3 in Action]" %}
</blockquote>

W książce *Rails 3 in Action* autorów Yehuda Katz i Ryan A. Bigg
opisano aplikację „Ticketee” *in an Agile-like fashion*.

Kod przedstawiony w książce można pobrać z repozytorium
[The Rails 3 in Action project, on Rails 3.1](https://github.com/rails3book/ticketee-v2):

    :::bash
    git clone git://github.com/rails3book/ticketee-v2.git
    cd ticketee-v2

Kod z rozdziału 3, *Developing a Real Rails Application*,
znajdziemy na gałęzi *remotes/origin/chapter_3*:

    git branch -a
    git checkout --track origin/chapter_3


## Przygotowanie aplikacji do BDD

Instalujemy Rails 3.1, następnie generujemy szkielet aplikacji:

    rails new fortunka

Następnie edytujemy plik *Gemfile*:

<blockquote>
{%= image_tag "/images/capybaras.jpg", :alt => "[Capybaras]" %}
<p class="author">źródło: <a href="http://robots.thoughtbot.com/post/8087279685/use-capybara-on-any-html-fragment-or-page">Use Capybara…</a></p>
</blockquote>

    :::ruby
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

Uruchamiamy powyższą feature:

    rake cucumber:ok
      .../fortunka/db/schema.rb doesn't exist yet.
      Run "rake db:migrate" to create it then try again.
      If you do not intend to use a database, you should instead alter
      .../fortunka/config/application.rb to limit the frameworks that will be loaded

Porażka. Zgodnie z wskazówką wykonujemy:

    rake db:migrate

i jeszcze raz uruchamiamy feature:

    rake cucumber:ok

Tym razem wynik jest taki:

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
Odpowiedzi powinniśmy szukać w wygenerowanym
pliku *web_steps.rb*, wiersz 44:

    :::ruby features/step_definitions/web_steps.rb
    Given /^(?:|I )am on (.+)$/ do |page_name|
      visit path_to(page_name)
    end

oraz *path.rb*

    :::ruby features/support/path.rb
    def path_to(page_name)
      case page_name
        when /^the home\s?page$/
          '/'
      ...

Stąd wynika, że wykonanie:

    :::ruby
    visit path_to('homepage')

powoduje wejście (*visit*) na stronę `/`, czyli
wyświetlenie strony „Welcome aboard” (*index.html*).

Po usunięciu pliku *public/index.html* wszystkie
pięć kroków powinno się zakończyć porażką (*failed*).


## Step definitions

Przyjrzyjmy się użytym powyżej definicjom kroków.

*features/step_definitions/web_steps.rb:44*:

    :::ruby
    Given /^(?:|I )am on (.+)$/ do |page_name|
      visit path_to(page_name)
    end

*features/step_definitions/web_steps.rb:56*:

    :::ruby
    When /^(?:|I )follow "([^"]*)"$/ do |link|
      click_link(link)
    end

*features/step_definitions/web_steps.rb:60*:

    :::ruby
    When /^(?:|I )fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
      fill_in(field, :with => value)
    end

*features/step_definitions/web_steps.rb:52*:

    :::ruby
    When /^(?:|I )press "([^"]*)"$/ do |button|
      click_button(button)
    end

*features/step_definitions/web_steps.rb:105*:

    :::ruby
    Then /^(?:|I )should see "([^"]*)"$/ do |text|
      if page.respond_to? :should
        page.should have_content(text)
      else
        assert page.has_content?(text)
      end
    end


# Behavior Driven Development – BDD

**Zadanie:**
Napisać kod tak aby wszystkie pięć kroków zostało zaliczonych (*passed*).

Ale wcześniej, zgodnie z sugestią z pliku *web_steps.rb*,
przystępujemy do lektury:

* [Imperative vs Declarative Scenarios in User Stories](http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html)
* [Whose domain is it anyway?](http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/)
* [You're Cuking It Wrong](http://elabs.se/blog/15-you-re-cuking-it-wrong)


## Ustawienie tytułu strony

Dodpisujemy dwa nowe kroki:

    :::text
    And I should be on the project page for "TextMate 2"
    And I should see "Show - Projects - Ticketee"

*features/step_definitions/web_steps.rb:187*:

    :::ruby
    Then /^(?:|I )should be on (.+)$/ do |page_name|
      current_path = URI.parse(current_url).path
      if current_path.respond_to? :should
        current_path.should == path_to(page_name)
      else
        assert_equal path_to(page_name), current_path
      end
    end

Wykonujemy:

    rake cucumber:ok

Wynik:

    And I should be on the project page for "TextMate 2" # features/step_definitions/web_steps.rb:187
      Can't find mapping from "the project page for "TextMate 2"" to a path.
      Now, go and add a mapping in /home/wbzyl/repos/dydaktyka/ticketee/features/support/paths.rb (RuntimeError)
      ./features/support/paths.rb:27:in `rescue in path_to'
      ./features/support/paths.rb:21:in `path_to'
      ./features/step_definitions/web_steps.rb:190:in `/^(?:|I )should be on (.+)$/'
      features/creating_projects.feature:12:in `And I should be on the project page for "TextMate 2"'

Dopisujemy:

    :::ruby features/support/path.rb
    when /^the home\s?page$/
      '/'
    when /the project page for "([^\"]*)"/
      project_path(Project.find_by_name!($1))

Ponownie wykonujemy:

    rake cucumber:ok

Tym razem, rezultat jest taki:

    And I should see "Show - Projects - Ticketee"        # features/step_definitions/web_steps.rb:105
      expected there to be content
          "Show - Projects - Ticketee" in "Ticketee\n\n  \n
          Project has been created.\n  \n\n
          TextMate 2\n\n\n" (RSpec::Expectations::ExpectationNotMetError)
      ./features/step_definitions/web_steps.rb:107:in `/^(?:|I )should see "([^"]*)"$/'
      features/creating_projects.feature:13:in `And I should see "Show - Projects - Ticketee"'

gdzie *features/step_definitions/web_steps.rb:13*:

