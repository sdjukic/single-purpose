
require 'sinatra/base'
require 'json'
require 'httparty'
require 'date'
require 'yaml'


class App < Sinatra::Base

  configure do
    data = YAML.load_file('.secret_config.yaml')
    API_KEY = data['WEATHER_KEY']

    data = YAML.load_file('conf.yaml')
    @@cities = data["Cities"] 
    
    @@latest_query = DateTime.new(0)
    QUERY = "http://api.wunderground.com/api/"
  end

  # don't want this, update if data stale
  before do
    right_now = DateTime.now
    if @@latest_query.strftime("%Y%m%d") != right_now.strftime("%Y%m%d") or 
       right_now.strftime("%H%M") - @@latest_query.strftime("%H%M").to_i > 15   # update every 15 minutes
      @@current_observation = update_conditions
      @@latest_query = DateTime.now
    end
  end


  def make_api_call(state, city)
    query = QUERY + API_KEY + "/conditions/q/#{state}/#{city}.json"
    res = HTTParty.get(query)
    parsed = JSON.parse(res.body)
    data = parsed['current_observation']
    response = {}
    response['city'] = city
    response['temp_c'] = data['temp_c']
    response['temp_f'] = data['temp_f']
    response['weather'] = data['weather']
    response['relative_humidity'] = data['relative_humidity']
    response['wind_string'] = data['wind_string']
    response
  end


  


  get '/' do
    puts "Latest update was at #{@@latest_query}"
    @@current_observation.each do |o| 
      puts "Here are observations for #{o['city']}:"
      puts "Temperature: #{o['temp_c']} C #{o['temp_f']} F"
      puts "Humidity: #{o['relative_humidity']}"
      puts "Wind: #{o['wind_string']}"
    end
    erb :home
  end

  helpers do
    
    def update_conditions
       result = []
       @@cities.each do |c|
        result << make_api_call(c['state'], c['city'])
      end
      result
    end
  
    def update? cities
      now = Time.now
      
    end

  end

end

