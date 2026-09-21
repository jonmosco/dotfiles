import Quickshell
import QtQuick
import Quickshell.Wayland

Scope {
  id: root

  property bool open: false
  property var barScreen: null
  property var commands: []
  property var theme
  property string font: "Hack Nerd Font"
  property string title: "Commands"
  property string subtitle: ""
  property string icon: "󱃾"
  property color accent: "#326ce5"
  property int iconSize: 20
  property int textSize: 16
  property int smallTextSize: 13
  property int barHeight: 48

  signal closeRequested()

  Variants {
    model: root.open && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-command-list"

      Shortcut { sequence: "Escape"; onActivated: root.closeRequested() }
      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 620
        height: Math.min(commandColumn.implicitHeight + 64, 720)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          anchors.fill: parent
          anchors.margins: 16
          spacing: 12

          Row {
            width: parent.width
            height: 28
            spacing: 8

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.icon
              color: root.accent
              font.pixelSize: root.iconSize + 2
              font.family: root.font
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.title
              color: root.theme.textPrimary
              font.pixelSize: root.textSize
              font.family: root.font
              font.bold: true
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.subtitle
              color: root.theme.textMuted
              font.pixelSize: root.smallTextSize
              font.family: root.font
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Flickable {
            width: parent.width
            height: Math.min(commandColumn.implicitHeight, 620)
            contentHeight: commandColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: commandColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.commands

                Column {
                  required property var modelData
                  width: commandColumn.width
                  spacing: 6

                  Text {
                    text: modelData.category
                    color: root.accent
                    font.pixelSize: root.smallTextSize
                    font.family: root.font
                    font.bold: true
                  }

                  Repeater {
                    model: modelData.bindings

                    Rectangle {
                      required property var modelData
                      width: commandColumn.width
                      height: 34
                      radius: 8
                      property bool hovered: false
                      color: hovered ? root.theme.bgHover : root.theme.bgSurface

                      Behavior on color { ColorAnimation { duration: 100 } }

                      Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 14

                        Text {
                          anchors.verticalCenter: parent.verticalCenter
                          width: 330
                          text: modelData.key
                          color: root.accent
                          font.pixelSize: 12
                          font.family: root.font
                          font.bold: true
                          elide: Text.ElideRight
                        }

                        Text {
                          anchors.verticalCenter: parent.verticalCenter
                          width: parent.width - 344
                          text: modelData.desc
                          color: root.theme.textPrimary
                          font.pixelSize: 12
                          font.family: root.font
                          elide: Text.ElideRight
                        }
                      }

                      MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
