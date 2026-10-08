# Window State

An Omarchy bar widget that shows the Hyprland state of the focused window and
the number of windows on the workspace in view.

## Constraints

- All plugin code lives in this directory; the only change outside it is the widget's entry in the bar layout in `~/.config/omarchy/shell.json`.
- Never modifies Hyprland or Omarchy configuration, keybindings, or anything under `/usr/share/omarchy/`.
- Starts no processes: no background services, helper scripts, or shell commands.
- Reads state only from Hyprland's IPC, from inside the shell process.
- Never polls on a recurring timer; state is refreshed only in response to a Hyprland event or a pause in input, apart from a bounded retry while the shell starts.
- Title changes of the focused window, which can arrive several times a second, trigger no refresh.
- When the bar has an instance per monitor, only one instance requests refreshes from Hyprland.
- Is read-only: it never changes window or workspace state and has no click actions, because moving the pointer to the bar can change which window is focused.
- Shows states in the bar as icons, never text labels; the only text is the window count.
- Uses only glyphs from the bar's own font.
- Takes colours, font and sizes from the shell's theme tokens, with no hardcoded colours.
- Works on a bar in any position: top, bottom, left or right.

## Intended Behaviors

- A hairline divider and spacing set the widget apart from the workspace switcher.
- The widget reads left to right: the focused window's state icons, then a workspace icon and the window count.
- The first state icon is the window's layout mode: tiled, floating, or pinned.
- Pinned (Omarchy's "pop out", float & pin) is a single icon, because a pinned window is always floating.
- A second icon follows the mode when the window is full width (Hyprland's maximized mode), tiled full screen (the app is fullscreen while Hyprland keeps it in its tile), or full screen; Hyprland's own fullscreen mode takes precedence over tiled full screen.
- A grouped window adds a group icon.
- A plain tiled window is drawn muted; every other window state is drawn in the bar's attention colour.
- The workspace in view is the special workspace shown on the focused monitor, or otherwise that monitor's active workspace.
- The count is the number of mapped windows on the workspace in view, including floating windows and every member of a group.
- While a special workspace is in view, the workspace icon becomes the special-workspace icon in the attention colour.
- A window's state is shown only while that window is Hyprland's active window and its workspace is in view; a focused pinned window always counts as in view.
- A window hidden along with its special workspace is not shown, even though Hyprland still reports it as active.
- With no window to show, the state icons are absent and only the workspace icon and count remain; an empty workspace shows a muted `0`.
- Every monitor's bar shows the same thing: the focused window's state and the focused monitor's workspace in view.
- The widget is hidden until the workspace in view is known.
- After the shell starts, the already-focused window's state is shown without waiting for a focus change.
- Changes Hyprland announces with an event (focus, float, pin, fullscreen, group, open, close, move, workspace switch, special workspace toggle) appear within about 50 ms.
- Changes Hyprland announces no event for, such as tiled full screen, appear about 50 ms after keyboard and pointer input pauses.
- Icons ease in and out and colours fade, so a state change never jumps.
- Hovering the widget for 300 ms opens a legend card beside the bar; moving the pointer off the widget closes it.
- The legend lists every icon the widget can show with its meaning, grouped under the focused window and the workspace.
- Legend rows that describe the current state are lit and the rest are muted.
- The legend's workspace row states the window count and how many of those windows are floating.
- Each legend row shows the key that toggles its state, read from Hyprland's current bindings by matching Omarchy's binding descriptions; a state with no matching binding shows no key.
- Key hints are read again after Hyprland's configuration is reloaded.
- While the legend is open, an underline marks the widget from its first icon to the end of the count.
- The legend never opens while another bar panel is open, and never closes one.

## Known Limitations

- Pseudotiling is not shown, because Hyprland (0.56.2) does not expose it over IPC.
- Real full screen hides the bar on its own monitor, so its icon can only be seen on another monitor's bar.
- A change Hyprland announces no event for is not picked up until input next pauses, so one made with no input at all (by a script, say) waits for the next key press or pointer move.
- If a toggle script takes longer than the 50 ms pause, its change is picked up at the following input pause, normally when the keys are released.
- A focused pinned window always counts as in view, so one popped out inside a special workspace may keep showing its pin after that workspace is hidden (untested).
- Key hints rely on the wording of Omarchy's binding descriptions; a binding whose description has been changed shows no key.
- Reading the key hints logs one harmless `PeerClosedError` warning in the shell log each time.
- Edits to the plugin take effect only after `omarchy restart shell`; saving a file did not reload it on this machine.
