// FILE: /home/lilith/code-shit/quickshell/panels/AudioPanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: audioPanel
    screen: rootScreen
    height: 400
    width: 320
    color: "transparent"
    
    property int panelMargin: 16
    property real cornerRadius: 24
    
    Rectangle {
        id: panelBackground
        anchors.fill: parent
        color: Theme.base
        opacity: 0.95
        radius: cornerRadius
        
        // Blur effect
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
        
        // Drop shadow
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
                text: "󰓃"
                color: Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: 24
            }
            
            Text {
                text: "Audio"
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
                    onClicked: audioPanel.close()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Output Devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Output"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            ListView {
                id: sinksList
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                model: ListModel { id: sinksModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: sinksList.width
                    height: 48
                    radius: 12
                    color: model.default ? Theme.blue : (mouseArea.containsMouse ? Theme.surface1 : Theme.surface0)
                    border.color: model.default ? Theme.blue : "transparent"
                    border.width: 2
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        Text {
                            text: model.default ? "󰕾" : "󰕿"
                            color: model.default ? Theme.base : Theme.text
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            
                            Text {
                                text: model.description
                                color: model.default ? Theme.base : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: model.name
                                color: model.default ? Theme.base : Theme.subtext0
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        
                        Text {
                            visible: model.default
                            text: "󰄬"
                            color: Theme.base
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh set-sink " + model.name], function() {
                                loadAudioInfo()
                            })
                        }
                    }
                }
            }
            
            // Volume Slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                RowLayout {
                    Text {
                        text: "Volume"
                        color: Theme.subtext0
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                    
                    Text {
                        id: volumeText
                        text: "50%"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.alignment: Qt.AlignRight
                    }
                }
                
                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 150
                    value: 50
                    
                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        width: volumeSlider.availableWidth
                        height: 6
                        radius: 3
                        color: Theme.surface1
                        
                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 3
                            color: Theme.blue
                        }
                    }
                    
                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        width: 20
                        height: 20
                        radius: 10
                        color: Theme.blue
                        border.color: Theme.base
                        border.width: 2
                    }
                    
                    onMoved: {
                        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh set-volume " + Math.round(value)])
                    }
                }
            }
            
            // Mute button
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 12
                color: muteMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    Text {
                        id: muteIcon
                        text: "󰖁"
                        color: Theme.red
                        font.family: Theme.iconFont
                        font.pixelSize: 16
                    }
                    
                    Text {
                        text: "Mute"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        Layout.fillWidth: true
                    }
                    
                    Switch {
                        id: muteSwitch
                        checked: false
                        Layout.alignment: Qt.AlignRight
                        
                        indicator: Rectangle {
                            implicitWidth: 48
                            implicitHeight: 24
                            radius: 12
                            color: muteSwitch.checked ? Theme.red : Theme.surface1
                            border.color: muteSwitch.checked ? Theme.red : Theme.overlay0
                            
                            Rectangle {
                                x: muteSwitch.checked ? parent.width - width - 2 : 2
                                y: 2
                                width: 20
                                height: 20
                                radius: 10
                                color: Theme.text
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }
                        }
                        
                        onCheckedChanged: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh toggle-mute"])
                        }
                    }
                }
                
                MouseArea {
                    id: muteMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: muteSwitch.toggle()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Input Devices
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Input"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            ListView {
                id: sourcesList
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                model: ListModel { id: sourcesModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: sourcesList.width
                    height: 40
                    radius: 12
                    color: model.default ? Theme.green : (mouseArea.containsMouse ? Theme.surface1 : Theme.surface0)
                    border.color: model.default ? Theme.green : "transparent"
                    border.width: 2
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        
                        Text {
                            text: model.default ? "󰍬" : "󰍭"
                            color: model.default ? Theme.base : Theme.text
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                        
                        Text {
                            text: model.description
                            color: model.default ? Theme.base : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            visible: model.default
                            text: "󰄬"
                            color: Theme.base
                            font.family: Theme.iconFont
                            font.pixelSize: 16
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh set-source " + model.name], function() {
                                loadAudioInfo()
                            })
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 1000
        running: audioPanel.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: loadAudioInfo()
    }
    
    function loadAudioInfo() {
        // Load sinks
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh list-sinks"], function(result) {
            try {
                var sinks = JSON.parse(result)
                sinksModel.clear()
                for (var i = 0; i < sinks.length; i++) {
                    sinksModel.append(sinks[i])
                }
            } catch (e) {
                console.log("Error parsing sinks:", e)
            }
        })
        
        // Load sources
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh list-sources"], function(result) {
            try {
                var sources = JSON.parse(result)
                sourcesModel.clear()
                for (var i = 0; i < sources.length; i++) {
                    sourcesModel.append(sources[i])
                }
            } catch (e) {
                console.log("Error parsing sources:", e)
            }
        })
        
        // Load current volume
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh info"], function(result) {
            try {
                var info = JSON.parse(result)
                volumeText.text = info.volume + "%"
                volumeSlider.value = info.volume
                muteSwitch.checked = info.muted === "true"
                muteIcon.text = info.muted === "true" ? "󰖁" : "󰕿"
            } catch (e) {
                console.log("Error parsing audio info:", e)
            }
        })
    }
    
    Component.onCompleted: loadAudioInfo()
}