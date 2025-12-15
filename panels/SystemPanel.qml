// FILE: /home/lilith/code-shit/quickshell/panels/SystemPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: systemPanel
    screen: rootScreen
    height: 700
    width: 400
    color: "transparent"
    
    property int panelMargin: 16
    property real cornerRadius: 24
    
    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: Theme.base
        opacity: 0.95
        radius: cornerRadius
        
        layer.enabled: true
        layer.effect: ShaderEffect {
            property real blurRadius: 32
            fragmentShader: "
                uniform lowp sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp float blurRadius;
                varying highp vec2 qt_TexCoord0;
                void main() {
                    vec4 color = vec4(0.0);
                    float total = 0.0;
                    float radius = blurRadius / 200.0;
                    
                    for (float x = -4.0; x <= 4.0; x += 1.0) {
                        for (float y = -4.0; y <= 4.0; y += 1.0) {
                            float weight = exp(-(x*x + y*y) / (2.0*radius*radius));
                            color += texture2D(source, qt_TexCoord0 + vec2(x/200.0, y/200.0)) * weight;
                            total += weight;
                        }
                    }
                    gl_FragColor = (color / total) * qt_Opacity;
                }
            "
        }
        
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            radius: 32
            samples: 64
            color: "#40000000"
            verticalOffset: 8
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: panelMargin
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "󰣇"
                color: Theme.mauve
                font.family: Theme.iconFont
                font.pixelSize: 24
            }
            
            Text {
                text: "System"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.titleFontSize
                font.bold: true
                Layout.fillWidth: true
            }
            
            Text {
                text: "󰆏"
                color: Theme.subtext0
                font.family: Theme.iconFont
                font.pixelSize: 20
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: systemPanel.close()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // System info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "System Information"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 180
                radius: 12
                color: Theme.surface0
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6
                    
                    RowLayout {
                        Text {
                            text: "󰣇"
                            color: Theme.mauve
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: hostname
                            text: "Hostname"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "󰍛"
                            color: Theme.blue
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: os
                            text: "Operating System"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "󰌢"
                            color: Theme.green
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: kernel
                            text: "Kernel"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "󰥔"
                            color: Theme.yellow
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: uptime
                            text: "Uptime"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "󰻠"
                            color: Theme.peach
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: cpu
                            text: "CPU"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "󰓃"
                            color: Theme.red
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            id: gpu
                            text: "GPU"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
        
        // Quick actions
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Quick Actions"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 8
                columnSpacing: 8
                
                Repeater {
                    model: ListModel {
                        ListElement { name: "Lock"; icon: "󰌾"; command: "swaylock"; color: "blue" }
                        ListElement { name: "Sleep"; icon: "󰒲"; command: "systemctl suspend"; color: "lavender" }
                        ListElement { name: "Logout"; icon: "󰗽"; command: "swaymsg exit"; color: "red" }
                        ListElement { name: "Reboot"; icon: "󰜉"; command: "systemctl reboot"; color: "yellow" }
                        ListElement { name: "Shutdown"; icon: "󰐥"; command: "systemctl poweroff"; color: "peach" }
                        ListElement { name: "Settings"; icon: "󰒓"; command: "xdg-open .config"; color: "mauve" }
                    }
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 80
                        radius: 12
                        color: actionMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: model.icon
                                color: Theme[model.color]
                                font.family: Theme.iconFont
                                font.pixelSize: 24
                            }
                            
                            Text {
                                text: model.name
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                        
                        MouseArea {
                            id: actionMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Process.exec(["bash", "-c", model.command])
                                systemPanel.close()
                            }
                        }
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Package updates
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Text {
                    text: "Package Updates"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                Text {
                    id: updatesCount
                    text: "0"
                    color: Theme.yellow
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: updateMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        text: "󰚰"
                        color: Theme.yellow
                        font.family: Theme.iconFont
                        font.pixelSize: 18
                    }
                    
                    Text {
                        text: "Check for updates"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "󰅂"
                        color: Theme.subtext0
                        font.family: Theme.iconFont
                        font.pixelSize: 16
                    }
                }
                
                MouseArea {
                    id: updateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/package-manager.sh update"])
                        systemPanel.close()
                    }
                }
            }
        }
        
        // VPN
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "VPN"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: vpnMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        id: vpnIcon
                        text: "󰦝"
                        color: Theme.green
                        font.family: Theme.iconFont
                        font.pixelSize: 18
                    }
                    
                    Text {
                        id: vpnStatus
                        text: "VPN: Disconnected"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.fillWidth: true
                    }
                    
                    Switch {
                        id: vpnSwitch
                        checked: false
                        Layout.alignment: Qt.AlignRight
                        
                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 24
                            radius: 12
                            color: vpnSwitch.checked ? Theme.green : Theme.surface1
                            border.color: vpnSwitch.checked ? Theme.green : Theme.overlay0
                            
                            Rectangle {
                                x: vpnSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: Theme.text
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }
                        }
                        
                        onCheckedChanged: {
                            if (vpnSwitch.checked) {
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/vpn.sh connect"])
                            } else {
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/vpn.sh disconnect"])
                            }
                        }
                    }
                }
                
                MouseArea {
                    id: vpnMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: vpnSwitch.toggle()
                }
            }
        }
    }
    
    Timer {
        interval: 5000
        running: systemPanel.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: loadSystemInfo()
    }
    
    function loadSystemInfo() {
        // System info
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/system-info.sh"], function(result) {
            try {
                var info = JSON.parse(result)
                hostname.text = info.hostname
                os.text = info.os
                kernel.text = "Kernel " + info.kernel
                uptime.text = "Uptime " + info.uptime
                cpu.text = info.cpu.model + " (" + info.cpu.cores + " cores)"
                gpu.text = info.gpu.model || "Unknown"
            } catch (e) {
                console.log("Error parsing system info:", e)
            }
        })
        
        // Package updates
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/package-manager.sh updates"], function(result) {
            try {
                var updates = JSON.parse(result)
                updatesCount.text = updates.total
            } catch (e) {
                console.log("Error parsing updates:", e)
            }
        })
        
        // VPN status
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/vpn.sh status"], function(result) {
            try {
                var vpn = JSON.parse(result)
                vpnSwitch.checked = vpn.connected
                vpnIcon.text = vpn.connected ? "󰦜" : "󰦝"
                vpnStatus.text = vpn.connected ? "VPN: " + (vpn.name || "Connected") : "VPN: Disconnected"
            } catch (e) {
                console.log("Error parsing VPN status:", e)
            }
        })
    }
    
    Component.onCompleted: loadSystemInfo()
}