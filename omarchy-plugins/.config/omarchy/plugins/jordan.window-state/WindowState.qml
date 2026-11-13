import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "Vocabulary.js" as Vocabulary

// The focused window's Hyprland state, and the window count of the workspace
// in view (special workspaces included). Hovering opens a legend of the icons.
//
// Hyprland's event socket does not report every change, so four gaps are
// covered here:
// - Quickshell drops the empty activewindowv2 sent when nothing is focused,
//   so the focused address is read from the raw event.
// - Hiding a special workspace leaves its window as Hyprland's active window
//   with no event, so a focused window only counts while its workspace is in
//   view.
// - HyprlandToplevel.lastIpcObject is a snapshot that Quickshell does not
//   renew on float, pin or group events, so those ask for a refresh.
// - Changing only the client's fullscreen state (Omarchy's "Tiled full
//   screen") emits no event at all, so a refresh also runs whenever keyboard
//   and pointer input pauses.
BarWidget {
  id: root
  moduleName: "jordan.window-state"

  readonly property var toplevelEvents: ({
    activewindowv2: true, openwindow: true, closewindow: true, movewindowv2: true,
    changefloatingmode: true, pin: true, fullscreen: true, togglegroup: true,
    moveintogroup: true, moveoutofgroup: true, workspacev2: true
  })
  readonly property var monitorEvents: ({
    moveworkspacev2: true, monitoraddedv2: true, monitorremovedv2: true
  })

  // Quickshell only learns the active window from focus events, so until the
  // first one after the shell starts, the most recently focused window in the
  // snapshots stands in.
  property string activeAddress: Hyprland.activeToplevel ? Hyprland.activeToplevel.address
    : lastFocusedAddress(Hyprland.toplevels.values)
  readonly property var toplevel: toplevelByAddress(activeAddress, Hyprland.toplevels.values)
  readonly property var info: toplevel && toplevel.lastIpcObject ? toplevel.lastIpcObject : ({})
  readonly property bool hasWindow: {
    if (toplevel === null || info.address === undefined) return false
    // A pinned window follows its monitor's active workspace.
    if (info.pinned === true) return true
    var id = info.workspace ? info.workspace.id : 0
    return id === activeWorkspaceId || (special && id === specialId)
  }

  // Pinning requires a floating window in Hyprland, so pinned covers both.
  readonly property string mode: !hasWindow ? ""
    : (info.pinned === true ? "pinned" : (info.floating === true ? "floating" : "tiled"))
  // Hyprland's own fullscreen mode comes first; "tiled full screen" is the
  // client believing it is fullscreen while Hyprland keeps it in its tile.
  readonly property string size: {
    if (!hasWindow) return ""
    if (info.fullscreen === 2) return "fullscreen"
    if (info.fullscreen === 1) return "wide"
    return info.fullscreenClient === 2 ? "tiledFullscreen" : ""
  }
  readonly property int groupSize: hasWindow && info.grouped ? info.grouped.length : 0

  // The workspace in view on the focused monitor: the special workspace when
  // one is shown over it, else its active workspace. Quickshell keeps the
  // active workspace current from events; the monitor's JSON only fills in
  // until the first event after the shell starts.
  readonly property var focusedMonitor: Hyprland.focusedMonitor
  readonly property var monitorInfo: focusedMonitor
    ? (focusedMonitor.lastIpcObject || ({})) : focusedMonitorInfo(Hyprland.monitors.values)
  readonly property string monitorName: focusedMonitor ? String(focusedMonitor.name) : String(monitorInfo.name || "")

  readonly property var activeWorkspace: Hyprland.focusedWorkspace
  readonly property bool hasWorkspace: activeWorkspace !== null || !!monitorInfo.activeWorkspace
  readonly property int activeWorkspaceId: activeWorkspace ? activeWorkspace.id
    : (monitorInfo.activeWorkspace ? monitorInfo.activeWorkspace.id : 0)

  // Quickshell does not track special workspaces, so the one shown on each
  // monitor is kept here from activespecialv2, by monitor name.
  property var shownSpecial: ({})
  readonly property var specialInfo: shownSpecial[monitorName] !== undefined
    ? shownSpecial[monitorName] : (monitorInfo.specialWorkspace || null)
  readonly property int specialId: specialInfo ? specialInfo.id : 0
  readonly property bool special: specialId !== 0
  readonly property string specialName: special ? String(specialInfo.name).replace(/^special:/, "") : ""
  readonly property int workspaceId: special ? specialId : activeWorkspaceId

  readonly property var tally: tallyWindows(hasWorkspace, workspaceId, Hyprland.toplevels.values)

  readonly property color foreground: bar ? bar.barForeground : Commons.Color.foreground
  readonly property color accent: bar ? bar.urgent : Commons.Color.bar.active
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  // State name -> key label for the legend, read from Hyprland on first use.
  property var keys: ({})
  property bool keysRequested: false
  property string bindsReply: ""

  property bool legendOpen: false
  // A panel opened on purpose always wins over the hover card.
  readonly property bool legendShown: legendOpen && !(bar && bar.activePopout)
  property bool wantToplevels: false
  property bool wantMonitors: false
  property int startupAttempts: 0

  visible: hasWorkspace
  implicitWidth: visible ? view.implicitWidth : 0
  implicitHeight: view.implicitHeight

  function toplevelByAddress(address, values) {
    if (address === "") return null
    for (var i = 0; i < values.length; i++) {
      if (values[i].address === address) return values[i]
    }
    return null
  }

  function lastFocusedAddress(values) {
    for (var i = 0; i < values.length; i++) {
      var o = values[i].lastIpcObject
      if (o && o.focusHistoryID === 0) return values[i].address
    }
    return ""
  }

  function focusedMonitorInfo(values) {
    for (var i = 0; i < values.length; i++) {
      var o = values[i].lastIpcObject
      if (o && o.focused === true) return o
    }
    return ({})
  }

  function tallyWindows(active, id, values) {
    var total = 0
    var floating = 0
    if (active) {
      for (var i = 0; i < values.length; i++) {
        var o = values[i].lastIpcObject
        if (!o || !o.workspace || o.mapped === false || o.workspace.id !== id) continue
        total++
        if (o.floating) floating++
      }
    }
    return { total: total, floating: floating }
  }

  // A bar exists per monitor and they all read the same Hyprland objects, so
  // only the first instance asks Hyprland to refresh them.
  function drivesRefresh() {
    if (!bar || typeof bar.moduleWidgets !== "function") return true
    var peers = bar.moduleWidgets(moduleName)
    return !peers || peers.length === 0 || peers[0] === root
  }

  function requestRefresh(toplevels, monitors) {
    wantToplevels = wantToplevels || toplevels
    wantMonitors = wantMonitors || monitors
    refreshTimer.restart()
  }

  function loadKeys() {
    if (keysRequested) return
    keysRequested = true
    bindsReply = ""
    bindsSocket.connected = true
  }

  // activespecialv2 carries "ID,NAME,MONITOR", with ID and NAME empty when
  // the special workspace is hidden.
  function noteSpecial(data) {
    var parts = String(data).split(",")
    if (parts.length < 3) return
    var next = ({})
    for (var name in shownSpecial) next[name] = shownSpecial[name]
    next[parts[parts.length - 1]] = {
      id: parseInt(parts[0]) || 0,
      name: parts.slice(1, parts.length - 1).join(",")
    }
    shownSpecial = next
  }

  Component.onCompleted: requestRefresh(true, true)

  Timer {
    id: refreshTimer
    interval: 40
    onTriggered: {
      var toplevels = root.wantToplevels
      var monitors = root.wantMonitors
      root.wantToplevels = false
      root.wantMonitors = false
      if (!root.drivesRefresh()) return
      if (toplevels) Hyprland.refreshToplevels()
      if (monitors) Hyprland.refreshMonitors()
    }
  }

  // The first refresh can run before the Hyprland connection is up, and
  // nothing else asks for one until the next event, so retry a few times
  // until the focused monitor's info arrives.
  Timer {
    interval: 400
    repeat: true
    running: !root.hasWorkspace && root.startupAttempts < 10
    onTriggered: {
      root.startupAttempts++
      root.requestRefresh(true, true)
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event.name
      if (name === "activewindowv2") {
        // Also sent on every title change of the focused window, which a
        // terminal can do several times a second.
        if (event.data === root.activeAddress) return
        root.activeAddress = event.data
      } else if (name === "activespecialv2") {
        root.noteSpecial(event.data)
        return
      } else if (name === "configreloaded") {
        root.keysRequested = false
        return
      }
      var toplevels = root.toplevelEvents[name] === true
      var monitors = root.monitorEvents[name] === true
      if (toplevels || monitors) root.requestRefresh(toplevels, monitors)
    }
  }

  // Fires each time input stops for a moment, which is right after any
  // keybinding has been pressed. 50 ms leaves room for Omarchy's toggle script
  // (about 15 ms) to land first; a refresh costs roughly 0.1 ms, so one per
  // keystroke is not worth saving. Inhibitors are ignored so a playing video
  // or Omarchy's stay-awake does not switch this off.
  IdleMonitor {
    timeout: 0.05
    respectInhibitors: false
    onIsIdleChanged: if (isIdle && root.drivesRefresh()) Hyprland.refreshToplevels()
  }

  // One request on Hyprland's command socket, which closes after replying.
  Socket {
    id: bindsSocket
    path: Hyprland.requestSocketPath
    parser: SplitParser {
      splitMarker: ""
      onRead: function(data) { root.bindsReply += data }
    }
    onConnectedChanged: {
      if (connected) {
        write("j/binds")
        flush()
      } else if (root.bindsReply !== "") {
        root.keys = Vocabulary.keysFromBinds(root.bindsReply)
        root.bindsReply = ""
      }
    }
  }

  StateView {
    id: view
    anchors.fill: parent
    mode: root.mode
    size: root.size
    grouped: root.groupSize > 0
    special: root.special
    count: root.tally.total
    marked: root.legendShown
    barPosition: root.bar ? root.bar.position : "top"
    vertical: root.vertical
    barSize: root.barSize
    foreground: root.foreground
    accent: root.accent
    fontFamily: root.fontFamily
  }

  // Hover only: clicks and drags fall through to the bar.
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
    onContainsMouseChanged: {
      if (containsMouse) {
        openTimer.restart()
      } else {
        openTimer.stop()
        root.legendOpen = false
      }
    }
  }

  Timer {
    id: openTimer
    interval: 300
    onTriggered: {
      root.loadKeys()
      root.legendOpen = true
    }
  }

  // The legend is a passive hover card, so it stays out of the bar's popout
  // registry: joining it would close a panel the user has open and draw the
  // bar's own open-panel mark, which StateView replaces.
  QtObject {
    id: legendHost
    readonly property string position: root.bar ? root.bar.position : "top"
    readonly property var activePopout: null
    function requestPopout(owner) {}
    function releasePopout(owner) {}
  }

  PopupCard {
    id: legendCard
    anchorItem: root
    bar: legendHost
    triggerMode: "hover"
    open: root.legendShown
    contentWidth: legendCard.fittedContentWidth(Style.space(320))
    contentHeight: legendCard.fittedContentHeight(legend.implicitHeight)

    Legend {
      id: legend
      width: parent.width
      mode: root.mode
      size: root.size
      grouped: root.groupSize > 0
      groupSize: root.groupSize
      special: root.special
      specialName: root.specialName
      count: root.tally.total
      floatingCount: root.tally.floating
      keys: root.keys
      accent: root.accent
      fontFamily: root.fontFamily
    }
  }
}
