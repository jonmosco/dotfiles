return {
	terminal = "uwsm app -- ghostty",
	fileManager = "uwsm app -- nautilus",
	menu = "qs ipc call launcher toggle",
	mainMod = "SUPER",

	-- Single source of truth for monitor identity. desc: matching survives
	-- connector renames (DP-6 vs DP-8). monitors.lua and rules.lua read these;
	-- hyprlock.conf is hyprlang, not Lua, so it still hardcodes them and must
	-- be updated by hand if a display changes.
	monitors = {
		laptop = "eDP-1",
		dell = "desc:Dell Inc. DELL U4025QW 71TS984",
		lg = "desc:LG Electronics LG SDQHD 303NTEPCB332",
	},
}
