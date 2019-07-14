require './color_cannon'
require './color_cannon_adaptor'

# using the color cannon the way it was first imagined. With an array of colors
canon = ColorCannon.new(['#DD4686', '#A1E237', '#01FEC5'])
canon.fire_all

# here we are fetching colors that come to us in a non compatable format. An adaptor encapsulates the conversion to make them compatable.
require 'net/http'
puts 'fetching colors...'
colors_json_str = Net::HTTP.get(URI.parse('https://api.noopschallenge.com/hexbot?count=3'))
colors = ColorCannonAdaptor.new(colors_json_str)
canon = ColorCannon.new(colors)
canon.fire_all
