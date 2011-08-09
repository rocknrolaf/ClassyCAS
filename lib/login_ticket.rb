class LoginTicket < Ticket

  def self.create!(store)
    super 1, store
  end
  def self.generate_id
    "LT-#{ rand 100_000_000_000_000_000 }"
  end

  set_ttl 300

end
