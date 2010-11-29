class Demo < UserStore
  def self.authenticate(userstore, password)
    true
  end
end