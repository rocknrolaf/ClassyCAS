class Ticket < Struct.new(:value, :id)

  alias_method :ticket, :id
  INFINITE = 1.0 / 0

  module ClassMethods

    attr_accessor :ttl
    alias_method :set_ttl, :ttl=

    def generate_id
      raise NotImplementedError
    end

    def create!(value, store)
      ticket = new value, generate_id
      ticket.save! store

      ticket
    end
    def validate(id, store)
      value = store[id] if id
      new value, id if value
    end
    def validate!(id, store)
      return unless ticket = validate(id, store)
      ticket.destroy! store
      new ticket.value, generate_id
    end

    def inherited(base)
      base.ttl = INFINITE
    end

  end
  extend ClassMethods

  def save!(store)
    store[id] = value
    store.expire id, ttl if ttl < INFINITE
  end
  def destroy!(store)
    store.del id
  end
  def remaining_time(store)
    ttl < INFINITE ? store.ttl(id) : INFINITE
  end

  protected

    def ttl
      self.class.ttl
    end

end
