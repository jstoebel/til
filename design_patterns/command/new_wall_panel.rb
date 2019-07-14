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
