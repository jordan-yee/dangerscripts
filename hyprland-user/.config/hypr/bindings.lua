-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

---------------------------------------
-- MY CUSTOM CHANGES BELOW THIS LINE --
---------------------------------------

-- Rebind 'Close window'
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Move 'Keybindings' to SUPER + B
hl.unbind("SUPER + K")
o.bind("SUPER + B", "Keybindings", "omarchy-menu-keybindings")

-- Move 'Toggle window split' to SUPER + E
hl.unbind("SUPER + J")
o.bind("SUPER + E", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Move 'Toggle workspace layout' to SUPER + W
hl.unbind("SUPER + L")
o.bind("SUPER + W", "Toggle workspace layout", "omarchy-hyprland-workspace-layout-toggle")

-- Vim-style window focus (mirrors SUPER + arrow keys)
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Vim-style window swap (mirrors SUPER + SHIFT + arrow keys)
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Move focused window between monitors
o.bind("SUPER + SHIFT + CTRL + LEFT", "Move window to left monitor", hl.dsp.window.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + CTRL + DOWN", "Move window to down monitor", hl.dsp.window.move({ monitor = "d" }))
o.bind("SUPER + SHIFT + CTRL + UP", "Move window to up monitor", hl.dsp.window.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + CTRL + RIGHT", "Move window to right monitor", hl.dsp.window.move({ monitor = "r" }))
o.bind("SUPER + SHIFT + CTRL + H", "Move window to left monitor", hl.dsp.window.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + CTRL + J", "Move window to down monitor", hl.dsp.window.move({ monitor = "d" }))
o.bind("SUPER + SHIFT + CTRL + K", "Move window to up monitor", hl.dsp.window.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + CTRL + L", "Move window to right monitor", hl.dsp.window.move({ monitor = "r" }))

-- Vim-style workspace-to-monitor moves (mirrors SUPER + SHIFT + ALT + arrow keys)
o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", hl.dsp.workspace.move({ monitor = "l" }))
o.bind("SUPER + SHIFT + ALT + J", "Move workspace to down monitor", hl.dsp.workspace.move({ monitor = "d" }))
o.bind("SUPER + SHIFT + ALT + K", "Move workspace to up monitor", hl.dsp.workspace.move({ monitor = "u" }))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", hl.dsp.workspace.move({ monitor = "r" }))

-- Rebind 'Tmux keybindings' to SUPER + ALT + B
hl.unbind("SUPER + ALT + K")
o.bind("SUPER + ALT + B", "Tmux keybindings", "omarchy-menu-tmux-keybindings")

-- Move Browser / Browser (private) to SUPER + I / SUPER + SHIFT + I
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + I", "Browser", { omarchy = "browser" })
hl.unbind("SUPER + SHIFT + ALT + B")
o.bind("SUPER + SHIFT + I", "Browser (private)", { omarchy = "browser --private" })

-- Move 'Herdr keybindings' to SUPER + SHIFT + B
hl.unbind("SUPER + CTRL + K")
o.bind("SUPER + SHIFT + B", "Herdr keybindings", "omarchy-menu-herdr-keybindings")

-- Move 'Herdr' to SUPER + SHIFT + RETURN (frees the default Browser there)
hl.unbind("SUPER + CTRL + RETURN")
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Herdr", { omarchy = "terminal-herdr" })

-- Vim-style into-group moves (mirrors SUPER + ALT + arrow keys)
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.bind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- Vim-style group focus on free SUPER + CTRL + J/K (mirrors SUPER + CTRL + arrow keys)
o.bind("SUPER + CTRL + J", "Move grouped window focus left", hl.dsp.group.prev())
o.bind("SUPER + CTRL + K", "Move grouped window focus right", hl.dsp.group.next())

-- Apostrophe mirrors of RETURN bindings
o.bind("SUPER + APOSTROPHE", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + SHIFT + APOSTROPHE", "Herdr", { omarchy = "terminal-herdr" })
o.bind("SUPER + ALT + APOSTROPHE", "Tmux", { omarchy = "terminal-tmux" })

-- Passwords: 1Password -> Bitwarden
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^(Bitwarden)$" })

-- HEY -> Google equivalents
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com" })
hl.unbind("SUPER + SHIFT + ALT + E")
o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://mail.google.com/mail/u/0/?fs=1&tf=cm" })

-- Unused webapp bindings
hl.unbind("SUPER + SHIFT + ALT + G") -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages
hl.unbind("SUPER + SHIFT + P") -- Google Photos
hl.unbind("SUPER + SHIFT + S") -- Google Maps
hl.unbind("SUPER + SHIFT + X") -- X
hl.unbind("SUPER + SHIFT + ALT + X") -- X Post

-- Utilities - Kyria-friendly alternative bindings
o.bind("SUPER + CTRL + ALT + F", "Calendar", "omarchy-shell shell toggle omarchy.clock")
o.bind("SUPER + CTRL + ALT + G", "Toggle weather", "omarchy-notification-weather")
