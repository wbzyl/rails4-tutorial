# cat ~/.railsrc
# --skip-bundle
# --no-test-framework

remove_file "README.rdoc"
remove_file "doc/README_FOR_APP"
create_file "README.md"

# add these gems

gem "thin"
gem "simple_form"

# and remove these gems

gsub_file 'Gemfile', /.+'sass-rails'.+\n/, ''
gsub_file 'Gemfile', /.+'coffee-rails'.+\n/, ''

# use Bootstrap for layout: http://twitter.github.com/bootstrap/

gem "less-rails"
gem "therubyracer"

# add Bootstrap to asset pipeline: https://github.com/seyhunak/twitter-bootstrap-rails

gem_group :assets do
  gem "twitter-bootstrap-rails"
end

gem_group :development, :test do
  gem "rspec-rails"
  gem "quiet_assets"
  gem "hirb"
  # for testing with MiniTest: https://github.com/commondream/tconsole
  gem "tconsole"
end

gem_group :test do
  gem "capybara"
end

# run "bundle install"
run "bundle install"

generate "rspec:install"
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
# to use with Less:
# add to application.css:
#
#   *= require bootstrap_and_overrides

generate "simple_form:install --bootstrap"

if yes? "Do you want to generate a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index"
  route "root to: '#{name}\#index'"
  remove_file "public/index.html"
end

# append_file ".gitignore", "config/database.yml"
# run "cp config/database.yml config/database_example.yml"

# add an empty favicon file
create_file "app/assets/favicon.ico"

git :init
git add: ".", commit: "-m 'initial commit'"

# gsub_file 'config/application.rb', /class Application < Rails::Application/ do |match|
#   match << "\n\n  config.generators.stylesheets = false\n  config.generators.javascripts = false"
# end
