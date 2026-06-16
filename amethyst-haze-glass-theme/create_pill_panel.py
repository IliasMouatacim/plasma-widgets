import xml.etree.ElementTree as ET

svg_content = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="100" height="100" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .bg { fill: #9C27B0; fill-opacity: 0.35; }
    </style>
  </defs>

  <!-- Hints -->
  <rect id="hint-top-margin" width="10" height="40" x="45" y="0" opacity="0"/>
  <rect id="hint-bottom-margin" width="10" height="40" x="45" y="60" opacity="0"/>
  <rect id="hint-left-margin" width="40" height="10" x="0" y="45" opacity="0"/>
  <rect id="hint-right-margin" width="40" height="10" x="60" y="45" opacity="0"/>
  
  <!-- Corners -->
  <g id="topleft">
    <path class="bg" d="M 40,0 A 40,40 0 0,0 0,40 L 40,40 Z"/>
  </g>
  <g id="topright">
    <path class="bg" d="M 60,0 A 40,40 0 0,1 100,40 L 60,40 Z"/>
  </g>
  <g id="bottomleft">
    <path class="bg" d="M 0,60 A 40,40 0 0,0 40,100 L 40,60 Z"/>
  </g>
  <g id="bottomright">
    <path class="bg" d="M 100,60 A 40,40 0 0,1 60,100 L 60,60 Z"/>
  </g>

  <!-- Edges -->
  <g id="top">
    <rect class="bg" x="40" y="0" width="20" height="40"/>
  </g>
  <g id="bottom">
    <rect class="bg" x="40" y="60" width="20" height="40"/>
  </g>
  <g id="left">
    <rect class="bg" x="0" y="40" width="40" height="20"/>
  </g>
  <g id="right">
    <rect class="bg" x="60" y="40" width="40" height="20"/>
  </g>

  <!-- Center -->
  <g id="center">
    <rect class="bg" x="40" y="40" width="20" height="20"/>
  </g>
</svg>
"""

with open('/home/ilias/widget/amethyst-haze-glass-theme/panel-background.svg', 'w') as f:
    f.write(svg_content)
