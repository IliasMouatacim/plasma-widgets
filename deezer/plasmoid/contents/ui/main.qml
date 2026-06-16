import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    preferredRepresentation: fullRepresentation
    
    property string trackTitle: "Offline"
    property string trackArtist: "Make sure Deezer is running"
    property string playbackStatus: "Stopped"
    property string artUrl: ""
    
    function updateStatus() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    if (data.status === "Error" || data.status === "Offline") {
                        root.trackTitle = "Offline";
                        root.trackArtist = "Make sure Deezer is running";
                        root.playbackStatus = "Stopped";
                        root.artUrl = "";
                    } else {
                        root.trackTitle = data.title;
                        root.trackArtist = data.artist;
                        root.playbackStatus = data.status; // "Playing" or "Paused"
                        // Clean up artUrl (sometimes dbus gives file:// paths)
                        root.artUrl = data.artUrl;
                    }
                } else {
                    root.trackTitle = "Disconnected";
                    root.trackArtist = "Backend not running";
                    root.playbackStatus = "Stopped";
                    root.artUrl = "";
                }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8081/status");
        xhr.send();
    }
    
    function sendCommand(cmd) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "http://127.0.0.1:8081/" + cmd);
        xhr.send();
        // Optimistic UI update
        if (cmd === "playpause") {
            root.playbackStatus = (root.playbackStatus === "Playing") ? "Paused" : "Playing";
        }
        // Force an immediate refresh a moment later
        refreshTimer.restart();
    }
    
    Timer {
        id: statusTimer
        interval: 1000 // 1 second
        running: true
        repeat: true
        onTriggered: root.updateStatus()
    }
    
    Timer {
        id: refreshTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: root.updateStatus()
    }
    
    Component.onCompleted: {
        root.updateStatus();
    }
    
    fullRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 16
        implicitHeight: Kirigami.Units.gridUnit * 8
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        
        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.largeSpacing
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
            border.width: 1
            
            // Background Image with heavy blur and dimming if artUrl exists
            Image {
                id: bgImage
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                visible: root.artUrl !== ""
                opacity: 0.15
                layer.enabled: true
                // We rely on standard layer effect or just low opacity for a subtle tint
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing
                spacing: Kirigami.Units.largeSpacing
                
                // Album Art thumbnail
                Rectangle {
                    width: Kirigami.Units.gridUnit * 5
                    height: width
                    radius: Kirigami.Units.smallSpacing
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: root.artUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: root.artUrl !== ""
                    }
                    
                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: "🎵"
                        font.pixelSize: Kirigami.Theme.largeFont.pixelSize * 1.5
                        visible: root.artUrl === ""
                    }
                }
                
                // Track Info & Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    PlasmaComponents.Label {
                        text: root.trackTitle
                        font.weight: Font.Bold
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    PlasmaComponents.Label {
                        text: root.trackArtist
                        font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
                        color: Kirigami.Theme.disabledTextColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    Item { Layout.fillHeight: true } // Spacer
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing
                        
                        PlasmaComponents.ToolButton {
                            text: "⏮"
                            font.pixelSize: Kirigami.Theme.largeFont.pixelSize * 1.2
                            onClicked: root.sendCommand("previous")
                        }
                        
                        PlasmaComponents.ToolButton {
                            text: root.playbackStatus === "Playing" ? "⏸" : "▶"
                            font.pixelSize: Kirigami.Theme.largeFont.pixelSize * 1.5
                            onClicked: root.sendCommand("playpause")
                        }
                        
                        PlasmaComponents.ToolButton {
                            text: "⏭"
                            font.pixelSize: Kirigami.Theme.largeFont.pixelSize * 1.2
                            onClicked: root.sendCommand("next")
                        }
                    }
                }
            }
        }
    }
}
