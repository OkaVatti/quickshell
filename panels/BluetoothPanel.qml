// FILE: /home/lilith/code-shit/quickshell/panels/BluetoothPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: bluetoothPanel
    screen: rootScreen
    height: 500
    width: 360
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
                text: "󰂯"
                color: Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: 24
            }
            
            Text {
                text: "Bluetooth"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.titleFontSize
                font.bold: true
                Layout.fillWidth: true
            }
            
            RowLayout {
                spacing: 8
                
                Text {
                    text: "󰍛"
                    color: scanMouseArea.containsMouse ? Theme.blue : Theme.subtext0
                    font.family: Theme.iconFont
                    font.pixelSize: 20
                    
                    MouseArea {
                        id: scanMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh scan"])
                            loadDevices()
                        }
                    }
                }
                
                Text {
                    text: "󰆏"
                    color: Theme.subtext0
                    font.family: Theme.iconFont
                    font.pixelSize: 20
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: bluetoothPanel.close()
                    }
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Power toggle
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 12
            color: powerMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                
                Text {
                    id: powerIcon
                    text: "󰂲"
                    color: Theme.blue
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                }
                
                Text {
                    text: "Bluetooth"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    Layout.fillWidth: true
                }
                
                Switch {
                    id: powerSwitch
                    checked: false
                    Layout.alignment: Qt.AlignRight
                    
                    indicator: Rectangle {
                        implicitWidth: 48
                        implicitHeight: 24
                        radius: 12
                        color: powerSwitch.checked ? Theme.blue : Theme.surface1
                        border.color: powerSwitch.checked ? Theme.blue : Theme.overlay0
                        
                        Rectangle {
                            x: powerSwitch.checked ? parent.width - width - 2 : 2
                            y: 2
                            width: 20
                            height: 20
                            radius: 10
                            color: Theme.text
                            Behavior on x { NumberAnimation { duration: 100 } }
                        }
                    }
                    
                    onCheckedChanged: {
                        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh toggle"], function() {
                            loadDevices()
                        })
                    }
                }
            }
            
            MouseArea {
                id: powerMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: powerSwitch.toggle()
            }
        }
        
        // Connected devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: connectedDevices.count > 0
            
            Text {
                text: "Connected"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            ListView {
                id: connectedDevices
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 200)
                model: ListModel { id: connectedModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: connectedDevices.width
                    height: 60
                    radius: 12
                    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 8
                            color: Theme.surface2
                            
                            Text {
                                anchors.centerIn: parent
                                text: getDeviceIcon(model.type)
                                color: Theme.text
                                font.family: Theme.iconFont
                                font.pixelSize: 20
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.name
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            RowLayout {
                                Text {
                                    text: model.mac
                                    color: Theme.subtext0
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                }
                                
                                Text {
                                    visible: model.battery && model.battery !== "null"
                                    text: model.battery + "%"
                                    color: getBatteryColor(model.battery)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                        
                        Text {
                            text: "󰄾"
                            color: Theme.red
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh disconnect " + model.mac], function() {
                                loadDevices()
                            })
                        }
                    }
                }
            }
        }
        
        // Available devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Available Devices"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            ListView {
                id: availableDevices
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel { id: availableModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: availableDevices.width
                    height: 60
                    radius: 12
                    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 8
                            color: Theme.surface2
                            
                            Text {
                                anchors.centerIn: parent
                                text: getDeviceIcon(model.type)
                                color: Theme.text
                                font.family: Theme.iconFont
                                font.pixelSize: 20
                            }
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.name
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: model.mac
                                color: Theme.subtext0
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                            }
                        }
                        
                        Text {
                            visible: !model.paired
                            text: "󰢱"
                            color: Theme.green
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            visible: model.paired && !model.connected
                            text: "󰂱"
                            color: Theme.blue
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!model.paired) {
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh pair " + model.mac], function() {
                                    loadDevices()
                                })
                            } else if (!model.connected) {
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh connect " + model.mac], function() {
                                    loadDevices()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 3000
        running: bluetoothPanel.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: loadDevices()
    }
    
    function getDeviceIcon(type) {
        switch(type) {
            case "audio-headset": return "󰋋"
            case "audio-card": return "󰋎"
            case "input-gaming": return "󰍴"
            case "input-keyboard": return "󰌌"
            case "input-mouse": return "󰍽"
            case "phone": return "󰄜"
            default: return "󰂯"
        }
    }
    
    function getBatteryColor(battery) {
        if (battery === "null") return Theme.subtext0
        var bat = parseInt(battery)
        if (bat > 60) return Theme.green
        if (bat > 20) return Theme.yellow
        return Theme.red
    }
    
    function loadDevices() {
        // Load status
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh status"], function(result) {
            try {
                var status = JSON.parse(result)
                powerSwitch.checked = status.powered === "yes"
                powerIcon.text = status.powered === "yes" ? "󰂯" : "󰂲"
            } catch (e) {
                console.log("Error parsing bluetooth status:", e)
            }
        })
        
        // Load devices
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/bluetooth.sh list"], function(result) {
            try {
                var devices = JSON.parse(result)
                connectedModel.clear()
                availableModel.clear()
                
                for (var i = 0; i < devices.length; i++) {
                    if (devices[i].connected) {
                        connectedModel.append(devices[i])
                    } else {
                        availableModel.append(devices[i])
                    }
                }
            } catch (e) {
                console.log("Error parsing bluetooth devices:", e)
            }
        })
    }
    
    Component.onCompleted: loadDevices()
}