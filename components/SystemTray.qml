// FILE: /home/lilith/code-shit/quickshell/components/SystemTray.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: systemTray
    width: trayLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var trayItems: []
    
    RowLayout {
        id: trayLayout
        anchors.centerIn: parent
        spacing: 4
        
        // Network manager applet
        Text {
            text: "󰀂"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep nm-applet"]) > 0
        }
        
        // Bluetooth applet
        Text {
            text: "󰂯"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep blueman-applet"]) > 0
        }
        
        // Volume applet
        Text {
            text: "󰓃"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep volumeicon"]) > 0
        }
        
        // Battery applet
        Text {
            text: "󰁹"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep cbatticon"]) > 0
        }
        
        // Dropbox
        Text {
            text: "󰇚"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep dropbox"]) > 0
        }
        
        // Discord
        Text {
            text: "󰙯"
            color: Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: 14
            visible: Process.exec(["bash", "-c", "pgrep Discord"]) > 0
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/TrayPanel.qml"])
        }
    }
}