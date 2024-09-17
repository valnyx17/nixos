local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Macchiato"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
-- config.font = wezterm.font({
-- 	family = "Rec Mono Waves",
-- 	weight = "Regular",
-- })
config.font = wezterm.font_with_fallback({
  -- { family = "Rec Mono Waves", weight = "Regular" },
  { family = "Monaspace Argon", weight = "Medium" },
  -- "CozetteHiDpi",
  "Symbols Nerd Font",
})
config.font_rules = {
  {
    italic = true,
    font = wezterm.font_with_fallback({
      {family = 'Monaspace Radon', weight = 'Regular'}
    })
  },
}
config.font_size = 13
config.cell_width = 0.95

config.set_environment_variables = {
  TERM = "xterm-256color",
  EDITOR = "nvim",
  VISUAL = "nvim",
}

config.window_padding = {
  left = 7,
  right = 7,
  top = 0,
  bottom = 0,
}

config.default_cursor_style = "SteadyBar"

-- wayland support
config.enable_wayland = false

config.unix_domains = {
  {
    name = "unix",
  },
}
config.freetype_load_flags = "DEFAULT"
config.window_background_opacity = 1.00
config.max_fps = 144
config.scrollback_lines = 10000

-- This causes `wezterm` to act as though it was started as
-- `wezterm connect unix` by default, connecting to the unix
-- domain on startup.
-- If you prefer to connect manually, leave out this line.
-- config.default_gui_startup_args = { "connect", "unix" }
config.ssh_domains = wezterm.default_ssh_domains()

return config
