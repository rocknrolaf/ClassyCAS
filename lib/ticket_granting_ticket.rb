class TicketGrantingTicket < Ticket

  alias_method :username, :value

  def self.prefix
    'TGC-'
  end
  set_ttl 300

  def to_cookie(domain, path = '/', opts = {})
    ['tgt', opts.merge({ :value => ticket, :path  => path })]
  end

end
