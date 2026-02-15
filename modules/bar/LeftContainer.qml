import QtQuick

Row {

    signal launcherRequested()

    spacing: 12

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

    Rectangle {
        width: 24
        height: 24
        radius: 12
        color: "#33ffffff"
    }

    Rectangle {
        width: 24
        height: 24
        radius: 12
        color: "#33ffffff"
    }
}
