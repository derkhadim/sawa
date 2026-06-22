source 'https://rubygems.org'

ruby '>= 3.0.0'

gem 'rails', '~> 7.0'
gem 'puma', '~> 6.0'
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.7'
gem 'rack-cors'
gem 'jbuilder', '~> 2.11'
gem 'bootsnap', require: false
gem "tailwindcss-rails", "~> 3.0"
gem "propshaft"

group :production do
  gem 'pg', '~> 1.5'
end

group :development, :test do
  gem 'sqlite3', '~> 2.0'
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
end

group :development do
  gem 'listen', '~> 3.8'
  gem 'brakeman'
end
