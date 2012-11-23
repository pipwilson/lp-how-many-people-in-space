require 'net/http'
require 'net/https'
require 'open-uri'

require 'feedzirra'
class SpaceParser
    
  def self.fetch_data()        
    feed = Feedzirra::Feed.fetch_and_parse("http://feeds.feedburner.com/SpaceRightNow")
    entry = feed.entries.first
    count = entry.title
    message = entry.summary
    date = entry.published
    return count, message, date
  end                                
end
