local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'GruvboxDarkHard'
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font "Cascadia Code NF"

config.set_environment_variables = {
  TERM = "xterm-256color",
  EDITOR = "nvim",
  VISUAL = "code --wait",
}

config.window_padding = {
  left = 7,
  right = 7,
  top = 0,
  bottom = 0,
}

config.default_cursor_style = 'SteadyBar'

return config