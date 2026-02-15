import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    id: root

    property string mode: "idle"

    property int collapsedHeight: 40
    property int expandedHeight: 460

    property int minWidth: 360
    property int maxWidth: 720
    property int horizontalPadding: 40

    // =========================
    // DYNAMIC WIDTH
    // =========================
    width: mode === "idle"
           ? Math.max(minWidth,
               Math.min(maxWidth,
                   timeText.implicitWidth +
                   windowTitle.implicitWidth +
                   horizontalPadding))
           : 620

    height: mode === "idle"
            ? collapsedHeight
            : expandedHeight

    radius: mode === "idle" ? 20 : 28
    color: "#cc101015"

    Behavior on width {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    Keys.onEscapePressed: mode = "idle"
    focus: true

    // =========================
    // IDLE MODE
    // =========================
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

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 16

            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Timer {
            interval: 60000
            running: true
            repeat: true
            onTriggered:
                timeText.text = Qt.formatTime(new Date(), "hh:mm")
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.mode = "dashboard"
        }
    }

    // =========================
    // DASHBOARD
    // =========================
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

    // =========================
    // LAUNCHER
    // =========================
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
