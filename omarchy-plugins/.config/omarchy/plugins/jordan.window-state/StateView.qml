import QtQuick
import qs.Commons
import "Vocabulary.js" as Vocabulary

// What the bar shows: a hairline that sets the widget apart from the
// workspace switcher, the focused window's state as icons, then the
// workspace and its window count.
//
// A plain tiled window is drawn muted and anything else takes the bar's
// attention colour, so the widget stays quiet until there is something to
// notice. Pinned implies floating in Hyprland, so "float & pin" is one icon.
Item {
  id: root

  // "" (nothing focused), "tiled", "floating" or "pinned"
  property string mode: ""
  // "", "wide", "tiledFullscreen" or "fullscreen"
  property string size: ""
  property bool grouped: false
  property bool special: false
  property int count: 0

  // Draws the open-panel mark under the icons and count while the legend is up.
  property bool marked: false
  property string barPosition: "top"

  property bool vertical: false
  property int barSize: Style.bar.sizeHorizontal
  property color foreground: Color.foreground
  property color accent: Color.bar.active
  property string fontFamily: Style.font.family

  readonly property bool hasWindow: mode !== ""
  readonly property real ruleLead: Style.space(7)
  readonly property real ruleTrail: Style.space(9)
  readonly property real ruleLength: Style.space(12)
  readonly property real iconGap: Style.space(2)
  readonly property real clusterGap: Style.space(9)
  readonly property real countGap: Style.space(3)
  readonly property real chrome: ruleLead + Style.spacing.hairline + ruleTrail

  implicitWidth: vertical ? barSize : chrome + slots.implicitWidth
  implicitHeight: vertical ? chrome + slots.implicitHeight : barSize

  Rectangle {
    id: rule
    x: root.vertical ? Math.round((root.width - width) / 2) : root.ruleLead
    y: root.vertical ? root.ruleLead : Math.round((root.height - height) / 2)
    width: root.vertical ? root.ruleLength : Style.spacing.hairline
    height: root.vertical ? Style.spacing.hairline : root.ruleLength
    color: Util.alpha(root.foreground, 0.2)
  }

  // Same mark the bar draws under an open panel, sized to what is painted
  // here instead of the bar's fraction of the slot, which would stop short
  // of the count because the hairline pushes the content off-centre.
  Rectangle {
    readonly property int inset: Style.space(2)
    readonly property int thickness: Style.space(2)

    visible: opacity > 0
    opacity: root.marked ? 0.9 : 0
    color: Color.accent
    radius: Math.min(width, height) / 2
    width: root.vertical ? thickness : slots.width
    height: root.vertical ? slots.height : thickness
    x: root.vertical ? (root.barPosition === "left" ? root.width - width - inset : inset) : slots.x
    y: root.vertical ? slots.y : (root.barPosition === "bottom" ? inset : root.height - height - inset)

    Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
  }

  Grid {
    id: slots
    x: root.vertical ? Math.round((root.width - width) / 2) : root.chrome
    y: root.vertical ? root.chrome : Math.round((root.height - height) / 2)
    rows: root.vertical ? 5 : 1
    columns: root.vertical ? 1 : 5
    flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter

    StateGlyph {
      text: root.hasWindow ? Vocabulary.glyphs[root.mode] : ""
      emphasized: root.mode === "floating" || root.mode === "pinned"
      vertical: root.vertical
      foreground: root.foreground
      accent: root.accent
      fontFamily: root.fontFamily
    }

    StateGlyph {
      text: root.size !== "" ? Vocabulary.glyphs[root.size] : ""
      emphasized: true
      lead: root.iconGap
      vertical: root.vertical
      foreground: root.foreground
      accent: root.accent
      fontFamily: root.fontFamily
    }

    StateGlyph {
      text: root.grouped ? Vocabulary.glyphs.grouped : ""
      emphasized: true
      lead: root.iconGap
      vertical: root.vertical
      foreground: root.foreground
      accent: root.accent
      fontFamily: root.fontFamily
    }

    StateGlyph {
      text: root.special ? Vocabulary.glyphs.special : Vocabulary.glyphs.windows
      emphasized: root.special
      lead: root.hasWindow ? root.clusterGap : 0
      vertical: root.vertical
      foreground: root.foreground
      accent: root.accent
      fontFamily: root.fontFamily
    }

    Text {
      textFormat: Text.PlainText
      text: String(root.count)
      color: Util.alpha(root.foreground, root.count > 0 ? 0.9 : 0.5)
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      renderType: Text.NativeRendering
      leftPadding: root.vertical ? 0 : root.countGap
      topPadding: root.vertical ? root.countGap : 0

      Behavior on color { ColorAnimation { duration: 160 } }
    }
  }
}
