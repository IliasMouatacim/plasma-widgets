# World Cup Plasma Widget

A minimalist, elegant World Cup score widget for KDE Plasma 6. 
It fetches real-time match data and displays it on your desktop.

## Installation

Run the provided installation script to pack and install the widget automatically:

```bash
./install.sh
```

## Manual Installation

You can also install the plasmoid manually using KDE's package tool:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

To update an existing installation, use:
```bash
kpackagetool6 -t Plasma/Applet -u .
```

After installation, the widget will be available in your Plasma widget explorer under the name "World Cup".
