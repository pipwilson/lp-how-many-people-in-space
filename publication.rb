require 'sinatra'
require 'json'

get '/edition/' do
  require './space_parser'
  
  if params["test"]
    etag Digest::MD5.hexdigest("test"+Time.now.getutc.to_s)
    @count, @message, @date = SpaceParser::fetch_data()
  else
    etag Digest::MD5.hexdigest(Time.now.strftime('%l%p'))
    
    err_count = 0
    while @count.nil?
      begin
        @count, @date = SpaceParser::fetch_data()
  
      rescue Exception => e
        err_count +=1
        if err_count > 2
          return 500
      
        end
      end
    end
  end
  


  if params["delivery_count"] == "0" || params["test"]
    erb :welcome
    
  # If the top item happened in the last day
  elsif Time.now - @date.to_time < 86400
    erb :edition
  end
end

post '/validate_config/' do
  content_type :json
  response = {}
  response[:valid] = true
  response.to_json
end


get '/sample/' do
  require './space_parser'
  @count = 8
  @message = "All on the ISS"
  erb :edition
end