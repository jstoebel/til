require './parts'
require './car_new'

class CarBuilder
  attr_reader :car

  def initialize(&block)
    # raise 'Car needs a block to be built' unless block_given?
    @car = Car.new
    self.instance_eval(&block) if block_given?
  end

  def add_color(c)
    @car.color = c
  end

  def add_engine(cylinders)
    @car.engine = Parts::Engine.new cylinders
  end

  def add_transmission(type)
    @car.transmission = Parts::Transmission.new type
  end

  def add_sound_system(serial_number)
    @car.sound_system = Parts::SoundSystem.new serial_number
  end

  def add_warrenty(number)
    @car.warrenty_numbers << number
  end
end
