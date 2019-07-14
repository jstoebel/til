In this example we are writing software for a company that builds custom vintage cars. The company needs a way to describe the details of each order. To construct a car object we could do it by providing all of the parameters to `new`...

```ruby
require './tedious_car'
require './parts'

color = '#FF0000'
engine = Parts::Engine.new(8)
transmission = Parts::Engine.new(:automatic)
sound_system = Parts::SoundSystem.new('48D3T8')
warranty_numbers = ['G42WV7', 'E4CDWQ']
car1 = TediousCar.new(color, engine, transmission, sound_system, warranty_numbers)
```

As my class name implies, constructing this object is a bit tedious. We have to pass in a bunch of arguments, including instantiating three other objects first. A constructor with so many required parameters is a code smell. A new team member reading this code months or years later could have a really tough time teasing apart how this code actually works. And s the codebase grows things could only get worse!

The builder pattern proposes a different way. When constructing an object becomes less simple, let's separate the responsibility of constructing an object away from an object itself. Under this pattern a `Car` object will encapsulate the car itself but the `CarBuilder` object just represents how the `Car` is created. This is aligned with the Single Responsibility Principal. When constructing an object becomes complex enough to be considered itself a concern, we should extract that responsibility to a new class.

Here's our new car. Notice that we are providing a way to construct a car without a builder class, if one really wanted to, but the class is designed with the intention of using a builder class.
```ruby
require './car_builder'

class Car
  attr_accessor :color, :engine, :transmission, :sound_system
  attr_reader :warranty_numbers
  # Car may be inited with starting values but it doesn't have to be.
  # The intended way to construct this class is by using the builder class.
  def initialize(**attrs)
    @warranty_numbers = []
    attrs.each do |attr, val|
      instance_variable_set "@#{attr}", val
    end
  end
end
```

and the builder class:

```ruby
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

  def add_warranty(number)
    @car.warranty_numbers << number
  end
end
```

The `CarBuilder` creates a simple ruby DSL that let's us build up a car class by sending a `CarBuilder` class messages about what the car should look like.

```ruby
car_builder = CarBuilder.new do
  add_color '#FF0000'
  add_engine 8
  add_transmission :manual
  add_sound_system :G5T6U8
  add_warranty :G5T3E5
  add_warranty :HY6D45
end

car3 = car_builder.car
p car3
```

Much cleaner, right? Someone coming back to this code later on can tell what I am up to more easily. Also, in creating the car, I am only concerned with the actual data I need to pass in. When I'm creating a car, I don't really car about what a `Parts::Transmission` class is. I only care if its a `manual` or `automatic`. Let the builder handle the rest of the details! The result is cleaner, more readable, more testable code.
