#!/bin/bash
cd "$(dirname "$0")"

echo "Installing Plasma 6 World Cup Widget..."

# Install or update plasmoid
kpackagetool6 -t Plasma/Applet -u . 2>/dev/null || kpackagetool6 -t Plasma/Applet -i .

echo "Installation complete! You can now add the 'World Cup' widget to your panel or desktop."
echo "If it doesn't appear in the widget list, restart Plasma: kquitapp6 plasmashell && kstart plasmashell"
