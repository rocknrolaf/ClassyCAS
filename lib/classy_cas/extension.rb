require 'warden'
require 'redis'

module ClassyCAS
  module Extension

    def self.registered(base)
      unless base.respond_to? :redis
        base.set :redis, lambda { Redis.new }
      end
      unless base.respond_to? :client_sites
        base.set :client_sites, %w[ http://localhost:3001 http://localhost:3002 ]
      end

      base.helpers Helper

      base.get('/') { redirect '/login' }
      base.get('/login') do
        case params
        when has?(:renew)
          renew_login
        when has?(:gateway)
          gateway_login
        else
          service_login
        end
      end
      base.post('/login') { login }
      base.get(%r'(proxy|service)Validate') { validate }
      base.get('/logout') { logout }

      warden_strategies = if base.respond_to? :warden_strategies
        base.warden_strategies
      else
        { :strategies => [:simple], :action => 'login' }
      end

      base.use Warden::Manager do |manager|
        manager.failure_app   = base
        manager.default_scope = :cas
        manager.scope_defaults  :cas, warden_strategies
      end
    end

  end
end
