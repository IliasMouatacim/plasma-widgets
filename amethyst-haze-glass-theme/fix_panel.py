import sys

with open("panel-background-check.svg", "r") as f:
    content = f.read()

# Change the main panel color to rich purple
content = content.replace("#E1BEE7", "#9C27B0")

# The main visible parts of the panel in this file use these opacities.
# We change them to 0.35 to give the glassy transparent look.
content = content.replace("opacity:0.75", "opacity:0.35")
content = content.replace("fill-opacity:0.998512", "fill-opacity:0.35")

# Note: We do NOT touch `#800080` (hints) or `#000000` (masks)!
# This ensures that Plasma's masking and margins still work flawlessly, 
# preventing any solid blocks from sticking out!

with open("panel-background.svg", "w") as f:
    f.write(content)
