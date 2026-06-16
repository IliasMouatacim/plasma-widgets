import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    preferredRepresentation: fullRepresentation
    
    property real cpuPercent: 0
    property real ramPercent: 0
    property string gpuTemp: "--"
    property real netUp: 0
    property real netDown: 0
    
    Plasmoid.backgroundHints: "NoBackground" // Remove the ugly black square frame
    
    function updateStats() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    root.cpuPercent = data.cpu;
                    root.ramPercent = data.ram;
                    root.gpuTemp = data.gpu_temp;
                    root.netUp = data.net_up;
                    root.netDown = data.net_down;
                } else {
                    console.log("Sysmon Backend Error:", xhr.status);
                }
            }
        }
        xhr.open("GET", "http://127.0.0.1:8082/stats");
        xhr.send();
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateStats()
    }
    
    Component.onCompleted: root.updateStats()
    
    fullRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 18
        implicitHeight: Kirigami.Units.gridUnit * 8.5
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        
        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.largeSpacing * 1.5
            border.color: Qt.rgba(1, 1, 1, 0.25)
            border.width: 1
            
            color: {
                var c = String(Plasmoid.configuration.baseColor || "#663399");
                var isTrans = Plasmoid.configuration.isTransparent;
                return Qt.alpha(c, isTrans ? 0.2 : 0.9);
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing * 1.5
                spacing: Kirigami.Units.largeSpacing
                
                // --- CPU SECTION ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            text: "CPU"
                            font.weight: Font.Bold
                            color: Plasmoid.configuration.textColor || "#FFFFFF"
                        }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label {
                            text: root.cpuPercent.toFixed(1) + "%"
                            color: "#3498db" // Blue
                            font.weight: Font.Bold
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Qt.rgba(1, 1, 1, 0.1)
                        
                        Rectangle {
                            height: parent.height
                            width: parent.width * (root.cpuPercent / 100.0)
                            radius: 3
                            color: "#3498db"
                            
                            Behavior on width {
                                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
                
                // --- RAM SECTION ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            text: "RAM"
                            font.weight: Font.Bold
                            color: Plasmoid.configuration.textColor || "#FFFFFF"
                        }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label {
                            text: root.ramPercent.toFixed(1) + "%"
                            color: "#9b59b6" // Purple
                            font.weight: Font.Bold
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Qt.rgba(1, 1, 1, 0.1)
                        
                        Rectangle {
                            height: parent.height
                            width: parent.width * (root.ramPercent / 100.0)
                            radius: 3
                            color: "#9b59b6"
                            
                            Behavior on width {
                                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
                
                // --- GPU SECTION ---
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents.Label {
                            text: "RTX 3050 TEMP"
                            font.weight: Font.Bold
                            color: Plasmoid.configuration.textColor || "#FFFFFF"
                        }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents.Label {
                            text: root.gpuTemp !== "N/A" ? root.gpuTemp + "°C" : "N/A"
                            color: "#e74c3c" // Red/Orange
                            font.weight: Font.Bold
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Qt.rgba(1, 1, 1, 0.1)
                        
                        Rectangle {
                            height: parent.height
                            // Assume max normal temp is 100C for the bar scale
                            property real tempVal: root.gpuTemp !== "N/A" ? parseFloat(root.gpuTemp) : 0
                            width: parent.width * Math.min(tempVal / 100.0, 1.0)
                            radius: 3
                            color: "#e74c3c"
                            
                            Behavior on width {
                                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
                
                // --- NETWORK SECTION ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing
                    
                    // Down
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        PlasmaComponents.Label {
                            text: "↓"
                            color: "#2ecc71" // Green
                            font.weight: Font.Bold
                            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.5
                        }
                        PlasmaComponents.Label {
                            text: root.netDown > 1024 ? (root.netDown / 1024).toFixed(1) + " MB/s" : root.netDown.toFixed(1) + " KB/s"
                            color: Plasmoid.configuration.textColor || "#FFFFFF"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Up
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        PlasmaComponents.Label {
                            text: "↑"
                            color: "#f1c40f" // Yellow
                            font.weight: Font.Bold
                            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.5
                        }
                        PlasmaComponents.Label {
                            text: root.netUp > 1024 ? (root.netUp / 1024).toFixed(1) + " MB/s" : root.netUp.toFixed(1) + " KB/s"
                            color: Plasmoid.configuration.textColor || "#FFFFFF"
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }
                
                // --- SETTINGS BUTTON ---
                RowLayout {
                    Layout.fillWidth: true
                    
                    PlasmaComponents.ToolButton {
                        icon.name: "settings-configure"
                        text: "⚙"
                        display: PlasmaComponents.AbstractButton.IconOnly
                        onClicked: settingsPopup.open()
                    }
                    Item { Layout.fillWidth: true }
                }
            }
        }
        
        PlasmaComponents.Popup {
            id: settingsPopup
            parent: root
            x: Kirigami.Units.largeSpacing
            y: root.height - height - Kirigami.Units.largeSpacing
            
            contentItem: Rectangle {
                color: Kirigami.Theme.backgroundColor
                border.color: Kirigami.Theme.textColor
                border.width: 1
                radius: Kirigami.Units.smallSpacing
                implicitWidth: Kirigami.Units.gridUnit * 12
                implicitHeight: settingsLayout.implicitHeight + Kirigami.Units.largeSpacing * 2
                
                ColumnLayout {
                    id: settingsLayout
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.smallSpacing
                    
                    PlasmaComponents.Label {
                        text: "Widget Settings"
                        font.weight: Font.Bold
                    }
                    
                    PlasmaComponents.CheckBox {
                        text: "Transparent"
                        checked: Plasmoid.configuration.isTransparent
                        onCheckedChanged: Plasmoid.configuration.isTransparent = checked
                    }
                    
                    PlasmaComponents.Label { text: "Base Color:" }
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Repeater {
                            model: ["#9C27B0", "#2980B9", "#27AE60", "#2C3E50", "#C0392B", "#000000", "#FFFFFF"]
                            Rectangle {
                                width: Kirigami.Units.gridUnit * 1.5
                                height: Kirigami.Units.gridUnit * 1.5
                                radius: width / 2
                                color: modelData
                                border.color: String(Plasmoid.configuration.baseColor).toUpperCase() === modelData.toUpperCase() ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                                border.width: String(Plasmoid.configuration.baseColor).toUpperCase() === modelData.toUpperCase() ? 3 : 1
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Plasmoid.configuration.baseColor = modelData
                                }
                            }
                        }
                    }
                    
                    PlasmaComponents.Label { text: "Text Color:" }
                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Repeater {
                            model: ["#FFFFFF", "#E0E0E0", "#2C3E50", "#000000", "#F1C40F", "#3498DB"]
                            Rectangle {
                                width: Kirigami.Units.gridUnit * 1.5
                                height: Kirigami.Units.gridUnit * 1.5
                                radius: width / 2
                                color: modelData
                                border.color: String(Plasmoid.configuration.textColor).toUpperCase() === modelData.toUpperCase() ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
                                border.width: String(Plasmoid.configuration.textColor).toUpperCase() === modelData.toUpperCase() ? 3 : 1
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Plasmoid.configuration.textColor = modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
