module Parts
  class Engine
    attr_reader :cylinders
    def initialize(cylinders)
      @cylinders = cylinders
    end
  end

  class Transmission
    attr_reader :cylinders
    def initialize(type)
      raise "must be either automatic or manual" unless %i[automatic manual].include? type.to_sym
      @type = type
    end
  end

  class SoundSystem
    attr_reader :serial_number
    def initialize(serial_number)
      @serial_number = serial_number.to_sym
    end
  end
end
