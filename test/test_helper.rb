$:.unshift(File.dirname(__FILE__) + "/../")

require 'test/unit'
require 'rubygems'
require 'bundler'
Bundler.require :test, :default

require 'shoulda'
require 'ruby-debug'
require 'redis'
require "rack/test"
require 'webrat'
# require 'rr'

Webrat.configure do |config|
  config.mode = :rack
end

Shoulda::ClassMethods.module_eval do
  alias :must :should
  alias :may :should
end

require_relative "../lib/classy_cas"

class ClassyCAS::Server
  set :environment, :test
  
  configure :test do    
    set :redis, Proc.new { Redis.new()}
    set :client_sites, [ "http://example.org", 'http://example.com']
  end
end

User = Struct.new(:login, :password)
Warden::Strategies.add(:simple_strategy) do
  def valid?
    params["username"] && params["password"]
  end
    
  def authenticate!
    if params["username"] == "test" && params["password"] == "password"
      u = User.new(params["username"], params["password"])
      success!(u)
    end
    fail!("Could not log in")
  end
end

module Test::Unit::Assertions
  def assert_false(object, message="")
    assert_equal(false, object, message)
  end
end

class Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  use Rack::Session::Cookie
end

