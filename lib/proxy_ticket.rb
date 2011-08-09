class ProxyTicket < Ticket

  def self.generate_id
    "PT-#{ rand 100_000_000_000_000_000 }"
  end
  set_ttl 300

  alias_method :service_name, :value

  def valid_for_service?(url)
    value == url
  end

end
