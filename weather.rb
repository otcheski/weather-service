require 'net/http'
require 'cgi'
require 'rexml/document'

require_relative 'lib/meteoservice_forecast'

CITIES = {
  37 => 'Москва',
  69 => 'Санкт-Петербург',
  99 => 'Новосибирск',
  59 => 'Пермь',
  115 => 'Орел',
  141 => 'Братск',
  199 => 'Краснодар',
  175 => 'Томск'
}.invert.freeze

city_names = CITIES.keys

puts 'Погоду какого города вы хотите узнать?'
city_names.each_with_index { |name, index| puts "#{index + 1}: #{name}"}
city_index = gets.to_i

unless city_index.between?(1, city_names.size)
  puts "Введите число от 1 до #{city_names.size}"
  city_index = gets.to_i
end

city_id = CITIES[city_names[city_index - 1]]

URL = "https://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml".freeze

response = Net::HTTP.get_response(URI.parse(URL))

doc = REXML::Document.new(response.body)

forecast_nodes = doc.root.elements['REPORT/TOWN'].elements.to_a

city_name = CGI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

puts '--------------------------'
puts city_name
puts '--------------------------'

forecast_nodes.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
