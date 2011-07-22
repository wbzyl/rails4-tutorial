# Testowanie kodu

„Whilst *RSpec* and *Test::Unit* are great for unit testing (testing a
single part), *Cucumber* is mostly used for testing the entire
integration stack.”


## Przykłady z RSpec

    gem install rspec

Testujemy:

    cd bacon
    rspec spec/bacon_spec.rb


## Przykłady z Cucumber

    gem install cucumber

Testujemy:

    cd accounts
    cucumber features
