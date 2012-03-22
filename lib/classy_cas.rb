if RUBY_VERSION < '1.9'
  require 'backports'
  require 'system_timer'
end

# TODO place files in cas/
require_relative 'ticket'
require_relative 'login_ticket'
require_relative 'proxy_ticket'
require_relative 'service_ticket'
require_relative 'ticket_granting_ticket'

require_relative 'classy_cas/helper'
require_relative 'classy_cas/extension'

require_relative "strategies/base"
# TODO autoload strategies
require_relative "strategies/simple"
require_relative "strategies/devise_database"

module ClassyCAS
  autoload :Server, File.expand_path('../classy_cas/server', __FILE__)
end
