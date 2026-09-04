import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import "../notifications" as Notif
Scope {
  id: root
  property var theme: DefaultTheme {}
  property string font: "Hack Nerd Font"
  property int iconSize: 20
  property int textSize: 16
  property int smallTextSize: 15
  property bool barVisible: true
  property bool historyOpen: false
  property bool volumeOpen: false
  property bool clipboardOpen: false
  property var clipboardItems: []
  property bool keysOpen: false
  property var keybindings: []
  property bool systemOpen: false
  property bool weatherOpen: false
  property bool vpnOpen: false
  property string vpnConnName: ""
  property bool vpnHasFedRAMP: false
  property bool vpnHasCommercial: false
  property var vpnConnections: []
  property bool appgateRunning: false
  property string weatherTemp: "--"
  property string weatherIcon: "󰖐"
  property string weatherDesc: ""
  property string weatherFeelsLike: ""
  property string weatherHumidity: ""
  property string weatherWind: ""
  property var weatherForecast: []

  // MPRIS active player
  property var activePlayer: {
    const players = Mpris.players.values;
    if (!players || players.length === 0) return null;
    for (const p of players) {
      if (p.playbackState === MprisPlaybackState.Playing) return p;
    }
    return players[0];
  }

  IpcHandler {
    target: "bar"
    function toggle(): void { root.barVisible = !root.barVisible; }
    function clipboard_toggle(): void {
      if (!root.clipboardOpen) {
        clipListIpcProc.running = true;
      } else {
        root.clipboardOpen = false;
      }
    }
    function keys_toggle(): void { root.keysOpen = !root.keysOpen; }
  }

  FileView {
    id: keybindingsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/keybindings.json"
    watchChanges: true
    onTextChanged: {
      const raw = keybindingsFile.text();
      if (!raw) return;
      try {
        root.keybindings = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse keybindings.json:", e);
      }
    }
  }

  Process {
    id: clipListIpcProc
    command: ["cliphist", "list"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n").filter(l => l.length > 0);
        const items = [];
        for (let i = 0; i < Math.min(lines.length, 30); i++) {
          const tab = lines[i].indexOf("\t");
          if (tab !== -1) {
            items.push({
              id: lines[i].substring(0, tab),
              preview: lines[i].substring(tab + 1),
              raw: lines[i]
            });
          }
        }
        root.clipboardItems = items;
        root.clipboardOpen = true;
      }
    }
  }

  PwObjectTracker {
    objects: [Pipewire.defaultAudioSink]
  }

  // Brightness state
  property real brightnessValue: 0
  property real brightnessMax: 1

  FileView {
    id: brightnessFile
    path: ""
    watchChanges: true
    onFileChanged: brightnessReadProc.running = true
  }

  Process {
    id: brightnessReadProc
    command: ["brightnessctl", "get"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const val = parseInt(text.trim());
        if (!isNaN(val) && root.brightnessMax > 0)
          root.brightnessValue = val / root.brightnessMax;
      }
    }
  }

  Process {
    id: brightnessSetProc
    running: false
  }

  Process {
    id: backlightDiscovery
    command: ["sh", "-c", "p=$(ls -d /sys/class/backlight/*/brightness 2>/dev/null | head -1); [ -n \"$p\" ] && echo \"$p\" && cat \"${p%brightness}max_brightness\""]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        if (lines.length >= 2) {
          const max = parseInt(lines[1]);
          if (!isNaN(max) && max > 0) root.brightnessMax = max;
          brightnessFile.path = lines[0];
          brightnessReadProc.running = true;
        }
      }
    }
  }

  function openNmEditor() { nmEditorProc.running = true; }
  function openAppgate() { appgateToggleProc.running = true; }

  Process {
    id: appgateCloseProc
    command: ["sh", "-c", "hyprctl eval 'hl.dsp.window.close({ class = \"appgate\" })' 2>/dev/null; pkill -f appgate-ui 2>/dev/null; sudo systemctl stop appgatedriver"]
    running: false
    onExited: { root.appgateRunning = false; }
  }

  Process {
    id: nmEditorProc
    command: ["nm-connection-editor"]
    running: false
  }

  Process {
    id: appgateToggleProc
    command: ["sh", "-c", "sudo systemctl start appgatedriver 2>/dev/null; pgrep -x appgate-ui > /dev/null && hyprctl eval 'hl.dsp.focus({ class = \"appgate\" })' || appgate"]
    running: false
  }

  Process {
    id: vpnListProc
    command: ["sh", "-c", "nmcli -t -f NAME,TYPE,ACTIVE con show | grep vpn"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n").filter(l => l.length > 0);
        const conns = [];
        for (const line of lines) {
          const parts = line.split(":");
          if (parts.length >= 3) {
            conns.push({ name: parts[0], active: parts[2] === "yes" });
          }
        }
        root.vpnConnections = conns;
      }
    }
  }

  Process {
    id: appgateCheckProc
    command: ["pgrep", "-x", "appgate-ui"]
    running: true
    onExited: function(code) { root.appgateRunning = code === 0; }
  }

  Process {
    id: vpnToggleProc
    running: false
    onExited: { vpnListProc.running = true; vpnCheck.running = true; }
  }

  function vpnConnect(name) { vpnToggleProc.command = ["nmcli", "con", "up", name]; vpnToggleProc.running = true; }
  function vpnDisconnect(name) { vpnToggleProc.command = ["nmcli", "con", "down", name]; vpnToggleProc.running = true; }

  Process {
    id: weatherFetchProc
    command: ["curl", "-sf", "https://wttr.in/16063?format=j1"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(text);
          const cur = data.current_condition[0];
          root.weatherTemp = cur.temp_F + "°";
          root.weatherFeelsLike = cur.FeelsLikeF + "°F";
          root.weatherHumidity = cur.humidity + "%";
          root.weatherWind = cur.windspeedMiles + " mph " + cur.winddir16Point;
          root.weatherDesc = cur.weatherDesc[0].value;
          const code = parseInt(cur.weatherCode);
          if (code === 113) root.weatherIcon = "󰖙";
          else if (code === 116) root.weatherIcon = "󰖐";
          else if (code === 119 || code === 122) root.weatherIcon = "";
          else if (code >= 176 && code <= 299) root.weatherIcon = "󰖗";
          else if (code >= 300 && code <= 399) root.weatherIcon = "󰖘";
          else if (code >= 200 && code <= 232) root.weatherIcon = "";
          else root.weatherIcon = "󰖐";
          const fc = [];
          for (let i = 0; i < Math.min(data.weather.length, 3); i++) {
            const d = data.weather[i];
            fc.push({
              date: d.date,
              high: d.maxtempF + "°",
              low: d.mintempF + "°",
              desc: d.hourly[4].weatherDesc[0].value
            });
          }
          root.weatherForecast = fc;
        } catch (e) {}
      }
    }
  }

  Timer {
    interval: 600000
    running: true
    repeat: true
    onTriggered: weatherFetchProc.running = true
  }

  property var barScreen: {
    const dell = "DELL U4025QW";
    for (const s of Quickshell.screens) {
      if (s.name.indexOf(dell) !== -1 || (s.model && s.model.indexOf(dell) !== -1)) return s;
    }
    return Quickshell.screens[0];
  }

  property bool isDocked: {
    const dell = "DELL U4025QW";
    for (const s of Quickshell.screens) {
      if (s.name.indexOf(dell) !== -1 || (s.model && s.model.indexOf(dell) !== -1)) return true;
    }
    return false;
  }

  property int barHeight: isDocked ? 48 : 38
  property int pillHeight: isDocked ? 32 : 26
  property int curIconSize: isDocked ? 20 : 16
  property int curTextSize: isDocked ? 16 : 13
  property int curSmallTextSize: isDocked ? 15 : 12

  Variants {
    model: root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: root.barVisible

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: root.barHeight
      color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.75)

      Item {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // Left section: Red Hat icon + Workspaces + Now Playing
        Row {
          id: leftSection
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          // Fedora icon
          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            color: root.theme.accentPrimary
            font.pixelSize: root.curIconSize
            font.family: root.font
          }

          // Workspaces
          Row {
            spacing: 4

            Repeater {
              model: Hyprland.workspaces

              Rectangle {
                id: wsPill
                required property var modelData
                property bool urgentBlink: false

                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + modelData.id + (modelData.focused ? ", active" : "") + (modelData.urgent ? ", urgent" : "")

                width: modelData.focused ? root.pillHeight : root.pillHeight - 4
                height: root.pillHeight
                radius: 12
                color: modelData.focused ? root.theme.accentPrimary :
                       modelData.urgent && urgentBlink ? root.theme.accentRed : root.theme.bgSurface

                Behavior on color {
                  ColorAnimation { duration: 150 }
                }

                SequentialAnimation {
                  loops: Animation.Infinite
                  running: wsPill.modelData.urgent && !wsPill.modelData.focused

                  PropertyAction { target: wsPill; property: "urgentBlink"; value: true }
                  PauseAnimation { duration: 500 }
                  PropertyAction { target: wsPill; property: "urgentBlink"; value: false }
                  PauseAnimation { duration: 500 }

                  onStopped: wsPill.urgentBlink = false
                }

                Text {
                  anchors.centerIn: parent
                  text: wsPill.modelData.id
                  color: wsPill.modelData.focused ? root.theme.bgBase : root.theme.textPrimary
                  font.pixelSize: root.curSmallTextSize
                  font.family: root.font
                  font.bold: wsPill.modelData.focused
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: wsPill.modelData.activate()
                }

                Behavior on width {
                  NumberAnimation { duration: 150 }
                }
              }
            }
          }

          // Now Playing
          Rectangle {
            height: root.pillHeight
            width: nowPlayingContent.width + 16
            radius: 12
            color: root.theme.bgSurface
            visible: root.activePlayer !== null

            Accessible.role: Accessible.Button
            Accessible.name: {
              if (!root.activePlayer) return "No media";
              const artist = root.activePlayer.trackArtist || "";
              const title = root.activePlayer.trackTitle || "";
              return "Now playing: " + (artist ? artist + " - " : "") + title;
            }

            Row {
              id: nowPlayingContent
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.activePlayer && root.activePlayer.isPlaying ? "󰐊" : "󰏤"
                color: root.theme.accentPrimary
                font.pixelSize: root.curIconSize
                font.family: root.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                  if (!root.activePlayer) return "";
                  const artist = root.activePlayer.trackArtist || "";
                  const title = root.activePlayer.trackTitle || "";
                  return artist ? artist + " - " + title : title;
                }
                color: root.theme.textPrimary
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 200)
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root.activePlayer.togglePlaying()
            }
          }
        }

        // Center section: Clock
        Row {
          anchors.centerIn: parent
          spacing: 8

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            color: root.theme.accentPrimary
            font.pixelSize: root.curIconSize
            font.family: root.font
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.dateString
            color: root.theme.textSecondary
            font.pixelSize: root.curTextSize
            font.family: root.font
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.timeString
            color: root.theme.textPrimary
            font.pixelSize: root.curTextSize
            font.family: root.font
          }
        }

        // Right section: System Info + System Tray
        Row {
          id: rightSection
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          // Volume
          Rectangle {
            height: root.pillHeight
            width: volContent.width + 16
            radius: 12
            color: root.theme.bgSurface

            Accessible.role: Accessible.Slider
            Accessible.name: {
              const sink = Pipewire.defaultAudioSink;
              if (!sink || !sink.audio) return "Volume";
              if (sink.audio.muted) return "Volume: muted";
              return "Volume: " + Math.round(sink.audio.volume * 100) + "%";
            }

            Row {
              id: volContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                  const sink = Pipewire.defaultAudioSink;
                  if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0) return "󰖁";
                  if (sink.audio.volume < 0.33) return "󰕿";
                  if (sink.audio.volume < 0.66) return "󰖀";
                  return "󰕾";
                }
                color: {
                  const sink = Pipewire.defaultAudioSink;
                  if (!sink || !sink.audio || sink.audio.muted) return root.theme.textMuted;
                  return root.theme.accentPrimary;
                }
                font.pixelSize: root.curIconSize
                font.family: root.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                  const sink = Pipewire.defaultAudioSink;
                  if (!sink || !sink.audio) return "–";
                  if (sink.audio.muted) return "Mute";
                  return Math.round(sink.audio.volume * 100) + "%";
                }
                color: root.theme.textPrimary
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                  const sink = Pipewire.defaultAudioSink;
                  if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
                } else {
                  root.volumeOpen = !root.volumeOpen;
                }
              }
              onWheel: (wheel) => {
                const sink = Pipewire.defaultAudioSink;
                if (!sink || !sink.audio) return;
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + delta));
              }
            }
          }

          // System (battery + CPU + temp + brightness bundled)
          Rectangle {
            id: sysPill
            height: root.pillHeight
            width: sysPillContent.width + 14
            radius: 12
            color: sysPillHover.containsMouse || root.systemOpen ? root.theme.bgHover : root.theme.bgSurface

            readonly property color batteryColor: {
              if (SystemInfo.batteryCharging) return root.theme.accentGreen;
              if (SystemInfo.batteryLevelRaw > 20) return root.theme.batteryGood;
              if (SystemInfo.batteryLevelRaw > 10) return root.theme.batteryWarning;
              return root.theme.batteryCritical;
            }

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              id: sysPillContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰒓"
                color: sysPillHover.containsMouse || root.systemOpen ? root.theme.accentPrimary : "#bd93f9"
                font.pixelSize: root.curIconSize + 4
                font.family: root.font
              }
            }

            MouseArea {
              id: sysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.systemOpen = !root.systemOpen
            }
          }

          // Weather
          Rectangle {
            height: root.pillHeight
            width: weatherPillContent.width + 14
            radius: 12
            color: weatherPillHover.containsMouse || root.weatherOpen ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              id: weatherPillContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherIcon
                color: root.theme.accentCyan
                font.pixelSize: root.curIconSize
                font.family: root.font
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherTemp
                color: root.theme.textPrimary
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
              }
            }

            MouseArea {
              id: weatherPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.weatherOpen = !root.weatherOpen
            }
          }

          // Networking group
          Rectangle {
            height: root.pillHeight + 4
            width: netGroup.width + 16
            radius: 14
            color: Qt.rgba(root.theme.bgSurface.r, root.theme.bgSurface.g, root.theme.bgSurface.b, 0.5)
            border.width: 1
            border.color: root.theme.bgBorder

            Row {
              id: netGroup
              anchors.centerIn: parent
              spacing: 6

          // VPN Status
          Rectangle {
            id: vpnPill
            height: root.pillHeight
            width: vpnContent.width + 14
            radius: 12
            color: vpnHover.containsMouse || root.vpnOpen ? root.theme.bgHover : root.theme.bgSurface

            property string vpnType: ""

            Behavior on color { ColorAnimation { duration: 150 } }

            Process {
              id: vpnCheck
              command: ["sh", "-c", "for tun in $(ip -o link show type tun 2>/dev/null | awk -F: '{print $2}' | tr -d ' '); do resolvectl domain $tun 2>/dev/null; done"]
              running: true
              stdout: StdioCollector {
                onStreamFinished: {
                  const out = text.toLowerCase();
                  root.vpnHasFedRAMP = out.includes("fedramp") || out.includes("openshiftusgov");
                  root.vpnHasCommercial = out.includes("redhat.com");
                  if (root.vpnHasFedRAMP && root.vpnHasCommercial) vpnPill.vpnType = "FedRAMP + Commercial";
                  else if (root.vpnHasFedRAMP) vpnPill.vpnType = "FedRAMP";
                  else if (root.vpnHasCommercial) vpnPill.vpnType = "Commercial";
                  else vpnPill.vpnType = "";
                }
              }
            }

            Process {
              id: vpnConnCheck
              command: ["sh", "-c", "nmcli -t -f NAME,TYPE con show --active | grep vpn | head -1 | cut -d: -f1"]
              running: true
              stdout: StdioCollector {
                onStreamFinished: { root.vpnConnName = text.trim(); }
              }
            }

            Timer {
              interval: 5000
              running: true
              repeat: true
              onTriggered: { vpnCheck.running = true; vpnConnCheck.running = true; vpnListProc.running = true; appgateCheckProc.running = true; }
            }

            Row {
              id: vpnContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: root.theme.accentRed
                font.pixelSize: root.curIconSize
                font.family: root.font
                visible: !vpnPill.vpnType.includes("FedRAMP")
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "🇺🇸"
                font.pixelSize: root.curTextSize
                font.family: "Noto Color Emoji"
                visible: vpnPill.vpnType.includes("FedRAMP")
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: vpnPill.vpnType || "VPN"
                color: vpnPill.vpnType !== "" ? root.theme.textPrimary : root.theme.textMuted
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
              }
            }

            MouseArea {
              id: vpnHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.vpnOpen = !root.vpnOpen
            }

          }

          // Network
          Rectangle {
            height: root.pillHeight
            width: netContent.width + 12
            radius: 12
            color: root.theme.bgSurface
            Accessible.role: Accessible.StaticText
            Accessible.name: {
              if (SystemInfo.networkType === "ethernet") return "Network: Ethernet"
              if (SystemInfo.networkType === "wifi") return "Network: WiFi " + SystemInfo.networkInfo
              return "Network: Disconnected"
            }

            Row {
              id: netContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                  if (SystemInfo.networkType === "ethernet") return "󰈀"
                  if (SystemInfo.networkType === "wifi") return "󰖩"
                  return "󰖪"
                }
                color: SystemInfo.networkType === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
                font.pixelSize: root.curIconSize
                font.family: root.font
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: SystemInfo.networkInfo
                color: root.theme.textPrimary
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
              }
            }
          }

            } // end netGroup Row
          } // end Networking group

          // System Tray
          Rectangle {
            implicitHeight: root.pillHeight
            implicitWidth: trayIcons.implicitWidth + 4
            radius: 12
            color: root.theme.bgSurface

            RowLayout {
              id: trayIcons
              anchors.centerIn: parent
              spacing: 2

              Repeater {
                model: SystemTray.items

                MouseArea {
                  id: trayDelegate
                  required property SystemTrayItem modelData

                  Accessible.role: Accessible.Button
                  Accessible.name: modelData.tooltipTitle || modelData.title || "System tray item"

                  Layout.preferredWidth: 24
                  Layout.preferredHeight: 24

                  acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                  onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                      modelData.activate()
                    } else if (mouse.button === Qt.RightButton) {
                      if (modelData.hasMenu) {
                        menuAnchor.open()
                      }
                    } else if (mouse.button === Qt.MiddleButton) {
                      modelData.secondaryActivate()
                    }
                  }

                  IconImage {
                    anchors.centerIn: parent
                    source: trayDelegate.modelData.icon
                    implicitSize: 16
                  }

                  QsMenuAnchor {
                    id: menuAnchor
                    menu: trayDelegate.modelData.menu

                    anchor.window: trayDelegate.QsWindow.window
                    anchor.adjustment: PopupAdjustment.Flip
                    anchor.onAnchoring: {
                      const window = trayDelegate.QsWindow.window;
                      const widgetRect = window.contentItem.mapFromItem(
                        trayDelegate, 0, trayDelegate.height,
                        trayDelegate.width, trayDelegate.height);
                      menuAnchor.anchor.rect = widgetRect;
                    }
                  }
                }
              }
            }
          }

          // Clipboard history
          Rectangle {
            height: root.pillHeight
            width: 32
            radius: 12
            color: clipHover.containsMouse || root.clipboardOpen ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "󰅌"
              color: clipHover.containsMouse || root.clipboardOpen ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.curIconSize
              font.family: root.font
            }

            MouseArea {
              id: clipHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (!root.clipboardOpen) {
                  clipListProc.running = true;
                } else {
                  root.clipboardOpen = false;
                }
              }
            }

            Process {
              id: clipListProc
              command: ["cliphist", "list"]
              running: false
              stdout: StdioCollector {
                onStreamFinished: {
                  const lines = text.trim().split("\n").filter(l => l.length > 0);
                  const items = [];
                  for (let i = 0; i < Math.min(lines.length, 30); i++) {
                    const tab = lines[i].indexOf("\t");
                    if (tab !== -1) {
                      items.push({
                        id: lines[i].substring(0, tab),
                        preview: lines[i].substring(tab + 1),
                        raw: lines[i]
                      });
                    }
                  }
                  root.clipboardItems = items;
                  root.clipboardOpen = true;
                }
              }
            }
          }

          // Notification bell
          Rectangle {
            id: bellPill
            height: root.pillHeight
            width: 32
            radius: 12
            color: bellHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: Notif.NotificationService.unreadCount > 0 ? "󰂚" : "󰂜"
              color: Notif.NotificationService.unreadCount > 0 ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.curIconSize
              font.family: root.font
            }

            Rectangle {
              visible: Notif.NotificationService.unreadCount > 0
              width: badgeText.width + 6
              height: 14
              radius: 7
              color: root.theme.accentRed
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.topMargin: 2
              anchors.rightMargin: 2

              Text {
                id: badgeText
                anchors.centerIn: parent
                text: Notif.NotificationService.unreadCount > 9 ? "9+" : Notif.NotificationService.unreadCount
                color: "white"
                font.pixelSize: 9
                font.family: root.font
                font.bold: true
              }
            }

            MouseArea {
              id: bellHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.historyOpen = !root.historyOpen;
                if (root.historyOpen) Notif.NotificationService.unreadCount = 0;
              }
            }
          }

          // Keybindings cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 32
            radius: 12
            color: keysPillHover.containsMouse || root.keysOpen ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "󰌌"
              color: keysPillHover.containsMouse || root.keysOpen ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.curIconSize
              font.family: root.font
            }

            MouseArea {
              id: keysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.keysOpen = !root.keysOpen
            }
          }
        }
      }

    }
  }

  // Notification history overlay
  Variants {
    model: root.historyOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-notif-history"

      Keys.onEscapePressed: root.historyOpen = false

      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        right: true
      }

      implicitWidth: 400
      implicitHeight: Math.min(historyColumn.implicitHeight + 120, 800)

      // Click outside to close
      MouseArea {
        anchors.fill: parent
        onClicked: root.historyOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 400
        height: Math.min(historyColumn.implicitHeight + 64, 740)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        Column {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 16
          spacing: 12

          // Header
          Row {
            width: parent.width
            height: root.pillHeight

            Row {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 8

              Text {
                text: "󰂚"
                color: root.theme.accentPrimary
                font.pixelSize: root.curIconSize
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Notifications"
                color: root.theme.textPrimary
                font.pixelSize: root.curTextSize
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Item { width: parent.width - 220; height: 1 }

            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 80
              height: 28
              radius: 10
              color: clearHover.containsMouse ? root.theme.accentRed : root.theme.bgSurface
              border.width: 1
              border.color: clearHover.containsMouse ? root.theme.accentRed : root.theme.bgBorder

              Behavior on color { ColorAnimation { duration: 150 } }
              Behavior on border.color { ColorAnimation { duration: 150 } }

              Text {
                anchors.centerIn: parent
                text: "Clear all"
                color: clearHover.containsMouse ? "white" : root.theme.textMuted
                font.pixelSize: 12
                font.family: root.font

                Behavior on color { ColorAnimation { duration: 150 } }
              }

              MouseArea {
                id: clearHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  Notif.NotificationService.history = [];
                  Notif.NotificationService.unreadCount = 0;
                  root.historyOpen = false;
                }
              }
            }
          }

          // Divider
          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(historyColumn.implicitHeight, 680)
            contentHeight: historyColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: historyColumn
              width: parent.width
              spacing: 8

              Text {
                visible: Notif.NotificationService.history.length === 0
                text: "No new notifications"
                color: root.theme.textMuted
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
                topPadding: 30
                bottomPadding: 30
                anchors.horizontalCenter: parent.horizontalCenter
              }

              Repeater {
                model: Notif.NotificationService.history

                Rectangle {
                  id: historyCard
                  required property var modelData
                  width: historyColumn.width
                  height: historyCardCol.implicitHeight + 20
                  radius: 10
                  color: cardHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface
                  border.width: 1
                  border.color: cardHover.containsMouse ? root.theme.bgBorder : "transparent"

                  Behavior on color { ColorAnimation { duration: 150 } }
                  Behavior on border.color { ColorAnimation { duration: 150 } }

                  // Urgency accent bar
                  Rectangle {
                    width: 3
                    height: parent.height - 12
                    radius: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: historyCard.modelData.urgency === 2 ? root.theme.accentRed :
                           historyCard.modelData.urgency === 0 ? root.theme.textMuted : root.theme.accentPrimary
                  }

                  Column {
                    id: historyCardCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 16
                    anchors.rightMargin: 10
                    anchors.topMargin: 10
                    spacing: 4

                    Text {
                      text: modelData.appName || "Notification"
                      color: root.theme.textMuted
                      font.pixelSize: 12
                      font.family: root.font
                    }

                    Text {
                      text: modelData.summary || ""
                      color: root.theme.textPrimary
                      font.pixelSize: root.curSmallTextSize
                      font.family: root.font
                      font.bold: true
                      elide: Text.ElideRight
                      width: parent.width
                    }

                    Text {
                      visible: (modelData.body || "") !== ""
                      text: modelData.body || ""
                      color: root.theme.textSecondary
                      font.pixelSize: 13
                      font.family: root.font
                      wrapMode: Text.Wrap
                      maximumLineCount: 3
                      elide: Text.ElideRight
                      width: parent.width
                    }
                  }

                  MouseArea {
                    id: cardHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.historyOpen = false
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Clipboard dropdown overlay
  Variants {
    model: root.clipboardOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-clipboard"

      Keys.onEscapePressed: root.clipboardOpen = false

      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        right: true
      }

      implicitWidth: 420
      implicitHeight: Math.min(clipColumn.implicitHeight + 120, 600)

      MouseArea {
        anchors.fill: parent
        onClicked: root.clipboardOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 400
        height: Math.min(clipColumn.implicitHeight + 64, 540)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        Column {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 16
          spacing: 12

          Row {
            width: parent.width
            height: root.pillHeight

            Row {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 8

              Text {
                text: "󰅌"
                color: root.theme.accentPrimary
                font.pixelSize: root.curIconSize
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Clipboard"
                color: root.theme.textPrimary
                font.pixelSize: root.curTextSize
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Item { width: parent.width - 200; height: 1 }

            Rectangle {
              anchors.verticalCenter: parent.verticalCenter
              width: 80
              height: 28
              radius: 10
              color: clipClearHover.containsMouse ? root.theme.accentRed : root.theme.bgSurface
              border.width: 1
              border.color: clipClearHover.containsMouse ? root.theme.accentRed : root.theme.bgBorder

              Behavior on color { ColorAnimation { duration: 150 } }
              Behavior on border.color { ColorAnimation { duration: 150 } }

              Text {
                anchors.centerIn: parent
                text: "Clear all"
                color: clipClearHover.containsMouse ? "white" : root.theme.textMuted
                font.pixelSize: 12
                font.family: root.font

                Behavior on color { ColorAnimation { duration: 150 } }
              }

              MouseArea {
                id: clipClearHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  clipWipeProc.running = true;
                  root.clipboardItems = [];
                  root.clipboardOpen = false;
                }
              }

              Process {
                id: clipWipeProc
                command: ["cliphist", "wipe"]
                running: false
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(clipColumn.implicitHeight, 440)
            contentHeight: clipColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: clipColumn
              width: parent.width
              spacing: 4

              Text {
                visible: root.clipboardItems.length === 0
                text: "Clipboard is empty"
                color: root.theme.textMuted
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
                topPadding: 30
                bottomPadding: 30
                anchors.horizontalCenter: parent.horizontalCenter
              }

              Repeater {
                model: root.clipboardItems

                Rectangle {
                  id: clipCard
                  required property var modelData
                  required property int index
                  width: clipColumn.width
                  height: clipText.implicitHeight + 16
                  radius: 8
                  color: clipCardHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface
                  border.width: 1
                  border.color: clipCardHover.containsMouse ? root.theme.bgBorder : "transparent"

                  Behavior on color { ColorAnimation { duration: 100 } }

                  Text {
                    id: clipText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    text: clipCard.modelData.preview
                    color: root.theme.textPrimary
                    font.pixelSize: 13
                    font.family: root.font
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                  }

                  MouseArea {
                    id: clipCardHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      clipDecodeProc.command = ["sh", "-c", "echo '" + clipCard.modelData.raw.replace(/'/g, "'\\''") + "' | cliphist decode | wl-copy"];
                      clipDecodeProc.running = true;
                      root.clipboardOpen = false;
                    }
                  }

                  Process {
                    id: clipDecodeProc
                    running: false
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // VPN dropdown overlay
  Variants {
    model: root.vpnOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-vpn"

      Keys.onEscapePressed: root.vpnOpen = false
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.vpnOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 480
        height: Math.min(vpnColumn.implicitHeight + 40, 600)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: vpnColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          // Header
          Row {
            spacing: 8
            Text {
              text: "󰖂"
              color: root.theme.accentGreen
              font.pixelSize: root.curIconSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "VPN Connections"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // NetworkManager VPN connections
          Flickable {
            width: parent.width
            height: Math.min(vpnListCol.implicitHeight, 400)
            contentHeight: vpnListCol.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: vpnListCol
              width: parent.width
              spacing: 4

          Repeater {
            model: root.vpnConnections

            Rectangle {
              id: vpnConnCard
              required property var modelData
              required property int index
              width: vpnListCol.width
              height: 52
              radius: 10
              color: vpnConnCardHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface

              Behavior on color { ColorAnimation { duration: 150 } }

              RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Rectangle {
                  Layout.preferredWidth: 8
                  Layout.preferredHeight: 8
                  radius: 4
                  Layout.alignment: Qt.AlignVCenter
                  color: vpnConnCard.modelData.active ? root.theme.accentGreen : root.theme.textMuted
                }

                Column {
                  Layout.fillWidth: true
                  Layout.alignment: Qt.AlignVCenter
                  spacing: 2
                  Text {
                    text: vpnConnCard.modelData.name
                    color: root.theme.textPrimary
                    font.pixelSize: 14
                    font.family: root.font
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                  }
                  Text {
                    text: vpnConnCard.modelData.active ? "Connected" : "Disconnected"
                    color: vpnConnCard.modelData.active ? root.theme.accentGreen : root.theme.textMuted
                    font.pixelSize: 12
                    font.family: root.font
                  }
                }

                Rectangle {
                  Layout.preferredWidth: vpnBtnText.width + 20
                  Layout.preferredHeight: 26
                  Layout.alignment: Qt.AlignVCenter
                  radius: 8
                  color: vpnConnCard.modelData.active ? root.theme.accentRed : root.theme.accentGreen
                  opacity: vpnBtnHover.containsMouse ? 1.0 : 0.8

                  Behavior on opacity { NumberAnimation { duration: 100 } }

                  Text {
                    id: vpnBtnText
                    anchors.centerIn: parent
                    text: vpnConnCard.modelData.active ? "Disconnect" : "Connect"
                    color: "white"
                    font.pixelSize: 11
                    font.family: root.font
                    font.bold: true
                  }

                  MouseArea {
                    id: vpnBtnHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      if (vpnConnCard.modelData.active)
                        root.vpnDisconnect(vpnConnCard.modelData.name);
                      else
                        root.vpnConnect(vpnConnCard.modelData.name);
                    }
                  }
                }
              }

              MouseArea {
                id: vpnConnCardHover
                anchors.fill: parent
                hoverEnabled: true
                z: -1
              }
            }
          }

            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // AppGate SDP
          Rectangle {
            width: parent.width
            height: 52
            radius: 10
            color: appgateCardHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: 14
              anchors.rightMargin: 14
              spacing: 10

              Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "file:///usr/share/icons/hicolor/scalable/apps/appgate-icon.svg"
                sourceSize.width: 22
                sourceSize.height: 22
                width: 22
                height: 22
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                  text: "AppGate SDP"
                  color: root.theme.textPrimary
                  font.pixelSize: 14
                  font.family: root.font
                  font.bold: true
                }
                Text {
                  text: root.vpnHasFedRAMP ? "Connected" : (root.appgateRunning ? "Running" : "Not running")
                  color: root.vpnHasFedRAMP ? root.theme.accentGreen : root.theme.textMuted
                  font.pixelSize: 12
                  font.family: root.font
                }
              }

              Item { width: parent.width - 240; height: 1 }

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: appgateBtnText.width + 20
                height: 26
                radius: 8
                color: root.theme.accentPrimary
                opacity: appgateBtnHover.containsMouse ? 1.0 : 0.8

                Behavior on opacity { NumberAnimation { duration: 100 } }

                Text {
                  id: appgateBtnText
                  anchors.centerIn: parent
                  text: "Open"
                  color: "white"
                  font.pixelSize: 11
                  font.family: root.font
                  font.bold: true
                }

                MouseArea {
                  id: appgateBtnHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.openAppgate();
                    root.vpnOpen = false;
                  }
                }
              }

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: appgateCloseBtnText.width + 20
                height: 26
                radius: 8
                color: root.theme.accentRed
                opacity: appgateCloseBtnHover.containsMouse ? 1.0 : 0.8
                visible: root.appgateRunning

                Behavior on opacity { NumberAnimation { duration: 100 } }

                Text {
                  id: appgateCloseBtnText
                  anchors.centerIn: parent
                  text: "Close"
                  color: "white"
                  font.pixelSize: 11
                  font.family: root.font
                  font.bold: true
                }

                MouseArea {
                  id: appgateCloseBtnHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    appgateCloseProc.running = true;
                    root.vpnOpen = false;
                  }
                }
              }
            }

            MouseArea {
              id: appgateCardHover
              anchors.fill: parent
              hoverEnabled: true
              z: -1
            }
          }
        }
      }
    }
  }

  // System dropdown overlay
  Variants {
    model: root.systemOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-system"

      Keys.onEscapePressed: root.systemOpen = false
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.systemOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 380
        height: sysColumn.implicitHeight + 40
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: sysColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 16

          // Header
          Row {
            spacing: 8
            Text {
              text: "󰒓"
              color: root.theme.accentPrimary
              font.pixelSize: root.curIconSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "System"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // Battery section
          Column {
            width: parent.width
            spacing: 8

            Row {
              width: parent.width
              spacing: 10

              Text {
                text: SystemInfo.batteryIcon
                color: {
                  if (SystemInfo.batteryCharging) return root.theme.accentGreen;
                  if (SystemInfo.batteryLevelRaw > 20) return root.theme.batteryGood;
                  if (SystemInfo.batteryLevelRaw > 10) return root.theme.batteryWarning;
                  return root.theme.batteryCritical;
                }
                font.pixelSize: 28
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                  text: "Battery"
                  color: root.theme.textPrimary
                  font.pixelSize: 14
                  font.family: root.font
                  font.bold: true
                }
                Text {
                  text: SystemInfo.batteryCharging ? "Charging" : "Discharging"
                  color: root.theme.textMuted
                  font.pixelSize: 12
                  font.family: root.font
                }
              }

              Item { width: 1; height: 1; Layout.fillWidth: true }

              Text {
                text: SystemInfo.batteryLevel
                color: root.theme.textPrimary
                font.pixelSize: 24
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            // Battery progress bar
            Rectangle {
              width: parent.width
              height: 6
              radius: 3
              color: root.theme.bgBorder

              Rectangle {
                width: parent.width * (SystemInfo.batteryLevelRaw / 100)
                height: parent.height
                radius: 3
                color: {
                  if (SystemInfo.batteryCharging) return root.theme.accentGreen;
                  if (SystemInfo.batteryLevelRaw > 20) return root.theme.batteryGood;
                  if (SystemInfo.batteryLevelRaw > 10) return root.theme.batteryWarning;
                  return root.theme.batteryCritical;
                }

                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // Stats row: CPU + Temp
          Row {
            width: parent.width
            spacing: 0

            // CPU
            Row {
              width: parent.width / 2
              spacing: 8

              Text {
                text: "󰻠"
                color: root.theme.accentOrange
                font.pixelSize: 18
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                  text: "CPU"
                  color: root.theme.textMuted
                  font.pixelSize: 12
                  font.family: root.font
                }
                Text {
                  text: SystemInfo.cpuUsage
                  color: root.theme.textPrimary
                  font.pixelSize: 15
                  font.family: root.font
                  font.bold: true
                }
              }
            }

            // Temperature
            Row {
              width: parent.width / 2
              spacing: 8

              Text {
                text: "󰔏"
                color: root.theme.accentRed
                font.pixelSize: 18
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                  text: "Temperature"
                  color: root.theme.textMuted
                  font.pixelSize: 12
                  font.family: root.font
                }
                Text {
                  text: SystemInfo.temperature
                  color: root.theme.textPrimary
                  font.pixelSize: 15
                  font.family: root.font
                  font.bold: true
                }
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder; visible: brightnessFile.path !== "" }

          // Brightness slider
          Column {
            width: parent.width
            spacing: 8
            visible: brightnessFile.path !== ""

            Row {
              spacing: 8
              Text {
                text: "󰃠"
                color: root.theme.accentOrange
                font.pixelSize: 18
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Brightness"
                color: root.theme.textMuted
                font.pixelSize: 12
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }
              Item { width: 1; height: 1 }
              Text {
                text: Math.round(root.brightnessValue * 100) + "%"
                color: root.theme.textPrimary
                font.pixelSize: 14
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }

            Slider {
              id: sysBrightSlider
              width: parent.width
              from: 0
              to: 1.0
              value: root.brightnessValue
              onMoved: {
                const pct = Math.round(value * 100);
                brightnessSetProc.command = ["brightnessctl", "set", pct + "%"];
                brightnessSetProc.running = true;
              }

              background: Rectangle {
                x: sysBrightSlider.leftPadding
                y: sysBrightSlider.topPadding + sysBrightSlider.availableHeight / 2 - height / 2
                width: sysBrightSlider.availableWidth
                height: 6
                radius: 3
                color: root.theme.bgBorder

                Rectangle {
                  width: sysBrightSlider.visualPosition * parent.width
                  height: parent.height
                  radius: 3
                  color: root.theme.accentOrange
                }
              }

              handle: Rectangle {
                x: sysBrightSlider.leftPadding + sysBrightSlider.visualPosition * (sysBrightSlider.availableWidth - width)
                y: sysBrightSlider.topPadding + sysBrightSlider.availableHeight / 2 - height / 2
                width: 16
                height: 16
                radius: 8
                color: sysBrightSlider.pressed ? root.theme.accentCyan : root.theme.accentOrange
              }
            }
          }
        }
      }
    }
  }

  // Weather dropdown overlay
  Variants {
    model: root.weatherOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-weather"

      Keys.onEscapePressed: root.weatherOpen = false
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.weatherOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 340
        height: weatherColumn.implicitHeight + 40
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: weatherColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          // Header
          Row {
            spacing: 8
            Text {
              text: root.weatherIcon
              color: root.theme.accentCyan
              font.pixelSize: root.curIconSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Weather"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // Current conditions
          Row {
            width: parent.width
            spacing: 14

            Text {
              text: root.weatherIcon
              color: root.theme.accentCyan
              font.pixelSize: 42
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2

              Text {
                text: root.weatherTemp
                color: root.theme.textPrimary
                font.pixelSize: 28
                font.family: root.font
                font.bold: true
              }

              Text {
                text: root.weatherDesc
                color: root.theme.textSecondary
                font.pixelSize: 13
                font.family: root.font
              }
            }
          }

          // Details
          Row {
            width: parent.width
            spacing: 0

            Column {
              width: parent.width / 2
              spacing: 4
              Row {
                spacing: 6
                Text { text: "Feels like"; color: root.theme.textMuted; font.pixelSize: 12; font.family: root.font }
                Text { text: root.weatherFeelsLike; color: root.theme.textPrimary; font.pixelSize: 12; font.family: root.font; font.bold: true }
              }
              Row {
                spacing: 6
                Text { text: "Humidity"; color: root.theme.textMuted; font.pixelSize: 12; font.family: root.font }
                Text { text: root.weatherHumidity; color: root.theme.textPrimary; font.pixelSize: 12; font.family: root.font; font.bold: true }
              }
            }

            Column {
              width: parent.width / 2
              spacing: 4
              Row {
                spacing: 6
                Text { text: "Wind"; color: root.theme.textMuted; font.pixelSize: 12; font.family: root.font }
                Text { text: root.weatherWind; color: root.theme.textPrimary; font.pixelSize: 12; font.family: root.font; font.bold: true }
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // Forecast
          Column {
            width: parent.width
            spacing: 6

            Text {
              text: "Forecast"
              color: root.theme.textMuted
              font.pixelSize: 12
              font.family: root.font
              font.bold: true
            }

            Repeater {
              model: root.weatherForecast

              Rectangle {
                required property var modelData
                width: weatherColumn.width - 40
                height: 36
                radius: 8
                color: root.theme.bgSurface

                Row {
                  anchors.fill: parent
                  anchors.leftMargin: 10
                  anchors.rightMargin: 10
                  spacing: 8

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                      const parts = modelData.date.split("-");
                      const d = parts.length === 3 ? parts[1] + "/" + parts[2] : modelData.date;
                      return d;
                    }
                    color: root.theme.textSecondary
                    font.pixelSize: 12
                    font.family: root.font
                    width: 40
                  }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.desc
                    color: root.theme.textPrimary
                    font.pixelSize: 12
                    font.family: root.font
                    elide: Text.ElideRight
                    width: parent.width - 130
                  }

                  Item { width: 1; height: 1 }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.high + " / " + modelData.low
                    color: root.theme.textPrimary
                    font.pixelSize: 12
                    font.family: root.font
                    font.bold: true
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Volume dropdown overlay
  Variants {
    model: root.volumeOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-volume"

      exclusionMode: ExclusionMode.Ignore

      Keys.onEscapePressed: root.volumeOpen = false

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 130

      MouseArea {
        anchors.fill: parent
        onClicked: root.volumeOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: parent.width * 0.35
        width: 320
        height: 70
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder

        Row {
          anchors.centerIn: parent
          anchors.margins: 16
          spacing: 12

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
              const sink = Pipewire.defaultAudioSink;
              if (!sink || !sink.audio || sink.audio.muted || sink.audio.volume <= 0) return "󰖁";
              if (sink.audio.volume < 0.33) return "󰕿";
              if (sink.audio.volume < 0.66) return "󰖀";
              return "󰕾";
            }
            color: {
              const sink = Pipewire.defaultAudioSink;
              if (!sink || !sink.audio || sink.audio.muted) return root.theme.textMuted;
              return root.theme.accentPrimary;
            }
            font.pixelSize: 22
            font.family: root.font

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                const sink = Pipewire.defaultAudioSink;
                if (sink && sink.audio) sink.audio.muted = !sink.audio.muted;
              }
            }
          }

          Slider {
            id: volDropSlider
            anchors.verticalCenter: parent.verticalCenter
            width: 200
            from: 0
            to: 1.0
            value: {
              const sink = Pipewire.defaultAudioSink;
              return (sink && sink.audio) ? sink.audio.volume : 0;
            }
            onMoved: {
              const sink = Pipewire.defaultAudioSink;
              if (sink && sink.audio) sink.audio.volume = value;
            }

            background: Rectangle {
              x: volDropSlider.leftPadding
              y: volDropSlider.topPadding + volDropSlider.availableHeight / 2 - height / 2
              width: volDropSlider.availableWidth
              height: 6
              radius: 3
              color: root.theme.bgBorder

              Rectangle {
                width: volDropSlider.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: root.theme.accentPrimary
              }
            }

            handle: Rectangle {
              x: volDropSlider.leftPadding + volDropSlider.visualPosition * (volDropSlider.availableWidth - width)
              y: volDropSlider.topPadding + volDropSlider.availableHeight / 2 - height / 2
              width: 18
              height: 18
              radius: 9
              color: volDropSlider.pressed ? root.theme.accentCyan : root.theme.accentPrimary
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: {
              const sink = Pipewire.defaultAudioSink;
              if (!sink || !sink.audio) return "–";
              if (sink.audio.muted) return "Mute";
              return Math.round(sink.audio.volume * 100) + "%";
            }
            color: root.theme.textPrimary
            font.pixelSize: root.curTextSize
            font.family: root.font
            font.bold: true
          }
        }
      }
    }
  }

  // Keybindings dropdown overlay
  Variants {
    model: root.keysOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
      WlrLayershell.namespace: "quickshell-keybindings"

      Keys.onEscapePressed: root.keysOpen = false

      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: root.keysOpen = false
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 400
        height: Math.min(keysColumn.implicitHeight + 64, 640)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 16
          spacing: 12

          Row {
            width: parent.width
            height: root.pillHeight

            Row {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 8

              Text {
                text: "󰌌"
                color: root.theme.accentPrimary
                font.pixelSize: root.curIconSize
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Keybindings"
                color: root.theme.textPrimary
                font.pixelSize: root.curTextSize
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(keysColumn.implicitHeight, 540)
            contentHeight: keysColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: keysColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.keybindings

                Column {
                  required property var modelData
                  width: keysColumn.width
                  spacing: 6

                  Text {
                    text: modelData.category
                    color: root.theme.accentCyan
                    font.pixelSize: root.curSmallTextSize
                    font.family: root.font
                    font.bold: true
                  }

                  Repeater {
                    model: modelData.bindings

                    Rectangle {
                      required property var modelData
                      width: keysColumn.width
                      height: 32
                      radius: 8
                      property bool hovered: false
                      color: hovered ? root.theme.bgHover : root.theme.bgSurface

                      Behavior on color { ColorAnimation { duration: 100 } }

                      Row {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                          anchors.verticalCenter: parent.verticalCenter
                          width: 150
                          text: modelData.key
                          color: root.theme.accentPrimary
                          font.pixelSize: 12
                          font.family: root.font
                          font.bold: true
                          elide: Text.ElideRight
                        }

                        Text {
                          anchors.verticalCenter: parent.verticalCenter
                          width: parent.width - 162
                          text: modelData.desc
                          color: root.theme.textPrimary
                          font.pixelSize: 13
                          font.family: root.font
                          elide: Text.ElideRight
                        }
                      }

                      MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
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
