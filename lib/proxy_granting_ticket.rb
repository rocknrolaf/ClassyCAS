class ProxyGrantingTicket < ProxyTicket

  def create_proxy_ticket!(store)
    ProxyTicket.create! service_name, store
  end

end
