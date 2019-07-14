# Adaptor class between hexbot api (https://github.com/noops-challenge/hexbot/)
# and the ColorCannon
class ColorCannonAdaptor
  # json: a json response from hebot
  # structure:
  # colors: [{value: '#000000'}]
  def initialize(json)
    @colors = JSON.parse(json)['colors']
  end

  def shift
    @colors.shift['value']
  end

  def length
    @colors.length
  end
end
