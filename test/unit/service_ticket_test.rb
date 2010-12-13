unless Kernel.method_defined?(:require_relative)
  require 'rubygems'
  require 'bundler'
  Bundler.require :test, :default
end

require_relative '../test_helper'
require_relative '../../lib/service_ticket'

class ServiceTicketTest < Test::Unit::TestCase
  context "A TicketGrantingTicket" do
    setup do
      @redis = Redis.new
      assert_not_nil @redis
      @st = ServiceTicket.new("http://localhost", "quentin")
      @st.save!(@redis)
    end
    # Most tests are in test/protocol.  Tests here are outside of the protocol, but are necessary anyway.
    context 'find!' do
      should "be able to retrieve the username" do
        assert_equal("quentin", @st.username)
        assert_equal("http://localhost", @st.service_url)

        st2 = ServiceTicket.find!(@st.ticket, @redis)
        assert_equal("quentin", st2.username)
        assert_equal("http://localhost", st2.service_url)
      end
      
      should "only be retrievable once" do
        st2 = ServiceTicket.find!(@st.ticket, @redis)
        assert_nil ServiceTicket.find!(@st.ticket, @redis)
      end      
    end
    
    context 'valid for service?' do
      setup do
        @retrieved_ticket = ServiceTicket.find!(@st.ticket, @redis)
      end
      should 'be true if url passed in is the same as in the the store' do
        assert @retrieved_ticket.valid_for_service?("http://localhost")
      end
      
      should 'be false if url passed in is not the same as in the store' do
        assert_false @retrieved_ticket.valid_for_service?("http://wronghost")      
      end
    end
    
    
  end
end
