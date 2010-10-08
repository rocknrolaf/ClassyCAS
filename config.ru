require 'classy_cas'
require 'rack/flash'
use Rack::Session::Cookie
use Rack::Flash

run Sinatra::Application