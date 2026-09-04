-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Use desc: matching so connector name changes (DP-6 vs DP-8) don't break things

-- Laptop (scaled 1.5x: effective 1920x1200)
hl.monitor({
	output = "eDP-1",
	mode = "2880x1800@120",
	position = "0x0",
	scale = 1.5,
})

-- Dell ultrawide (5120x2160, right of laptop)
hl.monitor({
	output = "desc:Dell Inc. DELL U4025QW 71TS984",
	mode = "5120x2160@60",
	position = "1920x0",
	scale = 1,
})

-- LG tall (2560x2880, right of Dell)
hl.monitor({
	output = "desc:LG Electronics LG SDQHD 303NTEPCB332",
	mode = "2560x2880@60",
	position = "7040x0",
	scale = 1,
})

-- Fallback for any other monitor
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
