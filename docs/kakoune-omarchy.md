# Using Kakoune as the default editor on Omarchy 4

This guide makes [Kakoune](https://kakoune.org/) the default text editor on an
Omarchy 4 system (Arch + Hyprland). After completing it, Kakoune is used for:

- `$EDITOR` / CLI launches — `git commit`, `sudoedit`, and any program that
  shells out to `$EDITOR`
- opening Omarchy config/settings files from the Omarchy menu, including the
  auto-apply-on-save behaviour (that is editor-agnostic; it watches the file)
- opening any text file via `xdg-open` or a file manager

Requires: `kak` installed (e.g. `sudo pacman -S kakoune`). The package ships no
`.desktop` entry, which is why one is created below.

## How Omarchy launches editors

- Omarchy sets `EDITOR=omarchy-launch-editor --inline` (session env via UWSM,
  shell env via `default/bash/envs`).
- `omarchy-launch-editor` reads the configured default from
  `~/.local/state/omarchy/defaults/editor`. Its **hardcoded TUI list**
  (`nvim|vim|nano|micro|hx|helix|fresh`) decides what is treated as a terminal
  editor; anything else is launched as a GUI app via `uwsm-app`, which breaks
  for terminal editors like Kakoune.
- The Omarchy menu opens config files via
  `omarchy-launch-config-editor <path>` → `omarchy-launch-editor <path>`
  (note: no `--inline`), which opens TUI editors in a fresh Omarchy-styled
  terminal via `omarchy-launch-tui`.
- Because `kak` is not in that list, two things are needed: (a) tell Omarchy
  that the default editor is `kak`, and (b) make the dispatcher launch `kak` as
  a TUI editor. Omarchy's session env puts `/usr/share/omarchy/bin` (symlinks
  to the packaged scripts) at the **front** of PATH for everything spawned by
  the bar/menu, keybindings and terminals, so the packaged dispatcher is
  patched in place (one line: add `kak` to its TUI list). Because `omarchy
  update` rewrites that file, a `post-update` omarchy hook re-applies the patch
  automatically afterwards — the registration survives updates with no manual
  step.

## Setup steps

### 1. Set the Omarchy default editor to Kakoune

```bash
mkdir -p ~/.local/state/omarchy/defaults
printf 'kak\n' > ~/.local/state/omarchy/defaults/editor
```

Verify: `omarchy default editor` should now print `kak`.

> Note: `omarchy default editor kak` (the setter) will reject the value — the
> CLI validates against its own hardcoded list. Writing the state file directly
> is the supported route here. Other editors can still be chosen with
> `omarchy default editor <name>`, and this file can be re-written to flip back
> to `kak` at any time.

### 2. Register Kakoune as a TUI editor (patched dispatcher + post-update hook)

Patch the packaged dispatcher in place, and let an *omarchy* post-update hook
re-apply the patch after every `omarchy update` so it survives updates:

**(a) Patch the packaged dispatcher** — add `kak` to its TUI list:

```bash
sudo sed -i 's/nvim | vim | nano | micro | hx | helix | fresh)/nvim | vim | nano | micro | hx | helix | fresh | kak)/' \
  /usr/bin/omarchy-launch-editor
```

**(b) Install the hook script.** Save it as `~/patch-kak-tui-editor.hook`,
then install with the omarchy mechanism (copies it into
`~/.config/omarchy/hooks/post-update.d/` and makes it executable):

```bash
install -m 0755 /dev/stdin ~/patch-kak-tui-editor.hook <<'EOF'
#!/bin/bash

# Re-apply the Kakoune (kak) TUI registration to the packaged dispatcher.
#
# Runs as an omarchy post-update hook: omarchy fires hooks in
# ~/.config/omarchy/hooks/post-update.d/ right after pacman upgraded packages
# and migrations ran, i.e. after the omarchy package rewrote
# /usr/bin/omarchy-launch-editor and dropped the custom entry.
#
# Idempotent: does nothing when the dispatcher's TUI list already contains a
# standalone 'kak' entry (note: 'kakoune' alone would not count). If a future
# omarchy restructures the dispatcher so the anchor no longer matches, this
# exits 1 and the update fails loudly rather than silently breaking the config
# menu.
#
# The dispatcher is root-owned, so elevate with sudo unless already root.
# Within `omarchy update` the sudo timestamp from the pacman step is still warm,
# so no extra prompt is normally needed.
#
# Tests: set OMARCHY_KAK_HOOK_NO_SUDO=1 to run in place against a writable
# copy, and pass the target as $1 instead of the default.

target="${1:-/usr/bin/omarchy-launch-editor}"

if [[ $EUID -ne 0 && -z ${OMARCHY_KAK_HOOK_NO_SUDO:-} ]]; then
  exec sudo "$0" "$@"
fi

[[ -f $target ]] || exit 0

python3 - "$target" <<'PYEOF'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8", errors="surrogateescape") as f:
    data = f.read()

# The TUI editor list line, e.g. "    nvim | vim | nano | micro | hx | helix | fresh)"
m = re.search(r"^(\s*nvim\s*\|\s*vim\b[^\n]*)\)", data, re.M)
if not m:
    sys.exit(1)

# A standalone 'kak' entry is already present.
if re.search(r"\bkak\b", m.group(1)):
    sys.exit(0)

data = data[: m.end(1)] + " | kak" + data[m.end(1):]

with open(path, "w", encoding="utf-8", errors="surrogateescape") as f:
    f.write(data)
PYEOF
status=$?
[[ $status -eq 0 ]] || exit "$status"

grep -Eq '\bkak[[:space:]]*\)' "$target" || exit 1
EOF

omarchy hook install post-update ~/patch-kak-tui-editor.hook
```

What this does:

- `--inline` given → `exec kak <args>` (used by `$EDITOR`, `git commit`,
  `sudoedit`, etc. — runs in the current terminal).
- otherwise → `exec omarchy-launch-tui kak <args>` (opens Kakoune in a new
  Omarchy-styled terminal; used by the menu's config editing).
- every other editor delegated unchanged by the packaged dispatcher.
- every `omarchy update` reinstates the `kak` entry automatically (`omarchy`
  fires the `post-update` hook right after the packages and migrations).
  Idempotent — a no-op when the entry is already present.

No session/login restart is needed: the dispatcher is a script read at each
invocation.

To revert: uninstall the hook and restore the original dispatcher.

```bash
rm ~/.config/omarchy/hooks/post-update.d/patch-kak-tui-editor.hook
sudo pacman -S --overwrite /usr/bin/omarchy-launch-editor omarchy
```

### 3. Desktop entry + MIME registration (text files of any kind)

Create `~/.local/share/applications/kakoune.desktop`:

```ini
[Desktop Entry]
Name=Kakoune
GenericName=Text Editor
Comment=Edit text files
TryExec=kak
Exec=kak %F
Terminal=true
Type=Application
Keywords=Text;editor;
Icon=kakoune
Categories=Utility;TextEditor;Development;
StartupNotify=false
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;application/xml;text/xml;text/markdown;text/csv;application/json;text/json;text/x-log
```

Register each MIME type as a default user handler in `~/.config/mimeapps.list`
(add these under the existing `[Default Applications]` section; this overrides
the system-wide `nvim.desktop` default):

```
text/english=kakoune.desktop
text/plain=kakoune.desktop
text/x-makefile=kakoune.desktop
text/x-c++hdr=kakoune.desktop
text/x-c++src=kakoune.desktop
text/x-chdr=kakoune.desktop
text/x-csrc=kakoune.desktop
text/x-java=kakoune.desktop
text/x-moc=kakoune.desktop
text/x-pascal=kakoune.desktop
text/x-tcl=kakoune.desktop
text/x-tex=kakoune.desktop
application/x-shellscript=kakoune.desktop
text/x-c=kakoune.desktop
text/x-c++=kakoune.desktop
application/xml=kakoune.desktop
text/xml=kakoune.desktop
text/markdown=kakoune.desktop
text/csv=kakoune.desktop
application/json=kakoune.desktop
text/json=kakoune.desktop
text/x-log=kakoune.desktop
```

Alternative: set them one at a time with
`xdg-mime default kakoune.desktop text/plain` (repeat per type).

Refresh the desktop database:

```bash
update-desktop-database -q ~/.local/share/applications
```

Verify: `xdg-mime query default text/plain` → `kakoune.desktop`.

### 4. Optional: icon

Only a ~128px PNG is needed (a larger ~262px file adds nothing). Install it
where icon themes expect user icons:

```bash
mkdir -p ~/.local/share/icons/hicolor/128x128/apps
cp /path/to/kakoune_icon.png ~/.local/share/icons/hicolor/128x128/apps/kakoune.png
```

Ensure the theme is indexed (some setups need a minimal `index.theme`):

```bash
# if ~/.local/share/icons/hicolor/index.theme does not exist:
printf '[Icon Theme]\nName=Hicolor\nDirectories=128x128/apps\n\n[128x128/apps]\nSize=128\nContext=Applications\nType=Direct\n' \
  > ~/.local/share/icons/hicolor/index.theme
gtk-update-icon-cache -f ~/.local/share/icons/hicolor
```

`kakoune.desktop` references it via `Icon=kakoune`. To swap the icon later,
replace the PNG and rerun `gtk-update-icon-cache -f ~/.local/share/icons/hicolor`.

## Surviving omarchy updates

`omarchy update` rewrites `/usr/bin/omarchy-launch-editor` when the omarchy
package is upgraded, which would drop the `kak` entry and silently break the
config menu. The hook from step 2 prevents that:

- `omarchy update` runs system packages and migrations, then fires the
  `post-update` hooks in `~/.config/omarchy/hooks/post-update.d/`.
- the hook is idempotent: if the packaged file already has a standalone `kak`
  entry it does nothing; otherwise it inserts the entry and exits 0.
- it elevates with `sudo`; within the update the sudo timestamp from the pacman
  step is still warm, so no extra prompt is normally needed.
- if a future omarchy restructures the dispatcher so the anchor no longer
  matches, the hook exits 1 and the update fails loudly — better than a
  silently broken menu.

Test the hook without an update (it leaves the file patched again):

```bash
sudo sed -i 's/fresh | kak)/fresh)/' /usr/bin/omarchy-launch-editor
bash ~/.config/omarchy/hooks/post-update.d/patch-kak-tui-editor.hook
grep -q 'kak)' /usr/bin/omarchy-launch-editor && echo patched
```

Manual re-patch (after `sudo pacman -Sy omarchy` bare, which bypasses the
hooks):

```bash
sudo sed -i 's/fresh)/fresh | kak)/' /usr/bin/omarchy-launch-editor
```

## Third-party tools that guess the editor

Steps 1-3 cover every tool that simply *executes* `$EDITOR` (`git commit`,
`sudoedit`, `xdg-open`, the Omarchy menu). A separate class of tool instead
*matches the editor by name* against a hardcoded table, and those need to be
told about Kakoune individually. The symptom is always the same: the tool opens
Vim (or nano) no matter what the steps above are set to, because the name it
sees is the `omarchy-launch-editor` wrapper, which matches nothing, and the
table has a fallback.

Omarchy's own dispatcher is the first instance of this — that is exactly what
step 2 patches. Others found so far:

### Lazygit

Pressing `e` on a file in [lazygit](https://github.com/jesseduffield/lazygit)
opens Vim. Lazygit resolves its editor by taking the basename of
`git config core.editor`, then `$GIT_EDITOR`, `$VISUAL`, `$EDITOR`, looking it
up in a table of built-in presets, and falling back to the **vim** preset when
nothing matches. Under Omarchy that basename is `omarchy-launch-editor`, so the
fallback always wins.

Lazygit ships a `kakoune` preset; name it explicitly in
`~/.config/lazygit/config.yml`:

```yaml
os:
  editPreset: "kakoune"
```

That restores both `e` (edit file) and the line-aware edits, which the preset
maps to `kak +<line> <file>`. In this repo the setting lives in the
`lazygit-user` stow package.

### Checking others

When a tool opens the wrong editor, check in this order:

1. does it run `$EDITOR` directly? Then it is already working — something else
   is wrong.
2. does it have its own editor setting or preset list? Set it to `kak` /
   `kakoune` there. This is the usual answer.
3. does it only accept a bare command? Point it at `kak` directly rather than
   at `$EDITOR`.

## Notes and caveats

- `$EDITOR` remains `omarchy-launch-editor --inline` (the Omarchy default); it
  now resolves to Kakoune through the patched dispatcher + state file.
- `omarchy default editor` (query) shows `kak`; using the setter with `kak` is
  rejected by its validation list — write the state file to switch back
  (`printf 'kak\n' > ~/.local/state/omarchy/defaults/editor`).
- Opening an Omarchy config file from the menu launches Kakoune in a new
  Omarchy-styled terminal, and the file's auto-apply-on-save still fires when
  you save — the watcher does not care which editor saved the file.
- Behavioural notes: `--inline` dispatch execs `kak`; switching the state file
  to `nvim` (or other packaged editors) still delegates correctly; xdg default
  queries resolve to `kakoune.desktop`.