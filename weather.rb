require 'net/http'
require 'rexml/document'
require 'json'

require_relative 'lib/meteoservice_forecast'

current_path = File.dirname(__FILE__)
cities_file_name = "#{current_path}/data/cities.json"

begin
  file = File.read(cities_file_name)
rescue Errno::ENOENT
  abort 'File not found'
end

cities_names = JSON.parse(file)

puts 'Погоду в каком городе России вы хотите узнать?'
user_input = STDIN.gets.chomp

city_id = nil
city_name = nil

cities_names.each do |key, value|
  if value == user_input.capitalize
    city_id = key
    city_name = value.to_s.capitalize
  end
end

abort "В нашем списке нет города #{user_input}" if city_id.nil?

URL = "https://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml".freeze

response = Net::HTTP.get_response(URI.parse(URL))

doc = REXML::Document.new(response.body)

forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

puts
puts '--------------------------'
puts "Погода в городе #{city_name}"
puts '--------------------------'

forecast_nodes.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
