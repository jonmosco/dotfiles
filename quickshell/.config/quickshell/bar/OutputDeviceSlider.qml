import QtQuick
import QtQuick.Controls

Column {
  id: root

  required property var node
  required property var theme
  property string font: "Hack Nerd Font"
  property int iconSize: 20
  property int textSize: 16
  property bool isDefault: false

  signal volumeRequested(real value)
  signal muteRequested()

  width: parent ? parent.width : 360
  spacing: 8

  Row {
    width: parent.width
    height: 20
    spacing: 8

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - defaultBadge.width - parent.spacing
      text: root.node
            ? (root.node.description || root.node.nickname || root.node.name || "Unknown output")
            : "Unknown output"
      color: root.theme.textSecondary
      font.pixelSize: 12
      font.family: root.font
      elide: Text.ElideRight
    }

    Rectangle {
      id: defaultBadge
      anchors.verticalCenter: parent.verticalCenter
      visible: root.isDefault
      width: visible ? defaultText.implicitWidth + 10 : 0
      height: 18
      radius: 9
      color: Qt.rgba(root.theme.accentPrimary.r, root.theme.accentPrimary.g,
                     root.theme.accentPrimary.b, 0.18)
      border.width: visible ? 1 : 0
      border.color: root.theme.accentPrimary

      Text {
        id: defaultText
        anchors.centerIn: parent
        text: "Default"
        color: root.theme.accentPrimary
        font.pixelSize: 9
        font.family: root.font
        font.bold: true
      }
    }
  }

  Row {
    width: parent.width
    height: 34
    spacing: 12

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: 30
      height: 30
      radius: 9
      color: muteMouse.containsMouse ? root.theme.bgHover : root.theme.bgSurface
      border.width: 1
      border.color: root.theme.bgBorder

      Text {
        anchors.centerIn: parent
        text: !root.node || !root.node.audio || root.node.audio.muted ? "󰖁" : "󰕾"
        color: !root.node || !root.node.audio || root.node.audio.muted
               ? root.theme.textMuted : root.theme.accentPrimary
        font.pixelSize: root.iconSize
        font.family: root.font
      }

      MouseArea {
        id: muteMouse
        anchors.fill: parent
        enabled: !!(root.node && root.node.audio)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.muteRequested()
      }
    }

    Slider {
      id: slider
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width - 30 - 46 - parent.spacing * 2
      height: 34
      from: 0
      to: 1
      stepSize: 0.01
      enabled: !!(root.node && root.node.audio)
      value: root.node && root.node.audio
             ? Math.max(0, Math.min(1, root.node.audio.volume)) : 0
      onMoved: root.volumeRequested(value)

      background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 7
        radius: 4
        color: root.theme.bgBorder

        Rectangle {
          width: slider.visualPosition * parent.width
          height: parent.height
          radius: parent.radius
          color: root.theme.accentPrimary
        }
      }

      handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 18
        height: 18
        radius: 9
        color: slider.pressed ? root.theme.accentCyan : root.theme.accentPrimary
        border.width: 2
        border.color: root.theme.bgBase
        scale: slider.hovered || slider.pressed ? 1.12 : 1

        Behavior on scale { NumberAnimation { duration: 100 } }
      }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      width: 46
      horizontalAlignment: Text.AlignRight
      text: !root.node || !root.node.audio
            ? "–" : Math.round(root.node.audio.volume * 100) + "%"
      color: root.theme.textPrimary
      font.pixelSize: root.textSize
      font.family: root.font
      font.bold: true
    }
  }
}
