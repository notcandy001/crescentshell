import QtQuick
import Quickshell
import Quickshell.Wayland._WlrLayerShell

WlrLayershell {

    id: bar

    layer: WlrLayer.Top
    anchors.top: true
    implicitWidth: screen.width

    property int topSpacing: 4

    // IMPORTANT:
    // Bar height stays constant.
    // Only notch animates.
    implicitHeight: notch.mode === "idle"
                    ? notch.collapsedHeight + topSpacing
                    : notch.expandedHeight + topSpacing

    margins.top: topSpacing

    // Reserve only collapsed height
    exclusiveZone: notch.collapsedHeight + topSpacing

    color: "transparent"

    Item {
        anchors.fill: parent

        // ========================
        // OUTSIDE CLICK OVERLAY
        // ========================
        MouseArea {
            anchors.fill: parent
            visible: notch.mode !== "idle"
            enabled: notch.mode !== "idle"
            z: 1
            onClicked: notch.mode = "idle"
        }

        // ========================
        // LEFT PILLS
        // ========================
        LeftContainer {
            id: leftPills

            anchors {
                left: parent.left
                top: parent.top
                leftMargin: 14
                topMargin: 10
            }

            z: 2

            onLauncherRequested: {
                notch.mode = "launcher"
            }
        }

        // ========================
        // RIGHT PILLS
        // ========================
        RightContainer {
            id: rightPills

            anchors {
                right: parent.right
                top: parent.top
                rightMargin: 14
                topMargin: 10
            }

            z: 2
        }

        // ========================
        // CENTER NOTCH
        // ========================
        Notch {
            id: notch

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 6

            z: 3
        }
    }
}
