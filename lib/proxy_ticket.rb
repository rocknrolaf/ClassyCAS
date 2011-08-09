class ProxyTicket < Ticket

  alias_method :service_url, :value
  alias_method :service_name, :service_url

  def self.prefix
    'PT-'
  end
  set_ttl 300

  def valid_for_service?(url)
    service_url == url
  end

end
