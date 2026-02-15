import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {

    id: root

    property string mode: "idle"   // idle, dashboard, launcher

    property int collapsedHeight: 40
    property int expandedHeight: 460

    width: mode === "idle" ? 420 : 620
    height: mode === "idle" ? collapsedHeight : expandedHeight

    radius: mode === "idle" ? 20 : 28
    color: "#cc101015"

    Behavior on width {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Behavior on height {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Keys.onEscapePressed: mode = "idle"
    focus: true

    // ===================================================
    // IDLE MODE (FIXED CENTER ALIGNMENT)
    // ===================================================
    Item {
        anchors.fill: parent
        visible: mode === "idle"

        Text {
            id: timeText
            text: Qt.formatTime(new Date(), "hh:mm")
            color: "#cfcfcf"
            font.pixelSize: 14

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
        }

        Text {
            id: windowTitle
            text: Hyprland.activeToplevel
                  && Hyprland.activeToplevel.title
                  ? Hyprland.activeToplevel.title
                  : "Desktop"

            color: "#ffffff"
            font.pixelSize: 14
            elide: Text.ElideRight

            anchors.centerIn: parent
            width: parent.width * 0.6
            horizontalAlignment: Text.AlignHCenter
        }

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered: timeText.text =
                Qt.formatTime(new Date(), "hh:mm")
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.mode = "dashboard"
        }
    }

    // ===================================================
    // DASHBOARD MODE (FIXED)
    // ===================================================
    Item {
        anchors.fill: parent
        anchors.margins: 24
        visible: mode === "dashboard"

        ColumnLayout {
            anchors.fill: parent
            spacing: 18

            Text {
                text: "Dashboard"
                color: "white"
                font.pixelSize: 20
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 22
                color: "#151515"
            }
        }
    }

    // ===================================================
    // LAUNCHER MODE
    // ===================================================
    Item {
        anchors.fill: parent
        anchors.margins: 24
        visible: mode === "launcher"

        Rectangle {
            width: parent.width * 0.7
            height: 320
            radius: 18
            anchors.centerIn: parent
            color: "#121212"
        }
    }
}
