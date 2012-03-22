class LoginTicket < Ticket

  set_ttl 300

  def self.create!(store)
    super 1, store
  end

end
