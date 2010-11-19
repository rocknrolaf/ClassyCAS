configure :production do
    require 'redis'
    uri = URI.parse('redis://heroku:60805d87e9dc1626bd64928253407933@goosefish.redistogo.com:9787/')
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    
    FIRST_SITE_URL = 'http://quiet-samurai-41.heroku.com'
    SECOND_SITE_URL = 'http://cold-river-72.heroku.com'
    USER_STORE_URL = 'http://stormy-river-84.heroku.com'
end

configure :development do
    REDIS = Redis.new
    FIRST_SITE_URL = 'http://redrum.local'
    SECOND_SITE_URL = 'http://greenie.local'
    USER_STORE_URL = 'http://0.0.0.0:3000'
end

