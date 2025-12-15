// FILE: /home/lilith/code-shit/quickshell/panels/NetworkPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: networkPanel
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
                text: "󰖪"
                color: Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: 24
            }
            
            Text {
                text: "Network"
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
                    onClicked: networkPanel.close()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Current connection
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Current Connection"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 80
                radius: 12
                color: Theme.surface0
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4
                    
                    RowLayout {
                        Text {
                            id: connectionIcon
                            text: "󰖪"
                            color: Theme.green
                            font.family: Theme.iconFont
                            font.pixelSize: 20
                        }
                        
                        Text {
                            id: connectionName
                            text: "Disconnected"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            id: signalStrength
                            text: ""
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                        }
                    }
                    
                    Text {
                        id: ipAddress
                        text: "IP: Not connected"
                        color: Theme.subtext0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }
                    
                    RowLayout {
                        Text {
                            id: downloadSpeed
                            text: "󰁅 0 KB/s"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                        }
                        
                        Text {
                            id: uploadSpeed
                            text: "󰁝 0 KB/s"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 12
                color: toggleMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        text: "󰀾"
                        color: Theme.blue
                        font.family: Theme.iconFont
                        font.pixelSize: 18
                    }
                    
                    Text {
                        text: "WiFi"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.fillWidth: true
                    }
                    
                    Switch {
                        id: wifiSwitch
                        checked: true
                        Layout.alignment: Qt.AlignRight
                        
                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 24
                            radius: 12
                            color: wifiSwitch.checked ? Theme.blue : Theme.surface1
                            border.color: wifiSwitch.checked ? Theme.blue : Theme.overlay0
                            
                            Rectangle {
                                x: wifiSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: Theme.text
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }
                        }
                        
                        onCheckedChanged: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh toggle"])
                        }
                    }
                }
                
                MouseArea {
                    id: toggleMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: wifiSwitch.toggle()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Available networks
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Text {
                    text: "Available Networks"
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.bold: true
                    Layout.fillWidth: true
                }
                
                Text {
                    text: "󰑓"
                    color: refreshMouseArea.containsMouse ? Theme.blue : Theme.subtext0
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                    
                    MouseArea {
                        id: refreshMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: loadNetworks()
                    }
                }
            }
            
            ListView {
                id: networksList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: ListModel { id: networksModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: networksList.width
                    height: 56
                    radius: 12
                    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: getSignalIcon(model.signal)
                            color: Theme.green
                            font.family: Theme.iconFont
                            font.pixelSize: 20
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.ssid || "Hidden Network"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            RowLayout {
                                Text {
                                    text: model.signal + "%"
                                    color: Theme.subtext0
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                }
                                
                                Text {
                                    text: model.security || "Open"
                                    color: Theme.subtext0
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                        
                        Text {
                            text: "󰖩"
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
                            if (model.security && model.security !== "Open") {
                                passwordDialog.network = model.ssid
                                passwordDialog.open()
                            } else {
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh connect \"" + model.ssid + "\""], function() {
                                    loadNetworks()
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    Dialog {
        id: passwordDialog
        property string network: ""
        
        title: "Connect to " + network
        anchors.centerIn: parent
        width: 300
        height: 200
        modal: true
        
        background: Rectangle {
            color: Theme.base
            radius: 12
            border.color: Theme.surface1
            border.width: 1
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            TextField {
                id: passwordField
                placeholderText: "Password"
                echoMode: TextInput.Password
                Layout.fillWidth: true
                
                background: Rectangle {
                    color: Theme.surface0
                    radius: 8
                    border.color: Theme.surface1
                    border.width: 1
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                Button {
                    text: "Cancel"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: Theme.surface0
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: Theme.text
                        font.family: Theme.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: passwordDialog.close()
                }
                
                Button {
                    text: "Connect"
                    Layout.fillWidth: true
                    
                    background: Rectangle {
                        color: Theme.blue
                        radius: 8
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: Theme.base
                        font.family: Theme.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh connect \"" + passwordDialog.network + "\" \"" + passwordField.text + "\""], function() {
                            passwordDialog.close()
                            loadNetworks()
                        })
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 2000
        running: networkPanel.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: loadNetworkInfo()
    }
    
    function getSignalIcon(signal) {
        var sig = parseInt(signal)
        if (sig > 75) return "󰤨"
        if (sig > 50) return "󰤥"
        if (sig > 25) return "󰤢"
        return "󰤟"
    }
    
    function loadNetworkInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh info"], function(result) {
            try {
                var info = JSON.parse(result)
                connectionIcon.text = getSignalIcon(info.signal)
                connectionName.text = info.ssid || "Disconnected"
                signalStrength.text = info.signal ? info.signal + "%" : ""
                ipAddress.text = info.ip ? "IP: " + info.ip : "IP: Not connected"
                downloadSpeed.text = "󰁅 " + info.download + " KB/s"
                uploadSpeed.text = "󰁝 " + info.upload + " KB/s"
                
                wifiSwitch.checked = info.type === "WiFi" || info.type === "Ethernet"
            } catch (e) {
                console.log("Error parsing network info:", e)
            }
        })
    }
    
    function loadNetworks() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/network.sh list"], function(result) {
            try {
                var networks = JSON.parse(result)
                networksModel.clear()
                for (var i = 0; i < networks.length; i++) {
                    networksModel.append(networks[i])
                }
            } catch (e) {
                console.log("Error parsing networks:", e)
            }
        })
    }
    
    Component.onCompleted: {
        loadNetworkInfo()
        loadNetworks()
    }
}