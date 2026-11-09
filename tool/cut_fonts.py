"""Cuts static Bricolage Grotesque instances from the variable font.

Flutter on iOS does not map FontWeight onto a variable font's wght axis, so
the app bundles one static file per weight instead. Same axes as Strata:
small optical size and full width for text, larger optical size and a
touch narrower for the heavy display weights.

    pip install fonttools
    python3 tool/cut_fonts.py path/to/BricolageGrotesque[opsz,wdth,wght].ttf
"""
import sys

from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

CUTS = [
    ("Regular", 400, 14, 100),
    ("Medium", 500, 14, 100),
    ("SemiBold", 600, 16, 100),
    ("Bold", 700, 24, 96),
    ("ExtraBold", 800, 48, 92),
]

for name, wght, opsz, wdth in CUTS:
    font = instantiateVariableFont(TTFont(sys.argv[1]), {"wght": wght, "opsz": opsz, "wdth": wdth})
    font.save(f"assets/fonts/Bricolage-{name}.ttf")
    print(name)
