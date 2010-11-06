require 'rest_client'

class UserStore
  def authenticate(username, password)
    begin
      RestClient.post "#{USER_STORE_URL}/users/sign_in.xml", 
                                :user => {:email => username, 
                                :password => password}, 
                                :content_type => :xml
    rescue RestClient::Request::Unauthorized
      return false
    rescue RestClient::Found
      return true
    rescue Exception => e
      raise e
    end                            
  end
end