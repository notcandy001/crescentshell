import QtQuick
import Quickshell
import Quickshell.Wayland._WlrLayerShell

WlrLayershell {
    id: bar
    layer: WlrLayer.Top
    anchors.top: true
    implicitWidth: screen.width
    property int topSpacing: 4
    property var monitor
    screen: monitor

    // Fixed at expanded height always — never resize the compositor surface
    // exclusiveZone stays collapsed so windows are not pushed down
    implicitHeight: notch.expandedHeight + topSpacing
    margins.top: topSpacing
    exclusiveZone: notch.collapsedHeight + topSpacing
    color: "transparent"

    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            visible: notch.mode !== "idle"
            enabled: notch.mode !== "idle"
            z: 1
            onClicked: notch.mode = "idle"
        }

        LeftContainer {
            id: leftPills
            monitor: bar.monitor
            anchors { left: parent.left; top: parent.top; leftMargin: 14; topMargin: 10 }
            z: 2
            onLauncherRequested: { notch.mode = "launcher" }
        }

        RightContainer {
            id: rightPills
            anchors { right: parent.right; top: parent.top; rightMargin: 14; topMargin: 10 }
            z: 2
        }

        Notch {
            id: notch
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 6
            z: 3
        }
    }
}
