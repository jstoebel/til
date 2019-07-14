require './hvac'
require './wall_panel'

hvac = HVAC.new
panel = WallPanel.new hvac

puts "mode is #{panel.mode}" # heat
panel.toggle_mode
puts "mode is #{panel.mode}" # cool
panel.toggle_mode
puts "mode is #{panel.mode}" # heat

puts "temp is set to #{panel.temp}" # 70
3.times {panel.temp_up}
puts "temp is set to #{panel.temp}" # 73
6.times {panel.temp_down}
puts "temp is set to #{panel.temp}" # 67


# using command pattern
require './commands'
require './new_wall_panel'

hvac2 = HVAC.new

puts "mode is #{hvac2.mode}" # heat

cmd_toggle_mode = ToggleMode.new hvac2
btn_toggle_mode = PanelButton.new cmd_toggle_mode

btn_toggle_mode.execute

puts "mode is #{panel.mode}" # heat
