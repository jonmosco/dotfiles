-- Persistent workspaces: 1-3 on Dell ultrawide, 4 on LG tall
hl.workspace_rule({ workspace = "1", monitor = "desc:Dell Inc. DELL U4025QW 71TS984", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "desc:Dell Inc. DELL U4025QW 71TS984", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "desc:Dell Inc. DELL U4025QW 71TS984", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "desc:LG Electronics LG SDQHD 303NTEPCB332", default = true, persistent = true })

-- Smart gaps: no gaps when only one tiled or fullscreen window
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({
	name = "no-gaps-wtv1",
	match = { float = false, workspace = "w[tv1]" },
	border_size = 0,
	rounding = 0,
})
hl.window_rule({
	name = "no-gaps-f1",
	match = { float = false, workspace = "f[1]" },
	border_size = 0,
	rounding = 0,
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "appgate-float",
	match = { class = "appgate" },
	float = true,
	size = { 800, 600 },
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "pip-float",
	match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
	float = true,
	pin = true,
	size = { 400, 225 },
})

hl.window_rule({
	name = "open-file",
	match = { title = "^(Open File)(.*)$" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "save-file",
	match = { title = "^(Save File)(.*)$" },
	float = true,
	center = true,
})

hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },
	move = "20 monitor_h-120",
	float = true,
})
