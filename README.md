# Custom KDE Plasma 6 Widgets

A collection of custom, native desktop widgets (Plasmoids) for KDE Plasma 6, featuring sleek designs and native integration.

## 🏆 World Cup 2026 Widget

A dynamic, transparent dashboard widget that shows live scores and schedules for the 2026 FIFA World Cup. 

### Features
* **Live Score Colors:** Automatically highlights the winning team in green and losing team in red. Ties are highlighted in blue.
* **Live Minute Tracking:** Automatically calculates and displays the current match minute or halftime (`HT`) / fulltime (`FT`) status for ongoing games.
* **Date Navigation:** Easily browse past, current, and upcoming matches.

### Installation
```bash
# Clone the repository
git clone https://github.com/IliasMouatacim/plasma-widgets.git
cd plasma-widgets

# Install the World Cup plasmoid
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.worldcup2026
cp -r plasmoid-worldcup/* ~/.local/share/plasma/plasmoids/org.kde.plasma.worldcup2026/

# Restart Plasma so it detects the new widget
systemctl --user restart plasma-plasmashell.service
```

## 🎵 Deezer Controller Widget

A native Plasma 6 media controller specifically designed to interface with the local Deezer application via Linux MPRIS DBus. 

Because Plasma 6 limits shell execution from pure QML widgets, this tool relies on a hybrid architecture: a lightweight Python DBus backend, and a beautiful QML frontend.

### Features
* Displays current track, artist, and album art.
* Native media controls (Play/Pause, Next, Previous).
* Communicates directly with Deezer's MPRIS interface.

### Installation
```bash
# Clone the repository
git clone https://github.com/IliasMouatacim/plasma-widgets.git
cd plasma-widgets

# 1. Install the Plasmoid UI
mkdir -p ~/.local/share/plasma/plasmoids/org.kde.plasma.deezer
cp -r deezer/plasmoid/* ~/.local/share/plasma/plasmoids/org.kde.plasma.deezer/

# 2. Start the Backend daemon (required for the widget to fetch track info)
chmod +x deezer/launch_deezer_backend.sh
./deezer/launch_deezer_backend.sh

# Restart Plasma
systemctl --user restart plasma-plasmashell.service
```

> **Note**: To have the Deezer backend start automatically, you can add `launch_deezer_backend.sh` to your system's Autostart settings.
