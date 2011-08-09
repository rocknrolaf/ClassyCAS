class ProxyGrantingTicket < ProxyTicket

  def self.generate_id
    "PGT-#{ rand 100_000_000_000_000_000 }"
  end

  def create_proxy_ticket!(store)
    ProxyTicket.create! service_name, store
  end

end
