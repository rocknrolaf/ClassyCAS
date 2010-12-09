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

class ClassyCAS
  set :environment, :test
  
  configure :test do
    require_relative '../lib/user_store/demo_user_store'
    
    set :redis, Proc.new { Redis.new()}
    set :client_sites, [ "http://example.org", 'http://example.com']
    set :user_store, DemoUserStore
  end
end

module Test::Unit::Assertions
  def assert_false(object, message="")
    assert_equal(false, object, message)
  end
end

class Test::Unit::TestCase
  # include RR::Adapters::TestUnit
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
  use Rack::Session::Cookie
end