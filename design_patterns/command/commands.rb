class Command
  def initialize(hvac)
    @hvac = hvac
  end
end

class ToggleMode < Command
  def execute
    if @hvac.mode == :heat
      @hvac.mode = :cool
      return
    end
    @hvac.mode = :heat
  end
end

class TempUp
  def exectue
    @hvac.desired_temp += 1
  end
end

class TempDown
  def execute
    @hvac.desired_temp -= 1
  end
end
