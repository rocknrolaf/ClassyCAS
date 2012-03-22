class ServiceTicket < ProxyTicket

  set_ttl 300

  def self.new(service_url, username, id)
    super({ 'service_url' => service_url, 'username' => username }, id)
  end

  def self.create!(service_url, username, store)
    ticket = new service_url, username, generate_id
    ticket.save! store

    ticket
  end
  def self.find!(id, store)
    mem = id ? store.hgetall(id) : {}
    service_url, username = mem.values_at 'service_url', 'username'
    return unless service_url and username

    new(service_url, username, id).destroy!(store).dup
  end

  def service_url
    value.fetch 'service_url'
  end
  def username
    value.fetch 'username'
  end

  def save(store)
    store.hset id, 'service_url', service_url
    store.hset id, 'username', username
  end

end
