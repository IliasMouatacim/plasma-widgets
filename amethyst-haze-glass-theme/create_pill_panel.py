import xml.etree.ElementTree as ET

svg_content = """<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg width="72" height="72" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <!-- Hints -->
  <rect id="hint-top-margin" x="30" y="0" width="12" height="30" fill="none"/>
  <rect id="hint-bottom-margin" x="30" y="42" width="12" height="30" fill="none"/>
  <rect id="hint-left-margin" x="0" y="30" width="30" height="12" fill="none"/>
  <rect id="hint-right-margin" x="42" y="30" width="30" height="12" fill="none"/>
  
  <rect id="hint-top-inset" x="30" y="0" width="12" height="6" fill="none"/>
  <rect id="hint-bottom-inset" x="30" y="66" width="12" height="6" fill="none"/>
  <rect id="hint-left-inset" x="0" y="30" width="6" height="12" fill="none"/>
  <rect id="hint-right-inset" x="66" y="30" width="6" height="12" fill="none"/>

  <!-- Elements -->
  <g id="topleft">
    <rect x="0" y="0" width="30" height="30" fill="none"/>
    <path fill="#9C27B0" fill-opacity="0.35" d="M 30,6 A 24,24 0 0,0 6,30 L 30,30 Z"/>
  </g>
  <g id="top">
    <rect x="30" y="0" width="12" height="30" fill="none"/>
    <rect fill="#9C27B0" fill-opacity="0.35" x="30" y="6" width="12" height="24"/>
  </g>
  <g id="topright">
    <rect x="42" y="0" width="30" height="30" fill="none"/>
    <path fill="#9C27B0" fill-opacity="0.35" d="M 42,6 A 24,24 0 0,1 66,30 L 42,30 Z"/>
  </g>

  <g id="left">
    <rect x="0" y="30" width="30" height="12" fill="none"/>
    <rect fill="#9C27B0" fill-opacity="0.35" x="6" y="30" width="24" height="12"/>
  </g>
  <g id="center">
    <rect x="30" y="30" width="12" height="12" fill="none"/>
    <rect fill="#9C27B0" fill-opacity="0.35" x="30" y="30" width="12" height="12"/>
  </g>
  <g id="right">
    <rect x="42" y="30" width="30" height="12" fill="none"/>
    <rect fill="#9C27B0" fill-opacity="0.35" x="42" y="30" width="24" height="12"/>
  </g>

  <g id="bottomleft">
    <rect x="0" y="42" width="30" height="30" fill="none"/>
    <path fill="#9C27B0" fill-opacity="0.35" d="M 6,42 A 24,24 0 0,0 30,66 L 30,42 Z"/>
  </g>
  <g id="bottom">
    <rect x="30" y="42" width="12" height="30" fill="none"/>
    <rect fill="#9C27B0" fill-opacity="0.35" x="30" y="42" width="12" height="24"/>
  </g>
  <g id="bottomright">
    <rect x="42" y="42" width="30" height="30" fill="none"/>
    <path fill="#9C27B0" fill-opacity="0.35" d="M 66,42 A 24,24 0 0,1 42,66 L 42,42 Z"/>
  </g>
</svg>
"""

with open('/home/ilias/widget/amethyst-haze-glass-theme/panel-background.svg', 'w') as f:
    f.write(svg_content)
