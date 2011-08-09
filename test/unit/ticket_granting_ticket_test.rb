unless Kernel.method_defined?(:require_relative)
  require 'rubygems'
  require 'bundler'
  Bundler.require :test, :default
end

require_relative '../test_helper'
require_relative '../../lib/ticket_granting_ticket'

class TicketGrantingTicketTest < Test::Unit::TestCase

  context "A TicketGrantingTicket" do
    setup do
      @redis = Redis.new
      @tgt = TicketGrantingTicket.create!("quentin", @redis)
    end
    # Most tests are in test/protocol.  Tests here are outside of the protocol, but are necessary anyway.

    should "be able to retrieve the username" do
      assert_equal("quentin", @tgt.username)

      tgt2 = TicketGrantingTicket.validate(@tgt.ticket, @redis)
      assert_equal("quentin", @tgt.username)
    end

    should "return a ticket" do
      assert_not_nil @tgt.ticket
    end

    should "be able to destroy itself" do
      assert_not_nil TicketGrantingTicket.validate(@tgt.ticket, @redis)
      @tgt.destroy!(@redis)
      assert_nil TicketGrantingTicket.validate(@tgt.ticket, @redis)
    end

    should 'be instatiated and saved in one method through create!' do
      @tgt = TicketGrantingTicket.create!('quentin', @redis)
      assert_not_nil @tgt
      assert TicketGrantingTicket.validate(@tgt.ticket, @redis)
    end

    should 'expire' do
      @tgt = TicketGrantingTicket.create!('quentin', @redis)
      ttl = @redis.ttl(@tgt.ticket)
      assert ttl >= 299 && ttl <= 300
    end

  end
end
