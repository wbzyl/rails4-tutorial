# -*- coding: utf-8 -*-
#
# cat ~/.railsrc
# --skip-bundle
# --no-test-framework

# docs:
#   http://guides.rubyonrails.org/generators.html
#   http://rdoc.info/github/wycats/thor/master/Thor/Actions

remove_file "README.rdoc"
remove_file "doc/README_FOR_APP"
create_file "README.md"

# add these gems

gem "thin"
gem "simple_form"

# and remove these gems

gsub_file 'Gemfile', /.+'sass-rails'.+\n/, ''

# use Less instead of CSS: http://lesscss.org/

gem "less-rails"
gem "therubyracer"

# add Bootstrap to asset pipeline: https://github.com/seyhunak/twitter-bootstrap-rails

gem_group :assets do
  # gem 'jquery-ui-rails'
  # gem 'jquery-datatables-rails'
  gem "twitter-bootstrap-rails"
end

gem_group :development, :test do
  gem "rspec-rails"
  gem "quiet_assets"
  gem "hirb"
  # for testing with MiniTest: https://github.com/commondream/tconsole
  # gem "tconsole"
  # bezproblemowe zapełnianie bazy danymi testowymi:
  #   https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md
  # gem 'factory_girl_rails'
  # gem 'faker'
  # gem 'populator'
end

gem_group :test do
  gem "capybara"
end

run "bundle install --local" # on Sigma
# run "bundle install"

generate "rspec:install"

append_to_file '.rspec' do
  '--format documentation'
end

generate "bootstrap:install less"
# generate layout
generate "bootstrap:layout"
# to generate views
#
#   rails g bootstrap:themed RESOURCE_NAME
#
# for example
#
#   rails g scaffold Gist snippet:text lexer:string description:string
#   rake db:migrate
#   rails g bootstrap:themed Gist
#
# to use with Less add to application.css:
#
#   *= require bootstrap_and_overrides

inside "app/assets/stylesheets" do
  # replace
  gsub_file "application.css", /\*= require_tree \./ do |match|
    "*= require bootstrap_and_overrides"
  end
  # fix: top margin
  # append onto match
  # gsub_file "application.css", /\*\// do |match|
  #   match << "\nbody { padding-top: 60px; }"
  # end
  append_to_file "application.css", "\nbody { padding-top: 60px; }\n"
end

# customize Bootstrap: http://twitter.github.com/bootstrap/customize.html
# example, append to bootstrap_and_overrides.less
#
# @baseFontSize: 18px;

generate "simple_form:install --bootstrap"

if yes? "Do you want to generate a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index"
  route "root to: '#{name}\#index'"
end

# append_file ".gitignore", "config/database.yml"
# run "cp config/database.yml config/database_example.yml"

# fix: add an empty favicon file
#  or: remove favicons from layout.html.erb
create_file "app/assets/images/favicon.ico"

git :init
git add: ".", commit: "-m 'initial commit'"
