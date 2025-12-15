import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: panel
            property var modelData
            screen: modelData
            
            anchors {
                top: true
                left: true
                right: true
            }
            
            height: 40
            color: "transparent"
            
            Bar {
                anchors.fill: parent
                screen: modelData
            }
        }
    }
}