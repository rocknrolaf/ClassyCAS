source "http://rubygems.org"
gem 'sinatra', '1.1'
gem 'redis', '~>2.0'
gem 'haml', '~>3.0.18'
gem 'addressable', '~>2.2.2'
gem 'nokogiri', '~>1.4.4'
gem 'rack', '~>1.2.0'
gem 'rack-flash'
# gem 'rest-client' # Used for devise client.

# If running under 1.8, Mongrel warns to install this.
gem "SystemTimer", "~>1.2", :platforms => [:ruby_18]

group :test, :development do
  gem "shotgun"
  gem "ruby-debug", :platforms => [:ruby_18]
  gem "ruby-debug19", :platforms => [:ruby_19]
end

group :test do
  gem 'webrat'
  gem 'shoulda'
  gem 'rr'
end

