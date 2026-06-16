import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    preferredRepresentation: fullRepresentation
    
    Plasmoid.backgroundHints: "NoBackground"
    
    property int dateOffset: 0
    property var matches: []
    property string lastUpdated: ""
    
    function getMatchStatus(dateStr, timeStr) {
        if (!dateStr || !timeStr) return "";
        
        var timeParts = timeStr.split(" ");
        var time = timeParts[0];
        var tzOffset = "Z";
        
        if (timeParts.length > 1) {
            var tz = timeParts[1].replace("UTC", ""); 
            var tzMatch = tz.match(/([+-])(\d+)/);
            if (tzMatch) {
                var sign = tzMatch[1];
                var hours = ("0" + tzMatch[2]).slice(-2);
                tzOffset = sign + hours + ":00";
            }
        }
        
        var startDateStr = dateStr + "T" + time + ":00" + tzOffset;
        var startTime = new Date(startDateStr);
        // Fallback if parsing fails
        if (isNaN(startTime.getTime())) return timeStr;
        
        var now = new Date();
        var diffMins = Math.floor((now - startTime) / 60000);
        
        if (diffMins < 0) {
            return startTime.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
        }
        
        if (diffMins <= 45) {
            if (diffMins === 0) return "1'";
            return diffMins + "'";
        } else if (diffMins <= 60) {
            return "HT";
        } else if (diffMins <= 110) {
            var min = diffMins - 15;
            if (min > 90) return "90+'";
            return min + "'";
        } else {
            return "FT";
        }
    }
    
    function fetchData() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var data = JSON.parse(xhr.responseText);
                    root.matches = data.matches || [];
                    
                    var date = new Date();
                    root.lastUpdated = date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat);
                } else {
                    root.lastUpdated = "Error fetching data";
                }
            }
        }
        xhr.open("GET", "https://raw.githubusercontent.com/openfootball/worldcup.json/master/2026/worldcup.json");
        xhr.send();
    }
    
    Timer {
        interval: 60000 // 1 minute
        running: true
        repeat: true
        onTriggered: root.fetchData()
    }
    
    Component.onCompleted: {
        root.fetchData();
    }
    
    fullRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 16
        implicitHeight: Kirigami.Units.gridUnit * 20
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        
        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.largeSpacing * 1.5
            
            color: {
                var c = String(Plasmoid.configuration.baseColor || "#663399");
                var isTrans = Plasmoid.configuration.isTransparent;
                return Qt.alpha(c, isTrans ? 0.2 : 0.9);
            }
            border.color: Qt.rgba(1, 1, 1, 0.25)
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.largeSpacing * 1.5
                spacing: Kirigami.Units.largeSpacing
            
            // Header
            RowLayout {
                PlasmaComponents.Label {
                    text: "🏆 World Cup 2026"
                    font.weight: Font.Bold
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.3
                    horizontalAlignment: Text.AlignHCenter
                    color: Plasmoid.configuration.textColor || "#FFFFFF"
                }
            }
            
            // Controls
            RowLayout {
                PlasmaComponents.Button {
                    text: "◀ Prev"
                    onClicked: root.dateOffset -= 1
                }
                
                PlasmaComponents.Label {
                    text: {
                        if (root.dateOffset === 0) return "Today"
                        if (root.dateOffset === -1) return "Yesterday"
                        if (root.dateOffset === 1) return "Tomorrow"
                        var d = new Date();
                        d.setDate(d.getDate() + root.dateOffset);
                        return d.toDateString();
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    font.weight: Font.Bold
                    color: Plasmoid.configuration.textColor || "#FFFFFF"
                }
                
                PlasmaComponents.Button {
                    text: "Next ▶"
                    onClicked: root.dateOffset += 1
                }
            }
            
            // Matches List
            ListView {
                id: matchesList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Kirigami.Units.smallSpacing
                
                model: {
                    var targetDate = new Date();
                    targetDate.setDate(targetDate.getDate() + root.dateOffset);
                    var targetDateStr = targetDate.toISOString().split('T')[0];
                    
                    var filtered = [];
                    for (var i = 0; i < root.matches.length; i++) {
                        if (root.matches[i].date === targetDateStr) {
                            filtered.push(root.matches[i]);
                        }
                    }
                    return filtered;
                }
                
                delegate: Rectangle {
                    id: matchItem
                    width: ListView.view.width
                    height: contentCol.implicitHeight + Kirigami.Units.largeSpacing
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
                    radius: Kirigami.Units.smallSpacing
                    
                    property color c1: {
                        if (!modelData.score || !modelData.score.ft) return "#FFFFFF";
                        var s1 = modelData.score.ft[0];
                        var s2 = modelData.score.ft[1];
                        if (s1 === s2) return "#f1c40f"; // Yellow
                        return s1 > s2 ? "#2ecc71" : "#e74c3c"; // Green or Red
                    }
                    property color c2: {
                        if (!modelData.score || !modelData.score.ft) return "#FFFFFF";
                        var s1 = modelData.score.ft[0];
                        var s2 = modelData.score.ft[1];
                        if (s1 === s2) return "#f1c40f"; // Yellow
                        return s2 > s1 ? "#2ecc71" : "#e74c3c"; // Green or Red
                    }
                    
                    ColumnLayout {
                        id: contentCol
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing / 2
                        spacing: Kirigami.Units.smallSpacing / 2
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Kirigami.Units.smallSpacing
                            
                            PlasmaComponents.Label {
                                text: modelData.team1 || "TBD"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                horizontalAlignment: Text.AlignRight
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                                font.weight: Font.DemiBold
                                wrapMode: Text.WordWrap
                                color: matchItem.c1
                            }
                            
                            PlasmaComponents.Label {
                                textFormat: Text.RichText
                                text: {
                                    if (modelData.score && modelData.score.ft) {
                                        return "<font color='" + matchItem.c1 + "'>" + modelData.score.ft[0] + "</font> - <font color='" + matchItem.c2 + "'>" + modelData.score.ft[1] + "</font>"
                                    }
                                    return "<font color='#f1c40f'>VS</font>"
                                }
                                font.weight: Font.Bold
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.2
                                horizontalAlignment: Text.AlignHCenter
                                Layout.minimumWidth: Kirigami.Units.gridUnit * 3
                            }
                            
                            PlasmaComponents.Label {
                                text: modelData.team2 || "TBD"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                horizontalAlignment: Text.AlignLeft
                                font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.1
                                font.weight: Font.DemiBold
                                wrapMode: Text.WordWrap
                                color: matchItem.c2
                            }
                        }
                        
                        PlasmaComponents.Label {
                            text: root.getMatchStatus(modelData.date, modelData.time)
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            color: text === "FT" ? "#BDC3C7" : "#F39C12" // Light Grey or Orange
                            Layout.alignment: Qt.AlignHCenter
                            visible: text !== ""
                        }
                    }
                }
                
                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: "No matches scheduled."
                    visible: matchesList.count === 0
                    color: Plasmoid.configuration.textColor || "#E0E0E0"
                }
            }
            
            // Footer
            RowLayout {
                Layout.fillWidth: true
                
                PlasmaComponents.Label {
                    text: "⚙"
                    font.pixelSize: Kirigami.Theme.defaultFont.pixelSize * 1.5
                    color: Plasmoid.configuration.textColor || "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                    
                    MouseArea {
                        anchors.fill: parent
                        // increase clickable area slightly
                        anchors.margins: -Kirigami.Units.smallSpacing
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsPopup.open()
                    }
                }
                
                Item { Layout.fillWidth: true } // Spacer
                
                PlasmaComponents.Label {
                    text: "Updated: " + root.lastUpdated
                    font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    color: Plasmoid.configuration.textColor || "#E0E0E0"
                }
                
                Item { Layout.fillWidth: true } // Spacer
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
