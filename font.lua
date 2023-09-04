local wezterm = require("wezterm")

local font_size = 13.5
local bold = false
local font_family = ({
	"JetBrainsMono Nerd Font", -- [2]
	"FiraCode Nerd Font Mono", -- [3]
})[1]

local options = {}
if bold then
	options["weight"] = "Bold"
end

local font = wezterm.font(font_family, options)

return {
	font = font,
	font_size = font_size,
}
