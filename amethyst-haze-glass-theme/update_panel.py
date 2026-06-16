import sys
import re

with open("panel-background.svg", "r") as f:
    content = f.read()

# Make sure all fill opacities are lowered to 0.0 for maximum transparency
content = re.sub(r'fill-opacity:[0-9.]+', 'fill-opacity:0.0', content)
content = re.sub(r'stop-opacity:[0-9.]+', 'stop-opacity:0.0', content)
content = re.sub(r'opacity:0\.75', 'opacity:0.0', content)
content = re.sub(r'opacity:0\.2', 'opacity:0.0', content)

with open("panel-background.svg", "w") as f:
    f.write(content)
