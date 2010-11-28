require File.dirname(__FILE__) + "/../test_helper"
require 'lib/redis_spawner'

class RedisSpawnerTest < Test::Unit::TestCase
  
  context "remote_redis_configured?" do
    setup do
      stub(Redis).new{true}
    end
    
    should 'return true if all host, port, and password are set' do
      RedisSpawner.new('redis_host' => 'localhost', 'redis_port' => '555', 'redis_password' => 'password')
      assert RedisSpawner.remote_redis_configured?
    end
    
    should "return false if one or more config args is missing " do
      RedisSpawner.new
      assert !RedisSpawner.remote_redis_configured?
    end
    
  end
end
  
