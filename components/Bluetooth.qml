import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: bluetooth
    width: btLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var btData: ({
        "powered": "no",
        "connected_devices": 0
    })
    
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateBluetoothInfo()
    }
    
    function updateBluetoothInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh status"], function(result) {
            try {
                btData = JSON.parse(result)
            } catch (e) {
                console.log("Error parsing bluetooth data:", e)
            }
        })
    }
    
    RowLayout {
        id: btLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: btData.powered === "yes" ? "" : "󰂲"
            color: btData.powered === "yes" ? Theme.blue : Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        Rectangle {
            visible: btData.connected_devices > 0
            width: btDeviceCount.width + 8
            height: 16
            radius: 8
            color: Theme.blue
            
            Text {
                id: btDeviceCount
                anchors.centerIn: parent
                text: btData.connected_devices
                color: Theme.base
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/BluetoothPanel.qml"])
        }
    }
}