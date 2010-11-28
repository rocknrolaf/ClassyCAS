require 'rest_client'

class UserStore
  APP_CONFIG = YAML.load_file("../config/classy_cas.yml")[ENV['RACK_ENV']]
  
  def self.authenticate(username, password)
    begin
      RestClient.post "#{AppConfig['user_store_url']}/users/sign_in.xml", 
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