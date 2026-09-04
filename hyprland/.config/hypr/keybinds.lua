local vars = require("vars")
local m = vars.mainMod

local M = {}

local function bind(key, desc, combo, action, opts)
	return { key = key, desc = desc, combo = combo, action = action, opts = opts }
end

local categories = {
	{
		category = "Applications",
		bindings = {
			bind(m .. " + Q", "Open terminal", m .. " + Q", hl.dsp.exec_cmd(vars.terminal)),
			bind(m .. " + E", "Open file manager", m .. " + E", hl.dsp.exec_cmd(vars.fileManager)),
			bind(m .. " + R", "App launcher", m .. " + R", hl.dsp.exec_cmd(vars.menu)),
			bind(m .. " + L", "Lock session", m .. " + L", hl.dsp.exec_cmd("loginctl lock-session")),
			bind(
				m .. " + M",
				"Log out",
				m .. " + M",
				hl.dsp.exec_cmd(
					"zenity --question --title='Log Out' --text='Log out of Hyprland?' && hyprctl dispatch exit"
				)
			),
		},
	},
	{
		category = "Window",
		bindings = {
			bind(m .. " + SHIFT + Q", "Close window", m .. " + SHIFT + Q", hl.dsp.window.close()),
			bind(m .. " + V", "Toggle floating", m .. " + V", hl.dsp.window.float({ action = "toggle" })),
			bind(m .. " + P", "Toggle pseudo (dwindle)", m .. " + P", hl.dsp.window.pseudo()),
			bind(m .. " + J", "Toggle split", m .. " + J", hl.dsp.layout("togglesplit")),
			bind(m .. " + LMB", "Drag window", m .. " + mouse:272", hl.dsp.window.drag(), { mouse = true }),
			bind(m .. " + RMB", "Resize window", m .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }),
		},
	},
	{
		category = "Focus & Move",
		bindings = {
			bind(m .. " + ←", "Focus left", m .. " + left", hl.dsp.focus({ direction = "left" })),
			bind(m .. " + →", "Focus right", m .. " + right", hl.dsp.focus({ direction = "right" })),
			bind(m .. " + ↑", "Focus up", m .. " + up", hl.dsp.focus({ direction = "up" })),
			bind(m .. " + ↓", "Focus down", m .. " + down", hl.dsp.focus({ direction = "down" })),
			bind(m .. " + SHIFT + ←", "Move window left", m .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" })),
			bind(m .. " + SHIFT + →", "Move window right", m .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" })),
			bind(m .. " + SHIFT + ↑", "Move window up", m .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" })),
			bind(m .. " + SHIFT + ↓", "Move window down", m .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" })),
		},
	},
	{
		category = "Workspaces",
		bindings = (function()
			local bindings = {}
			for i = 1, 4 do
				table.insert(
					bindings,
					bind(m .. " + " .. i, "Switch to workspace " .. i, m .. " + " .. i, hl.dsp.focus({ workspace = i }))
				)
				table.insert(
					bindings,
					bind(
						m .. " + SHIFT + " .. i,
						"Move window to workspace " .. i,
						m .. " + SHIFT + " .. i,
						hl.dsp.window.move({ workspace = i })
					)
				)
			end
			table.insert(bindings, bind(m .. " + S", "Toggle special workspace", m .. " + S", hl.dsp.workspace.toggle_special("magic")))
			table.insert(
				bindings,
				bind(
					m .. " + SHIFT + S",
					"Move to special workspace",
					m .. " + SHIFT + S",
					hl.dsp.window.move({ workspace = "special:magic" })
				)
			)
			table.insert(bindings, bind(m .. " + Scroll ↓", "Next workspace", m .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" })))
			table.insert(bindings, bind(m .. " + Scroll ↑", "Previous workspace", m .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" })))
			return bindings
		end)(),
	},
	{
		category = "Screenshots",
		bindings = {
			bind(
				"Print",
				"Screenshot (full screen)",
				"PRINT",
				hl.dsp.exec_cmd("f=~/Pictures/screenshots/$(date +'%Y%m%d-%H%M%S').png && grim $f && wl-copy < $f")
			),
			bind(
				m .. " + SHIFT + X",
				"Screenshot (region)",
				m .. " + SHIFT + X",
				hl.dsp.exec_cmd("f=~/Pictures/screenshots/$(date +'%Y%m%d-%H%M%S').png && grim -g \"$(slurp)\" $f && wl-copy < $f")
			),
		},
	},
	{
		category = "Bar & System",
		bindings = {
			bind(m .. " + SHIFT + V", "Clipboard history", m .. " + SHIFT + V", hl.dsp.exec_cmd("qs ipc call bar clipboard_toggle")),
			bind(m .. " + SHIFT + /", "Keybindings cheat sheet", m .. " + SHIFT + slash", hl.dsp.exec_cmd("qs ipc call bar keys_toggle")),
			bind(m .. " + SHIFT + R", "Reload Hyprland config", m .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload")),
		},
	},
	{
		category = "Media & Hardware",
		bindings = {
			bind(
				"Volume Up",
				"Raise volume",
				"XF86AudioRaiseVolume",
				hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
				{ locked = true, repeating = true }
			),
			bind(
				"Volume Down",
				"Lower volume",
				"XF86AudioLowerVolume",
				hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
				{ locked = true, repeating = true }
			),
			bind(
				"Volume Mute",
				"Toggle mute",
				"XF86AudioMute",
				hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
				{ locked = true }
			),
			bind(
				"Mic Mute",
				"Toggle microphone mute",
				"XF86AudioMicMute",
				hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
				{ locked = true }
			),
			bind(
				"Brightness Up",
				"Raise brightness",
				"XF86MonBrightnessUp",
				hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
				{ locked = true, repeating = true }
			),
			bind(
				"Brightness Down",
				"Lower brightness",
				"XF86MonBrightnessDown",
				hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
				{ locked = true, repeating = true }
			),
			bind("Media Next", "Next track", "XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true }),
			bind("Media Previous", "Previous track", "XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true }),
			bind("Media Play/Pause", "Play or pause", "XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }),
			bind("Media Play/Pause", "Play or pause", "XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }),
		},
	},
}

M.categories = categories

local function json_escape(value)
	return value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
end

function M.register_all()
	for _, category in ipairs(categories) do
		for _, entry in ipairs(category.bindings) do
			hl.bind(entry.combo, entry.action, entry.opts)
		end
	end
end

function M.export_json(path)
	local lines = { "[" }
	for category_index, category in ipairs(categories) do
		table.insert(lines, '  {')
		table.insert(lines, '    "category": "' .. json_escape(category.category) .. '",')
		table.insert(lines, '    "bindings": [')
		for binding_index, entry in ipairs(category.bindings) do
			local suffix = binding_index < #category.bindings and "," or ""
			table.insert(
				lines,
				string.format(
					'      {"key": "%s", "desc": "%s"}%s',
					json_escape(entry.key),
					json_escape(entry.desc),
					suffix
				)
			)
		end
		local suffix = category_index < #categories and "," or ""
		table.insert(lines, "    ]")
		table.insert(lines, "  }" .. suffix)
	end
	table.insert(lines, "]")

	local file = io.open(path, "w")
	if not file then
		return false
	end
	file:write(table.concat(lines, "\n") .. "\n")
	file:close()
	return true
end

return M
