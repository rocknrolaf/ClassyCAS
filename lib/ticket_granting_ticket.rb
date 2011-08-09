class TicketGrantingTicket < Ticket

  alias_method :username, :value

  def self.generate_id
    "TGC-#{ rand 100_000_000_000_000_000 }"
  end
  set_ttl 300

  def to_cookie(domain, path = "/", opts = {})
    ['tgt', opts.merge({
      :value => ticket,
      :path  => path
    })]
  end

end
