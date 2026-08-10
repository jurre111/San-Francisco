import plistlib
from operator import itemgetter
import os
from fontTools.ttLib import TTFont


path = "/System/Library/PrivateFrameworks/SFSymbols.framework/Resources/CoreGlyphs.bundle/Contents/Resources"

font = TTFont(f"/System/Library/Fonts/Core/SFUI.ttf")
glyphs = font.getGlyphSet()
print(f"{len(glyphs)} glyps")
exit(1)

with open(f"{path}/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open(f"{path}/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

with open(f"{path}/name_aliases.strings", "rb") as f:
    name_aliases = plistlib.load(f)

with open(f"{path}/categories.plist", "rb") as f:
    categoriesInfo = plistlib.load(f)


year_to_release = name_availability["year_to_release"]
for year in year_to_release.keys():
    year_to_release[year] = float(year_to_release[year]["iOS"])


# get symbols
symbols = []

for symbol, value in name_availability["symbols"].items():
    categories = ["all"]
    if symbol in symbol_categories:
        categories += symbol_categories[symbol]
    dict = {"name": symbol, "categories": categories, "availability": year_to_release.get(value, 0.0)}
    symbols = sorted(symbols, key=itemgetter("name"))
    symbols.append(dict)
with open("symbols.plist", "wb") as f:
    plistlib.dump(symbols, f)


# a dict of all the categories and their display name (yes this is manual and may be subject to change)
category_display_names = {
    "all": "All",
    "whatsnew": "What's New",
    "draw": "Draw",
    "variable": "Variable",
    "multicolor": "Multicolor",
    "communication": "Communication",
    "weather": "Weather",
    "maps": "Maps",
    "objectsandtools": "Objects & Tools",
    "devices": "Devices",
    "cameraandphotos": "Camera & Photos",
    "gaming": "Gaming",
    "connectivity": "Connectivity",
    "transportation": "Transportation",
    "automotive": "Automotive",
    "accessibility": "Accessibility",
    "privacyandsecurity": "Privacy & Security",
    "human": "Human",
    "home": "Home",
    "fitness": "Fitness",
    "nature": "Nature",
    "editing": "Editing",
    "textformatting": "Text Formatting",
    "media": "Media",
    "keyboard": "Keyboard",
    "commerce": "Commerce",
    "time": "Time",
    "health": "Health",
    "shapes": "Shapes",
    "arrows": "Arrows",
    "indices": "Indices",
    "math": "Math",
}

# get category info
categories = []
for category in categoriesInfo:
    key = category["key"]
    dict = {
        "name": key,
        "displayName": category_display_names.get(key, key),
        "icon": category["icon"],
    }
    categories.append(dict)
with open("categories.plist", "wb") as file:
    plistlib.dump(categories, file)




# dump name aliases
with open("name_aliases.plist", "wb") as f:
    dict = {}
    for key, value in name_aliases.items():
        dict[value] = key

    plistlib.dump(dict, f)

print("Plists Dumped!")