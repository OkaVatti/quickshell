import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: performance
    width: perfLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var perfData: ({
        "cpu": {
            "usage": 0,
            "temperature": 0
        },
        "memory": {
            "percent": 0
        },
        "profile": "balanced"
    })
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updatePerfInfo()
    }
    
    function updatePerfInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/performance.sh info"], function(result) {
            try {
                perfData = JSON.parse(result)
            } catch (e) {
                console.log("Error parsing performance data:", e)
            }
        })
    }
    
    function getProfileIcon() {
        switch (perfData.profile) {
            case "power-save": return "󰾅"
            case "balanced": return "󰾆"
            case "performance": return "󰓅"
            case "overclock": return "󱐋"
            default: return "󰾆"
        }
    }
    
    function getProfileColor() {
        switch (perfData.profile) {
            case "power-save": return Theme.green
            case "balanced": return Theme.blue
            case "performance": return Theme.yellow
            case "overclock": return Theme.red
            default: return Theme.blue
        }
    }
    
    RowLayout {
        id: perfLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: getProfileIcon()
            color: getProfileColor()
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        ColumnLayout {
            spacing: 0
            
            RowLayout {
                spacing: 4
                
                Text {
                    text: "CPU:"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
                
                Text {
                    text: Math.round(perfData.cpu.usage) + "%"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
                
                Text {
                    text: Math.round(perfData.cpu.temperature) + "°C"
                    color: perfData.cpu.temperature > 80 ? Theme.red : Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
            }
            
            RowLayout {
                spacing: 4
                
                Text {
                    text: "MEM:"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
                
                Text {
                    text: perfData.memory.percent.toFixed(1) + "%"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/PerformancePanel.qml"])
        }
    }
}