"""Writes every iOS and Android launcher size from assets/brand/icon_1024.png.

Sizes come from the iOS AppIcon Contents.json, so a new Xcode template needs
no edit here. Uses macOS `sips` and strips alpha for iOS.
"""
import json
import os
import subprocess

SRC = "assets/brand/icon_1024.png"
IOS = "ios/Runner/Assets.xcassets/AppIcon.appiconset"


def resize(px, out, opaque=False):
    subprocess.run(["sips", "-s", "format", "png", "-z", str(px), str(px), SRC, "--out", out],
                   check=True, capture_output=True)
    if opaque:
        # Round-trip through JPEG to drop the alpha channel iOS rejects.
        tmp = out + ".jpg"
        subprocess.run(["sips", "-s", "format", "jpeg", "-s", "formatOptions", "100", out, "--out", tmp],
                       check=True, capture_output=True)
        subprocess.run(["sips", "-s", "format", "png", tmp, "--out", out], check=True, capture_output=True)
        os.remove(tmp)


for img in json.load(open(f"{IOS}/Contents.json"))["images"]:
    if "filename" not in img:
        continue
    pt = float(img["size"].split("x")[0])
    scale = int(img["scale"].rstrip("x"))
    resize(round(pt * scale), f"{IOS}/{img['filename']}", opaque=True)

for folder, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    resize(px, f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png")
print("icons written")
