import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
  id: root

  required property var coordinator
  required property var theme
  required property var barScreen
  required property string font
  required property int barHeight

  readonly property bool calendarOpen: coordinator.isOpen("calendar")
  readonly property bool worldClocksOpen: coordinator.isOpen("world-clocks")
  property var worldClockTimes: []
  readonly property var worldClockZones: [
    { city: "UTC", region: "Coordinated Universal Time", zone: "UTC" },
    { city: "New York", region: "Americas", zone: "America/New_York" },
    { city: "Chicago", region: "Americas", zone: "America/Chicago" },
    { city: "Denver", region: "Americas", zone: "America/Denver" },
    { city: "Los Angeles", region: "Americas", zone: "America/Los_Angeles" },
    { city: "São Paulo", region: "Americas", zone: "America/Sao_Paulo" },
    { city: "London", region: "United Kingdom", zone: "Europe/London" },
    { city: "Stockholm", region: "Sweden", zone: "Europe/Stockholm" },
    { city: "Paris", region: "France", zone: "Europe/Paris" },
    { city: "Madrid", region: "Spain", zone: "Europe/Madrid" },
    { city: "Johannesburg", region: "Africa", zone: "Africa/Johannesburg" },
    { city: "Dubai", region: "Middle East", zone: "Asia/Dubai" },
    { city: "New Delhi", region: "Asia", zone: "Asia/Kolkata" },
    { city: "Singapore", region: "Asia", zone: "Asia/Singapore" },
    { city: "Hong Kong", region: "Asia", zone: "Asia/Hong_Kong" },
    { city: "Tokyo", region: "Asia", zone: "Asia/Tokyo" },
    { city: "Sydney", region: "Pacific", zone: "Australia/Sydney" },
    { city: "Auckland", region: "Pacific", zone: "Pacific/Auckland" }
  ]
  property date calendarToday: new Date()
  property int calendarViewYear: calendarToday.getFullYear()
  property int calendarViewMonth: calendarToday.getMonth()
  readonly property int calendarWeekStart: Qt.locale().firstDayOfWeek % 7

  function calendarDateKey(date) {
    return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, "0") + "-" + String(date.getDate()).padStart(2, "0");
  }

  function calendarIsoWeek(date) {
    const target = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const day = target.getUTCDay() || 7;
    target.setUTCDate(target.getUTCDate() + 4 - day);
    const yearStart = new Date(Date.UTC(target.getUTCFullYear(), 0, 1));
    return Math.ceil((((target - yearStart) / 86400000) + 1) / 7);
  }

  function calendarWeeks() {
    const leading = (new Date(calendarViewYear, calendarViewMonth, 1).getDay() - calendarWeekStart + 7) % 7;
    const cursor = new Date(calendarViewYear, calendarViewMonth, 1 - leading);
    const todayKey = calendarDateKey(calendarToday);
    const weeks = [];
    for (let row = 0; row < 6; row++) {
      const days = [];
      const weekDate = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate());
      for (let column = 0; column < 7; column++) {
        const key = calendarDateKey(cursor);
        days.push({
          day: cursor.getDate(),
          inMonth: cursor.getMonth() === calendarViewMonth && cursor.getFullYear() === calendarViewYear,
          weekend: cursor.getDay() === 0 || cursor.getDay() === 6,
          today: key === todayKey
        });
        cursor.setDate(cursor.getDate() + 1);
      }
      weeks.push({ week: calendarIsoWeek(weekDate), days: days });
    }
    return weeks;
  }

  function calendarMoveMonth(delta) {
    const next = new Date(calendarViewYear, calendarViewMonth + delta, 1);
    calendarViewYear = next.getFullYear();
    calendarViewMonth = next.getMonth();
  }

  function calendarGoToToday() {
    calendarToday = new Date();
    calendarViewYear = calendarToday.getFullYear();
    calendarViewMonth = calendarToday.getMonth();
  }

  function toggleCalendar() {
    const opening = !calendarOpen;
    coordinator.toggle("calendar");
    if (opening) calendarGoToToday();
  }

  function worldClockCommand() {
    let command = "";
    for (let i = 0; i < worldClockZones.length; i++)
      command += "TZ='" + worldClockZones[i].zone + "' date '+%a %b %-d|%-I:%M %p|%Z';";
    return ["sh", "-c", "LC_ALL=C; " + command];
  }

  function refreshWorldClocks() {
    if (!worldClockProc.running) {
      worldClockProc.command = worldClockCommand();
      worldClockProc.running = true;
    }
  }

  function toggleWorldClocks() {
    const opening = !worldClocksOpen;
    coordinator.toggle("world-clocks");
    if (opening) refreshWorldClocks();
  }

  Process {
    id: openGoogleCalendarProc
    command: ["uwsm", "app", "--", "google-chrome-stable", "--profile-directory=Profile 1", "https://calendar.google.com/calendar/u/0/r"]
  }

  Process {
    id: worldClockProc
    command: root.worldClockCommand()
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        const clocks = [];
        for (let i = 0; i < Math.min(lines.length, root.worldClockZones.length); i++) {
          const parts = lines[i].split("|");
          if (parts.length < 3) continue;
          clocks.push({
            city: root.worldClockZones[i].city,
            region: root.worldClockZones[i].region,
            date: parts[0],
            time: parts[1],
            abbreviation: parts[2]
          });
        }
        root.worldClockTimes = clocks;
      }
    }
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: root.refreshWorldClocks()
  }

  // Omarchy-style calendar overlay
  Variants {
    model: root.calendarOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-calendar"
      exclusionMode: ExclusionMode.Ignore

      Shortcut { sequence: "Escape"; onActivated: root.coordinator.close("calendar") }
      Shortcut { sequence: "Left"; onActivated: root.calendarMoveMonth(-1) }
      Shortcut { sequence: "Right"; onActivated: root.calendarMoveMonth(1) }
      Shortcut { sequence: "Up"; onActivated: root.calendarMoveMonth(-12) }
      Shortcut { sequence: "Down"; onActivated: root.calendarMoveMonth(12) }
      Shortcut { sequence: "T"; onActivated: root.calendarGoToToday() }

      anchors { top: true; bottom: true; left: true; right: true }

      MouseArea {
        anchors.fill: parent
        onClicked: root.coordinator.close("calendar")
      }

      Rectangle {
        id: calendarCard
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.barHeight + 6
        width: Math.min(560, parent.width - 20)
        height: calendarContent.implicitHeight + 40
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.97)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true
        property real weekWidth: 30
        property real gutterWidth: 8
        property real cellSpacing: 4
        property real dayWidth: (calendarContent.width - weekWidth - gutterWidth - (cellSpacing * 8)) / 7

        MouseArea { anchors.fill: parent; onClicked: {} }

        WheelHandler {
          onWheel: function(event) {
            if (event.angleDelta.y !== 0) root.calendarMoveMonth(event.angleDelta.y > 0 ? -1 : 1);
          }
        }

        Column {
          id: calendarContent
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 12

          Item {
            width: parent.width
            height: calendarHeroRow.height

            Row {
              id: calendarHeroRow
              anchors.horizontalCenter: parent.horizontalCenter
              spacing: 16

              Text {
                anchors.baseline: calendarHeroDate.baseline
                text: "󰃭"
                color: root.theme.accentCyan
                font.pixelSize: 38
                font.family: root.font
              }

              Text {
                id: calendarHeroDate
                text: Qt.formatDate(root.calendarToday, "MMMM d")
                color: root.theme.textPrimary
                font.pixelSize: 38
                font.family: root.font
                font.bold: true
              }
            }

            MouseArea {
              x: calendarHeroRow.x
              y: calendarHeroRow.y
              width: calendarHeroRow.width
              height: calendarHeroRow.height
              cursorShape: Qt.PointingHandCursor
              onClicked: root.calendarGoToToday()
            }
          }

          Item {
            width: parent.width
            height: 18
            readonly property int dayOfYear: Math.floor((Date.UTC(root.calendarToday.getFullYear(), root.calendarToday.getMonth(), root.calendarToday.getDate()) - Date.UTC(root.calendarToday.getFullYear(), 0, 1)) / 86400000) + 1
            readonly property int daysInYear: (new Date(root.calendarToday.getFullYear(), 1, 29).getMonth() === 1) ? 366 : 365
            readonly property int progress: Math.round((dayOfYear - 1) * 100 / daysInYear)

            Text {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: root.calendarToday.getFullYear()
              color: root.theme.textMuted
              font.pixelSize: 10
              font.family: root.font
              font.letterSpacing: 1
            }

            Text {
              id: calendarYearPercent
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: parent.progress + "%"
              color: root.theme.textSecondary
              font.pixelSize: 10
              font.family: root.font
            }

            Rectangle {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: 42
              anchors.rightMargin: 35
              anchors.verticalCenter: parent.verticalCenter
              height: 5
              radius: 3
              color: root.theme.bgBorder

              Rectangle {
                width: parent.width * parent.parent.progress / 100
                height: parent.height
                radius: parent.radius
                color: root.theme.accentCyan
                Behavior on width { NumberAnimation { duration: 160 } }
              }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Row {
            width: parent.width
            spacing: calendarCard.cellSpacing

            Text {
              width: calendarCard.weekWidth
              height: 18
              text: "W"
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              color: root.theme.textMuted
              font.pixelSize: 10
              font.family: root.font
              font.bold: true
            }
            Item { width: calendarCard.gutterWidth; height: 18 }
            Repeater {
              model: {
                const names = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
                const ordered = [];
                for (let i = 0; i < 7; i++) ordered.push(names[(root.calendarWeekStart + i) % 7]);
                return ordered;
              }
              Text {
                required property string modelData
                width: calendarCard.dayWidth
                height: 18
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.theme.textMuted
                font.pixelSize: 10
                font.family: root.font
                font.bold: true
              }
            }
          }

          Column {
            width: parent.width
            spacing: 3

            Repeater {
              model: root.calendarWeeks()

              Row {
                required property var modelData
                width: calendarContent.width
                spacing: calendarCard.cellSpacing

                Text {
                  width: calendarCard.weekWidth
                  height: 34
                  text: modelData.week
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                  color: root.theme.textMuted
                  opacity: 0.65
                  font.pixelSize: 10
                  font.family: root.font
                }

                Rectangle {
                  width: calendarCard.gutterWidth
                  height: 34
                  color: "transparent"
                  Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 1
                    height: parent.height
                    color: root.theme.bgBorder
                  }
                }

                Repeater {
                  model: modelData.days

                  Rectangle {
                    required property var modelData
                    width: calendarCard.dayWidth
                    height: 34
                    radius: 7
                    color: modelData.today ? Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.12) : "transparent"
                    border.width: modelData.today ? 1 : 0
                    border.color: root.theme.accentCyan

                    Text {
                      anchors.centerIn: parent
                      text: modelData.day
                      color: !modelData.inMonth ? root.theme.textMuted : (modelData.weekend ? root.theme.textSecondary : root.theme.textPrimary)
                      opacity: modelData.inMonth ? 1 : 0.42
                      font.pixelSize: 13
                      font.family: root.font
                      font.bold: modelData.today
                    }
                  }
                }
              }
            }
          }

          Item {
            width: parent.width
            height: 34

            Rectangle {
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              width: 34; height: 30; radius: 8
              color: calendarPreviousMouse.containsMouse ? root.theme.bgHover : "transparent"
              Text { anchors.centerIn: parent; text: "󰅁"; color: root.theme.textPrimary; font.pixelSize: 16; font.family: root.font }
              MouseArea { id: calendarPreviousMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.calendarMoveMonth(-1) }
            }

            Text {
              anchors.centerIn: parent
              text: Qt.formatDate(new Date(root.calendarViewYear, root.calendarViewMonth, 1), "MMMM yyyy").toUpperCase()
              color: root.theme.textSecondary
              font.pixelSize: 12
              font.family: root.font
              font.bold: true
              font.letterSpacing: 1
            }

            Rectangle {
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              width: 34; height: 30; radius: 8
              color: calendarNextMouse.containsMouse ? root.theme.bgHover : "transparent"
              Text { anchors.centerIn: parent; text: "󰅂"; color: root.theme.textPrimary; font.pixelSize: 16; font.family: root.font }
              MouseArea { id: calendarNextMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.calendarMoveMonth(1) }
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 180
            height: 34
            radius: 9
            color: calendarOpenMouse.containsMouse ? root.theme.accentCyan : Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.15)
            border.width: 1
            border.color: root.theme.accentCyan

            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
              anchors.centerIn: parent
              spacing: 8
              Text { text: "󰸗"; color: calendarOpenMouse.containsMouse ? root.theme.bgBase : root.theme.accentCyan; font.pixelSize: 15; font.family: root.font }
              Text { text: "Open Google Calendar"; color: calendarOpenMouse.containsMouse ? root.theme.bgBase : root.theme.textPrimary; font.pixelSize: 11; font.family: root.font; font.bold: true }
            }

            MouseArea {
              id: calendarOpenMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                openGoogleCalendarProc.running = true;
                root.coordinator.close("calendar");
              }
            }
          }
        }
      }
    }
  }

  // World clocks overlay
  Variants {
    model: root.worldClocksOpen && root.barScreen ? [root.barScreen] : []

    PanelWindow {
      required property var modelData
      screen: modelData
      visible: true
      focusable: true
      color: "transparent"

      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      WlrLayershell.namespace: "quickshell-world-clocks"
      exclusionMode: ExclusionMode.Ignore

      Shortcut { sequence: "Escape"; onActivated: root.coordinator.close("world-clocks") }
      anchors { top: true; bottom: true; left: true; right: true }

      MouseArea {
        anchors.fill: parent
        onClicked: root.coordinator.close("world-clocks")
      }

      Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.barHeight + 6
        width: Math.min(620, parent.width - 20)
        height: worldClockContent.implicitHeight + 40
        radius: 14
        color: Qt.rgba(root.theme.bgBase.r, root.theme.bgBase.g, root.theme.bgBase.b, 0.97)
        border.width: 1
        border.color: root.theme.bgBorder
        clip: true

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
          id: worldClockContent
          anchors.top: parent.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.margins: 20
          spacing: 12

          Row {
            width: parent.width
            spacing: 10

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: "󰥔"
              color: root.theme.accentCyan
              font.pixelSize: 22
              font.family: root.font
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              spacing: 1
              Text {
                text: "World Clocks"
                color: root.theme.textPrimary
                font.pixelSize: 16
                font.family: root.font
                font.bold: true
              }
              Text {
                text: "Major time zones around the world"
                color: root.theme.textMuted
                font.pixelSize: 10
                font.family: root.font
              }
            }

            Item { width: 1; height: 1 }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              text: Time.utcTimeString + " UTC"
              color: root.theme.accentCyan
              font.pixelSize: 15
              font.family: root.font
              font.bold: true
            }
          }

          Rectangle { width: parent.width; height: 1; color: root.theme.bgBorder }

          Grid {
            id: worldClockGrid
            width: parent.width
            columns: 2
            columnSpacing: 10
            rowSpacing: 8

            Repeater {
              model: root.worldClockTimes

              Rectangle {
                required property var modelData
                width: (worldClockGrid.width - worldClockGrid.columnSpacing) / 2
                height: 50
                radius: 9
                color: modelData.city === "UTC"
                  ? Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.11)
                  : root.theme.bgSurface
                border.width: modelData.city === "UTC" ? 1 : 0
                border.color: Qt.rgba(root.theme.accentCyan.r, root.theme.accentCyan.g, root.theme.accentCyan.b, 0.45)

                Column {
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: 12
                  spacing: 1

                  Text {
                    text: modelData.city
                    color: root.theme.textPrimary
                    font.pixelSize: 13
                    font.family: root.font
                    font.bold: true
                  }

                  Text {
                    text: modelData.region + "  •  " + modelData.date
                    color: root.theme.textMuted
                    font.pixelSize: 9
                    font.family: root.font
                  }
                }

                Column {
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.rightMargin: 12
                  spacing: 1

                  Text {
                    anchors.right: parent.right
                    text: modelData.time
                    color: modelData.city === "UTC" ? root.theme.accentCyan : root.theme.textPrimary
                    font.pixelSize: 14
                    font.family: root.font
                    font.bold: true
                  }

                  Text {
                    anchors.right: parent.right
                    text: modelData.abbreviation
                    color: root.theme.textMuted
                    font.pixelSize: 9
                    font.family: root.font
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
