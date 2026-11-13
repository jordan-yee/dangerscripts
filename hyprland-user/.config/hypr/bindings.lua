-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

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

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

---------------------------------------
-- MY CUSTOM CHANGES BELOW THIS LINE --
---------------------------------------

-- Close window stays on SUPER + Q only (an Omarchy default since 4.5);
-- SUPER + W is reused for the workspace layout below.

-- Move 'Keybindings' to SUPER + B (SUPER + K is rebound below)
o.bind("SUPER + B", "Keybindings", "omarchy-menu-keybindings")

-- Move 'Toggle window split' to SUPER + E (SUPER + J is rebound below)
o.bind("SUPER + E", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Move 'Cycle workspace layout' to SUPER + W, and its reverse to SUPER + SHIFT + W
-- (SUPER + L and SUPER + ALT + L are rebound below)
o.rebind("SUPER + W", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle")
o.rebind("SUPER + SHIFT + W", "Cycle workspace layout back", "omarchy-hyprland-workspace-layout-toggle back")

-- Move 'Omawrite' to SUPER + CTRL + W (replaces the second Background switcher
-- key; SUPER + CTRL + SPACE still opens it)
o.rebind("SUPER + CTRL + W", "Omawrite", { launch = "omawrite" })

-- Vim-style window focus (mirrors SUPER + arrow keys)
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Vim-style window swap (mirrors SUPER + SHIFT + arrow keys)
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Vim-style window-to-monitor moves (mirrors the default SUPER + SHIFT + CTRL + arrow keys)
o.bind("SUPER + SHIFT + CTRL + H", "Move window to left monitor", o.workspaces.move_window_to_monitor("l"))
o.bind("SUPER + SHIFT + CTRL + J", "Move window to down monitor", o.workspaces.move_window_to_monitor("d"))
o.bind("SUPER + SHIFT + CTRL + K", "Move window to up monitor", o.workspaces.move_window_to_monitor("u"))
o.bind("SUPER + SHIFT + CTRL + L", "Move window to right monitor", o.workspaces.move_window_to_monitor("r"))

-- Vim-style workspace-to-monitor moves (mirrors SUPER + SHIFT + ALT + arrow keys).
-- o.workspaces keeps the moved workspace in the target monitor's own 1-10 block.
o.bind("SUPER + SHIFT + ALT + H", "Move workspace to left monitor", o.workspaces.move_to_monitor("l"))
o.bind("SUPER + SHIFT + ALT + J", "Move workspace to down monitor", o.workspaces.move_to_monitor("d"))
o.bind("SUPER + SHIFT + ALT + K", "Move workspace to up monitor", o.workspaces.move_to_monitor("u"))
o.bind("SUPER + SHIFT + ALT + L", "Move workspace to right monitor", o.workspaces.move_to_monitor("r"))

-- Rebind 'Tmux keybindings' to SUPER + ALT + B (SUPER + ALT + K is rebound below)
o.bind("SUPER + ALT + B", "Tmux keybindings", "omarchy-menu-tmux-keybindings")

-- Move Browser / Browser (private) to SUPER + I / SUPER + SHIFT + I,
-- and input-language switching to SUPER + ALT + I / SUPER + SHIFT + ALT + I
hl.unbind("SUPER + SHIFT + ALT + B")
o.rebind("SUPER + I", "Browser", { omarchy = "browser" })
o.rebind("SUPER + SHIFT + I", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + ALT + I", "Switch input language", "omarchy-input-method cycle")
o.bind("SUPER + SHIFT + ALT + I", "Switch input language back", "omarchy-input-method cycle back")

-- Move 'Herdr keybindings' to SUPER + SHIFT + B (frees the default Browser there;
-- SUPER + CTRL + K is rebound below)
o.rebind("SUPER + SHIFT + B", "Herdr keybindings", "omarchy-menu-herdr-keybindings")

-- Move 'Herdr' to SUPER + SHIFT + RETURN (frees the default Browser there)
hl.unbind("SUPER + CTRL + RETURN")
o.rebind("SUPER + SHIFT + RETURN", "Herdr", { omarchy = "terminal-herdr" })

-- Vim-style into-group moves (mirrors SUPER + ALT + arrow keys)
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))
o.rebind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.rebind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))

-- Vim-style group focus on SUPER + CTRL + J/K (mirrors SUPER + CTRL + arrow keys)
o.bind("SUPER + CTRL + J", "Move grouped window focus left", hl.dsp.group.prev())
o.rebind("SUPER + CTRL + K", "Move grouped window focus right", hl.dsp.group.next())

-- Apostrophe mirrors of RETURN bindings
o.bind("SUPER + APOSTROPHE", "Terminal", { omarchy = "terminal" })
o.bind("SUPER + SHIFT + APOSTROPHE", "Herdr", { omarchy = "terminal-herdr" })
o.bind("SUPER + ALT + APOSTROPHE", "Tmux", { omarchy = "terminal-tmux" })

-- Passwords: 1Password -> Bitwarden
o.rebind("SUPER + SHIFT + SLASH", "Passwords", { launch = "bitwarden-desktop", focus = "^(Bitwarden)$" })

-- HEY -> Google equivalents
o.rebind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })
o.rebind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com" })
o.rebind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://mail.google.com/mail/u/0/?fs=1&tf=cm" })

-- Unused webapp bindings
hl.unbind("SUPER + SHIFT + ALT + G") -- WhatsApp
hl.unbind("SUPER + SHIFT + CTRL + G") -- Google Messages
hl.unbind("SUPER + SHIFT + P") -- Google Photos
hl.unbind("SUPER + SHIFT + S") -- Google Maps
hl.unbind("SUPER + SHIFT + X") -- X
hl.unbind("SUPER + SHIFT + ALT + X") -- X Post

-- Utilities - Kyria-friendly alternative bindings
-- (replaces the default 'Toggle full screen desktop' on SUPER + CTRL + ALT + F)
o.rebind("SUPER + CTRL + ALT + F", "Calendar", { panel = "omarchy.clock" })
o.bind("SUPER + CTRL + ALT + G", "Toggle weather", "omarchy-notification-weather")
