import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// One icon slot. An empty `text` collapses the slot so the row closes up
// around it; filling it eases the slot open, so a state change reads as a
// change rather than a jump.
Item {
  id: root

  property string text: ""
  // Resting states stay muted; anything worth noticing takes the accent.
  property bool emphasized: false
  // Space before the icon along the bar's axis.
  property real lead: 0
  property bool vertical: false
  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.bar.active
  property string fontFamily: Style.font.family

  readonly property bool shown: text !== ""
  readonly property real canvas: Style.bar.iconCanvas
  // The last icon shown, kept while the slot fades out.
  property string heldText: ""
  property real extent: shown ? lead + canvas : 0
  property real offset: lead

  onTextChanged: if (text !== "") heldText = text
  Component.onCompleted: heldText = text

  implicitWidth: vertical ? canvas : extent
  implicitHeight: vertical ? extent : canvas
  opacity: shown ? 1 : 0
  clip: true

  Behavior on extent { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on offset { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  OpticalGlyph {
    x: root.vertical ? 0 : root.offset
    y: root.vertical ? root.offset : 0
    width: root.canvas
    height: root.canvas
    text: root.heldText
    fontFamily: root.fontFamily
    fontSize: Style.bar.iconFont
    color: root.emphasized ? root.accent : Util.alpha(root.foreground, 0.5)

    Behavior on color { ColorAnimation { duration: 160 } }
  }
}
