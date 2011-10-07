source "http://rubygems.org"
gem 'sinatra', '1.1'
gem 'redis', '~>2.0'
gem 'addressable', '~>2.2.6'
gem 'nokogiri', '~>1.5.0'
gem 'rack', '~>1.2.0'
gem 'rack-flash'
gem 'warden'
# gem 'rest-client' # Used for devise client.

platforms :ruby_18 do
  # If running under 1.8, Mongrel warns to install this.
  gem "SystemTimer", "~>1.2"
  # Doing our part to slowly, but surely pull everyone up to 1.9...
  gem "backports"
end

group :test, :development do
  gem "shotgun"
  gem "ruby-debug", :platforms => [:ruby_18]
  gem "ruby-debug19", :platforms => [:ruby_19]
end

group :test do
  gem 'webrat'
  gem 'shoulda'
end

