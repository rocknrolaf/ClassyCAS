require 'rubygems'
require 'bundler'
Bundler.require
require './lib/classy_cas'

class ClassyCAS
  set :redis, Proc.new { Redis.new()}
  set :client_sites, [ "http://casclientone.heroku.com", 'http://casclienttwo.heroku.com']
end

run ClassyCAS