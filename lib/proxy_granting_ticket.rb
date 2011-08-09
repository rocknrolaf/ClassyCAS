class ProxyGrantingTicket < ProxyTicket

  def self.prefix
    'PGT-'
  end

  def create_proxy_ticket!(store)
    ProxyTicket.create! service_name, store
  end

end
