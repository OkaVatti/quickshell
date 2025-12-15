// FILE: /home/lilith/code-shit/quickshell/components/Bar.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

Rectangle {
    id: bar
    
    property var screen
    
    color: "transparent"
    
    // Blur effect background with rounded corners
    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: Theme.borderRadius
        color: Theme.mantle
        opacity: 0.95
        
        // Frosted glass effect
        layer.enabled: true
        layer.effect: ShaderEffect {
            property real blurRadius: 20
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
        
        // Subtle border
        border.color: Theme.surface0
        border.width: 1
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: Theme.spacing
        
        // Left side
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: Theme.spacing
            
            Workspace {
                Layout.preferredWidth: 300
                Layout.preferredHeight: parent.height
            }
            
            // Application launcher button
            Rectangle {
                width: 30
                height: 30
                radius: 8
                color: launcherMouseArea.containsMouse ? Theme.surface1 : Theme.surface0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰣇"
                    color: Theme.text
                    font.family: Theme.iconFont
                    font.pixelSize: 16
                }
                
                MouseArea {
                    id: launcherMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        Process.exec(["bash", "-c", "rofi -show drun -theme ~/.config/rofi/launcher.rasi"])
                    }
                }
            }
        }
        
        // Center
        Item {
            Layout.fillWidth: true
            
            Clock {
                anchors.centerIn: parent
            }
        }
        
        // Right side
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: Theme.spacing
            
            Notifications {
                Layout.preferredHeight: parent.height
            }
            
            MediaPlayer {
                Layout.preferredHeight: parent.height
            }
            
            SystemTray {
                Layout.preferredHeight: parent.height
            }
            
            Network {
                Layout.preferredHeight: parent.height
            }
            
            Bluetooth {
                Layout.preferredHeight: parent.height
            }
            
            Audio {
                Layout.preferredHeight: parent.height
            }
            
            Performance {
                Layout.preferredHeight: parent.height
            }
        }
    }
}