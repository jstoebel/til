class TediousCar
  attr_accessor :color, :engine, :transmission, :sound_system, :add_ons
  def initialize(color, engine, transmission, sound_system, warrenty_numbers=[])
    @color = color
    @engine = engine
    @transmission = transmission
    @sound_system = sound_system
    @warrenty_numbers = warrenty_numbers
  end
end
