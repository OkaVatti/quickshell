import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: mediaPlayer
    width: mediaLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    visible: mediaData.status !== "Stopped" && mediaData.title !== ""
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property var mediaData: ({
        "status": "Stopped",
        "title": "",
        "artist": "",
        "album": "",
        "art_url": "",
        "position": 0,
        "length": 0,
        "player": ""
    })
    
    property string scriptPath: Quickshell.env("HOME") + "/.config/omarchy/scripts/media.sh"
    property bool seeking: false
    property real seekTarget: 0
    
    Timer {
        interval: 1000
        running: mediaData.status === "Playing" && !seeking
        repeat: true
        triggeredOnStart: true
        onTriggered: updateMediaInfo()
    }
    
    function updateMediaInfo() {
        Process.exec(["bash", scriptPath, "info"], function(result) {
            try {
                var parsed = JSON.parse(result)
                if (parsed.title !== mediaData.title || parsed.artist !== mediaData.artist) {
                    mediaData = parsed
                } else {
                    // Only update position if same track to avoid flickering
                    mediaData.position = parsed.position
                    mediaData.status = parsed.status
                }
            } catch (e) {
                console.log("Error parsing media data:", e)
            }
        })
    }
    
    function executeCommand(command, arg) {
        var cmd = [scriptPath, command]
        if (arg !== undefined) cmd.push(arg)
        
        Process.exec(["bash", cmd.join(" ")], function(result) {
            try {
                mediaData = JSON.parse(result)
            } catch (e) {
                updateMediaInfo()
            }
        })
    }
    
    function formatTime(seconds) {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
            }
        }
        
        onDoubleClicked: {
            executeCommand("play-pause")
        }
    }
    
    RowLayout {
        id: mediaLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        // Play/Pause Icon
        Rectangle {
            width: 24
            height: 24
            radius: 4
            color: playPauseMouseArea.containsMouse ? Theme.surface2 : "transparent"
            
            Text {
                anchors.centerIn: parent
                text: mediaData.status === "Playing" ? "󰏤" : "󰐊"
                color: Theme.green
                font.family: Theme.iconFont
                font.pixelSize: 14
            }
            
            MouseArea {
                id: playPauseMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: executeCommand("play-pause")
            }
        }
        
        // Track info
        ColumnLayout {
            spacing: 0
            
            Text {
                text: mediaData.title.substring(0, 30) + (mediaData.title.length > 30 ? "..." : "")
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
                elide: Text.ElideRight
                Layout.maximumWidth: 200
            }
            
            RowLayout {
                spacing: 4
                
                Text {
                    text: mediaData.artist
                    color: Theme.subtext0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    elide: Text.ElideRight
                    Layout.maximumWidth: 150
                }
                
                Text {
                    visible: mediaData.length > 0
                    text: formatTime(mediaData.position) + " / " + formatTime(mediaData.length)
                    color: Theme.subtext1
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
            }
        }
        
        // Control buttons
        RowLayout {
            spacing: 2
            
            // Previous button
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: prevMouseArea.containsMouse ? Theme.surface2 : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: Theme.text
                    font.family: Theme.iconFont
                    font.pixelSize: 14
                }
                
                MouseArea {
                    id: prevMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: executeCommand("previous")
                }
            }
            
            // Next button
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: nextMouseArea.containsMouse ? Theme.surface2 : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: Theme.text
                    font.family: Theme.iconFont
                    font.pixelSize: 14
                }
                
                MouseArea {
                    id: nextMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: executeCommand("next")
                }
            }
            
            // Stop button
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: stopMouseArea.containsMouse ? Theme.surface2 : "transparent"
                visible: mediaData.status !== "Stopped"
                
                Text {
                    anchors.centerIn: parent
                    text: "󰓛"
                    color: Theme.red
                    font.family: Theme.iconFont
                    font.pixelSize: 14
                }
                
                MouseArea {
                    id: stopMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: executeCommand("stop")
                }
            }
        }
        
        // Progress bar (visible on hover)
        Rectangle {
            id: progressBarContainer
            width: 150
            height: 4
            radius: 2
            color: Theme.surface2
            visible: mouseArea.containsMouse && mediaData.length > 0
            
            Rectangle {
                id: progressBar
                width: mediaData.length > 0 ? (parent.width * mediaData.position / mediaData.length) : 0
                height: parent.height
                radius: 2
                color: Theme.mauve
                
                Behavior on width {
                    enabled: !seeking
                    NumberAnimation { duration: 200 }
                }
            }
            
            MouseArea {
                id: seekArea
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: function(mouse) {
                    if (mediaData.length > 0) {
                        var percent = mouse.x / width
                        seekTarget = Math.floor(percent * mediaData.length)
                        seeking = true
                        executeCommand("seek", "+" + seekTarget)
                        
                        // Update position immediately for visual feedback
                        mediaData.position = seekTarget
                        
                        seeking = false
                    }
                }
            }
        }
    }
    
    // Context menu for additional controls
    Menu {
        id: contextMenu
        
        MenuItem {
            text: "Switch Player"
            onTriggered: playersMenu.popup()
        }
        
        MenuSeparator {}
        
        MenuItem {
            text: "Copy Track Info"
            onTriggered: {
                var info = mediaData.title + " - " + mediaData.artist
                Quickshell.clipboard.writeText(info)
            }
        }
    }
    
    Menu {
        id: playersMenu
        
        Instantiator {
            model: ListModel { id: playersModel }
            
            delegate: MenuItem {
                text: model.player + (model.status === "Playing" ? " ▶" : "")
                checkable: true
                checked: mediaData.player === model.player
                onTriggered: executeCommand("switch-player", model.player)
            }
            
            onObjectAdded: function(index, object) {
                playersMenu.insertItem(index, object)
            }
            onObjectRemoved: function(index, object) {
                playersMenu.removeItem(object)
            }
        }
        
        onAboutToShow: {
            Process.exec(["bash", scriptPath, "list-players"], function(result) {
                try {
                    var players = JSON.parse(result)
                    playersModel.clear()
                    for (var i = 0; i < players.length; i++) {
                        playersModel.append(players[i])
                    }
                } catch (e) {
                    console.log("Error parsing players list:", e)
                }
            })
        }
    }
    
    // Album art tooltip on hover
    ToolTip {
        id: albumArtTooltip
        visible: mouseArea.containsMouse && mediaData.art_url !== ""
        delay: 500
        
        contentItem: Image {
            id: albumArt
            width: 200
            height: 200
            source: mediaData.art_url
            fillMode: Image.PreserveAspectFit
            
            Rectangle {
                anchors.fill: parent
                color: Theme.surface0
                opacity: 0.3
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                
                Text {
                    text: mediaData.title
                    color: Theme.text
                    font.bold: true
                    font.pixelSize: 16
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: mediaData.artist
                    color: Theme.subtext0
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: mediaData.album
                    color: Theme.subtext1
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}