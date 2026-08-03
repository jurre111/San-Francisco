import plistlib
import json
import subprocess
from pathlib import Path


# should find the right path to the bundle where the SF Symbols live
volumes = Path("/Library/Developer/CoreSimulator/Volumes")
runtime_roots = sorted(
    volumes.glob("iOS_*/Library/Developer/CoreSimulator/Profiles/Runtimes/*.simruntime/Contents/Resources/RuntimeRoot")
)
print(runtime_roots)
path = runtime_roots[-1]

with open(f"{path}/CoreGlyphs.bundle/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/categories.plist", "rb") as f:
    categoriesInfo = plistlib.load(f)

# get symbols
symbols = {}

for symbol, value in name_availability["symbols"].items():
    if symbol in symbol_categories:
        categories = symbol_categories[symbol]
    else:
        categories = ["other"]
    dict = {"categories": categories, "availability": value}
    symbols[symbol] = dict
with open("symbols.plist", "wb") as f:
    plistlib.dump(symbols, f)



# get category info
categories = []
for category in categoriesInfo:
    key = category["key"]
    dict = {
        "key": key,
        "displayName": "",
        "icon": category["icon"],
        "symbols": []
    }
    for symbol, info in symbols.items():
        if key in info.categories:
            dict["symbols"].append(symbol)
    categories.append(dict)
with open("categories.plist", "wb") as file:
    plistlib.dump(categories, file)




# dump year to release version dictionary
with open("year_to_release.plist", "wb") as f:
    plistlib.dump(name_availability["year_to_release"], f)
