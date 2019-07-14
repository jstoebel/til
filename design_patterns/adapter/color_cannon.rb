require 'json'
# I am a color cannon! Load me up with colors and fire them off one by one
class ColorCannon
  # colors: A string representation of json
  # of An array-like of strings representing hexadecimal colors
  def initialize(colors)
    @colors = colors
  end

  # fire a color from the cannon
  def fire
    @colors.shift
  end

  def fire_all
    @colors.length.times do
      puts "Boom! Here's #{fire}."
    end
  end
end
