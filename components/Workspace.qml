import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../theme"

RowLayout {
    id: workspaceWidget
    spacing: Theme.spacing
    
    property var workspaces: []
    property int activeWorkspace: 1
    
    Process {
        id: workspaceProc
        command: ["bash", "-c", "swaymsg -t subscribe -m '[\"workspace\"]'"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data)
                    if (json.change === "focus") {
                        activeWorkspace = json.current.num
                    }
                    updateWorkspaces()
                } catch (e) {
                    console.log("Error parsing workspace data:", e)
                }
            }
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateWorkspaces()
    }
    
    Component.onCompleted: updateWorkspaces()
    
    function updateWorkspaces() {
        Process.exec(["swaymsg", "-t", "get_workspaces", "-r"], function(result) {
            try {
                var ws = JSON.parse(result)
                workspaces = ws
                recreateWorkspaceButtons()
            } catch (e) {
                console.log("Error parsing workspaces:", e)
            }
        })
    }
    
    function recreateWorkspaceButtons() {
        // Remove old buttons
        for (var i = children.length - 1; i >= 0; i--) {
            if (children[i].objectName === "workspaceButton") {
                children[i].destroy()
            }
        }
        
        // Create new buttons
        for (var j = 0; j < workspaces.length; j++) {
            var ws = workspaces[j]
            createWorkspaceButton(ws)
        }
    }
    
    function createWorkspaceButton(workspace) {
        var component = Qt.createComponent("WorkspaceButton.qml")
        if (component.status === Component.Ready) {
            var button = component.createObject(workspaceWidget, {
                "workspaceNum": workspace.num,
                "workspaceName": workspace.name,
                "isActive": workspace.focused,
                "isVisible": workspace.visible,
                "isUrgent": workspace.urgent,
                "objectName": "workspaceButton"
            })
        }
    }
}