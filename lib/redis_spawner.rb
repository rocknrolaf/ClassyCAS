class RedisSpawner
  @@config = {}
  
  def initialize(config = {})
    return Redis.new
    # @@config = config
    if RedisSpawner.remote_redis_configured?
        Redis.new(:host => config['redis_host'], 
                  :port => config['redis_port'], 
                  :password =>  config['redis_password'])
    else
      Redis.new
    end    
  end
  

    def self.remote_redis_configured?
      @@config['redis_host'] &&
      @@config['redis_port'] &&
      @@config['redis_password']
    end

end

