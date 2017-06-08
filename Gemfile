ruby File.read(".ruby-version").strip[/^[^-]+/]
source 'https://rubygems.org'

ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'haml'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'twitter'
gem 'sidekiq'
gem 'sidetiq'
gem 'sidekiq-unique-jobs'
gem 'sidekiq-failures'
gem 'sinatra', '2.0.0.beta2'
gem 'aws-sdk', '~> 2.0'
gem 'annotate'
gem 'rails_12factor', group: :production
gem 'devise'
gem 'devise_token_auth'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'rollbar'
gem 'gibberish'
gem 'paperclip'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'react-rails'
gem 'stripe'
gem 'react-bootstrap-rails'
gem 'paper_trail'
gem 'browserify-rails'
gem 'active_model_serializers'
gem "paranoia", '~> 2.2.0.pre'
gem 'puma'
gem 'websocket-rails', git: 'https://github.com/ricardo-quinones/websocket-rails.git'
gem 'mini_magick'
gem 'thin'
gem 'gibbon'
gem 'high_voltage', '~> 3.0.0'
gem 'pry-rails'
gem 'pry-theme'
gem 'pry'
gem 'hashie'
gem 'mandrill-api'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-byebug', '~> 1.3.3'
  gem 'spring'
  gem 'dotenv-rails'
  gem 'awesome_print'
end

group :development do
  gem 'web-console'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'ultrahook'
  gem 'httplog'
end

group :test do
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'spring-commands-rspec', require: false
  gem "factory_girl_rails", "~> 4.0"
  gem 'vcr'
  gem 'webmock'
  gem 'stripe-ruby-mock', '~> 2.3.1', :require => 'stripe_mock'
end
