#!/bin/bash
cd "$(dirname "$0")"

echo "Applying Amethyst.Haze Glass Theme modifications..."

THEME_DIR="$HOME/.local/share/plasma/desktoptheme/Amethyst.Haze"

if [ ! -d "$THEME_DIR" ]; then
    echo "Amethyst.Haze theme not found in $THEME_DIR!"
    echo "Please install Amethyst.Haze theme from the KDE store first."
    exit 1
fi

echo "Replacing icon and text colors with pure white..."
sed -i 's/ForegroundNormal=.*/ForegroundNormal=255,255,255/g' "$THEME_DIR/colors"
sed -i 's/ForegroundActive=.*/ForegroundActive=255,255,255/g' "$THEME_DIR/colors"
sed -i 's/ForegroundInactive=.*/ForegroundInactive=255,255,255/g' "$THEME_DIR/colors"

echo "Applying glassy purple transparency to the panel..."
# Copy the fixed background SVG over the existing one
python fix_panel.py
gzip -c panel-background.svg > "$THEME_DIR/widgets/panel-background.svgz"

echo "Flushing Plasma cache and restarting shell to apply changes..."
rm -rf ~/.cache/plasma*
kquitapp6 plasmashell || killall plasmashell
sleep 1
kstart plasmashell &

echo "Theme modifications applied successfully!"
