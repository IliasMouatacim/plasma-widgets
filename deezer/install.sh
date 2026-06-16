#!/bin/bash
cd "$(dirname "$0")"

echo "Installing Plasma 6 Deezer Widget..."

# Install or update plasmoid
kpackagetool6 -t Plasma/Applet -u plasmoid 2>/dev/null || kpackagetool6 -t Plasma/Applet -i plasmoid

# Ensure backend scripts are executable
chmod +x launch_deezer_backend.sh

# Set up autostart for the backend
mkdir -p ~/.config/autostart-scripts
ln -sf "$(pwd)/launch_deezer_backend.sh" ~/.config/autostart-scripts/launch_deezer_backend.sh

# Start the backend now
./launch_deezer_backend.sh

echo "Installation complete! You can now add the 'Deezer' widget to your panel or desktop."
echo "If it doesn't appear in the widget list, restart Plasma: kquitapp6 plasmashell && kstart plasmashell"
