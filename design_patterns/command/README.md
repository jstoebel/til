The command pattern seeks to separate an object that performs an action from the commands that it will receive.

Imagine that we have a simple HVAC system. We can toggle between modes (heat and cool) and we can change the desired temperature.

```
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
```

We also have a wall panel class that is aware of the HVAC it controls. Users wanting to interact with the hvac do so via the wall panel. (This is an example of delegation, btw).
```
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
```

This seems to work just fine. But what happens when there is not a simple one to one relationship between wall pannels? What if, for example, a wall panel needs to control more than one HVAC system? Or if wall panels can vary in the types of commands they can perform? The command pattern proposes that a command sent to the HVAC system should be its own object, and that wall panels should only know what commands they have access to, but not what those commands ultimatly do. In a more complex system, this more fine grained seperation of concerns might be a good idea.

In our revised version, a wall panel can have an arbitrary number of buttons each of which is wired to a command. The wall panel and button are not concerend with who will recieve the command or what that command will do. In a complex system this decoupling may be useful (but like all patterns it might also be over engineered -- knowing when to use a pattern is an art in itself!)

```
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

class NewWallPanel
  def initialize
    @buttons = []
  end

  def add_button(button)
    @buttons << button
  end
end

class PanelButton
  def initialize(cmd)
    @cmd = cmd
  end

  def on_press
    @cmd.execute
  end
end

```


If for example we want to create a minimal wall panel that only lets the user toggle between heat and cool, but not change the temp:

```
hvac2 = HVAC.new

puts "mode is #{hvac2.mode}" # heat

cmd_toggle_mode = ToggleMode.new hvac2
btn_toggle_mode = PanelButton.new cmd_toggle_mode

btn_toggle_mode.execute

puts "mode is #{panel.mode}" # heat
```