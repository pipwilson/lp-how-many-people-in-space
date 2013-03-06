require 'sinatra'
require 'json'

get '/edition/' do
  require './space_parser'
  
  if params["test"]
    etag Digest::MD5.hexdigest("test"+Time.now.getutc.to_s)
    @count = SpaceParser::fetch_data()
  else
    etag Time.now.getutc.strftime('%F'+ params["delivery_count"])
    
    err_count = 0
    while @count.nil?
      begin
        @number_changed, @count = SpaceParser::fetch_data()
        
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
  else
    if @number_changed
      erb :edition
    end
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