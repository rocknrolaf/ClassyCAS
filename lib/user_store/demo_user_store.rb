class DemoUserStore < UserStore
  def self.should_authenticate?
    @@should_authenticate
  end
  
  def self.should_authenticate=(should_it)
    @@should_authenticate = should_it
  end

  def self.authenticate(userstore, password)
    should_authenticate?
  end
end