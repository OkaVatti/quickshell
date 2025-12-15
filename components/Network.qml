import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: network
    width: networkLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var networkData: ({
        "connected": false,
        "type": "disconnected",
        "ssid": "",
        "signal": 0,
        "download": 0,
        "upload": 0
    })
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateNetworkInfo()
    }
    
    function updateNetworkInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh info"], function(result) {
            try {
                networkData = JSON.parse(result)
            } catch (e) {
                console.log("Error parsing network data:", e)
            }
        })
    }
    
    function getIcon() {
        if (!networkData.connected) return "󰖪"
        if (networkData.type === "WiFi") {
            if (networkData.signal > 75) return "󰤨"
            if (networkData.signal > 50) return "󰤥"
            if (networkData.signal > 25) return "󰤢"
            return "󰤟"
        }
        return "󰈀"
    }
    
    RowLayout {
        id: networkLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: getIcon()
            color: networkData.connected ? Theme.green : Theme.red
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        ColumnLayout {
            spacing: 0
            visible: networkData.connected
            
            Text {
                text: networkData.ssid || "Connected"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            RowLayout {
                spacing: 4
                
                Text {
                    text: "󰁅 " + (networkData.download || 0) + " KB/s"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
                
                Text {
                    text: "󰁝 " + (networkData.upload || 0) + " KB/s"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/NetworkPanel.qml"])
        }
    }
}