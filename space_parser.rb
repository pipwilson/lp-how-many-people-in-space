require 'net/http'
require 'net/https'
require 'open-uri'
require 'redis'

require 'rest-client'
class SpaceParser
  REDISTOGO_URL = "redis://redistogo:0c04c34a0dd134694eb52b71e5f78af7@barreleye.redistogo.com:10253/"
  
  def self.redis
    @@redis
  end
  
  
  def self.fetch_data()  
    uri = URI.parse(REDISTOGO_URL)
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    
    last_count = @redis.get('people_in_space')
    date_changed = @redis.get('date_changed')
    
    today = Time.now.getutc.strftime('%Y-%m-%d')
    date_changed = today if date_changed.nil?
    
    feed = RestClient.get("http://howmanypeopleareinspacerightnow.com/space.json")
    people_in_space = JSON.parse(feed)
    count = people_in_space['number']
    
    is_new = false
    
    if today == date_changed
      is_new = true
    elsif count.to_s != last_count
      @redis.set('people_in_space', count)
      @redis.set('date_changed', today)
      is_new = true
    end
  
    return [is_new, count]
  end
              
end
