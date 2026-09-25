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
import Quickshell.Networking
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
  readonly property bool historyOpen: panelCoordinator.isOpen("notifications")
  readonly property bool volumeOpen: panelCoordinator.isOpen("volume")
  property real volumeAnchorCenterX: 0
  readonly property bool clipboardOpen: panelCoordinator.isOpen("clipboard")
  property var clipboardItems: []
  property bool keysOpen: false
  property var keybindings: []
  property bool nvimKeysOpen: false
  property var nvimKeybindings: []
  property bool tmuxKeysOpen: false
  property var tmuxKeybindings: []
  property bool ghosttyKeysOpen: false
  property var ghosttyKeybindings: []
  readonly property color ghosttyAccent: "#bd93f9"
  property bool shellAliasesOpen: false
  property var shellAliases: []
  readonly property color shellAliasAccent: root.theme.accentRed
  property bool kubeCommandsOpen: false
  property var kubeCommands: []
  readonly property color kubeAccent: "#326ce5"
  property bool codexCommandsOpen: false
  property var codexCommands: []
  readonly property color codexAccent: "#10a37f"
  property bool claudeCommandsOpen: false
  property var claudeCommands: []
  readonly property color claudeAccent: "#d97757"
  property bool helpersPinned: false
  readonly property bool systemOpen: panelCoordinator.isOpen("system")
  readonly property bool vpnOpen: panelCoordinator.isOpen("vpn")
  property string vpnConnName: ""
  property bool vpnHasFedRAMP: false
  property bool vpnHasCommercial: false
  property bool netbirdConnected: false
  property var vpnConnections: []
  property bool appgateRunning: false
  property string weatherTemp: "--"
  property string weatherIcon: "󰖐"
  property string weatherLocation: "Zelienople, PA • 16063"
  property string weatherDesc: ""
  property string weatherFeelsLike: ""
  property string weatherHumidity: ""
  property string weatherWind: ""
  property var weatherForecast: []

  signal vpnRefreshRequested()

  PanelCoordinator {
    id: panelCoordinator
  }

  function closeBarDropdowns() {
    closeHelperPanels();
    panelCoordinator.close();
    networkPanel.open = false;
    bluetoothPanel.open = false;
  }

  function toggleDropdown(name) {
    const opening = !panelCoordinator.isOpen(name);
    closeBarDropdowns();
    if (opening) panelCoordinator.open(name);
  }

  function toggleCalendarPanel() {
    if (!clockPanels.calendarOpen) closeBarDropdowns();
    clockPanels.toggleCalendar();
  }

  function toggleWorldClocksPanel() {
    if (!clockPanels.worldClocksOpen) closeBarDropdowns();
    clockPanels.toggleWorldClocks();
  }

  function handleHelperOutsideClick(x, y) {
    root.closeHelperPanels();
  }

  function closeHelperPanels() {
    root.keysOpen = false;
    root.nvimKeysOpen = false;
    root.tmuxKeysOpen = false;
    root.ghosttyKeysOpen = false;
    root.kubeCommandsOpen = false;
    root.codexCommandsOpen = false;
    root.claudeCommandsOpen = false;
    root.shellAliasesOpen = false;
    root.helpersPinned = false;
  }

  function toggleHelperPanel(name) {
    panelCoordinator.close();
    networkPanel.open = false;
    bluetoothPanel.open = false;
    // Selecting a helper pins the expanded selector. Selecting another helper
    // replaces the panel; only Escape or an outside click closes the selector.
    root.keysOpen = false;
    root.nvimKeysOpen = false;
    root.tmuxKeysOpen = false;
    root.ghosttyKeysOpen = false;
    root.kubeCommandsOpen = false;
    root.codexCommandsOpen = false;
    root.claudeCommandsOpen = false;
    root.shellAliasesOpen = false;
    root.helpersPinned = true;

    if (name === "hyprland") root.keysOpen = true;
    else if (name === "nvim") root.nvimKeysOpen = true;
    else if (name === "tmux") root.tmuxKeysOpen = true;
    else if (name === "ghostty") root.ghosttyKeysOpen = true;
    else if (name === "kube") root.kubeCommandsOpen = true;
    else if (name === "codex") root.codexCommandsOpen = true;
    else if (name === "claude") root.claudeCommandsOpen = true;
    else if (name === "aliases") root.shellAliasesOpen = true;
  }

  ClockPanels {
    id: clockPanels
    coordinator: panelCoordinator
    theme: root.theme
    barScreen: root.barScreen
    font: root.font
    barHeight: root.barHeight
  }

  NetworkPanel {
    id: networkPanel
    theme: root.theme
    barScreen: root.barScreen
    font: root.font
    iconSize: root.curIconSize
    textSize: root.curTextSize
    smallTextSize: root.curSmallTextSize
  }

  Connections {
    target: networkPanel
    function onOpenChanged(): void {
      if (networkPanel.open) panelCoordinator.open("network");
      else panelCoordinator.close("network");
    }
  }

  BluetoothPanel {
    id: bluetoothPanel
    theme: root.theme
    barScreen: root.barScreen
    font: root.font
    iconSize: root.curIconSize
    textSize: root.curTextSize
    smallTextSize: root.curSmallTextSize
  }

  Connections {
    target: bluetoothPanel
    function onOpenChanged(): void {
      if (bluetoothPanel.open) panelCoordinator.open("bluetooth");
      else panelCoordinator.close("bluetooth");
    }
  }

  CommandListPanel {
    open: root.kubeCommandsOpen
    barScreen: root.barScreen
    commands: root.kubeCommands
    theme: root.theme
    font: root.font
    title: "OpenShift & Kubernetes Commands"
    subtitle: "(oc / kubectl)"
    icon: "󱃾"
    accent: root.kubeAccent
    iconSize: root.curIconSize
    textSize: root.curTextSize
    smallTextSize: root.curSmallTextSize
    barHeight: root.barHeight
    onCloseRequested: root.closeHelperPanels()
  }

  CommandListPanel {
    open: root.codexCommandsOpen
    barScreen: root.barScreen
    commands: root.codexCommands
    theme: root.theme
    font: root.font
    title: "Codex CLI & Slash Commands"
    subtitle: "(codex / …)"
    icon: "󰚩"
    accent: root.codexAccent
    iconSize: root.curIconSize
    textSize: root.curTextSize
    smallTextSize: root.curSmallTextSize
    barHeight: root.barHeight
    onCloseRequested: root.closeHelperPanels()
  }

  CommandListPanel {
    open: root.claudeCommandsOpen
    barScreen: root.barScreen
    commands: root.claudeCommands
    theme: root.theme
    font: root.font
    title: "Claude Code CLI & Slash Commands"
    subtitle: "(claude / …)"
    icon: "✦"
    accent: root.claudeAccent
    iconSize: root.curIconSize
    textSize: root.curTextSize
    smallTextSize: root.curSmallTextSize
    barHeight: root.barHeight
    onCloseRequested: root.closeHelperPanels()
  }

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
    function volume_toggle(): void { root.toggleDropdown("volume"); }
    function clipboard_toggle(): void {
      if (!root.clipboardOpen) {
        root.closeBarDropdowns();
        clipListIpcProc.running = true;
      } else {
        panelCoordinator.close("clipboard");
      }
    }
    function calendar_toggle(): void { root.toggleCalendarPanel(); }
    function world_clocks_toggle(): void { root.toggleWorldClocksPanel(); }
    function network_toggle(): void {
      const opening = !networkPanel.open;
      root.closeBarDropdowns();
      bluetoothPanel.open = false;
      if (opening) networkPanel.open = true;
    }
    function keys_toggle(): void { root.toggleHelperPanel("hyprland"); }
    function nvim_keys_toggle(): void { root.toggleHelperPanel("nvim"); }
    function tmux_keys_toggle(): void { root.toggleHelperPanel("tmux"); }
    function ghostty_keys_toggle(): void { root.toggleHelperPanel("ghostty"); }
    function shell_aliases_toggle(): void { root.toggleHelperPanel("aliases"); }
    function kube_commands_toggle(): void { root.toggleHelperPanel("kube"); }
    function codex_commands_toggle(): void { root.toggleHelperPanel("codex"); }
    function claude_commands_toggle(): void { root.toggleHelperPanel("claude"); }
    function helpers_close(): void { root.closeHelperPanels(); }
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

  FileView {
    id: nvimKeybindingsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/nvim-keybindings.json"
    watchChanges: true
    onTextChanged: {
      const raw = nvimKeybindingsFile.text();
      if (!raw) return;
      try {
        root.nvimKeybindings = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse nvim-keybindings.json:", e);
      }
    }
  }

  FileView {
    id: tmuxKeybindingsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/tmux-keybindings.json"
    watchChanges: true
    onTextChanged: {
      const raw = tmuxKeybindingsFile.text();
      if (!raw) return;
      try {
        root.tmuxKeybindings = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse tmux-keybindings.json:", e);
      }
    }
  }

  FileView {
    id: ghosttyKeybindingsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/ghostty-keybindings.json"
    watchChanges: true
    onTextChanged: {
      const raw = ghosttyKeybindingsFile.text();
      if (!raw) return;
      try {
        root.ghosttyKeybindings = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse ghostty-keybindings.json:", e);
      }
    }
  }

  FileView {
    id: shellAliasesFile
    path: Quickshell.env("HOME") + "/.config/quickshell/shell-aliases.json"
    watchChanges: true
    onTextChanged: {
      const raw = shellAliasesFile.text();
      if (!raw) return;
      try {
        root.shellAliases = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse shell-aliases.json:", e);
      }
    }
  }

  FileView {
    id: kubeCommandsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/kube-commands.json"
    watchChanges: true
    onTextChanged: {
      const raw = kubeCommandsFile.text();
      if (!raw) return;
      try {
        root.kubeCommands = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse kube-commands.json:", e);
      }
    }
  }

  FileView {
    id: codexCommandsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/codex-commands.json"
    watchChanges: true
    onTextChanged: {
      const raw = codexCommandsFile.text();
      if (!raw) return;
      try {
        root.codexCommands = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse codex-commands.json:", e);
      }
    }
  }

  FileView {
    id: claudeCommandsFile
    path: Quickshell.env("HOME") + "/.config/quickshell/claude-commands.json"
    watchChanges: true
    onTextChanged: {
      const raw = claudeCommandsFile.text();
      if (!raw) return;
      try {
        root.claudeCommands = JSON.parse(raw);
      } catch (e) {
        console.error("Failed to parse claude-commands.json:", e);
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
        panelCoordinator.open("clipboard");
      }
    }
  }

  readonly property var outputSinks: {
    const nodes = Pipewire.nodes ? Pipewire.nodes.values : [];
    const sinks = [];
    for (let i = 0; i < nodes.length; i++) {
      const node = nodes[i];
      if (node && node.isSink && !node.isStream) sinks.push(node);
    }
    return sinks;
  }

  // Keep the default output plus every currently connected Bluetooth output.
  // Bluetooth sink nodes exist only while their devices are connected, avoiding
  // a list full of inactive HDMI and dock profiles.
  readonly property var connectedOutputSinks: {
    const result = [];
    const defaultSink = Pipewire.defaultAudioSink;
    if (defaultSink) result.push(defaultSink);
    for (let i = 0; i < outputSinks.length; i++) {
      const node = outputSinks[i];
      const name = String(node.name || "");
      if (name.startsWith("bluez_output.") && node !== defaultSink) result.push(node);
    }
    return result;
  }

  PwObjectTracker {
    objects: root.outputSinks
  }

  // Quickshell's PipeWire volume setter does not currently commit changes on
  // this system, so serialize writes through wpctl while retaining the native
  // PipeWire model for live state and device updates.
  property real pendingOutputVolume: 0
  property string pendingOutputTarget: "@DEFAULT_AUDIO_SINK@"
  property bool outputVolumePending: false

  function requestOutputVolume(value, target) {
    pendingOutputVolume = Math.max(0, Math.min(1, value));
    pendingOutputTarget = target === undefined || target === null
                          ? "@DEFAULT_AUDIO_SINK@" : String(target);
    outputVolumePending = true;
    if (!outputVolumeSetProc.running) outputVolumeFlushTimer.restart();
  }

  function flushOutputVolume() {
    if (!outputVolumePending || outputVolumeSetProc.running) return;
    outputVolumeSetProc.command = ["wpctl", "set-volume", pendingOutputTarget,
                                   pendingOutputVolume.toFixed(4)];
    outputVolumePending = false;
    outputVolumeSetProc.running = true;
  }

  function toggleOutputMute(target) {
    const output = target === undefined || target === null
                   ? "@DEFAULT_AUDIO_SINK@" : String(target);
    Quickshell.execDetached(["wpctl", "set-mute", output, "toggle"]);
  }

  function unmuteOutput(target) {
    const output = target === undefined || target === null
                   ? "@DEFAULT_AUDIO_SINK@" : String(target);
    Quickshell.execDetached(["wpctl", "set-mute", output, "0"]);
  }

  Timer {
    id: outputVolumeFlushTimer
    interval: 1
    onTriggered: root.flushOutputVolume()
  }

  Process {
    id: outputVolumeSetProc
    running: false
    onExited: function(code) {
      if (root.outputVolumePending) outputVolumeFlushTimer.restart();
    }
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

  function openAppgate() { appgateToggleProc.running = true; }

  Process {
    id: appgateCloseProc
    command: ["sh", "-c", "hyprctl eval 'hl.dsp.window.close({ class = \"appgate\" })' 2>/dev/null; pkill -f appgate-ui 2>/dev/null; sudo systemctl stop appgatedriver"]
    running: false
    onExited: { root.appgateRunning = false; }
  }

  Process {
    id: appgateToggleProc
    command: ["sh", "-c", "sudo systemctl start appgatedriver 2>/dev/null; pgrep -x appgate-ui > /dev/null && hyprctl eval 'hl.dsp.focus({ class = \"appgate\" })' || uwsm app -- appgate"]
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
        conns.push({ name: "Commercial (NetBird)", active: root.netbirdConnected, netbird: true });
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
    onExited: {
      vpnListProc.running = true;
      root.vpnRefreshRequested();
    }
  }

  function vpnConnect(name) { vpnToggleProc.command = ["nmcli", "con", "up", name]; vpnToggleProc.running = true; }
  function vpnDisconnect(name) { vpnToggleProc.command = ["nmcli", "con", "down", name]; vpnToggleProc.running = true; }
  function netbirdConnect() { vpnToggleProc.command = ["netbird", "up"]; vpnToggleProc.running = true; }
  function netbirdDisconnect() { vpnToggleProc.command = ["netbird", "down"]; vpnToggleProc.running = true; }

  Process {
    id: weatherFetchProc
    command: ["curl", "-sf", "https://wttr.in/16063,USA?format=j1"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const data = JSON.parse(text);
          const cur = data.current_condition[0];
          const area = data.nearest_area && data.nearest_area[0];
          if (area) {
            const town = area.areaName && area.areaName[0] ? area.areaName[0].value : "Zelienople";
            const region = area.region && area.region[0] ? area.region[0].value : "Pennsylvania";
            const regionLabel = region === "Pennsylvania" ? "PA" : region;
            root.weatherLocation = town + ", " + regionLabel + " • 16063";
          }
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
                visible: !(modelData.name && modelData.name.startsWith("special:"))

                Accessible.role: Accessible.Button
                Accessible.name: "Workspace " + modelData.id + (modelData.focused ? ", active" : "") + (modelData.urgent ? ", urgent" : "")

                width: Math.max(modelData.focused ? root.pillHeight : root.pillHeight - 4, wsLabel.implicitWidth + 16)
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
                  id: wsLabel
                  anchors.centerIn: parent
                  text: wsPill.modelData.name && wsPill.modelData.name.startsWith("special:") ? wsPill.modelData.name.substring(8) : wsPill.modelData.id
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
            id: barDateText
            anchors.verticalCenter: parent.verticalCenter
            text: Time.dateString
            color: barDateMouse.containsMouse || clockPanels.calendarOpen ? root.theme.accentCyan : root.theme.textSecondary
            font.pixelSize: root.curTextSize
            font.family: root.font

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
              id: barDateMouse
              anchors.fill: parent
              anchors.margins: -5
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleCalendarPanel()
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.timeString
            color: root.theme.textPrimary
            font.pixelSize: root.curTextSize
            font.family: root.font
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.timeZoneString
            color: root.theme.accentCyan
            font.pixelSize: root.curSmallTextSize
            font.family: root.font
            font.bold: true
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "•"
            color: root.theme.textMuted
            font.pixelSize: root.curSmallTextSize
            font.family: root.font
          }

          Text {
            id: utcClockText
            anchors.verticalCenter: parent.verticalCenter
            text: Time.utcTimeString + " UTC"
            color: utcClockMouse.containsMouse || clockPanels.worldClocksOpen ? root.theme.accentCyan : root.theme.textSecondary
            font.pixelSize: root.curSmallTextSize
            font.family: root.font

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
              id: utcClockMouse
              anchors.fill: parent
              anchors.margins: -5
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleWorldClocksPanel()
            }
          }
        }

        // Right section: System Info + System Tray
        Row {
          id: rightSection
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter
          spacing: 10

          // Right-side controls are instantiated in five semantic groups below.

          // Volume is instantiated beside Bluetooth below.
          Component {
            id: volumePillComponent

            Rectangle {
            id: volumePill
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
                  if (sink && sink.audio) root.toggleOutputMute();
                } else {
                  const position = volumePill.mapToItem(null, 0, 0);
                  root.volumeAnchorCenterX = position.x + volumePill.width / 2;
                  root.toggleDropdown("volume");
                }
              }
              onWheel: (wheel) => {
                const sink = Pipewire.defaultAudioSink;
                if (!sink || !sink.audio) return;
                const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                root.requestOutputVolume(Math.max(0, Math.min(1, sink.audio.volume + delta)));
              }
            }
          }
          }

          // System is instantiated at the far right below.
          Component {
            id: systemPillComponent

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
              onClicked: root.toggleDropdown("system")
            }
          }
          }

          // Networking is instantiated beside System at the far right below.
          Component {
            id: networkingGroupComponent

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

            function updateVpnType() {
              if (root.vpnHasFedRAMP && root.vpnHasCommercial) vpnType = "FedRAMP + Commercial";
              else if (root.vpnHasFedRAMP) vpnType = "FedRAMP";
              else if (root.vpnHasCommercial) vpnType = "Commercial";
              else vpnType = "";
            }

            Behavior on color { ColorAnimation { duration: 150 } }

            Process {
              id: vpnCheck
              command: ["sh", "-c", "for tun in $(ip -o link show type tun 2>/dev/null | awk -F: '{print $2}' | tr -d ' '); do resolvectl domain $tun 2>/dev/null; done"]
              running: true
              stdout: StdioCollector {
                onStreamFinished: {
                  const out = text.toLowerCase();
                  root.vpnHasFedRAMP = out.includes("fedramp") || out.includes("openshiftusgov");
                  root.vpnHasCommercial = out.includes("redhat.com") || root.netbirdConnected;
                  vpnPill.updateVpnType();
                }
              }
            }

            Process {
              id: netbirdCheck
              command: ["netbird", "status", "--json"]
              running: true
              stdout: StdioCollector {
                onStreamFinished: {
                  try {
                    root.netbirdConnected = JSON.parse(text).daemonStatus === "Connected";
                  } catch (e) {
                    root.netbirdConnected = false;
                  }
                  root.vpnHasCommercial = root.vpnHasCommercial || root.netbirdConnected;
                  vpnPill.updateVpnType();
                  if (root.vpnOpen) vpnListProc.running = true;
                }
              }
              onExited: function(code) {
                if (code !== 0) {
                  root.netbirdConnected = false;
                  vpnCheck.running = true;
                  if (root.vpnOpen) vpnListProc.running = true;
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

            Connections {
              target: root
              function onVpnRefreshRequested() {
                vpnCheck.running = true;
                netbirdCheck.running = true;
                vpnConnCheck.running = true;
                if (root.vpnOpen) {
                  vpnListProc.running = true;
                  appgateCheckProc.running = true;
                }
              }
              function onVpnOpenChanged() {
                if (root.vpnOpen) root.vpnRefreshRequested();
              }
            }

            Timer {
              interval: root.vpnOpen ? 5000 : 30000
              running: true
              repeat: true
              onTriggered: {
                vpnCheck.running = true;
                netbirdCheck.running = true;
                vpnConnCheck.running = true;
                if (root.vpnOpen) {
                  vpnListProc.running = true;
                  appgateCheckProc.running = true;
                }
              }
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
              onClicked: root.toggleDropdown("vpn")
            }

          }

          // Network
          Rectangle {
            height: root.pillHeight
            width: netContent.width + 12
            radius: 12
            color: networkPillHover.containsMouse || networkPanel.open ? root.theme.bgHover : root.theme.bgSurface
            Accessible.role: Accessible.Button
            Accessible.name: "Network: " + networkPanel.label

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              id: netContent
              anchors.centerIn: parent
              spacing: 6

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: networkPanel.icon
                color: networkPanel.kind === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
                font.pixelSize: root.curIconSize
                font.family: root.font
              }
              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: networkPanel.label
                color: root.theme.textPrimary
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
              }
            }

            MouseArea {
              id: networkPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                const opening = !networkPanel.open;
                root.closeBarDropdowns();
                bluetoothPanel.open = false;
                if (opening) networkPanel.open = true;
              }
            }
          }

            } // end netGroup Row
          } // end Networking group
          }

          // Bluetooth
          Component {
            id: bluetoothPillComponent

            Rectangle {
            id: bluetoothPill
            height: root.pillHeight
            width: 32
            radius: 12
            color: bluetoothHover.containsMouse || bluetoothPanel.open ? root.theme.bgHover : root.theme.bgSurface

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: bluetoothPanel.icon
              color: bluetoothPanel.adapter && bluetoothPanel.adapter.enabled ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.curIconSize
              font.family: root.font
            }

            Rectangle {
              visible: bluetoothPanel.connectedCount > 0
              width: bluetoothBadgeText.width + 6
              height: 14
              radius: 7
              color: root.theme.accentGreen
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.topMargin: 2
              anchors.rightMargin: 2

              Text {
                id: bluetoothBadgeText
                anchors.centerIn: parent
                text: bluetoothPanel.connectedCount > 9 ? "9+" : bluetoothPanel.connectedCount
                color: root.theme.bgBase
                font.pixelSize: 9
                font.family: root.font
                font.bold: true
              }
            }

            MouseArea {
              id: bluetoothHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton && bluetoothPanel.adapter)
                  bluetoothPanel.adapter.enabled = !bluetoothPanel.adapter.enabled;
                else {
                  const opening = !bluetoothPanel.open;
                  if (opening) root.closeBarDropdowns();
                  bluetoothPanel.open = opening;
                }
              }
            }
          }
          }

          // System Tray
          Component {
            id: trayComponent

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

                  readonly property bool hidden: modelData.id === "blueman" || modelData.id === "nm-applet" || modelData.id === "NetBird"

                  Accessible.role: Accessible.Button
                  Accessible.name: modelData.tooltipTitle || modelData.title || "System tray item"

                  visible: !hidden
                  Layout.preferredWidth: hidden ? 0 : 24
                  Layout.preferredHeight: hidden ? 0 : 24

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
          }

          // Clipboard history
          Component {
            id: clipboardPillComponent

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
                  root.closeBarDropdowns();
                  clipListProc.running = true;
                } else {
                  panelCoordinator.close("clipboard");
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
                  panelCoordinator.open("clipboard");
                }
              }
            }
          }
          }

          // Notification bell is instantiated beside System at the far right.
          Component {
            id: notificationPillComponent

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
              color: bellHover.containsMouse ? root.theme.accentCyan : root.theme.accentOrange
              font.pixelSize: root.curIconSize
              font.family: root.font

              Behavior on color { ColorAnimation { duration: 150 } }
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
                root.toggleDropdown("notifications");
                if (root.historyOpen) Notif.NotificationService.unreadCount = 0;
              }
            }
          }
          }

          // Keybinding helpers are instantiated first in this row above.
          Component {
            id: keybindingHelpersComponent

            Rectangle {
            id: keybindingHelpers
            property bool hoverExpanded: false
            property bool expanded: hoverExpanded
                                    || root.helpersPinned
                                    || root.keysOpen
                                    || root.nvimKeysOpen
                                    || root.tmuxKeysOpen
                                    || root.ghosttyKeysOpen
                                    || root.kubeCommandsOpen
                                    || root.codexCommandsOpen
                                    || root.claudeCommandsOpen
                                    || root.shellAliasesOpen
            height: root.pillHeight + 4
            width: keybindingsGroup.width + 12
            radius: 14
            color: Qt.rgba(root.theme.bgSurface.r, root.theme.bgSurface.g, root.theme.bgSurface.b, 0.5)
            border.width: 1
            border.color: keybindingHelpers.expanded ? root.theme.accentPrimary : root.theme.bgBorder

            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            HoverHandler {
              id: helperGroupHover
              cursorShape: Qt.PointingHandCursor
              onHoveredChanged: {
                if (hovered) {
                  helperCollapseTimer.stop();
                  helperExpandTimer.restart();
                } else {
                  helperExpandTimer.stop();
                  helperCollapseTimer.restart();
                }
              }
            }

            Timer {
              id: helperExpandTimer
              interval: 300
              onTriggered: keybindingHelpers.hoverExpanded = true
            }

            Timer {
              id: helperCollapseTimer
              interval: 550
              onTriggered: keybindingHelpers.hoverExpanded = false
            }

            Row {
              id: keybindingsGroup
              anchors.centerIn: parent
              spacing: 5

              Rectangle {
                width: 54
                height: root.pillHeight
                radius: 12
                color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b,
                               keybindingHelpers.expanded ? 0.28 : 0.16)
                border.width: 1
                border.color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b,
                                      keybindingHelpers.expanded ? 0.90 : 0.60)

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Row {
                  anchors.centerIn: parent
                  anchors.horizontalCenterOffset: -2
                  spacing: 4

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: keybindingHelpers.expanded ? "" : ""
                    color: root.theme.accentCyan
                    font.pixelSize: root.curIconSize + 2
                    font.family: root.font
                    font.bold: true
                  }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: root.theme.accentCyan
                    font.pixelSize: root.curIconSize + 1
                    font.family: root.font
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    helperExpandTimer.stop();
                    helperCollapseTimer.stop();
                    if (keybindingHelpers.expanded) {
                      keybindingHelpers.hoverExpanded = false;
                      root.closeHelperPanels();
                    } else {
                      root.closeBarDropdowns();
                      root.helpersPinned = true;
                      keybindingHelpers.hoverExpanded = true;
                    }
                  }
                }
              }

              Row {
                visible: keybindingHelpers.expanded
                spacing: 5

          // Hyprland keybindings cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b,
                           keysPillHover.containsMouse || root.keysOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b,
                                  keysPillHover.containsMouse || root.keysOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: ""
              color: root.theme.accentCyan
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: keysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("hyprland")
            }
          }

          // Neovim keybindings cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.theme.accentGreen.r, root.theme.accentGreen.g, root.theme.accentGreen.b,
                           nvimKeysPillHover.containsMouse || root.nvimKeysOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.theme.accentGreen.r, root.theme.accentGreen.g, root.theme.accentGreen.b,
                                  nvimKeysPillHover.containsMouse || root.nvimKeysOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: ""
              color: root.theme.accentGreen
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: nvimKeysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("nvim")
            }
          }

          // tmux keybindings cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.theme.accentOrange.r, root.theme.accentOrange.g, root.theme.accentOrange.b,
                           tmuxKeysPillHover.containsMouse || root.tmuxKeysOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.theme.accentOrange.r, root.theme.accentOrange.g, root.theme.accentOrange.b,
                                  tmuxKeysPillHover.containsMouse || root.tmuxKeysOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: ""
              color: root.theme.accentOrange
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: tmuxKeysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("tmux")
            }
          }

          // Ghostty keybindings cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.ghosttyAccent.r, root.ghosttyAccent.g, root.ghosttyAccent.b,
                           ghosttyKeysPillHover.containsMouse || root.ghosttyKeysOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.ghosttyAccent.r, root.ghosttyAccent.g, root.ghosttyAccent.b,
                                  ghosttyKeysPillHover.containsMouse || root.ghosttyKeysOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            IconImage {
              anchors.centerIn: parent
              source: Quickshell.iconPath("com.mitchellh.ghostty")
              implicitSize: root.curIconSize + 2
            }

            MouseArea {
              id: ghosttyKeysPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("ghostty")
            }
          }

          // Codex CLI command reference
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.codexAccent.r, root.codexAccent.g, root.codexAccent.b,
                           codexCommandsPillHover.containsMouse || root.codexCommandsOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.codexAccent.r, root.codexAccent.g, root.codexAccent.b,
                                  codexCommandsPillHover.containsMouse || root.codexCommandsOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "󰚩"
              color: root.codexAccent
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: codexCommandsPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("codex")
            }
          }

          // Claude Code CLI and slash-command reference
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.claudeAccent.r, root.claudeAccent.g, root.claudeAccent.b,
                           claudeCommandsPillHover.containsMouse || root.claudeCommandsOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.claudeAccent.r, root.claudeAccent.g, root.claudeAccent.b,
                                  claudeCommandsPillHover.containsMouse || root.claudeCommandsOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "✦"
              color: root.claudeAccent
              font.pixelSize: root.curIconSize + 2
              font.family: root.font
              font.bold: true
            }

            MouseArea {
              id: claudeCommandsPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("claude")
            }
          }

          // OpenShift and Kubernetes command reference
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.kubeAccent.r, root.kubeAccent.g, root.kubeAccent.b,
                           kubeCommandsPillHover.containsMouse || root.kubeCommandsOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.kubeAccent.r, root.kubeAccent.g, root.kubeAccent.b,
                                  kubeCommandsPillHover.containsMouse || root.kubeCommandsOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "󱃾"
              color: root.kubeAccent
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: kubeCommandsPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("kube")
            }
          }

          // Shell aliases cheat sheet
          Rectangle {
            height: root.pillHeight
            width: 34
            radius: 12
            color: Qt.rgba(root.shellAliasAccent.r, root.shellAliasAccent.g, root.shellAliasAccent.b,
                           shellAliasesPillHover.containsMouse || root.shellAliasesOpen ? 0.24 : 0.10)
            border.width: 1
            border.color: Qt.rgba(root.shellAliasAccent.r, root.shellAliasAccent.g, root.shellAliasAccent.b,
                                  shellAliasesPillHover.containsMouse || root.shellAliasesOpen ? 0.75 : 0.35)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: ""
              color: root.shellAliasAccent
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
            }

            MouseArea {
              id: shellAliasesPillHover
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: root.toggleHelperPanel("aliases")
            }
          }

              } // end expanded helpers
            } // end keybindingsGroup
          } // end keybinding cheat sheets
          }

          // Utilities: reference helpers and clipboard history.
          Rectangle {
            height: root.pillHeight + 4
            width: utilityGroup.width + 16
            radius: 14
            color: Qt.rgba(root.theme.bgSurface.r, root.theme.bgSurface.g, root.theme.bgSurface.b, 0.5)
            border.width: 1
            border.color: root.theme.bgBorder

            Row {
              id: utilityGroup
              anchors.centerIn: parent
              spacing: 6

              Loader { sourceComponent: keybindingHelpersComponent }
              Loader { sourceComponent: clipboardPillComponent }
            }
          }

          // Background application controls.
          Loader { sourceComponent: trayComponent }

          // Network connectivity: VPN and Wi-Fi.
          Loader { sourceComponent: networkingGroupComponent }

          // Headset/device and audio controls.
          Rectangle {
            height: root.pillHeight + 4
            width: audioGroup.width + 16
            radius: 14
            color: Qt.rgba(root.theme.bgSurface.r, root.theme.bgSurface.g, root.theme.bgSurface.b, 0.5)
            border.width: 1
            border.color: root.theme.bgBorder

            Row {
              id: audioGroup
              anchors.centerIn: parent
              spacing: 6

              Loader { sourceComponent: bluetoothPillComponent }
              Loader { sourceComponent: volumePillComponent }
            }
          }

          // General desktop status and administration at the far-right edge.
          Rectangle {
            height: root.pillHeight + 4
            width: statusGroup.width + 16
            radius: 14
            color: Qt.rgba(root.theme.bgSurface.r, root.theme.bgSurface.g, root.theme.bgSurface.b, 0.5)
            border.width: 1
            border.color: root.theme.bgBorder

            Row {
              id: statusGroup
              anchors.centerIn: parent
              spacing: 6

              Loader { sourceComponent: notificationPillComponent }
              Loader { sourceComponent: systemPillComponent }
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

      Shortcut { sequence: "Escape"; onActivated: panelCoordinator.close("notifications") }

      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      // Click outside to close
      MouseArea {
        anchors.fill: parent
        onClicked: panelCoordinator.close("notifications")
      }

      Rectangle {
        id: historyPanel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 440
        height: Math.min(historyPanelContent.implicitHeight + 40, 740)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.95)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        // Consume unused panel space without dismissing the dropdown.
        MouseArea {
          anchors.fill: parent
          onClicked: {}
        }

        Column {
          id: historyPanelContent
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          // Header
          RowLayout {
            width: parent.width
            height: 34
            spacing: 10

            Text {
              text: "󰂚"
              color: root.theme.accentPrimary
              font.pixelSize: root.curIconSize + 2
              font.family: root.font
              Layout.alignment: Qt.AlignVCenter
            }

            Text {
              text: "Notifications"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            Rectangle {
              Layout.preferredWidth: 82
              Layout.preferredHeight: 28
              Layout.alignment: Qt.AlignVCenter
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
                  panelCoordinator.close("notifications");
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
            height: Math.min(historyColumn.implicitHeight, 620)
            contentHeight: historyColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: historyColumn
              width: parent.width
              spacing: 10

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
                  height: historyCardCol.implicitHeight + 28
                  radius: 10
                  color: cardHover.containsMouse ? root.theme.bgHover : root.theme.bgSurface
                  border.width: 1
                  border.color: cardHover.containsMouse ? root.theme.bgBorder : "transparent"

                  Behavior on color { ColorAnimation { duration: 150 } }
                  Behavior on border.color { ColorAnimation { duration: 150 } }

                  // Urgency accent bar
                  Rectangle {
                    width: 3
                    height: parent.height - 16
                    radius: 2
                    anchors.left: parent.left
                    anchors.leftMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    color: historyCard.modelData.urgency === 2 ? root.theme.accentRed :
                           historyCard.modelData.urgency === 0 ? root.theme.textMuted : root.theme.accentPrimary
                  }

                  Column {
                    id: historyCardCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    anchors.rightMargin: 14
                    anchors.topMargin: 14
                    spacing: 6

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
                    onClicked: panelCoordinator.close("notifications")
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

      Shortcut { sequence: "Escape"; onActivated: panelCoordinator.close("clipboard") }

      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: panelCoordinator.close("clipboard")
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

        // Consume clicks inside the dropdown; the full-window MouseArea behind
        // it closes the clipboard only when the click is outside this card.
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
                  panelCoordinator.close("clipboard");
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
                      panelCoordinator.close("clipboard");
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

      Shortcut { sequence: "Escape"; onActivated: panelCoordinator.close("vpn") }
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: panelCoordinator.close("vpn")
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
                      if (vpnConnCard.modelData.netbird) {
                        if (vpnConnCard.modelData.active)
                          root.netbirdDisconnect();
                        else
                          root.netbirdConnect();
                      } else if (vpnConnCard.modelData.active) {
                        root.vpnDisconnect(vpnConnCard.modelData.name);
                      } else {
                        root.vpnConnect(vpnConnCard.modelData.name);
                      }
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
                    panelCoordinator.close("vpn");
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
                    panelCoordinator.close("vpn");
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

      Shortcut { sequence: "Escape"; onActivated: panelCoordinator.close("system") }
      exclusionMode: ExclusionMode.Ignore

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: panelCoordinator.close("system")
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

          // Defined here and placed below the system statistics.
          Component {
            id: systemWeatherComponent

            Column {
            width: parent.width
            spacing: 10

            Row {
              width: parent.width
              spacing: 8

              Text {
                id: systemWeatherHeaderIcon
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherIcon
                color: root.theme.accentCyan
                font.pixelSize: 17
                font.family: root.font
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - systemWeatherHeaderIcon.width - parent.spacing
                text: "Weather  •  " + root.weatherLocation
                elide: Text.ElideRight
                color: root.theme.textPrimary
                font.pixelSize: 14
                font.family: root.font
                font.bold: true
              }
            }

            Row {
              width: parent.width
              spacing: 12

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.weatherIcon
                color: root.theme.accentCyan
                font.pixelSize: 36
                font.family: root.font
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                  text: root.weatherTemp + "  " + root.weatherDesc
                  color: root.theme.textPrimary
                  font.pixelSize: 17
                  font.family: root.font
                  font.bold: true
                }

                Text {
                  text: "Feels " + root.weatherFeelsLike + "  •  Humidity " + root.weatherHumidity + "  •  Wind " + root.weatherWind
                  color: root.theme.textMuted
                  font.pixelSize: 11
                  font.family: root.font
                }
              }
            }

            Repeater {
              model: root.weatherForecast

              Rectangle {
                required property var modelData
                width: sysColumn.width
                height: 30
                radius: 7
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
                      return parts.length === 3 ? parts[1] + "/" + parts[2] : modelData.date;
                    }
                    color: root.theme.textSecondary
                    font.pixelSize: 11
                    font.family: root.font
                    width: 42
                  }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.desc
                    color: root.theme.textPrimary
                    font.pixelSize: 11
                    font.family: root.font
                    elide: Text.ElideRight
                    width: parent.width - 142
                  }

                  Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.high + " / " + modelData.low
                    color: root.theme.textPrimary
                    font.pixelSize: 11
                    font.family: root.font
                    font.bold: true
                  }
                }
              }
            }
          }
          }

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

          // Stats row: CPU + memory + temperature
          Row {
            width: parent.width
            spacing: 0

            // CPU
            Row {
              width: parent.width / 3
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

            // Memory
            Row {
              width: parent.width / 3
              spacing: 8

              Text {
                text: "󰍛"
                color: root.theme.accentCyan
                font.pixelSize: 18
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                  text: "Memory"
                  color: root.theme.textMuted
                  font.pixelSize: 12
                  font.family: root.font
                }
                Text {
                  text: SystemInfo.memoryUsage
                  color: root.theme.textPrimary
                  font.pixelSize: 15
                  font.family: root.font
                  font.bold: true
                }
              }
            }

            // Temperature
            Row {
              width: parent.width / 3
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

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          // Weather summary and forecast
          Loader {
            width: parent.width
            sourceComponent: systemWeatherComponent
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

      Shortcut { sequence: "Escape"; onActivated: panelCoordinator.close("volume") }

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: panelCoordinator.close("volume")
      }

      Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 54
        anchors.leftMargin: Math.max(10, Math.min(parent.width - width - 10,
                                                  root.volumeAnchorCenterX - width / 2))
        width: 400
        height: volumeColumn.implicitHeight + 40
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.96)
        border.width: 1
        border.color: root.theme.bgBorder

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: volumeColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          Row {
            width: parent.width
            height: root.pillHeight
            spacing: 10

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
                return !sink || !sink.audio || sink.audio.muted ? root.theme.textMuted : root.theme.accentPrimary;
              }
              font.pixelSize: root.curIconSize + 2
              font.family: root.font
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - 44
              spacing: 1

              Text {
                text: "Volume"
                color: root.theme.textPrimary
                font.pixelSize: root.curTextSize
                font.family: root.font
                font.bold: true
              }

              Text {
                width: parent.width
                text: {
                  const sink = Pipewire.defaultAudioSink;
                  if (!sink) return "No output device";
                  return sink.description || sink.nickname || sink.name || "Unknown output device";
                }
                color: root.theme.textMuted
                font.pixelSize: 11
                font.family: root.font
                elide: Text.ElideRight
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Column {
            width: parent.width
            spacing: 14

            Text {
              visible: root.connectedOutputSinks.length === 0
              text: "No connected audio outputs"
              color: root.theme.textMuted
              font.pixelSize: 12
              font.family: root.font
            }

            Repeater {
              model: root.connectedOutputSinks

              Column {
                required property var modelData
                required property int index
                width: parent.width
                spacing: 14

                OutputDeviceSlider {
                  width: parent.width
                  node: modelData
                  theme: root.theme
                  font: root.font
                  iconSize: root.curIconSize
                  textSize: root.curTextSize
                  isDefault: modelData === Pipewire.defaultAudioSink
                  onVolumeRequested: function(value) {
                    root.requestOutputVolume(value, modelData.id);
                    if (modelData.audio && modelData.audio.muted && value > 0)
                      root.unmuteOutput(modelData.id);
                  }
                  onMuteRequested: root.toggleOutputMute(modelData.id)
                }

                Rectangle {
                  visible: index < root.connectedOutputSinks.length - 1
                  width: parent.width
                  height: 1
                  color: root.theme.bgBorder
                }
              }
            }
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
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-keybindings"

      Shortcut { sequence: "Escape"; onActivated: root.closeHelperPanels() }

      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => root.handleHelperOutsideClick(mouse.x, mouse.y)
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
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
                text: ""
                color: root.theme.accentCyan
                font.pixelSize: root.curIconSize + 1
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Hyprland Keybindings"
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

  // Shell aliases dropdown overlay
  Variants {
    model: root.shellAliasesOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-shell-aliases"

      Shortcut { sequence: "Escape"; onActivated: root.closeHelperPanels() }
      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => root.handleHelperOutsideClick(mouse.x, mouse.y)
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 440
        height: Math.min(shellAliasesColumn.implicitHeight + 64, 700)
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
            spacing: 8

            Text {
              text: ""
              color: root.shellAliasAccent
              font.pixelSize: root.curIconSize + 2
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "Shell Aliases"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "(~/.aliases)"
              color: root.theme.textMuted
              font.pixelSize: root.curSmallTextSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(shellAliasesColumn.implicitHeight, 600)
            contentHeight: shellAliasesColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: shellAliasesColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.shellAliases

                Column {
                  required property var modelData
                  width: shellAliasesColumn.width
                  spacing: 6

                  Text {
                    text: modelData.category
                    color: root.shellAliasAccent
                    font.pixelSize: root.curSmallTextSize
                    font.family: root.font
                    font.bold: true
                  }

                  Repeater {
                    model: modelData.bindings

                    Rectangle {
                      required property var modelData
                      width: shellAliasesColumn.width
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
                          width: 105
                          text: modelData.key
                          color: root.shellAliasAccent
                          font.pixelSize: 12
                          font.family: root.font
                          font.bold: true
                          elide: Text.ElideRight
                        }

                        Text {
                          anchors.verticalCenter: parent.verticalCenter
                          width: parent.width - 117
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

  // Ghostty keybindings dropdown overlay
  Variants {
    model: root.ghosttyKeysOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-ghostty-keybindings"

      Shortcut { sequence: "Escape"; onActivated: root.closeHelperPanels() }
      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => root.handleHelperOutsideClick(mouse.x, mouse.y)
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 400
        height: Math.min(ghosttyKeysColumn.implicitHeight + 64, 640)
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
            spacing: 8

            IconImage {
              source: Quickshell.iconPath("com.mitchellh.ghostty")
              implicitSize: root.curIconSize + 3
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "Ghostty Keybindings"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "(defaults)"
              color: root.theme.textMuted
              font.pixelSize: root.curSmallTextSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(ghosttyKeysColumn.implicitHeight, 540)
            contentHeight: ghosttyKeysColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: ghosttyKeysColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.ghosttyKeybindings

                Column {
                  required property var modelData
                  width: ghosttyKeysColumn.width
                  spacing: 6

                  Text {
                    text: modelData.category
                    color: root.ghosttyAccent
                    font.pixelSize: root.curSmallTextSize
                    font.family: root.font
                    font.bold: true
                  }

                  Repeater {
                    model: modelData.bindings

                    Rectangle {
                      required property var modelData
                      width: ghosttyKeysColumn.width
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
                          color: root.ghosttyAccent
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

  // tmux keybindings dropdown overlay
  Variants {
    model: root.tmuxKeysOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-tmux-keybindings"

      Shortcut { sequence: "Escape"; onActivated: root.closeHelperPanels() }
      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => root.handleHelperOutsideClick(mouse.x, mouse.y)
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 400
        height: Math.min(tmuxKeysColumn.implicitHeight + 64, 640)
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
            spacing: 8

            Text {
              text: ""
              color: root.theme.accentOrange
              font.pixelSize: root.curIconSize + 1
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "tmux Keybindings"
              color: root.theme.textPrimary
              font.pixelSize: root.curTextSize
              font.family: root.font
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: "(prefix = Ctrl+A)"
              color: root.theme.textMuted
              font.pixelSize: root.curSmallTextSize
              font.family: root.font
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.theme.bgBorder
          }

          Flickable {
            width: parent.width
            height: Math.min(tmuxKeysColumn.implicitHeight, 540)
            contentHeight: tmuxKeysColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: tmuxKeysColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.tmuxKeybindings

                Column {
                  required property var modelData
                  width: tmuxKeysColumn.width
                  spacing: 6

                  Text {
                    text: modelData.category
                    color: root.theme.accentOrange
                    font.pixelSize: root.curSmallTextSize
                    font.family: root.font
                    font.bold: true
                  }

                  Repeater {
                    model: modelData.bindings

                    Rectangle {
                      required property var modelData
                      width: tmuxKeysColumn.width
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
                          color: root.theme.accentOrange
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

  // Neovim keybindings dropdown overlay
  Variants {
    model: root.nvimKeysOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-nvim-keybindings"

      Shortcut { sequence: "Escape"; onActivated: root.closeHelperPanels() }

      exclusionMode: ExclusionMode.Ignore
      implicitHeight: modelData.height - root.barHeight

      anchors {
        bottom: true
        left: true
        right: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => root.handleHelperOutsideClick(mouse.x, mouse.y)
      }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 10
        width: 400
        height: Math.min(nvimKeysColumn.implicitHeight + 64, 640)
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
                text: ""
                color: root.theme.accentGreen
                font.pixelSize: root.curIconSize + 1
                font.family: root.font
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "Neovim Keybindings"
                color: root.theme.textPrimary
                font.pixelSize: root.curTextSize
                font.family: root.font
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
              }

              Text {
                text: "(leader = ;)"
                color: root.theme.textMuted
                font.pixelSize: root.curSmallTextSize
                font.family: root.font
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
            height: Math.min(nvimKeysColumn.implicitHeight, 540)
            contentHeight: nvimKeysColumn.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: nvimKeysColumn
              width: parent.width
              spacing: 16

              Repeater {
                model: root.nvimKeybindings

                Column {
                  required property var modelData
                  width: nvimKeysColumn.width
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
                      width: nvimKeysColumn.width
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
