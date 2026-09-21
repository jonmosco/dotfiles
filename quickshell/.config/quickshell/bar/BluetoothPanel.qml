import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
  id: root

  required property var theme
  required property var barScreen
  required property string font
  required property int iconSize
  required property int textSize
  required property int smallTextSize

  property bool open: false
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
  readonly property int connectedCount: {
    let count = 0;
    for (const device of devices) if (device && device.connected) count++;
    return count;
  }
  readonly property string icon: !adapter || !adapter.enabled ? "󰂲" : connectedCount > 0 ? "󰂱" : "󰂯"
  readonly property string status: !adapter ? "No adapter" : !adapter.enabled ? "Off" : connectedCount > 0 ? connectedCount + " connected" : "On"

  function deviceLabel(device): string {
    if (!device) return "Unknown device";
    return device.name || device.deviceName || device.address || "Unknown device";
  }

  function setDiscovery(enabled): void {
    if (!adapter || !adapter.enabled) return;
    adapter.discovering = enabled;
  }

  function togglePanel(): void {
    open = !open;
  }

  function runDeviceAction(device, action): void {
    if (!device || !device.address) return;

    // Use Quickshell's live BlueZ object for connection changes. This keeps
    // the button state synchronized and avoids waiting on a detached
    // bluetoothctl process.
    if (action === "connect") {
      device.trusted = true;
      device.connected = true;
      bluetoothDefaultOutput.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/bluetooth-default-output", device.address];
      bluetoothDefaultOutput.running = true;
      return;
    }
    if (action === "disconnect") {
      device.connected = false;
      return;
    }

    // Pairing and forgetting retain the helper's timeout and trust handling.
    if (bluetoothAction.running) return;
    bluetoothAction.command = [Quickshell.env("HOME") + "/.config/hypr/scripts/bluetooth-device", action, device.address];
    bluetoothAction.running = true;
  }

  onOpenChanged: setDiscovery(open)

  Connections {
    target: root.adapter
    function onEnabledChanged(): void {
      if (root.open && root.adapter && root.adapter.enabled) discoveryDelay.restart();
    }
  }

  Timer {
    id: discoveryDelay
    interval: 400
    repeat: false
    onTriggered: root.setDiscovery(true)
  }

  Process {
    id: bluetoothAction
    running: false
  }

  Process {
    id: bluetoothDefaultOutput
    running: false
  }

  Variants {
    model: root.open && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-bluetooth"

      Shortcut { sequence: "Escape"; onActivated: root.open = false }
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 430
        height: Math.min(bluetoothColumn.implicitHeight + 40, 610)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.96)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: bluetoothColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          RowLayout {
            width: parent.width
            height: 34
            spacing: 10

            Text {
              text: root.icon
              color: root.connectedCount > 0 ? root.theme.accentGreen : root.adapter && root.adapter.enabled ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.iconSize + 2
              font.family: root.font
              Layout.alignment: Qt.AlignVCenter
            }

            Column {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              spacing: 1

              Text {
                text: "Bluetooth"
                color: root.theme.textPrimary
                font.pixelSize: root.textSize
                font.family: root.font
                font.bold: true
              }

              Text {
                text: root.status
                color: root.connectedCount > 0 ? root.theme.accentGreen : root.adapter && root.adapter.enabled ? root.theme.accentPrimary : root.theme.textMuted
                font.pixelSize: 11
                font.family: root.font
              }
            }

            Rectangle {
              Layout.preferredWidth: 48
              Layout.preferredHeight: 26
              Layout.alignment: Qt.AlignVCenter
              radius: 13
              color: root.adapter && root.adapter.enabled ? root.theme.accentPrimary : root.theme.bgBorder
              opacity: powerHover.containsMouse ? 1 : 0.85

              Rectangle {
                width: 20
                height: 20
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                x: root.adapter && root.adapter.enabled ? parent.width - width - 3 : 3
                color: root.theme.textPrimary
                Behavior on x { NumberAnimation { duration: 150 } }
              }

              MouseArea {
                id: powerHover
                anchors.fill: parent
                enabled: root.adapter !== null
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.adapter.enabled = !root.adapter.enabled
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Item {
            width: parent.width
            height: 22

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.adapter && root.adapter.discovering ? "Scanning for devices…" : "Devices"
              color: root.adapter && root.adapter.discovering ? root.theme.accentCyan : root.theme.textMuted
              font.pixelSize: 12
              font.family: root.font
              font.bold: true
            }

            Text {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              visible: root.adapter && root.adapter.enabled
              text: root.adapter && root.adapter.discovering ? "󰑓" : "Scan"
              color: scanHover.containsMouse ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.adapter && root.adapter.discovering ? root.iconSize : 12
              font.family: root.font

              MouseArea {
                id: scanHover
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.adapter.discovering = !root.adapter.discovering
              }
            }
          }

          Flickable {
            width: parent.width
            height: Math.min(deviceColumn.implicitHeight, 440)
            contentHeight: deviceColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: deviceColumn
              width: parent.width
              spacing: 6

              Text {
                visible: !root.adapter || !root.adapter.enabled
                width: parent.width
                topPadding: 28
                bottomPadding: 28
                horizontalAlignment: Text.AlignHCenter
                text: !root.adapter ? "No Bluetooth adapter found" : "Turn Bluetooth on to manage devices"
                color: root.theme.textMuted
                font.pixelSize: root.smallTextSize
                font.family: root.font
              }

              Text {
                visible: root.adapter && root.adapter.enabled && root.devices.length === 0
                width: parent.width
                topPadding: 28
                bottomPadding: 28
                horizontalAlignment: Text.AlignHCenter
                text: root.adapter && root.adapter.discovering ? "Looking for nearby devices…" : "No devices found"
                color: root.theme.textMuted
                font.pixelSize: root.smallTextSize
                font.family: root.font
              }

              Repeater {
                model: Bluetooth.devices

                Rectangle {
                  id: deviceCard
                  required property BluetoothDevice modelData
                  readonly property bool isConnected: modelData.connected || modelData.state === BluetoothDeviceState.Connected
                  readonly property bool connectionBusy: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting || modelData.pairing
                  readonly property bool shown: isConnected || modelData.paired || modelData.bonded || (root.adapter && root.adapter.discovering)
                  readonly property bool saved: modelData.paired || modelData.bonded
                  readonly property color stateColor: isConnected ? root.theme.accentGreen : saved ? root.theme.accentOrange : root.theme.accentRed
                  visible: shown
                  width: deviceColumn.width
                  height: shown ? 58 : 0
                  radius: 10
                  color: deviceHover.containsMouse ? root.theme.bgHover : Qt.rgba(stateColor.r, stateColor.g, stateColor.b, 0.10)
                  border.width: isConnected ? 2 : 1
                  border.color: stateColor

                  Behavior on color { ColorAnimation { duration: 120 } }

                  RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 10

                    Text {
                      text: deviceCard.isConnected ? "󰂱" : deviceCard.saved ? "󰂯" : "󰂰"
                      color: deviceCard.stateColor
                      font.pixelSize: root.iconSize
                      font.family: root.font
                      Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                      Layout.fillWidth: true
                      Layout.alignment: Qt.AlignVCenter
                      spacing: 2

                      Text {
                        width: parent.width
                        text: root.deviceLabel(deviceCard.modelData)
                        color: root.theme.textPrimary
                        font.pixelSize: 13
                        font.family: root.font
                        font.bold: true
                        elide: Text.ElideRight
                      }

                      Text {
                        text: {
                          if (deviceCard.modelData.pairing) return "Pairing…";
                          if (deviceCard.modelData.state === BluetoothDeviceState.Connecting) return "Connecting…";
                          if (deviceCard.modelData.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…";
                          if (deviceCard.isConnected && deviceCard.modelData.batteryAvailable)
                            return "Connected · " + Math.round(deviceCard.modelData.battery * 100) + "% battery";
                          if (deviceCard.isConnected) return "Connected";
                          if (deviceCard.saved) return "Paired · Disconnected";
                          return "Disconnected · Not paired";
                        }
                        color: deviceCard.stateColor
                        font.pixelSize: 11
                        font.family: root.font
                      }
                    }

                    Rectangle {
                      Layout.preferredWidth: actionText.implicitWidth + 18
                      Layout.preferredHeight: 26
                      Layout.alignment: Qt.AlignVCenter
                      radius: 8
                      color: deviceCard.isConnected ? root.theme.accentGreen : deviceCard.saved ? root.theme.accentOrange : root.theme.accentPrimary
                      opacity: deviceCard.connectionBusy ? 0.55 : actionHover.containsMouse ? 1 : 0.82

                      Text {
                        id: actionText
                        anchors.centerIn: parent
                        text: {
                          if (deviceCard.modelData.state === BluetoothDeviceState.Connecting) return "Connecting…";
                          if (deviceCard.modelData.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…";
                          if (deviceCard.modelData.pairing) return "Pairing…";
                          return deviceCard.isConnected ? "Disconnect" : deviceCard.saved ? "Connect" : "Pair";
                        }
                        color: "white"
                        font.pixelSize: 11
                        font.family: root.font
                        font.bold: true
                      }

                      MouseArea {
                        id: actionHover
                        anchors.fill: parent
                        enabled: !deviceCard.connectionBusy
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.runDeviceAction(deviceCard.modelData,
                          deviceCard.isConnected ? "disconnect" :
                          deviceCard.saved ? "connect" : "pair")
                      }
                    }

                    Rectangle {
                      visible: deviceCard.modelData.paired || deviceCard.modelData.bonded
                      Layout.preferredWidth: visible ? 26 : 0
                      Layout.preferredHeight: 26
                      Layout.alignment: Qt.AlignVCenter
                      radius: 8
                      color: forgetHover.containsMouse ? root.theme.accentRed : root.theme.bgBorder

                      Text {
                        anchors.centerIn: parent
                        text: "󰆴"
                        color: forgetHover.containsMouse ? "white" : root.theme.textMuted
                        font.pixelSize: 13
                        font.family: root.font
                      }

                      MouseArea {
                        id: forgetHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runDeviceAction(deviceCard.modelData, "forget")
                      }
                    }
                  }

                  MouseArea {
                    id: deviceHover
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    z: -1
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
