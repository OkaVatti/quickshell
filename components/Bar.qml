import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

Rectangle {
    id: bar
    
    property var screen
    
    color: Theme.mantle
    opacity: 0.95
    radius: Theme.borderRadius
    
    // Blur effect background
    layer.enabled: true
    layer.effect: ShaderEffect {
        fragmentShader: "
            uniform lowp sampler2D source;
            uniform lowp float qt_Opacity;
            varying highp vec2 qt_TexCoord0;
            void main() {
                gl_FragColor = texture2D(source, qt_TexCoord0) * qt_Opacity;
            }
        "
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.margin
        spacing: Theme.spacing
        
        // Left side
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: Theme.spacing
            
            Workspace {
                Layout.preferredWidth: 300
                Layout.preferredHeight: parent.height
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