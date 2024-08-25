local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "camellia-hope-dark"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
-- config.font = wezterm.font({
-- 	family = "Rec Mono Waves",
-- 	weight = "Regular",
-- })
config.font = wezterm.font_with_fallback({
	-- { family = "Rec Mono Waves", weight = "Regular" },
	{ family = "JuliaMono", weight = "Regular" },
	-- "CozetteHiDpi",
	"Symbols Nerd Font Mono",
})
config.font_size = 10
-- config.cell_width = 0.88

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

return config
