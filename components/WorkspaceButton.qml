import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: button
    
    property int workspaceNum: 1
    property string workspaceName: "1"
    property bool isActive: false
    property bool isVisible: false
    property bool isUrgent: false
    
    width: 35
    height: 30
    radius: Theme.borderRadius - 4
    
    color: isActive ? Theme.blue : (isVisible ? Theme.surface1 : Theme.surface0)
    opacity: isActive ? 1.0 : (isVisible ? 0.8 : 0.5)
    
    border.color: isUrgent ? Theme.red : "transparent"
    border.width: isUrgent ? 2 : 0
    
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on opacity { NumberAnimation { duration: 200 } }
    
    Text {
        anchors.centerIn: parent
        text: workspaceName
        color: isActive ? Theme.base : Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.bold: isActive
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: parent.opacity = 1.0
        onExited: parent.opacity = isActive ? 1.0 : (isVisible ? 0.8 : 0.5)
        
        onClicked: {
            Process.exec(["swaymsg", "workspace", "number", workspaceNum.toString()])
        }
    }
}