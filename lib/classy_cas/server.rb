Bundler.setup :standalone
require 'rack'
require 'rack-flash'
require 'sinatra'

module ClassyCAS
  class Server < Sinatra::Base
    register Extension

    LOGOUT_MSG = 'The application you just logged out of has provided a link it would like you to follow. Please <a href="%s">click here</a> to access <a href="%s">%s</a>'

    configure(:development) { enable :dump_errors }

    set :root,          File.expand_path('../..', __FILE__)
    set :public_folder, File.expand_path('../public', root)

    use Rack::Session::Cookie
    use Rack::Flash, :accessorize => [:notice, :error]

    def destroy_sso
      super

      flash.now[:notice] = 'Logout Successful.'
      flash.now[:notice] += LOGOUT_MSG % [ @url, @url, @url ] if @url
    end

  end
end
