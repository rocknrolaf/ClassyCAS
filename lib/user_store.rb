class UserStore
  def self.authenticate(username, password)
    if username == "quentin" and password == "testpassword"
      true
    else
      false
    end
  end
end