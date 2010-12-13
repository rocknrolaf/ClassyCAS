require 'rubygems'
require 'bundler'
Bundler.require :default, :development
require './lib/classy_cas'

# use Rack::Session::Cookie, :secret => "sdhjlfhaothuowqerwb24y803u023hfds23r3rbweruh23r"

# User = Struct.new(:login, :password)
# Warden::Strategies.add(:simple_strategy) do
#   def valid?
#     params["username"] && params["password"]
#   end
#     
#   def authenticate!
#     if params["username"] == "test" && params["password"] == "password"
#       u = User.new(params["username"], params["password"])
#       success!(u)
#     end
#     fail!("Could not log in")
#   end
# end
# use Warden::Manager do |manager|
#   manager.default_strategies :simple
#   # ClassyCAS.configure_warden!(manager)
# end

run ClassyCAS::Server