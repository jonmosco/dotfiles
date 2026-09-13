require("monitors")
require("look")
require("binds")
require("rules")

hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/lid-switch close"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/lid-switch open"), { locked = true })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprlock", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
