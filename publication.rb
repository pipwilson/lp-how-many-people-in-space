require 'sinatra'
require 'json'

get '/edition/' do
  require './space_parser'
  @checkin_time = "#{Time.now().strftime('%l%P')}"
  
  if params["test"]
    etag Digest::MD5.hexdigest("test"+Time.now.getutc.to_s)
    @count, @message, @date = SpaceParser::fetch_data()
  else
    etag Digest::MD5.hexdigest(Time.now.strftime('%l%p'))
    
    err_count = 0
    while @count.nil?
      begin
        @count, @message, @date = SpaceParser::fetch_data()
  
      rescue Exception => e
        err_count +=1
        if err_count > 2
          return 500
        end
      end
    end
  end
  
  # strip html from @message, current implentation of render stack gives mojibake with links
  @message = @message.gsub(/<\s*a.*?>|<\s*\/\s*a>/i, '')
  if params["delivery_count"] == "0" || params["test"]
    erb :welcome
  elsif Time.now - @date < 1.day 
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