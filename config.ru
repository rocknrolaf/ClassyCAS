require 'rubygems'
require 'bundler'
Bundler.setup :default, :development, :standalone
require File.expand_path('../lib/classy_cas', __FILE__)

run ClassyCAS::Server
