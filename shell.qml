import QtQuick
import Quickshell
import Quickshell.Hyprland
import "./modules/bar"

ShellRoot {
 
  Instantiator {
        model: Quickshell.screens

        delegate: Bar {
            monitor: modelData        }
    }
}
