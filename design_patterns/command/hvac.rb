class HVAC
  attr_accessor :desired_temp, :mode
  def initialize
    @desired_temp = 70
    @mode = :heat
  end

  def heat
    @mode = :heat
  end

  def cool
    @mode = :cool
  end
end
