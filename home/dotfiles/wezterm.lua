local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Gruvbox Material (Gogh)"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font_with_fallback({
    { family = "Cartograph CF", weight = "Medium" },
    "Symbols Nerd Font",
})

config.font_size = 13
-- config.line_height = 1.2

config.set_environment_variables = {
    TERM = "xterm-256color",
}

config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
}

config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0

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
