require 'rubygems'
require 'bundler'
Bundler.require
require './lib/classy_cas'

class ClassyCAS
  require_relative 'user_store/demo'
  
  set :redis, Proc.new { Redis.new()}
  set :client_sites, [ "http://casclientone.heroku.com", 'http://casclienttwo.heroku.com']
  set :user_store, DemoUserStore
end

run ClassyCAS