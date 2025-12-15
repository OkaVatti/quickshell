// FILE: /home/lilith/code-shit/quickshell/panels/PerformancePanel.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

PanelWindow {
    id: performancePanel
    screen: rootScreen
    height: 600
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
                id: profileIcon
                text: "󰾆"
                color: Theme.blue
                font.family: Theme.iconFont
                font.pixelSize: 24
            }
            
            Text {
                text: "Performance"
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
                    onClicked: performancePanel.close()
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.surface0
        }
        
        // Performance profiles
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Performance Profile"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                
                Repeater {
                    model: ListModel {
                        ListElement { name: "Power Save"; value: "power-save"; icon: "󰾅"; color: "green" }
                        ListElement { name: "Balanced"; value: "balanced"; icon: "󰾆"; color: "blue" }
                        ListElement { name: "Performance"; value: "performance"; icon: "󰓅"; color: "yellow" }
                        ListElement { name: "Overclock"; value: "overclock"; icon: "󱐋"; color: "red" }
                    }
                    
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        radius: 12
                        color: model.value === currentProfile ? Theme[model.color] : (profileMouseArea.containsMouse ? Theme.surface1 : Theme.surface0)
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                text: model.icon
                                color: model.value === currentProfile ? Theme.base : Theme[model.color]
                                font.family: Theme.iconFont
                                font.pixelSize: 20
                            }
                            
                            Text {
                                text: model.name
                                color: model.value === currentProfile ? Theme.base : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                visible: model.value === currentProfile
                                text: "󰄬"
                                color: Theme.base
                                font.family: Theme.iconFont
                                font.pixelSize: 16
                            }
                        }
                        
                        MouseArea {
                            id: profileMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                currentProfile = model.value
                                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/performance.sh profile " + model.value], function() {
                                    loadPerformanceInfo()
                                })
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
        
        // CPU Stats
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "CPU"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 100
                radius: 12
                color: Theme.surface0
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    RowLayout {
                        Text {
                            text: "Usage"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        
                        Text {
                            id: cpuUsage
                            text: "0%"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    
                    ProgressBar {
                        id: cpuBar
                        Layout.fillWidth: true
                        value: 0
                        from: 0
                        to: 100
                        
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 8
                            color: Theme.surface1
                            radius: 4
                        }
                        
                        contentItem: Item {
                            Rectangle {
                                width: cpuBar.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Theme.blue }
                                    GradientStop { position: 1.0; color: Theme.lavender }
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "Temperature"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        
                        Text {
                            id: cpuTemp
                            text: "0°C"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
        
        // Memory Stats
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Memory"
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
                    spacing: 8
                    
                    RowLayout {
                        Text {
                            text: "Usage"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        
                        Text {
                            id: memUsage
                            text: "0%"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    
                    ProgressBar {
                        id: memBar
                        Layout.fillWidth: true
                        value: 0
                        from: 0
                        to: 100
                        
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 8
                            color: Theme.surface1
                            radius: 4
                        }
                        
                        contentItem: Item {
                            Rectangle {
                                width: memBar.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Theme.mauve }
                                    GradientStop { position: 1.0; color: Theme.pink }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // GPU Stats
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: hasGPU
            
            Text {
                text: "GPU"
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
                    spacing: 8
                    
                    RowLayout {
                        Text {
                            text: "Usage"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        
                        Text {
                            id: gpuUsage
                            text: "0%"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    
                    ProgressBar {
                        id: gpuBar
                        Layout.fillWidth: true
                        value: 0
                        from: 0
                        to: 100
                        
                        background: Rectangle {
                            implicitWidth: 200
                            implicitHeight: 8
                            color: Theme.surface1
                            radius: 4
                        }
                        
                        contentItem: Item {
                            Rectangle {
                                width: gpuBar.visualPosition * parent.width
                                height: parent.height
                                radius: 4
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Theme.red }
                                    GradientStop { position: 1.0; color: Theme.peach }
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Text {
                            text: "Temperature"
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                        
                        Text {
                            id: gpuTemp
                            text: "0°C"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                }
            }
        }
        
        // Process list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Top Processes"
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }
            
            ListView {
                id: processList
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                model: ListModel { id: processModel }
                spacing: 4
                clip: true
                
                delegate: Rectangle {
                    width: processList.width
                    height: 36
                    radius: 8
                    color: Theme.surface0
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8
                        
                        Text {
                            text: (index + 1) + "."
                            color: Theme.subtext0
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                        }
                        
                        Text {
                            text: model.command.substring(0, 30) + (model.command.length > 30 ? "..." : "")
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        RowLayout {
                            spacing: 12
                            
                            Text {
                                text: model.cpu + "%"
                                color: Theme.blue
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.bold: true
                            }
                            
                            Text {
                                text: model.mem + "%"
                                color: Theme.mauve
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 2000
        running: performancePanel.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: loadPerformanceInfo()
    }
    
    property string currentProfile: "balanced"
    property bool hasGPU: false
    
    function loadPerformanceInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/performance.sh info"], function(result) {
            try {
                var info = JSON.parse(result)
                currentProfile = info.profile
                profileIcon.text = getProfileIcon(info.profile)
                
                // CPU
                cpuUsage.text = Math.round(info.cpu.usage) + "%"
                cpuBar.value = info.cpu.usage
                cpuTemp.text = Math.round(info.cpu.temperature) + "°C"
                
                // Memory
                memUsage.text = info.memory.percent.toFixed(1) + "%"
                memBar.value = info.memory.percent
                
                // GPU
                hasGPU = info.gpu && info.gpu.usage !== undefined
                if (hasGPU) {
                    gpuUsage.text = Math.round(info.gpu.usage) + "%"
                    gpuBar.value = info.gpu.usage
                    gpuTemp.text = Math.round(info.gpu.temperature) + "°C"
                }
            } catch (e) {
                console.log("Error parsing performance info:", e)
            }
        })
        
        // Load processes
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/performance.sh processes"], function(result) {
            try {
                var processes = JSON.parse(result)
                processModel.clear()
                for (var i = 0; i < Math.min(processes.length, 5); i++) {
                    processModel.append(processes[i])
                }
            } catch (e) {
                console.log("Error parsing processes:", e)
            }
        })
    }
    
    function getProfileIcon(profile) {
        switch(profile) {
            case "power-save": return "󰾅"
            case "balanced": return "󰾆"
            case "performance": return "󰓅"
            case "overclock": return "󱐋"
            default: return "󰾆"
        }
    }
    
    Component.onCompleted: loadPerformanceInfo()
}