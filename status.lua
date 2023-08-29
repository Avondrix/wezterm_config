-- - @alias battery_state 'Charging' | 'Discharging' | 'Empty' | 'Full' | 'Unknown'
-- - @alias battery { state: battery_state, state_of_charge: number }

local M = {}

local wezterm = require("wezterm")

-- - @param battery battery state of charge, from 0.00 to 1.00
-- - @return string
-- local function render_battery(battery)
--    --- @type table<string, string>
--    local icons = wezterm.nerdfonts
--    local percent = battery.state_of_charge
--    local formatted_percent = string.format("%.0f%%", percent * 100)
--
--    local get_icon = function()
--       local prefix = "mdi_battery"
--       if battery.state == "Charging" then
--          return icons[prefix .. "_charging"]
--       end
--
--       --- @type string
--       local icon_name
--
--       if percent == 1 then
--          icon_name = prefix
--       else
--          local suffix = math.max(1, math.ceil(percent * 10)) .. "0"
--          icon_name = prefix .. "_" .. suffix
--       end
--
--       local color = percent <= 0.1 and "Red" or "Green"
--       return wezterm.format({
--          { Foreground = { AnsiColor = color } },
--          { Text = icons[icon_name] },
--       })
--    end
--
--    return string.format("%s %s", get_icon(), formatted_percent)
-- end
--
-- local function update_right_status(window)
--    -- "Wed Mar 3 08:14"
--    --- @type string
--    local date = wezterm.strftime("%a %b %-d %H:%M")
--
--    --- @type string
--    local tilde = wezterm.format({
--       { Foreground = { AnsiColor = "Fuchsia" } },
--       { Text = "~" },
--    })
--
--    --- @type string
--    local battery
--
--    for _, b in ipairs(wezterm.battery_info()) do
--       battery = render_battery(b)
--    end
--
--    local status = string.format("%s %s %s ", battery, tilde, date)
--    window:set_right_status(wezterm.format({
--       { Text = status },
--    }))
-- end

-- local terminal = require("terminal")

function M.enable()
	wezterm.on("update-right-status", function(window, pane)
		local cells = {}
		local key_mode = window:active_key_table()
		local mode = {
			["search_mode"] = "󰜏",
			["copy_mode"] = "",
		}
		if not key_mode then
			table.insert(cells, "")
		else
			table.insert(cells, mode[key_mode])
		end

		--
		local workspace = window:active_workspace()
		if workspace == "default" then
			workspace = ""
		end
		table.insert(cells, workspace)

		local cwd_uri = pane:get_current_working_dir()
		if cwd_uri then
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			local cwd = ""
			local hostname = ""
			if slash then
				hostname = cwd_uri:sub(1, slash - 1)
				-- Remove the domain name portion of the hostname
				local dot = hostname:find("[.]")
				if dot then
					hostname = hostname:sub(1, dot - 1)
				end
				-- and extract the cwd from the uri
				cwd = cwd_uri:sub(slash)
				-- table.insert(cells, cwd)
				if hostname == "" then
					table.insert(cells, "")
				elseif string.find(hostname, "arch") then
					table.insert(cells, "")
				else
					table.insert(cells, "")
				end
			end
		end
		local current_time = tonumber(wezterm.strftime("%H"))
		-- stylua: ignore
		local time = {
			[00] = "",
			[01] = "",
			[02] = "",
			[03] = "",
			[04] = "",
			[05] = "",
			[06] = "",
			[07] = "",
			[08] = "",
			[09] = "",
			[10] = "󰗲",
			[11] = "",
			[12] = "",
			[13] = "",
			[14] = "",
			[15] = "",
			[16] = "",
			[17] = "",
			[18] = "",
			[19] = "󰗲",
			[20] = "",
			[21] = "",
			[22] = "",
			[23] = "",
		}
		local date = wezterm.strftime("%H:%M %a %b %d ")
		local date_time = time[current_time] .. " " .. date
		table.insert(cells, date_time)
		-- local text_fg = terminal.colors.transparent
		-- local SEPERATOR = " █"
		local SEPERATOR = "  "
		local pallete = {
			"#f7768e",
			"#9ece6a",
			"#7dcfff",
			"#C0CBF5",
			"#e0af68",
			"#7aa2f7",
		}
		local cols = pane:get_dimensions().cols
		local padding = wezterm.pad_right("", (cols / 2) - string.len(date_time) - 2)
		local elements = {}
		local num_cells = 0

		-- Translate into elements
		local function push(text, is_last)
			local cell_no = num_cells + 1
			if is_last then
				-- table.insert(elements, text_fg)
				table.insert(elements, { Text = padding })
			end
			table.insert(elements, { Foreground = { Color = pallete[cell_no] } })
			-- table.insert(elements, { Background = { Color = terminal.colors.transparent } })
			table.insert(elements, { Text = "" .. text .. "" })
			if not is_last then
				-- table.insert(elements, { Foreground = { Color = terminal.colors.transparent } })
				-- table.insert(elements, { Background = { Color = terminal.colors.transparent } })
				table.insert(elements, { Text = SEPERATOR })
			end
			num_cells = num_cells + 1
		end

		while #cells > 0 do
			local cell = table.remove(cells, 1)
			push(cell, #cells == 0)
		end
		window:set_right_status(wezterm.format(elements))
	end)
end

return M
