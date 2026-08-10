import plistlib
from operator import itemgetter
import subprocess
from pathlib import Path
import os

# path = "/Library/Developer/CoreSimulator/Images/images.plist"
# with open(path, "rb") as f:
#     images = plistlib.load(f)["images"]
# 
# ios_runtimes = []
# for image in images:
#     path = image["path"]["relative"].replace("file://", "")
#     bundle_id = image["runtimeInfo"]["bundleIdentifier"]
#     build = image["runtimeInfo"]["build"]
#     if "iOS" in bundle_id:
#         version = [int(x) for x in bundle_id.split("iOS-")[-1].split("-")]
#         ios_runtimes.append({
#             "path": path,
#             "version": version,
#             "versionString": bundle_id.split("iOS-")[-1].replace("-", "."),
#             "build": build
#         })
# 
# runtime = max(ios_runtimes, key=lambda r: r["version"], default=None)
# print("retrieved latest runtime:\n")
# for key, value in runtime.items():
#     print(f"{key}: {value}")
# 
# try:
#     result = subprocess.run(
#         ["hdiutil", "attach", runtime["path"], "-noverify", "-plist"],
#         check=True,
#         capture_output=True,
#         text=True
#     )
#     plist = plistlib.loads(result.stdout)
# 
#     mount_point = None
#     for entity in plist.get("system-entities", []):
#         if "mount-point" in entity:
#             mount_point = entity["mount-point"]
#     print(f"Runtime mounted at {mount_point}!\n\n\n--------------\n\n\n")
# except subprocess.CalledProcessError as e:
#     print(f"Failed to mount Runtime (Exit Code {e.returncode}):")
#     print(e.stderr)
#     raise
# 


print(os.listdir("/System/Library/PrivateFrameworks/SFSymbols.framework"))
exit(1)
path = ""
# f"{mount_point}/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS {runtime['versionString']}.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/SFSymbols.framework"

with open(f"{path}/CoreGlyphs.bundle/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/name_aliases.strings", "rb") as f:
    name_aliases = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/categories.plist", "rb") as f:
    categoriesInfo = plistlib.load(f)
    print(f"{path}/CoreGlyphs.bundle/categories.plist:\n")
    print(categoriesInfo)


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