class UserStore
  def self.authenticate
    raise "UserStore#authenticate must be implemented by subclasses"
  end
end