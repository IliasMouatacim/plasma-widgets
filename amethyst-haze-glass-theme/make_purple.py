import sys
import re

with open("panel-background.svg", "r") as f:
    content = f.read()

# Make the color a stronger, richer purple
content = content.replace("#E1BEE7", "#9C27B0")
content = content.replace("#800080", "#9C27B0")

# Bring opacity up from 0.0 to 0.35 so the purple is clearly visible as a glass tint
content = re.sub(r'fill-opacity:0\.0', 'fill-opacity:0.35', content)
content = re.sub(r'stop-opacity:0\.0', 'stop-opacity:0.35', content)
content = re.sub(r'opacity:0\.0', 'opacity:0.35', content)

with open("panel-background.svg", "w") as f:
    f.write(content)
