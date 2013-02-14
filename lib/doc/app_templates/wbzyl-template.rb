# rails new AppName -m

# $HOME/.railsrc
# --skip-test-unit --skip-bundle

remove_file "README.rdoc"
create_file "README.md", "TODO"

gem "thin"
gem "simple_form"

# remove these gems

gsub_file 'Gemfile', /.+'sass-rails'.+\n/, ''
gsub_file 'Gemfile', /.+'coffee-rails'.+\n/, ''

gem "less-rails"
gem "therubyracer"

gem_group :development, :test do
  gem "rspec-rails"
  gem "quiet_assets"
  gem "hirb"
end

gem_group :test do
  gem "capybara"
end

gem_group :assets do
  gem "twitter-bootstrap-rails"
end

# gsub_file 'config/application.rb', /class Application < Rails::Application/ do |match|
#   match << "\n\n  config.generators.stylesheets = false\n  config.generators.javascripts = false"
# end

run "bundle install"

generate "rspec:install"
generate "bootstrap:install"
generate "bootstrap:layout"
generate "simple_form:install --bootstrap"

if yes? "Do you want to generate a root controller?"
  name = ask("What should it be called?").underscore
  generate :controller, "#{name} index"
  route "root to: '#{name}\#index'"
  remove_file "public/index.html"
end

git :init
append_file ".gitignore", "config/database.yml"
# run "cp config/database.yml config/example_database.yml"
git add: ".", commit: "-m 'initial commit'"
