require './publication'  # <-- your sinatra app
require './space_parser'  # <-- your sinatra app
require 'rspec'
require 'rack/test'
require 'json'
require 'webmock/rspec'

set :environment, :test

describe 'Space Publication' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  describe '#publication' do
      
    # Get Sample
    describe 'get a sample' do
      it 'should return some html for get requests to /sample.html' do
        get '/sample/'
        last_response.body.scan("All on the ISS").length.should == 1
        last_response.status.should ==200
      end
    end

    # Post validate_config
    describe 'posting a validation config' do
      it 'should return valid for any config passed to it (there is no validation on this application)' do
        random_key = (0...8).map{65.+(rand(25)).chr}.join.to_sym
        post '/validate_config/', :config => {random_key => rand.to_s}.to_json
        resp = JSON.parse(last_response.body)
        resp["valid"].should == true
      end
    end
    

    describe 'edition' do
      
      it 'should return nothing if space parsers date is not today and if this is not the first edition' do
        
        SpaceParser.should_receive(:fetch_data).and_return(['1', 'On the ISS', Time.now - 1.day])
        
        get '/edition/?delivery_count=1'
        
        last_response.should be_ok
        last_response.body.scan('html').should == []
        last_response.status.should ==200
      end

      it 'should return something if edition count = 0' do
        count = "space_count"
        SpaceParser.should_receive(:fetch_data).and_return([count, 'On the ISS', Time.now - 2.days])
        
        get '/edition/?delivery_count=0'
        last_response.should be_ok
        last_response.body.scan(count).length.should == 1
        last_response.body.scan("On the ISS").length.should == 1
        
      end
      
      it 'should return something if date is today' do
         count = "space_count"
         SpaceParser.should_receive(:fetch_data).and_return([count, 'On the ISS', Time.now])

         get '/edition/?delivery_count=6'
         last_response.should be_ok
         last_response.body.scan(count).length.should == 1
         last_response.body.scan("On the ISS").length.should == 1

       end
      
      # It should throw a 502 after three erroring (with network) calls to fetch_data
      it 'should retry three times before returning a 502 if there is an upstream error' do
        SpaceParser.should_receive(:fetch_data).exactly(3).times.and_raise(Exception)
        get '/edition/?devlivery_count=0'
        last_response.status.should == 500
      end

      it 'should set an etag that changes every hour' do
        SpaceParser.stub!(:fetch_data).and_return(['0', 'some thing something', Time.now])
        
        date_one = Time.parse('3rd Feb 2001 04:05:06+03:30')
        date_two = Time.parse('4th Feb 2001 05:05:06+03:30')
        date_three = Time.parse('4th Feb 2001 05:10:06+03:30')
        
        Time.stub(:now).and_return(date_one)
        get '/edition/?access_token=123&ll=123,123'
        etag_one = last_response.original_headers["ETag"]

        Time.stub(:now).and_return(date_two)
        get '/edition/?access_token=123&ll=123,123'
        etag_two = last_response.original_headers["ETag"]

        get '/edition/?access_token=123&ll=123,123'
        etag_three = last_response.original_headers["ETag"]

        Time.stub(:now).and_return(date_three)
        get '/edition/?access_token=123&ll=123,123'
        etag_four = last_response.original_headers["ETag"]

        etag_one.should_not == etag_two
        etag_two.should == etag_three
        etag_four.should == etag_three
      end
    end
  end
  
  
  #
  # Generic statements about push publication (asset checking)
  #
  
  describe '#assets' do
    describe '#get meta.json' do
      it 'should return json for meta.json' do
        get '/meta.json'
        last_response["Content-Type"].should == "application/json;charset=utf-8"
        json = JSON.parse(last_response.body)
        json["name"].should_not == nil
        json["description"].should_not == nil
      end

    end

    describe '#get icon' do
      it 'should return a png for /icon' do
        get '/icon.png'
        last_response['Content-Type'].should == 'image/png'
      end
    end
  end
end
