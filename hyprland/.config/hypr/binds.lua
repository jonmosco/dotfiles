local keybinds = require("keybinds")

keybinds.register_all()
keybinds.export_json(os.getenv("HOME") .. "/.config/quickshell/keybindings.json")
