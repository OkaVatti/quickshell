import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: audio
    width: audioLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var audioData: ({
        "volume": 50,
        "muted": false,
        "mic_muted": false
    })
    
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateAudioInfo()
    }
    
    function updateAudioInfo() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh info"], function(result) {
            try {
                audioData = JSON.parse(result)
            } catch (e) {
                console.log("Error parsing audio data:", e)
            }
        })
    }
    
    function getVolumeIcon() {
        if (audioData.muted) return "󰖁"
        if (audioData.volume > 66) return "󰕾"
        if (audioData.volume > 33) return "󰖀"
        if (audioData.volume > 0) return "󰕿"
        return "󰖁"
    }
    
    RowLayout {
        id: audioLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: getVolumeIcon()
            color: audioData.muted ? Theme.red : Theme.text
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        Text {
            text: audioData.volume + "%"
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        
        Text {
            visible: !audioData.mic_muted
            text: ""
            color: Theme.green
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize - 4
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/AudioPanel.qml"])
        }
        
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh volume-up"])
            } else {
                Process.exec(["bash", "-c", "~/.config/omarchy/scripts/audio.sh volume-down"])
            }
        }
    }
}