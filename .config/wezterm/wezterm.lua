-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration.
local config = wezterm.config_builder()

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "y", mods = "CTRL", action = "ActivateCopyMode" },
	{ key = "q", mods = "CTRL", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "t", mods = "CTRL", action = act({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "j", mods = "LEADER", action = act({ ActivateTabRelative = -1 }) },
	{ key = "k", mods = "LEADER", action = act({ ActivateTabRelative = 1 }) },
	{ key = "l", mods = "LEADER", action = act({ ActivateTabRelative = -1 }) },
	{ key = "h", mods = "LEADER", action = act({ ActivateTabRelative = 1 }) },
	{ key = "s", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "v", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "LEADER", action = act.PaneSelect },
	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	{ key = "i", mods = "ALT", action = "QuickSelect" },
}

-- This is where you actually apply your config choices
-- For example, changing the color scheme:
-- config.color_scheme = "AdventureTime"
config.color_scheme = "Atom"
config.font_size = 15

-- and finally, return the configuration to wezterm
return config
