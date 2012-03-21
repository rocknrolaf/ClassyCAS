require 'rubygems'
require 'bundler'
Bundler.require
# Bundler.require doesn't seem to be pulling this in when used as gem...
require 'sinatra'
require 'redis'
require 'nokogiri'
require 'rack'
require 'rack-flash'
require 'warden'

if RUBY_VERSION < "1.9"
  require 'backports'
  require 'system_timer'
end

require 'addressable/uri'

require_relative 'ticket'
require_relative 'login_ticket'
require_relative 'proxy_ticket'
require_relative 'service_ticket'
require_relative 'ticket_granting_ticket'
require_relative 'strategies'

module ClassyCAS

  module Builder

    def new(opts = {})
      app = Class.new  opts[:super]  || ClassyCAS::Server

      app.set :root,   opts[:root]   || File.dirname(__FILE__)
      app.set :public, opts[:public] || File.expand_path('../public', app.root)
      app.set :views,  opts[:views]  || File.expand_path('views', app.root)
      app.set :redis,  opts[:redis]  || Proc.new { Redis.new }

      app.set :client_sites, opts[:client_sites] ||
        %w[ http://localhost:3001 http://localhost:3002 ]

        opts.fetch(:use, []).each do |(middleware, *args)|
        if block = Proc === args.last ? args.pop : nil
          app.use middleware, *args, &block
        else
          app.use middleware, *args
        end
      end

      flash_config = {:accessorize => [:notice, :error]}.merge opts.fetch(:flash, {})
      app.use Rack::Flash, flash_config

      cas_defaults = {:strategies => [:simple], :action => 'login'}.merge opts.fetch(:warden, {})
      app.use Warden::Manager do |manager|
        manager.failure_app   = app
        manager.default_scope = :cas
        manager.scope_defaults  :cas, cas_defaults
      end

      return app
    end
    module_function :new

  end

  class Server < Sinatra::Base
    URI = Addressable::URI

    class << self
      alias_method :new_instance, :new
    end

    def self.new(opts = {})
      server = Builder.new opts
      server.use Rack::Session::Cookie
      server.new_instance
    end

    configure(:development) { set :dump_errors }

    before do
      raise 'No Session!' unless request.env.member? 'rack.session'
    end

    get '/' do
      redirect '/login'
    end

    get '/login' do
      @service_url = URI.parse params[:service]
      @renew   = [true, "true", "1", 1].include? params[:renew]
      @gateway = [true, "true", "1", 1].include? params[:gateway]

      if @renew
        @login_ticket = LoginTicket.create!(settings.redis)
        render_login
      elsif @gateway
        if @service_url
          if sso_session
            st = ServiceTicket.create!(params[:service], sso_session.username, settings.redis)
            redirect_url = @service_url.clone
            if @service_url.query_values.nil?
              redirect_url.query_values = @service_url.query_values = {:ticket => st.ticket}
            else
              redirect_url.query_values = @service_url.query_values.merge(:ticket => st.ticket)
            end
            redirect redirect_url.to_s, 303
          else
            redirect @service_url.to_s, 303
          end
        else
          @login_ticket = LoginTicket.create!(settings.redis)
          render_login
        end
      else
        if sso_session
          if @service_url
            st = ServiceTicket.create!(params[:service], sso_session.username, settings.redis)
            redirect_url = @service_url.clone
            if @service_url.query_values.nil?
              redirect_url.query_values = @service_url.query_values = {:ticket => st.ticket}
            else
              redirect_url.query_values = @service_url.query_values.merge(:ticket => st.ticket)
            end
            redirect redirect_url.to_s, 303
          else
            render_logged_in
          end
        else
          @login_ticket = LoginTicket.create!(settings.redis)
          render_login
        end
      end
    end

    post "/login" do
      username = params[:username]
      password = params[:password]

      service_url = params[:service]

      warn = [true, "true", "1", 1].include? params[:warn]
      # Spec is undefined about what to do without these params, so redirecting to credential requestor
      redirect "/login", 303 unless username && password && login_ticket
      # Failures will throw back to self, which we've registered with Warden to handle login failures
      warden.authenticate!(:scope => :cas, :action => 'unauthenticated')

      tgt = TicketGrantingTicket.create!(username, settings.redis)
      cookie = tgt.to_cookie(request.host)
      response.set_cookie(*cookie)

      if service_url && !warn
        st = ServiceTicket.create!(service_url, username, settings.redis)
        st.save!(settings.redis)
        redirect service_url + "?ticket=#{st.ticket}", 303
      else
        render_logged_in
      end
    end

    get %r{(proxy|service)Validate} do
      service_url = params[:service]
      ticket = params[:ticket]
      # proxy_gateway = params[:pgtUrl]
      # renew = params[:renew]

      xml = if service_url && ticket
      if service_ticket
        if service_ticket.valid_for_service?(service_url)
          render_validation_success service_ticket.username
        else
          render_validation_error(:invalid_service)
        end
      else
        render_validation_error(:invalid_ticket, "ticket #{ticket} not recognized")
      end
      else
        render_validation_error(:invalid_request)
      end

      content_type :xml
      xml
    end


    get '/logout' do
      @url = params[:url]

      if sso_session
        @sso_session.destroy!(settings.redis)
        response.delete_cookie(*sso_session.to_cookie(request.host))
        warden.logout(:cas)
        flash.now[:notice] = "Logout Successful."
        if @url
          msg = "  The application you just logged out of has provided a link it would like you to follow."
          msg += "Please <a href=\"#{@url}\">click here</a> to access <a href=\"#{@url}\">#{@url}</a>"
          flash.now[:notice] += msg
        end
      end
      @login_ticket = LoginTicket.create!(settings.redis)
      @logout = true
      render_login
    end

    def render_login
      erb :login
    end

    def render_logged_in
      erb :logged_in
    end

    # Override to add user info back to client applications
    def append_user_info(username, xml)
    end

    private
      def warden
        request.env['warden']
      end

      def sso_session
        @sso_session ||= TicketGrantingTicket.validate(request.cookies["tgt"], settings.redis)
      end

      def ticket_granting_ticket
        @ticket_granting_ticket ||= sso_session
      end

      def login_ticket
        @login_ticket ||= LoginTicket.validate!(params[:lt], settings.redis)
      end

      def service_ticket
        @service_ticket ||= ServiceTicket.find!(params[:ticket], settings.redis)
      end

      def render_validation_error(code, message = nil)
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.serviceResponse("xmlns:cas" => "http://www.yale.edu/tp/cas") {
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml['cas'].authenticationFailure(message, :code => code.to_s.upcase){
            }
          }
        end
        xml.to_xml
      end

      def render_validation_success(username)
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.serviceResponse("xmlns:cas" => "http://www.yale.edu/tp/cas") {
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml['cas'].authenticationSuccess {
              xml['cas'].user username
              append_user_info(username, xml)
            }
          }
        end
        xml.to_xml
      end
  end
end
