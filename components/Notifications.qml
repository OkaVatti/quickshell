// FILE: /home/lilith/code-shit/quickshell/components/Notifications.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: notifications
    width: notificationLayout.width + Theme.padding * 2
    height: 30
    radius: Theme.borderRadius - 4
    color: mouseArea.containsMouse ? Theme.surface1 : Theme.surface0
    
    Behavior on color { ColorAnimation { duration: 150 } }
    
    property int notificationCount: 0
    property var notifications: []
    
    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkNotifications()
    }
    
    function checkNotifications() {
        // Check for notifications using system dbus
        Process.exec(["bash", "-c", "~/.config/omarchy/scripts/notifications.sh count"], function(result) {
            try {
                var data = JSON.parse(result)
                notificationCount = data.count || 0
            } catch (e) {}
        })
    }
    
    RowLayout {
        id: notificationLayout
        anchors.centerIn: parent
        spacing: Theme.spacing
        
        Text {
            text: notificationCount > 0 ? "󱅫" : "󰂚"
            color: notificationCount > 0 ? Theme.yellow : Theme.subtext0
            font.family: Theme.iconFont
            font.pixelSize: Theme.iconSize
        }
        
        Rectangle {
            visible: notificationCount > 0
            width: countText.width + 8
            height: 16
            radius: 8
            color: Theme.yellow
            
            Text {
                id: countText
                anchors.centerIn: parent
                text: notificationCount
                color: Theme.base
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            Process.exec(["quickshell", "-c", "~/.config/quickshell/panels/NotificationsPanel.qml"])
        }
    }
}