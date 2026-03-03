import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    height: 28

    // Get monitor from window context
    readonly property var monitor:
        Hyprland.monitorFor(QsWindow.window?.screen)

    readonly property int activeWsId:
        monitor?.activeWorkspace?.id ?? 1

    readonly property var workspaces:
        Hyprland.workspaces.values

    // Occupied detection using toplevels (reliable)
    readonly property var occupiedMap: {
        const map = {}
        const tops = Hyprland.toplevels
        for (let i = 0; i < tops.length; i++) {
            const wsId = tops[i].workspace?.id
            if (!wsId) continue
            map[wsId] = true
        }
        return map
    }

    property int dotSize: 10
    property int spacingSize: 14
    property int animDuration: 180

    implicitWidth: row.implicitWidth + 24

    Rectangle {
        id: container
        anchors.verticalCenter: parent.verticalCenter
        height: dotSize + 14
        width: root.implicitWidth
        radius: height / 2
        color: "#1e1e1e"

        Row {
            id: row
            anchors.centerIn: parent
            spacing: spacingSize

            Repeater {
                id: repeater
                model: workspaces

                delegate: Item {
                    required property var modelData
                    property int wsId: modelData.id

                    width: dotSize
                    height: dotSize

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2

                        color: wsId === activeWsId
                               ? "#ffffff"
                               : occupiedMap[wsId]
                                 ? "#aaaaaa"
                                 : "#555555"

                        Behavior on color {
                            ColorAnimation {
                                duration: animDuration
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + wsId)
                    }
                }
            }
        }

        Rectangle {
            id: activeIndicator
            width: dotSize
            height: dotSize
            radius: width / 2
            color: "#ffffff"
            y: (container.height - height) / 2

            x: {
                for (let i = 0; i < workspaces.length; i++) {
                    if (workspaces[i].id === activeWsId) {
                        const item = repeater.itemAt(i)
                        if (item)
                            return item.x + row.x
                    }
                }
                return 0
            }

            Behavior on x {
                NumberAnimation {
                    duration: animDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
