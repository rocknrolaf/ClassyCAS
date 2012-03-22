class TicketGrantingTicket < Ticket

  alias_method :username, :value

  set_prefix 'TGC-'
  set_ttl 300

  def to_cookie(domain, path = '/', opts = {})
    ['tgt', opts.merge({ :value => ticket, :path  => path })]
  end

end
