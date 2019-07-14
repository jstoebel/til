require './tedious_car'
require './parts'

# first lets create a car by cramming a bunch of data into the constructor
engine = Parts::Engine.new(8)
transmission = Parts::Engine.new(:automatic)
sound_system = Parts::SoundSystem.new('48D3T8')

car1 = TediousCar.new('#FF0000', engine, transmission, sound_system, ['G42WV7', 'E4CDWQ'])

require './car_builder'
require './car_new'
# CarNew _can_ be constructed by passing in a hash, but it doesn't have to be.

car2 = Car.new({
  color: 'red',
  engine: engine,
  transmission: transmission,
  sound_system: sound_system,
  warrenty_numbers: ['g5t1d5', 'h7yt5d']
})

p car1

car_builder = CarBuilder.new do
  add_color '#FF0000'
  add_engine 8
  add_transmission :manual
  add_sound_system :G5T6U8
  add_warrenty :G5T3E5
  add_warrenty :HY6D45
end

car3 = car_builder.car
p car3