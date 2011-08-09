class Ticket < Struct.new(:value, :id)

  alias_method :ticket, :id
  INFINITE = 1.0 / 0

  module ClassMethods

    attr_accessor :ttl
    alias_method :set_ttl, :ttl=

    def prefix
      raise NotImplementedError
    end

    def generate_id
      "#{ prefix }#{ rand 100_000_000_000_000_000 }"
    end

    def create!(value, store)
      new(value, generate_id).save! store
    end
    def validate(id, store)
      value = store[id] if id
      new value, id if value
    end
    def validate!(id, store)
      return unless ticket = validate(id, store)
      ticket.destroy!(store).dup
    end

    def inherited(base)
      base.ttl = INFINITE
    end

  end
  extend ClassMethods

  def save!(store)
    store.pipelined do
      save store
      store.expire id, ttl if ttl < INFINITE
    end
    self
  end
  def destroy!(store)
    store.del id
    self
  end
  def remaining_time(store)
    ttl < INFINITE ? store.ttl(id) : INFINITE
  end
  def dup
    duplicate = super
    duplicate.id = self.class.generate_id
    duplicate
  end

  protected

    def ttl
      self.class.ttl
    end
    def save(store)
      store[id] = value
    end

end
