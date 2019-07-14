class WallPanel
  def initialize(hvac)
    @hvac = hvac
  end

  def mode
    @hvac.mode
  end

  def toggle_mode
    if @hvac.mode == :heat
      @hvac.mode = :cool
      return
    end
    @hvac.mode = :heat
  end

  def temp
    @hvac.desired_temp
  end

  def temp_up
    @hvac.desired_temp += 1
  end

  def temp_down
    @hvac.desired_temp -= 1
  end
end
