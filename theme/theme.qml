pragma Singleton
import QtQuick

QtObject {
    id: theme
    
    // Load colors from omarchy theme
    property string themeFile: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/omarchy/current-theme.json"
    property var themeData: ({})
    
    Component.onCompleted: {
        loadTheme()
    }
    
    function loadTheme() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + themeFile)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        themeData = JSON.parse(xhr.responseText)
                    } catch (e) {
                        console.log("Failed to parse theme:", e)
                        loadDefaultTheme()
                    }
                } else {
                    loadDefaultTheme()
                }
            }
        }
        xhr.send()
    }
    
    function loadDefaultTheme() {
        themeData = {
            "base": "#1e1e2e",
            "mantle": "#181825",
            "crust": "#11111b",
            "text": "#cdd6f4",
            "subtext0": "#a6adc8",
            "subtext1": "#bac2de",
            "surface0": "#313244",
            "surface1": "#45475a",
            "surface2": "#585b70",
            "overlay0": "#6c7086",
            "overlay1": "#7f849c",
            "overlay2": "#9399b2",
            "blue": "#89b4fa",
            "lavender": "#b4befe",
            "sapphire": "#74c7ec",
            "sky": "#89dceb",
            "teal": "#94e2d5",
            "green": "#a6e3a1",
            "yellow": "#f9e2af",
            "peach": "#fab387",
            "maroon": "#eba0ac",
            "red": "#f38ba8",
            "mauve": "#cba6f7",
            "pink": "#f5c2e7",
            "flamingo": "#f2cdcd",
            "rosewater": "#f5e0dc"
        }
    }
    
    // Color properties
    property color base: themeData.base || "#1e1e2e"
    property color mantle: themeData.mantle || "#181825"
    property color crust: themeData.crust || "#11111b"
    property color text: themeData.text || "#cdd6f4"
    property color subtext0: themeData.subtext0 || "#a6adc8"
    property color subtext1: themeData.subtext1 || "#bac2de"
    property color surface0: themeData.surface0 || "#313244"
    property color surface1: themeData.surface1 || "#45475a"
    property color surface2: themeData.surface2 || "#585b70"
    property color overlay0: themeData.overlay0 || "#6c7086"
    property color overlay1: themeData.overlay1 || "#7f849c"
    property color overlay2: themeData.overlay2 || "#9399b2"
    property color blue: themeData.blue || "#89b4fa"
    property color lavender: themeData.lavender || "#b4befe"
    property color sapphire: themeData.sapphire || "#74c7ec"
    property color sky: themeData.sky || "#89dceb"
    property color teal: themeData.teal || "#94e2d5"
    property color green: themeData.green || "#a6e3a1"
    property color yellow: themeData.yellow || "#f9e2af"
    property color peach: themeData.peach || "#fab387"
    property color maroon: themeData.maroon || "#eba0ac"
    property color red: themeData.red || "#f38ba8"
    property color mauve: themeData.mauve || "#cba6f7"
    property color pink: themeData.pink || "#f5c2e7"
    property color flamingo: themeData.flamingo || "#f2cdcd"
    property color rosewater: themeData.rosewater || "#f5e0dc"
    
    // Spacing and sizing
    property int padding: 8
    property int margin: 4
    property int borderRadius: 12
    property int borderWidth: 2
    property int iconSize: 20
    property int fontSize: 11
    property int titleFontSize: 13
    property int spacing: 8
    
    // Fonts
    property string fontFamily: "JetBrainsMono Nerd Font"
    property string iconFont: "JetBrainsMono Nerd Font"
    
    // Effects
    property real blurRadius: 20
    property real shadowOpacity: 0.3
    property real hoverOpacity: 0.8
    property real activeOpacity: 1.0
    property real inactiveOpacity: 0.6
}