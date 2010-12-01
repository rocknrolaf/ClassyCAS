source "http://rubygems.org"
gem 'sinatra', '1.1'
gem 'redis', '~>2.0'
gem 'haml', '~>3.0.18'
gem 'addressable', '~>2.1.2'
gem 'nokogiri', '~>1.4.0'
gem 'rack', '~>1.2.0'
gem 'rack-flash'
gem 'rest-client'

platforms :ruby_18 do
  # If running under 1.8, Mongrel warns to install this.
  gem "SystemTimer", "~>1.2"
end

group :test, :development do
  gem "shotgun"
  platforms :ruby_18 do
    gem "ruby-debug"
  end
  platforms :ruby_19 do
    gem "ruby-debug19"
  end
end

group :test do
  gem 'webrat'
  gem 'shoulda'
  gem 'rr'
end

