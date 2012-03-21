$:.unshift(File.dirname(__FILE__) + "/../")

require 'test/unit'

require 'rubygems'
require 'bundler/setup'
Bundler.require :test, :default

require "rack/test"
# require 'rr'

Webrat.configure { |config| config.mode = :rack }

Shoulda::ClassMethods.module_eval do
  alias :must :should
  alias :may :should
end

require_relative "../lib/classy_cas"

ClassyCAS::Server.client_sites = %w[ http://example.org http://example.com ]
ClassyCAS::Server.set :environment, :test

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

