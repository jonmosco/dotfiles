pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  readonly property string timeString: {
    Qt.formatDateTime(clock.date, "h:mm AP")
  }

  readonly property string dateString: {
    Qt.formatDateTime(clock.date, "ddd MMM d")
  }

  readonly property string timeZoneString: {
    Qt.formatDateTime(clock.date, "t")
  }

  readonly property string utcTimeString: {
    const hours = String(clock.date.getUTCHours()).padStart(2, "0")
    const minutes = String(clock.date.getUTCMinutes()).padStart(2, "0")
    return hours + ":" + minutes
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
