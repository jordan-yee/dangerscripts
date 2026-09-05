-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Framework 13 Laptop Screen
hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "0x0", scale = 2 })

-- External Monitor (ASUS VG279QL1A)
--
-- Deliberately kept in SDR. The panel's firmware refuses DDC brightness writes
-- (VCP 0x10) unless its GameVisual preset is "Racing", and HDR locks the preset
-- menu entirely -- so HDR and adjustable brightness are mutually exclusive here.
-- SDR + Racing is the only state where the Omarchy display panel can set
-- brightness. Setting bitdepth/cm explicitly matters: Hyprland does not revert
-- monitor state when a rule is removed, so commenting these lines out leaves
-- whatever was applied last still active.
--
-- Matched on EDID description, not on DP-2: this 1080p/SDR rule would be wrong
-- for any other display landing on that port, and the generic `output = ""`
-- rule above already handles unknown monitors. The helper scripts likewise
-- identify this panel by EDID model before touching DDC.
--
-- Supporting pieces, all outside this file:
--   ~/.local/bin/vg279ql1a-racing        forces GameVisual to Racing over DDC
--   ~/.local/bin/vg279ql1a-racing-watch  re-applies it on monitor hotplug
--   ~/.local/bin/vg279ql1a-hdr-toggle    switches HDR/SDR live for HDR content
--   ~/.config/omarchy/hooks/post-boot.d/vg279ql1a-racing  applies Racing at login
--   ~/.config/hypr/autostart.lua   launches the hotplug watcher
--
-- For HDR: `vg279ql1a-hdr-toggle hdr` (brightness locks while on), then `sdr`
-- to come back, plus `vg279ql1a-racing` if the preset did not survive the trip.
hl.monitor({
  output = "desc:ASUSTek COMPUTER INC VG279QL1A",
  mode = "1920x1080@144",
  -- Sits to the right of the laptop screen (logical 1440x960 at 0x0), raised
  -- so its bottom edge is ~1.5" above the laptop's. At 81.6 px/inch vertical
  -- (1080px over 336mm), 1.5" is ~122px: bottom lands at y=838, top at y=-242.
  position = "1440x-242",
  scale = 1,
  bitdepth = 8,
  cm = "srgb",
})

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
