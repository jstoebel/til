require './car_builder'

class Car
  attr_accessor :color, :engine, :transmission, :sound_system
  attr_reader :warrenty_numbers
  # Car may be inited with starting values but it doesn't have to be.
  # The intended way to construct this class is by using the builder class.
  def initialize(**attrs)
    @warrenty_numbers = []
    attrs.each do |attr, val|
      instance_variable_set "@#{attr}", val
    end
  end
end
