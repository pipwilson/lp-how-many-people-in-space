require 'net/http'
require 'net/https'
require 'open-uri'

require 'rest-client'
class SpaceParser
    
  def self.fetch_data()        
    feed = RestClient.get("http://bradeshbach.com/howmanypeopleareinspacerightnow/space.json")
    people_in_space = JSON.parse(feed)
    
    count = people_in_space['number']
    most_recent_launch_date = Date.parse(people_in_space['people'][0]['launchdate'])
    
    people_in_space['people'].each do |person|
      
      if most_recent_launch_date > Date.parse(person['launchdate'])
        most_recent_launch_date = Date.parse(person['launchdate'])
      end
      
    end
    
    return count, most_recent_launch_date
  end                                
end
