import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Scope {
  id: root

  required property var theme
  required property var barScreen
  required property string font
  required property int iconSize
  required property int textSize
  required property int smallTextSize

  property bool open: false
  property var wifiNetworks: []
  property string passwordSsid: ""
  property string passwordText: ""
  property string identityText: ""
  property string actionSsid: ""
  property string failureSsid: ""
  property string failureReason: ""

  readonly property bool networkManagerAvailable: Networking.backend === NetworkBackendType.NetworkManager
  readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
  readonly property var wifiDevice: findDevice(DeviceType.Wifi)
  readonly property var wiredDevice: findDevice(DeviceType.Wired)
  readonly property var wifiNetworkObjects: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
  readonly property var connectedWifiNetwork: findConnectedWifiNetwork()
  readonly property string kind: wiredDevice && wiredDevice.connected ? "ethernet" : connectedWifiNetwork ? "wifi" : "disconnected"
  readonly property string label: kind === "ethernet" ? "Ethernet" : connectedWifiNetwork ? connectedWifiNetwork.name : "Disconnected"
  readonly property int signalStrength: connectedWifiNetwork ? Math.round((connectedWifiNetwork.signalStrength || 0) * 100) : -1
  readonly property string icon: kind === "ethernet" ? "󰈀" : kind === "wifi" ? signalIcon(signalStrength) : "󰤮"
  readonly property bool captivePortal: Networking.connectivity === NetworkConnectivity.Portal

  function findDevice(type): var {
    const devices = networkDevices || [];
    for (let i = 0; i < devices.length; i++)
      if (devices[i] && devices[i].type === type) return devices[i];
    return null;
  }

  function findConnectedWifiNetwork(): var {
    const networks = wifiNetworkObjects || [];
    for (let i = 0; i < networks.length; i++)
      if (networks[i] && networks[i].connected) return networks[i];
    return null;
  }

  function networkForSsid(ssid): var {
    const networks = wifiNetworkObjects || [];
    for (let i = 0; i < networks.length; i++)
      if (networks[i] && networks[i].name === ssid) return networks[i];
    return null;
  }

  function signalIcon(strength): string {
    if (strength >= 80) return "󰤨";
    if (strength >= 60) return "󰤥";
    if (strength >= 40) return "󰤢";
    if (strength >= 20) return "󰤟";
    return "󰤯";
  }

  function securityLabel(security): string {
    if (security === WifiSecurityType.Open) return "Open";
    if (security === WifiSecurityType.Owe) return "Enhanced Open";
    if (security === WifiSecurityType.Wpa2Eap || security === WifiSecurityType.WpaEap) return "Enterprise";
    if (security === WifiSecurityType.Sae) return "WPA3";
    if (security === WifiSecurityType.Wpa2Psk) return "WPA2";
    if (security === WifiSecurityType.WpaPsk) return "WPA";
    return "Secured";
  }

  function requiresCredentials(security): bool {
    return security !== WifiSecurityType.Open && security !== WifiSecurityType.Owe;
  }

  function isEnterprise(security): bool {
    return security === WifiSecurityType.Wpa2Eap || security === WifiSecurityType.WpaEap;
  }

  // Keep only primitive snapshots in the repeater. NetworkManager can destroy
  // live access-point objects while a scan is refreshing the list.
  function syncWifiNetworks(): void {
    const bySsid = {};
    const networks = wifiNetworkObjects || [];
    for (let i = 0; i < networks.length; i++) {
      const network = networks[i];
      if (!network || !network.name) continue;
      const row = {
        ssid: network.name,
        connected: !!network.connected,
        known: !!network.known,
        signal: Math.round((network.signalStrength || 0) * 100),
        security: network.security
      };
      const previous = bySsid[row.ssid];
      if (!previous || row.connected || (!previous.connected && row.known && !previous.known) ||
          (row.connected === previous.connected && row.known === previous.known && row.signal > previous.signal))
        bySsid[row.ssid] = row;
    }

    const rows = Object.keys(bySsid).map(key => bySsid[key]);
    rows.sort((a, b) => {
      if (a.connected !== b.connected) return a.connected ? -1 : 1;
      if (a.known !== b.known) return a.known ? -1 : 1;
      return b.signal - a.signal;
    });
    wifiNetworks = rows;
  }

  function clearPrompt(): void {
    passwordSsid = "";
    passwordText = "";
    identityText = "";
  }

  function openPasswordPrompt(ssid): void {
    if (passwordSsid !== ssid) {
      passwordText = "";
      identityText = "";
    }
    passwordSsid = ssid;
    failureSsid = "";
    failureReason = "";
  }

  function activateNetwork(row): void {
    if (!row || actionSsid !== "") return;
    const network = networkForSsid(row.ssid);
    if (!network) return;

    failureSsid = "";
    failureReason = "";
    if (network.connected) {
      actionSsid = row.ssid;
      network.disconnect();
      actionTimeout.restart();
    } else if (requiresCredentials(network.security) && !network.known) {
      openPasswordPrompt(row.ssid);
    } else {
      actionSsid = row.ssid;
      network.connect();
      actionTimeout.restart();
    }
  }

  function submitPassword(row): void {
    if (!row || !passwordText || actionSsid !== "") return;
    const network = networkForSsid(row.ssid);
    if (!network) return;

    actionSsid = row.ssid;
    failureSsid = "";
    failureReason = "";
    if (isEnterprise(network.security)) {
      if (!identityText) {
        actionSsid = "";
        failureSsid = row.ssid;
        failureReason = "Identity required";
        return;
      }
      enterpriseConnect.secret = passwordText;
      enterpriseConnect.command = ["bash", "-c", enterpriseConnectScript, "nmcli-eap", row.ssid, identityText];
      enterpriseConnect.running = true;
    } else {
      network.connectWithPsk(passwordText);
    }
    passwordText = "";
    actionTimeout.restart();
  }

  function forgetNetwork(ssid): void {
    if (actionSsid !== "") return;
    const network = networkForSsid(ssid);
    if (!network || network.connected) return;
    actionSsid = ssid;
    network.forget();
    actionTimeout.restart();
  }

  function connectionFailed(ssid, reason): void {
    actionTimeout.stop();
    actionSsid = "";
    failureSsid = ssid;
    if (reason === ConnectionFailReason.NoSecrets) failureReason = "Passphrase required";
    else if (reason === ConnectionFailReason.WifiAuthTimeout) failureReason = "Wrong password";
    else if (reason === ConnectionFailReason.WifiNetworkLost) failureReason = "Network lost";
    else failureReason = "Connection failed";
    const network = networkForSsid(ssid);
    if (network && requiresCredentials(network.security) &&
        (reason === ConnectionFailReason.NoSecrets || reason === ConnectionFailReason.WifiAuthTimeout))
      openPasswordPrompt(ssid);
    Qt.callLater(syncWifiNetworks);
  }

  function togglePanel(): void { open = !open; }

  function setScanning(enabled): void {
    if (wifiDevice) wifiDevice.scannerEnabled = enabled;
  }

  onOpenChanged: {
    if (open) {
      syncWifiNetworks();
      setScanning(true);
      Networking.checkConnectivity();
    } else {
      setScanning(false);
      clearPrompt();
    }
  }
  onWifiDeviceChanged: { setScanning(open); syncWifiNetworks(); }
  onWifiNetworkObjectsChanged: Qt.callLater(syncWifiNetworks)

  Component.onCompleted: syncWifiNetworks()
  Component.onDestruction: setScanning(false)

  // Native NetworkManager model changes drive updates. This one-shot refresh
  // only lets the initial scan settle after opening the panel.
  Timer {
    id: scanSettle
    interval: 1200
    repeat: false
    running: root.open
    onTriggered: root.syncWifiNetworks()
  }

  Timer {
    id: actionTimeout
    interval: 15000
    repeat: false
    onTriggered: {
      if (root.actionSsid !== "") {
        root.failureSsid = root.actionSsid;
        root.failureReason = "Operation timed out";
        root.actionSsid = "";
        root.syncWifiNetworks();
      }
    }
  }

  readonly property string enterpriseConnectScript:
    "u=$(uuidgen); IFS= read -r pw;" +
    " nmcli connection add type wifi con-name \"$1\" ssid \"$1\" connection.uuid \"$u\"" +
    " wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2" +
    " 802-1x.identity \"$2\" 802-1x.auth-timeout 8 >/dev/null" +
    " && printf 'set 802-1x.password %s\\nsave\\nquit\\n' \"$pw\" | nmcli connection edit uuid \"$u\" >/dev/null" +
    " && nmcli connection up uuid \"$u\"" +
    " || { nmcli connection delete uuid \"$u\" >/dev/null 2>&1; false; }"

  Process {
    id: enterpriseConnect
    property string secret: ""
    stdinEnabled: true
    onStarted: {
      write(secret + "\n");
      secret = "";
    }
    onExited: function(code) {
      if (code !== 0) {
        root.failureSsid = root.actionSsid;
        root.failureReason = "Enterprise connection failed";
        root.actionSsid = "";
      }
      Qt.callLater(root.syncWifiNetworks);
    }
  }

  Process {
    id: captivePortalProc
    command: ["uwsm", "app", "--", "google-chrome-stable", "--profile-directory=Profile 1", "http://nmcheck.gnome.org/"]
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
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-network"
      exclusionMode: ExclusionMode.Ignore

      Shortcut { sequence: "Escape"; onActivated: root.open = false }
      anchors { top: true; bottom: true; left: true; right: true }

      MouseArea { anchors.fill: parent; onClicked: root.open = false }

      Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 54
        anchors.rightMargin: 10
        width: 430
        height: Math.min(networkColumn.implicitHeight + 40, 650)
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.96)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: networkColumn
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 14

          RowLayout {
            width: parent.width
            height: 38
            spacing: 10

            Text {
              text: root.icon
              color: root.kind === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
              font.pixelSize: root.iconSize + 3
              font.family: root.font
              Layout.alignment: Qt.AlignVCenter
            }

            Column {
              Layout.fillWidth: true
              Layout.alignment: Qt.AlignVCenter
              spacing: 1
              Text { text: "Network"; color: root.theme.textPrimary; font.pixelSize: root.textSize; font.family: root.font; font.bold: true }
              Text {
                text: root.kind === "wifi" ? root.label + "  •  " + root.signalStrength + "%" : root.label
                color: root.kind === "disconnected" ? root.theme.textMuted : root.theme.accentGreen
                font.pixelSize: 11
                font.family: root.font
              }
            }

            Rectangle {
              Layout.preferredWidth: 48
              Layout.preferredHeight: 26
              Layout.alignment: Qt.AlignVCenter
              radius: 13
              color: Networking.wifiEnabled ? root.theme.accentPrimary : root.theme.bgBorder
              opacity: wifiPowerHover.containsMouse ? 1 : 0.85
              Rectangle {
                width: 20; height: 20; radius: 10
                anchors.verticalCenter: parent.verticalCenter
                x: Networking.wifiEnabled ? parent.width - width - 3 : 3
                color: root.theme.textPrimary
                Behavior on x { NumberAnimation { duration: 150 } }
              }
              MouseArea {
                id: wifiPowerHover
                anchors.fill: parent
                enabled: root.networkManagerAvailable && root.wifiDevice !== null
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Rectangle {
            visible: root.captivePortal
            width: parent.width
            height: visible ? 38 : 0
            radius: 9
            color: Qt.rgba(root.theme.accentOrange.r, root.theme.accentOrange.g, root.theme.accentOrange.b, 0.14)
            border.width: 1
            border.color: root.theme.accentOrange
            Text { anchors.centerIn: parent; text: "Sign in to this network"; color: root.theme.accentOrange; font.pixelSize: 12; font.family: root.font; font.bold: true }
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: { captivePortalProc.running = true; root.open = false; }
            }
          }

          Item {
            width: parent.width
            height: 22
            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: root.wifiDevice && root.wifiDevice.scannerEnabled ? "Wi-Fi networks  •  Scanning…" : "Wi-Fi networks"
              color: root.wifiDevice && root.wifiDevice.scannerEnabled ? root.theme.accentCyan : root.theme.textMuted
              font.pixelSize: 12
              font.family: root.font
              font.bold: true
            }
            Text {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              visible: Networking.wifiEnabled && root.wifiDevice !== null
              text: "󰑓"
              color: scanHover.containsMouse ? root.theme.accentPrimary : root.theme.textMuted
              font.pixelSize: root.iconSize
              font.family: root.font
              MouseArea {
                id: scanHover
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.setScanning(false); scanRestart.restart(); }
              }
            }
          }

          Timer {
            id: scanRestart
            interval: 100
            onTriggered: root.setScanning(true)
          }

          Flickable {
            width: parent.width
            height: Math.min(wifiList.implicitHeight, 470)
            contentHeight: wifiList.implicitHeight
            clip: true
            boundsMovement: Flickable.StopAtBounds

            Column {
              id: wifiList
              width: parent.width
              spacing: 6

              Text {
                visible: !root.networkManagerAvailable || !root.wifiDevice || !Networking.wifiEnabled
                width: parent.width
                topPadding: 28
                bottomPadding: 28
                horizontalAlignment: Text.AlignHCenter
                text: !root.networkManagerAvailable ? "NetworkManager is unavailable" : !root.wifiDevice ? "No Wi-Fi adapter found" : "Turn Wi-Fi on to see networks"
                color: root.theme.textMuted
                font.pixelSize: root.smallTextSize
                font.family: root.font
              }

              Text {
                visible: root.networkManagerAvailable && root.wifiDevice && Networking.wifiEnabled && root.wifiNetworks.length === 0
                width: parent.width
                topPadding: 28
                bottomPadding: 28
                horizontalAlignment: Text.AlignHCenter
                text: "Looking for nearby networks…"
                color: root.theme.textMuted
                font.pixelSize: root.smallTextSize
                font.family: root.font
              }

              Repeater {
                model: root.wifiNetworks

                Rectangle {
                  id: networkCard
                  required property var modelData
                  readonly property var liveNetwork: root.networkForSsid(modelData.ssid)
                  readonly property bool connected: liveNetwork ? liveNetwork.connected : modelData.connected
                  readonly property bool known: liveNetwork ? liveNetwork.known : modelData.known
                  readonly property bool busy: root.actionSsid === modelData.ssid || (liveNetwork && liveNetwork.stateChanging)
                  readonly property bool promptOpen: root.passwordSsid === modelData.ssid
                  readonly property bool enterprise: root.isEnterprise(modelData.security)
                  readonly property color stateColor: connected ? root.theme.accentGreen : known ? root.theme.accentOrange : root.theme.accentPrimary

                  width: wifiList.width
                  height: 58 + (promptOpen ? (enterprise ? 112 : 78) : 0)
                  radius: 10
                  color: networkHover.containsMouse ? root.theme.bgHover : Qt.rgba(stateColor.r, stateColor.g, stateColor.b, 0.09)
                  border.width: connected ? 2 : 1
                  border.color: stateColor

                  Behavior on height { NumberAnimation { duration: 130 } }
                  Behavior on color { ColorAnimation { duration: 120 } }

                  RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    height: 58
                    spacing: 10

                    Text { text: root.signalIcon(modelData.signal); color: networkCard.stateColor; font.pixelSize: root.iconSize; font.family: root.font; Layout.alignment: Qt.AlignVCenter }

                    Column {
                      Layout.fillWidth: true
                      Layout.alignment: Qt.AlignVCenter
                      spacing: 2
                      Text { width: parent.width; text: modelData.ssid; color: root.theme.textPrimary; font.pixelSize: 13; font.family: root.font; font.bold: true; elide: Text.ElideRight }
                      Text {
                        text: {
                          if (networkCard.busy) return networkCard.connected ? "Disconnecting…" : "Connecting…";
                          if (root.failureSsid === modelData.ssid) return root.failureReason;
                          if (networkCard.connected) return "Connected  •  " + modelData.signal + "%";
                          return (networkCard.known ? "Known" : root.securityLabel(modelData.security)) + "  •  " + modelData.signal + "%";
                        }
                        color: root.failureSsid === modelData.ssid ? root.theme.accentRed : networkCard.stateColor
                        font.pixelSize: 11
                        font.family: root.font
                      }
                    }

                    Rectangle {
                      Layout.preferredWidth: networkActionText.implicitWidth + 18
                      Layout.preferredHeight: 26
                      radius: 8
                      color: networkCard.connected ? root.theme.accentGreen : networkCard.known ? root.theme.accentOrange : root.theme.accentPrimary
                      opacity: networkCard.busy ? 0.55 : networkActionHover.containsMouse ? 1 : 0.82
                      Text {
                        id: networkActionText
                        anchors.centerIn: parent
                        text: networkCard.busy ? (networkCard.connected ? "Disconnecting…" : "Connecting…") : networkCard.connected ? "Disconnect" : "Connect"
                        color: "white"; font.pixelSize: 11; font.family: root.font; font.bold: true
                      }
                      MouseArea {
                        id: networkActionHover
                        anchors.fill: parent
                        enabled: !networkCard.busy
                        hoverEnabled: true
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: root.activateNetwork(networkCard.modelData)
                      }
                    }

                    Rectangle {
                      visible: networkCard.known && !networkCard.connected
                      Layout.preferredWidth: visible ? 26 : 0
                      Layout.preferredHeight: 26
                      radius: 8
                      color: forgetHover.containsMouse ? root.theme.accentRed : root.theme.bgBorder
                      Text { anchors.centerIn: parent; text: "󰆴"; color: forgetHover.containsMouse ? "white" : root.theme.textMuted; font.pixelSize: 13; font.family: root.font }
                      MouseArea { id: forgetHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.forgetNetwork(modelData.ssid) }
                    }
                  }

                  Column {
                    visible: networkCard.promptOpen
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 58
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6

                    Rectangle {
                      visible: networkCard.enterprise
                      width: parent.width
                      height: visible ? 30 : 0
                      radius: 7
                      color: root.theme.bgBase
                      border.width: 1
                      border.color: identityInput.activeFocus ? root.theme.accentCyan : root.theme.bgBorder
                      TextInput {
                        id: identityInput
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        verticalAlignment: TextInput.AlignVCenter
                        text: networkCard.promptOpen ? root.identityText : ""
                        color: root.theme.textPrimary
                        font.pixelSize: 11
                        font.family: root.font
                        clip: true
                        onTextEdited: root.identityText = text
                      }
                      Text { anchors.fill: identityInput; verticalAlignment: Text.AlignVCenter; text: "Identity"; visible: identityInput.text.length === 0 && !identityInput.activeFocus; color: root.theme.textMuted; font.pixelSize: 11; font.family: root.font }
                    }

                    Row {
                      width: parent.width
                      spacing: 6
                      Rectangle {
                        width: parent.width - connectPasswordButton.width - parent.spacing
                        height: 30
                        radius: 7
                        color: root.theme.bgBase
                        border.width: 1
                        border.color: passwordInput.activeFocus ? root.theme.accentCyan : root.theme.bgBorder
                        TextInput {
                          id: passwordInput
                          anchors.fill: parent
                          anchors.leftMargin: 9
                          anchors.rightMargin: 9
                          verticalAlignment: TextInput.AlignVCenter
                          text: networkCard.promptOpen ? root.passwordText : ""
                          color: root.theme.textPrimary
                          font.pixelSize: 11
                          font.family: root.font
                          echoMode: TextInput.Password
                          clip: true
                          onTextEdited: root.passwordText = text
                          Keys.onReturnPressed: root.submitPassword(networkCard.modelData)
                          Keys.onEnterPressed: root.submitPassword(networkCard.modelData)
                        }
                        Text { anchors.fill: passwordInput; verticalAlignment: Text.AlignVCenter; text: "Password"; visible: passwordInput.text.length === 0 && !passwordInput.activeFocus; color: root.theme.textMuted; font.pixelSize: 11; font.family: root.font }
                      }

                      Rectangle {
                        id: connectPasswordButton
                        width: 72
                        height: 30
                        radius: 7
                        color: passwordConnectHover.containsMouse ? root.theme.accentCyan : root.theme.accentPrimary
                        Text { anchors.centerIn: parent; text: "Connect"; color: "white"; font.pixelSize: 10; font.family: root.font; font.bold: true }
                        MouseArea { id: passwordConnectHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.submitPassword(networkCard.modelData) }
                      }
                    }
                  }

                  MouseArea { id: networkHover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; z: -1 }

                  Connections {
                    target: networkCard.liveNetwork
                    function onConnectedChanged(): void {
                      if (networkCard.liveNetwork && networkCard.liveNetwork.connected && root.actionSsid === networkCard.modelData.ssid) {
                        root.actionSsid = "";
                        root.clearPrompt();
                      } else if (root.actionSsid === networkCard.modelData.ssid && networkCard.liveNetwork && !networkCard.liveNetwork.stateChanging) {
                        root.actionSsid = "";
                      }
                      Qt.callLater(root.syncWifiNetworks);
                    }
                    function onKnownChanged(): void {
                      if (networkCard.liveNetwork && !networkCard.liveNetwork.known && root.actionSsid === networkCard.modelData.ssid)
                        root.actionSsid = "";
                      Qt.callLater(root.syncWifiNetworks);
                    }
                    function onStateChangingChanged(): void {
                      if (networkCard.liveNetwork && !networkCard.liveNetwork.stateChanging && root.actionSsid === networkCard.modelData.ssid)
                        root.actionSsid = "";
                      Qt.callLater(root.syncWifiNetworks);
                    }
                    function onConnectionFailed(reason): void { root.connectionFailed(networkCard.modelData.ssid, reason); }
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
