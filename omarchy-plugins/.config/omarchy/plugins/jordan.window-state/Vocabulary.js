.pragma library

// Icons are Material Design glyphs from the bar's Nerd Font, picked so each
// state has its own silhouette at bar size.
var glyphs = {
  tiled: "󰃇",                // border_all
  floating: "󱂬",             // dock_window
  pinned: "󰐃",               // pin
  wide: "󰡎",                 // arrow_expand_horizontal
  tiledFullscreen: "󱣵",      // fit_to_screen_outline
  fullscreen: "󰊓",           // fullscreen
  grouped: "󰓩",              // tab
  special: "󰫣",              // star_four_points_outline
  windows: "󰧾"               // layers_outline
}

// Omarchy's own keybinding descriptions, used to find the key that toggles
// each state so the legend shows the user's real bindings.
var bindDescriptions = {
  floating: "Toggle window floating/tiling",
  pinned: "Pop window out (float & pin)",
  wide: "Full width",
  tiledFullscreen: "Tiled full screen",
  fullscreen: "Full screen",
  grouped: "Toggle window grouping",
  special: "Toggle scratchpad"
}

var modifiers = [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]

function keyLabel(bind) {
  var parts = []
  for (var i = 0; i < modifiers.length; i++) {
    if (bind.modmask & modifiers[i][0]) parts.push(modifiers[i][1])
  }
  var key = String(bind.key || "")
  if (key === "") return ""
  parts.push(key.length === 1 ? key.toUpperCase() : key.charAt(0).toUpperCase() + key.slice(1).toLowerCase())
  return parts.join(" ")
}

// Maps each state to its key label from the JSON reply to Hyprland's "binds"
// request. States with no matching binding are simply left without a hint.
function keysFromBinds(raw) {
  var keys = {}
  var binds
  try {
    binds = JSON.parse(raw)
  } catch (error) {
    return keys
  }
  if (!Array.isArray(binds)) return keys

  for (var state in bindDescriptions) {
    for (var i = 0; i < binds.length; i++) {
      if (binds[i].description !== bindDescriptions[state] || binds[i].mouse) continue
      var label = keyLabel(binds[i])
      if (label !== "") {
        keys[state] = label
        break
      }
    }
  }
  return keys
}
