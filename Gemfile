source 'http://rubygems.org'

ruby '2.0.0'

gem 'rake'
gem 'nokogiri'
gem 'newrelic_rpm'

gem 'sinatra'
gem 'kaminari', require: 'kaminari/sinatra'
gem 'padrino-helpers', '~> 0.11'
gem 'slim'
gem 'activerecord'
gem 'unicorn'

group :development, :test do
  gem 'sqlite3'
  gem 'pry'
  gem 'yard'
  gem 'sinatra-contrib'
end

group :production do
  gem 'pg'
end

