import QtQuick
import "./workspaces"

Row {

    signal launcherRequested()

    spacing: 12
    required property var monitor

    // Launcher button (unchanged)
    Rectangle {
        width: 28
        height: 28
        radius: 14
        color: "#44ffffff"

        MouseArea {
            anchors.fill: parent
            onClicked: launcherRequested()
        }
    }

    // Second pile (unchanged placeholder)
    Rectangle {
        width: 24
        height: 24
        radius: 12
        color: "#33ffffff"
    }

    // Third pile → Workspaces module
   Workspaces {
    monitor: root.monitor
  }
}
