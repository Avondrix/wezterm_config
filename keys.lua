local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

config.keys = {}
for i = 1, 9 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CMD",
		action = act.ActivateTab(i - 1),
	})
	-- F1 through F8 to activate that tab
	-- table.insert(config.keys, {
	-- 	key = "F" .. tostring(i),
	-- 	action = act.ActivateTab(i - 1),
	-- })
end

for i = 1, 9 do
	-- CTRL+ALT + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.MoveTab(i - 1),
	})
end

table.insert(config.keys, {
	key = "w",
	mods = "CMD",
	action = wezterm.action.CloseCurrentTab({ confirm = true }),
})

local function is_vim(pane)
	local is_vim_env = pane:get_user_vars().IS_NVIM == "true"
	if is_vim_env == true then
		return true
	end
	-- This gsub is equivalent to POSIX basename(3)
	-- Given "/foo/bar" returns "bar"
	-- Given "c:\\foo\\bar" returns "bar"
	local process_name = string.gsub(pane:get_foreground_process_name(), "(.*[/\\])(.*)", "%2")
	return process_name == "nvim" or process_name == "vim"
end

--- cmd+keys that we want to send to neovim.
local super_vim_keys_map = {
	["\\"] = utf8.char(0xAA),
	["s"] = utf8.char(0xAB),
	["Enter"] = utf8.char(0xAC),
	["Shift"] = utf8.char(0xAD),
	o = utf8.char(0xAF),
}

local function bind_super_key_to_vim(key)
	return {
		key = key,
		mods = "CMD",
		action = wezterm.action_callback(function(win, pane)
			local char = super_vim_keys_map[key]
			if char and is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = char, mods = nil },
				}, pane)
			else
				win:perform_action({
					SendKey = {
						key = key,
						mods = "CMD",
					},
				}, pane)
			end
		end),
	}
end

table.insert(config.keys, bind_super_key_to_vim("\\"))
table.insert(config.keys, bind_super_key_to_vim("s"))
table.insert(config.keys, bind_super_key_to_vim("Enter"))
-- table.insert(config.keys, bind_super_key_to_vim("Shift-Enter"))

return config
