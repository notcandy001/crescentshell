import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "../../../services"

Item {
    id: workspacesWidget

    required property var monitor

    readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(monitor)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int activeWsId: hyprMonitor?.activeWorkspace?.id ?? 1

    property int shown: 10
    property list<bool> workspaceOccupied: []
    property list<int> dynamicWorkspaceIds: []
    property int effectiveWorkspaceCount: dynamicWorkspaceIds.length
    property int widgetPadding: 4
    property int buttonSize: 28
    property int animDuration: 180
    property var occupiedRanges: []

    readonly property int activeIndex: {
        var idx = dynamicWorkspaceIds.indexOf(activeWsId)
        return idx < 0 ? 0 : idx
    }

    function updateWorkspaceOccupied() {
        var occupiedIds = Hyprland.workspaces.values
            .filter(function(ws) { return HyprlandData.workspaceOccupationMap[ws.id] })
            .map(function(ws) { return ws.id })
            .sort(function(a, b) { return a - b })
            .slice(0, shown)

        var aId = activeWsId
        if (occupiedIds.indexOf(aId) === -1) {
            occupiedIds.push(aId)
            occupiedIds.sort(function(a, b) { return a - b })
            if (occupiedIds.length > shown)
                occupiedIds.pop()
        }

        if (occupiedIds.length < shown) {
            var maxId = occupiedIds.length > 0 ? occupiedIds[occupiedIds.length - 1] : 0
            for (var i = 1; occupiedIds.length < shown; i++) {
                var candidate = maxId + i
                if (occupiedIds.indexOf(candidate) === -1)
                    occupiedIds.push(candidate)
            }
            occupiedIds.sort(function(a, b) { return a - b })
        }

        dynamicWorkspaceIds = occupiedIds
        workspaceOccupied = Array.from(
            { length: dynamicWorkspaceIds.length },
            function(_, i) { return !!HyprlandData.workspaceOccupationMap[dynamicWorkspaceIds[i]] }
        )
        updateOccupiedRanges()
    }

    function updateOccupiedRanges() {
        var ranges = []
        var rangeStart = -1
        for (var i = 0; i < effectiveWorkspaceCount; i++) {
            if (workspaceOccupied[i]) {
                if (rangeStart === -1) rangeStart = i
            } else {
                if (rangeStart !== -1) {
                    ranges.push({ start: rangeStart, end: i - 1 })
                    rangeStart = -1
                }
            }
        }
        if (rangeStart !== -1)
            ranges.push({ start: rangeStart, end: effectiveWorkspaceCount - 1 })
        occupiedRanges = ranges
    }

    Timer {
        id: updateTimer
        interval: 100
        repeat: false
        onTriggered: workspacesWidget.updateWorkspaceOccupied()
    }

    Component.onCompleted: updateTimer.restart()

    Connections { target: Hyprland.workspaces; function onValuesChanged() { updateTimer.restart() } }
    Connections { target: workspacesWidget.hyprMonitor; function onActiveWorkspaceChanged() { updateTimer.restart() } }
    Connections { target: workspacesWidget.activeWindow; function onActivatedChanged() { updateTimer.restart() } }
    Connections { target: HyprlandData; function onWindowListChanged() { updateTimer.restart() } }

    implicitWidth: buttonSize * effectiveWorkspaceCount + widgetPadding * 2
    implicitHeight: buttonSize + widgetPadding * 2

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#1e1e1e"
    }

    WheelHandler {
        onWheel: function(event) {
            if (event.angleDelta.y < 0) Hyprland.dispatch("workspace r+1")
            else if (event.angleDelta.y > 0) Hyprland.dispatch("workspace r-1")
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    Repeater {
        model: occupiedRanges
        Rectangle {
            required property int index
            required property var modelData
            z: 1
            height: workspacesWidget.buttonSize
            width: (modelData.end - modelData.start + 1) * workspacesWidget.buttonSize
            radius: height / 2
            color: "#2a2a2a"
            x: modelData.start * workspacesWidget.buttonSize + workspacesWidget.widgetPadding
            y: workspacesWidget.widgetPadding
            Behavior on x { NumberAnimation { duration: workspacesWidget.animDuration; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: workspacesWidget.animDuration; easing.type: Easing.OutCubic } }
        }
    }

    Item {
        id: activeHighlight
        z: 2
        property real margin: 3
        property real idx1: workspacesWidget.activeIndex
        property real idx2: workspacesWidget.activeIndex

        // idx1 is slow - lags behind = the stretchy tail
        Behavior on idx1 {
            NumberAnimation { duration: workspacesWidget.animDuration; easing.type: Easing.OutSine }
        }
        // idx2 is fast - leading edge snaps ahead
        Behavior on idx2 {
            NumberAnimation { duration: workspacesWidget.animDuration / 3; easing.type: Easing.OutSine }
        }

        x: Math.min(idx1, idx2) * workspacesWidget.buttonSize + margin + workspacesWidget.widgetPadding
        y: workspacesWidget.widgetPadding + margin
        width: Math.abs(idx1 - idx2) * workspacesWidget.buttonSize + workspacesWidget.buttonSize - margin * 2
        height: workspacesWidget.buttonSize - margin * 2

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: "#ffffff"
            opacity: 0.92
        }
    }

    // When active workspace changes: idx2 snaps (fast leading edge)
    // idx1 catches up slowly via Behavior (stretchy tail)
    Connections {
        target: workspacesWidget
        function onActiveIndexChanged() {
            activeHighlight.idx2 = workspacesWidget.activeIndex
        }
    }

    Row {
        z: 3
        anchors.fill: parent
        anchors.margins: widgetPadding
        spacing: 0

        Repeater {
            model: effectiveWorkspaceCount

            Item {
                id: wsButton
                required property int index
                property int wsId: workspacesWidget.dynamicWorkspaceIds[index] ?? (index + 1)
                property bool isActive: wsId === workspacesWidget.activeWsId
                property bool isOccupied: workspacesWidget.workspaceOccupied[index] ?? false

                property var focusedWindow: {
                    var wins = HyprlandData.workspaceWindowsMap[wsId] || []
                    if (wins.length === 0) return null
                    return wins.reduce(function(best, win) {
                        var bestFocus = (best && best.focusHistoryID !== undefined) ? best.focusHistoryID : Infinity
                        var winFocus = win.focusHistoryID !== undefined ? win.focusHistoryID : Infinity
                        return winFocus < bestFocus ? win : best
                    }, null)
                }

                width: workspacesWidget.buttonSize
                height: workspacesWidget.buttonSize

                Rectangle {
                    anchors.centerIn: parent
                    width:  wsButton.isActive ? 9 : (wsButton.isOccupied ? 6 : 5)
                    height: width
                    radius: width / 2
                    opacity: wsButton.focusedWindow ? 0 : 1
                    color: wsButton.isActive ? "#1e1e1e" : (wsButton.isOccupied ? "#dddddd" : "#555555")
                    Behavior on opacity { NumberAnimation { duration: workspacesWidget.animDuration } }
                    Behavior on color   { ColorAnimation  { duration: workspacesWidget.animDuration } }
                    Behavior on width   { NumberAnimation { duration: workspacesWidget.animDuration; easing.type: Easing.OutCubic } }
                }

                IconImage {
                    anchors.centerIn: parent
                    source: wsButton.focusedWindow
                        ? Quickshell.iconPath(wsButton.focusedWindow.class, "application-x-executable")
                        : ""
                    implicitSize: workspacesWidget.buttonSize * 0.62
                    opacity: wsButton.focusedWindow ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: workspacesWidget.animDuration } }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + wsButton.wsId)
                }
            }
        }
    }
}
