require File.dirname(__FILE__) + "/../test_helper"
require "rack/test"
require File.dirname(__FILE__) + "/../../classy_cas"

class CasServerTest < Test::Unit::TestCase
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers

  def app
    Sinatra::Application.new
  end

  context "A CAS server" do
    setup do
      @service_url = "http://example.com?page=foo bar"
      @redis = Redis.new
    end
    
    # 2.1
    context "/login as credential requestor" do
      # 2.1.1
      context "parameters" do
        should "request credentials" do
          get "/login"
          
          assert_have_selector "form"
        end

        context "a single sign-on session already exists" do
          should "notify the client that it is already logged in"
        end

        context "with a 'service' parameter" do
          should "be url-encoded" do
            service_url = "http://example.com?page=foo bar"

            get "/login?service=#{URI.encode(service_url)}"
            assert last_response.ok?

            assert_raise(URI::InvalidURIError) { get "/login?service=#{service_url}" }
          end
                
          context "a single sign-on session already exists" do

          end
        end
      
        context "with a 'renew' parameter" do
          context "a single sign-on session already exists" do
            should "bypass single sign on and force the client to renew"
          end

          context "with a 'gateway' parameter" do
            # RECOMMENDED
            should "have 'renew' take precedence over a 'gateway' parameter"
          end
        end
      
        context "with a 'gateway' parameter" do
          # RECOMMENDED
          should "request credentials as though neither 'gateway' or 'service' were set"
        
          context "with a 'service' parameter" do
            should "not ask for credentials"

            context "a single sign-on session already exists" do
              # MAY
              should "redirect the client to the service URL, appending a valid service ticket"
            
              # MAY
              # should "interpose an advisory page informing the client that a CAS authentication has taken place"
            end
            # MUST
            should "redirect the client to the service URL without a ticket"
          end
        end
      end
    
      # 2.1.3
      context "response for username/password authentication" do
        # MUST
        should "include a form with the parameters, 'username', 'password', and 'lt'" do
          get "/login"
          
          assert_have_selector "input[name='username']"
          assert_have_selector "input[name='password']"
          assert_have_selector "input[name='lt']"
        end
      
        # MAY
        should "include the parameter 'warn' in the form" do
          get "/login"

          assert_have_selector "input[name='warn']"
        end
      
        context "with a 'service' parameter" do
          # MUST
          should "include the parameter 'service' in the form" do
            get "/login?service=#{URI.encode(@service_url)}"
            
            assert_have_selector "input[name='service']"
            assert field_named("service").value == @service_url
          end
        end
      end
    
      # 2.1.4
      context "response for trust authentication" do
        # TODO
      end
    
      # 2.1.5
      context "response for single sign-on authentication" do
        context "a single sign-on session already exists" do
          # As 2.2.4
        end
        # As 2.1.3 or 2.1.4
      end
    end

    # 2.2
    context "/login as credential acceptor" do
      # 2.2.1
      # Tests in 2.2.4
      # context "parameters common to all types of authentication" do
      #   context "with a 'service' parameter" do
      #     # MUST
      #     should "redirect the client to the 'service' url"
      #   end
      #   
      #   context "with a 'warn' parameter" do
      #     # MUST
      #     should "prompt the client before authenticating on another service"
      #   end
      # end
      
      # 2.2.2
      context "parameters for username/password authentication" do
        # MUST
        should "require 'username', 'password', and 'lt' (login ticket) parameters" do
          post "/login"
          
          assert !last_response.ok?
        end
      end
      
      # 2.2.3
      context "parameters for trust verification" do
        # TODO
      end
      
      # 2.2.4
      context "responding" do
        context "with success" do
          setup { @params = {:username => "quentin", :password => "testpassword", :lt => "LT-1"} }
          
          context "with a 'service' parameter" do
            setup { @params[:service] = URI.encode(@service_url)}
            # MUST
            should "cause the client the send a GET request to the 'service'" do
              post "/login", @params
              assert last_response.redirect?
              assert_equal URI.encode(@service_url), last_response.headers["Location"]
            end
            
            # MUST
            should "not forward the client's credentials to the 'service'" do
              post "/login", @params
              
              assert_no_match /testpassword/, last_response.inspect
            end
            
            # 2.2.1 again
            context "with a 'warn' parameter" do
              setup { @params[:warn] = "true" }
              # MUST
              should "prompt the client before authenticating to another service" do
                post "/login", @params
                assert !last_response.redirect?
              end
            end
          end
          
          # MUST
          should "display a message notifying the client that it has successfully initiated a single sign-on session" do
            post "/login", @params
            assert !last_response.redirect?
          end
        end
        
        context "with failure" do
          should "return to /login as a credential requester"
          
          # RECOMMENDED
          should "display an error message describing why login failed"
          
          # RECOMMENDED
          should "provide an opportunity to attempt to login again"
        end
      end
    end
    
    # 2.3
    context "/logout" do
      context "parameters" do
      end

      # 2.3.3
      context "response" do
        # MUST
        should "display a page stating that user has been logged out"

        # 2.3.1
        context "with a 'url' parameter" do
          # MAY
          should "link back to 'url' on the logout page"
        end
      end
    end

    # 2.4 [CAS 1.0: Skipped]
    
    # 2.5
    context "/serviceValidate" do
      
    end
    
    # 3.1
    context "service ticket" do
      setup do
        @st = ServiceTicket.new(@service_url)
        @st.save!(@redis)
      end
      
      # 3.1.1
      context "properties" do
        should "be valid only for the service that was specified to /login when they were generated" do
          assert @st.valid_for_service?(@service_url)
          assert !@st.valid_for_service?("http://google.com")
        end
        
        should "not include the service identifier in the service ticket" do
          assert !@st.ticket.include?(@service_url)
        end
        
        # MUST
        should "be valid for only one attempt" do
          assert ServiceTicket.validate!(@st.ticket, @redis)

          assert !ServiceTicket.validate!(@st.ticket, @redis)
        end
        
        should "expire unvalidated service tickets in a reasonable period of time (recommended to be less than 5 minutes)" do
          assert @st.remaining_time(@redis) <= 300
        end
        
        # MUST
        # should "contain adequate secure random data so that a ticket is not guessable" Is this even testable?
        
        # MUST
        should "begin with the characters 'ST-'" do
          assert_match /^ST-/, @st.ticket
        end
        
        # Services must accept a minimum of 32 chars.  Recommended 256
      end
    end
    
    # 3.2
    context "proxy ticket" do
      setup do
        @pt = ProxyTicket.new(@service_url)
        @pt.save!(@redis)
      end
      
      # 3.2.1
      context "properties" do
        should "be valid only for the service that was specified to /proxy when they were generated" do
          assert @pt.valid_for_service?(@service_url)
          assert !@pt.valid_for_service?("http://google.com")
        end
        
        should "not include the service identifier in the proxy ticket" do
          assert !@pt.ticket.include?(@service_url)
        end
        
        # MUST
        should "be valid for only one attempt" do
          assert ProxyTicket.validate!(@pt.ticket, @redis)

          assert !ProxyTicket.validate!(@pt.ticket, @redis)
        end
        
        should "expire unvalidated service tickets in a reasonable period of time (recommended to be less than 5 minutes)" do
          assert @pt.remaining_time(@redis) <= 300
        end
        
        # MUST
        # should "contain adequate secure random data so that a ticket is not guessable" Is this even testable?
        
        should "begin with the characters 'PT-'" do
          assert_match /^PT-/, @pt.ticket
        end
        
        # MUST
        should "begin with the characters 'ST-' or 'PT-'" do
          assert_match /^(ST|PT)-/, @pt.ticket
        end
        
        # Services must accept a minimum of 32 chars.  Recommended 256
      end
    end
    
    # 3.3
    context "proxy-granting ticket" do
      # 3.3.1
      context "properties" do
        # MAY
        should "be able to be used by services to obtain multiple proxy tickets"
        
        # MUST
        should "expire with the client logs out of CAS"
        
        # MUST
        # should "contain adequate secure random data so that the ticket-granting cookie is not guessable in a reasonable period of time"
        # MUST
        should "begin with the characters 'PGT-'"
        
        # Services must accept a minimum of 64 chars.  Recommended 256
      end
    end
    
    # 3.5
    context "login ticket" do
      setup do
        @lt = LoginTicket.new
        @lt.save!(@redis)
      end
      
      # 3.5.1
      context "properties" do
        # MUST
        # should "be probablistically unique"
      
        # MUST
        should "be valid for only one attempt" do
          assert LoginTicket.validate!(@lt.ticket, @redis)
          
          assert !LoginTicket.validate!(@lt.ticket, @redis)
        end
      
        should "begin with the characters 'LT-'" do
          assert_match /^LT-/, @lt.ticket
        end
      end
    end
    
    # 3.6
    context "ticket-granting cookie" do
      setup do
        @tgt = TicketGrantingTicket.new
        @tgt.save!(@redis)
      end
      # 3.6.1
      context "properties" do
        # MUST
        should "be set to expire at the end of the client's browser session" do
          cookie_args = @tgt.to_cookie("http://localhost", "/cas")
          assert_equal(nil, cookie_args[1][:expires])
        end
        
        # MUST
        should "have a cookie path set to be as restrictive as possible" do
          cookie_args = @tgt.to_cookie("http://localhost", "/cas")
        
          assert_equal("/cas", cookie_args[1][:path])
        end
        
        # MUST
        # should "contain adequate secure random data so that the ticket-granting cookie is not guessable in a reasonable period of time"
        
        should "begin with the characters 'TGC-'" do
          assert_match /^TGC-/, @tgt.ticket
        end
      end
    end
    
    # 3.7
    context "ticket and ticket-granting cookie character set" do
      setup do
        @tickets = [
          LoginTicket.new,
          ServiceTicket.new("foo"),
          TicketGrantingTicket.new
        ]
      end
      # MUST
      should "contain only characters from the set {A-Z, a-z, 0-9, and the hyphen character}" do
        @tickets.each do |t|
          assert_match /^[A-Za-z0-9\-]+$/, t.ticket
        end
        
      end
    end
  end
end