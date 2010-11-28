class LocalDb < UserStore
  def self.authenticate
    #TODOV
    raise "UserStore#authenticate must be implemented by subclasses"
  end
end