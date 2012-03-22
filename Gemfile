source :rubygems

gem 'redis', '~>2.0'
gem 'addressable', '~>2.2.6'
gem 'nokogiri', '~>1.5.0'
gem 'warden'
# gem 'rest-client' # Used for devise client.

group :standalone, :test do
  gem 'sinatra', '~>1.3.2'
  gem 'rack-flash3'
end

platforms :ruby_18 do
  # If running under 1.8, Mongrel warns to install this.
  gem 'SystemTimer', '~>1.2'
  # Doing our part to slowly, but surely pull everyone up to 1.9...
  gem 'backports'
end

group :development, :test do
  gem 'shotgun'
  gem 'ruby-debug', :platforms => [:ruby_18]
  # not working with ruby 1.9.3 :/
  # gem "ruby-debug19", :platforms => [:ruby_19]
end

group :test do
  gem 'rack-test'
  gem 'webrat'
  gem 'shoulda', '~>2.11'
end

