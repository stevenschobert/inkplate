source 'https://rubygems.org'

gem 'rake',           '~> 11.1.0'
gem 'dotenv',         '~> 2.0.2'
gem 'rack',           '~> 1.6.4'
gem 'simple_router',  '~> 0.9.8'
gem 'xmlrpc',         '~> 0.3.0'
gem 'activerecord',   '~> 4.2.7.1'
gem 'pg',             '~> 0.18.3'

group :development, :test do
  gem 'pry', '~> 0.10.3'
end

group :production do
  gem 'puma', '~> 3.4.0'
  gem 'rack-ssl', '~> 1.4.1'
end

group :test do
  gem 'simplecov', '~> 0.11.0', require: false
  gem 'rspec', '~> 3.4.0'
end
