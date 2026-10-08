import QtQuick
import qs.Commons
import qs.Ui
import "Vocabulary.js" as Vocabulary

// The hover card: every icon the widget can show, with the key that toggles
// it. Rows describing the current state are lit and the rest stay muted, so
// the card also reads out what the bar icons mean right now.
Column {
  id: root

  property string mode: ""
  property string size: ""
  property bool grouped: false
  property int groupSize: 0
  property bool special: false
  property string specialName: ""
  property int count: 0
  property int floatingCount: 0
  // State name -> key label, e.g. { pinned: "Super O" }.
  property var keys: ({})

  property color foreground: Color.popups.text
  property color accent: Color.bar.active
  property string fontFamily: Style.font.family

  readonly property string countLabel: {
    if (count === 0) return "No windows"
    var label = count + (count === 1 ? " window" : " windows")
    return floatingCount > 0 ? label + " · " + floatingCount + " floating" : label
  }

  component Entry: Item {
    id: entry

    property string name: ""
    property string label: ""
    property bool active: false
    // A resting state is lit in the text colour rather than the accent, as in the bar.
    property bool resting: false
    readonly property string hint: root.keys[name] || ""

    width: root.width
    implicitHeight: Style.space(22)

    OpticalGlyph {
      id: icon
      anchors.verticalCenter: parent.verticalCenter
      width: Style.bar.iconCanvas
      height: Style.bar.iconCanvas
      text: Vocabulary.glyphs[entry.name] || ""
      fontFamily: root.fontFamily
      fontSize: Style.bar.iconFont
      color: !entry.active ? Util.alpha(root.foreground, 0.4) : (entry.resting ? root.foreground : root.accent)
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: icon.right
      anchors.leftMargin: Style.space(10)
      anchors.right: hintText.left
      anchors.rightMargin: Style.space(12)
      textFormat: Text.PlainText
      text: entry.label
      color: Util.alpha(root.foreground, entry.active ? 1 : 0.5)
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      elide: Text.ElideRight
    }

    Text {
      id: hintText
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      textFormat: Text.PlainText
      text: entry.hint
      color: Util.alpha(root.foreground, 0.4)
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  PanelSectionHeader {
    text: "Focused window"
    foreground: root.foreground
    fontFamily: root.fontFamily
    bottomPadding: Style.space(4)
  }

  Entry { name: "tiled"; label: "Tiled"; active: root.mode === "tiled"; resting: true }
  Entry { name: "floating"; label: "Floating"; active: root.mode === "floating" }
  Entry { name: "pinned"; label: "Popped out · float & pin"; active: root.mode === "pinned" }
  Entry { name: "wide"; label: "Full width"; active: root.size === "wide" }
  Entry { name: "tiledFullscreen"; label: "Tiled full screen"; active: root.size === "tiledFullscreen" }
  Entry { name: "fullscreen"; label: "Full screen"; active: root.size === "fullscreen" }
  Entry {
    name: "grouped"
    label: root.grouped && root.groupSize > 1 ? "Grouped · " + root.groupSize + " windows" : "Grouped"
    active: root.grouped
  }

  Item { width: 1; height: Style.space(6) }
  PanelSeparator { foreground: root.foreground }
  Item { width: 1; height: Style.space(6) }

  PanelSectionHeader {
    text: "This workspace"
    foreground: root.foreground
    fontFamily: root.fontFamily
    bottomPadding: Style.space(4)
  }

  Entry { name: "windows"; label: root.countLabel; active: root.count > 0; resting: true }
  Entry {
    name: "special"
    label: root.special && root.specialName !== "" && root.specialName !== "scratchpad"
      ? "Special workspace · " + root.specialName : "Scratchpad"
    active: root.special
  }
}
