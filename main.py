import plistlib
from operator import itemgetter
import json
import subprocess

print("loading...")

# the path to where all the metadata about SF Symbols is stored on MacOS. Equivalent to /System/Library/PrivateFrameworks/SFSymbols.framework/CoreGlyphs.bundle/ on iOS
path = "/System/Library/PrivateFrameworks/SFSymbols.framework/Resources/CoreGlyphs.bundle/Contents/Resources"


# open and load the plists files we need
with open(f"{path}/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open(f"{path}/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

with open(f"{path}/name_aliases.strings", "rb") as f:
    name_aliases = plistlib.load(f)

with open(f"{path}/categories.plist", "rb") as f:
    categoriesInfo = plistlib.load(f)


# convert year to iOS version (will get used later)
year_to_release = name_availability["year_to_release"]
for year in year_to_release.keys():
    year_to_release[year] = float(year_to_release[year]["iOS"])


# load the symbols list
# run a custom version os sfsym which can batch output the info of all SF Symbols on the system (the Assets.car) https://github.com/jurre111/sfsym (changes were made by ai)
result = subprocess.run(["./sfsym", "batch", "--json"], input=json.dumps(list(name_availability["symbols"].keys())), capture_output=True, text=True)
symbols = json.loads(result.stdout)

for index, symbol in enumerate(symbols):
    name = symbol["name"]
    # load the catagories the icon belongs to
    categories = ["all"]
    if name in symbol_categories:
        categories += symbol_categories[name]
    dict = {"name": name, "categories": categories, "availability": year_to_release.get(name_availability["symbols"][name], 0.0), "layers": symbol.get("hierarchyLayers", 1)}
    symbols[index] = dict

# dump the loaded symbols to a plist file which will end up in the app bundle
symbols = sorted(symbols, key=itemgetter("name"))
with open("symbols.plist", "wb") as f:
    plistlib.dump(symbols, f)


# a dict of all the categories and their display name (yes this is manual and might be subject to change)
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

# get category info from the plist
categories = []
for category in categoriesInfo:
    key = category["key"]
    dict = {
        "name": key,
        "displayName": category_display_names.get(key, key),
        "icon": category["icon"],
    }
    categories.append(dict)

# dump to plist
with open("categories.plist", "wb") as file:
    plistlib.dump(categories, file)




# dump name aliases. we reverse the keys and values so that we can get the older alternative of a new symbol by calling dict[newSymbol]
with open("name_aliases.plist", "wb") as f:
    dict = {}
    for key, value in name_aliases.items():
        dict[value] = key

    plistlib.dump(dict, f)

print("Done!")