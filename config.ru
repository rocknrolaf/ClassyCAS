require 'rubygems'
require 'bundler'
Bundler.require :default, :production
require './lib/classy_cas'

redis_uri = URI.parse(ENV["REDISTOGO_URL"])

ClassyCAS::Server.redis = Redis.new(:host => redis_uri.host, :port => redis_uri.port, :password => redis_uri.password)
ClassyCAS::Server.client_sites = [ 'http://casclientone.heroku.com', 'http://casclienttwo.heroku.com' ]
run ClassyCAS::Server