import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: clock
    width: clockLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: Theme.surface0
    
    property string currentTime: ""
    property string currentDate: ""
    property int unreadMail: 0
    property var upcomingEvents: []
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            currentTime = Qt.formatTime(now, "hh:mm:ss")
            currentDate = Qt.formatDate(now, "ddd, MMM dd")
        }
    }
    
    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkCalendar()
            checkMail()
        }
    }
    
    function checkCalendar() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/calendar.sh events"], function(result) {
            try {
                var data = JSON.parse(result)
                upcomingEvents = data.events || []
            } catch (e) {}
        })
    }
    
    function checkMail() {
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/mail.sh count"], function(result) {
            try {
                var data = JSON.parse(result)
                unreadMail = data.unread || 0
            } catch (e) {}
        })
    }
    
    RowLayout {
        id: clockLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: "󰃭"
            color: Theme.blue
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        ColumnLayout {
            spacing: 0
            
            Text {
                text: currentTime
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
            }
            
            Text {
                text: currentDate
                color: Theme.subtext0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
        
        Rectangle {
            visible: unreadMail > 0
            width: mailText.width + 8
            height: 16
            radius: 8
            color: Theme.red
            
            Text {
                id: mailText
                anchors.centerIn: parent
                text: unreadMail
                color: Theme.base
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }
        
        Rectangle {
            visible: upcomingEvents.length > 0
            width: 6
            height: 6
            radius: 3
            color: Theme.green
        }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/SystemPanel.qml"])
        }
    }
}