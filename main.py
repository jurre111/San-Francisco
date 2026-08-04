import plistlib
import json
import subprocess
from pathlib import Path
import os

path = "/Library/Developer/CoreSimulator/Images/images.plist"
with open(path, "rb") as f:
    images = plistlib.load(f)["images"]

ios_runtimes = []
for image in images:
    path = image["path"]["relative"].replace("file://", "")
    bundle_id = image["runtimeInfo"]["bundleIdentifier"]
    build = image["runtimeInfo"]["build"]
    if "iOS" in bundle_id:
        version = [int(x) for x in bundle_id.split("iOS-")[-1].split("-")]
        ios_runtimes.append({
            "path": path,
            "version": version,
            "build": build
        })

runtime = max(ios_runtimes, key=lambda r: r["version"], default=None)
print("retrieved latest runtime:\n")
for key, value in runtime.items():
    print(f"{key}: {value}")

try:
    result = subprocess.run(
        ["hdiutil", "attach", runtime["path"], "-noverify", "-plist"],
        check=True,
        capture_output=True,
        text=True
    )
    plist = plistlib.loads(result.stdout)

    mount_point = None
    for entity in plist.get("system-entities", []):
        if "mount-point" in entity:
            mount_point = entity["mount-point"]
    print("Runtime mounted!")
    print(plist)

    print("\n\n\n-------------------------------------------\n\n\nContent:\n\n")
    print(os.listdir(mount_point), sep="\n")
except subprocess.CalledProcessError as e:
    print(f"Failed to mount Runtime (Exit Code {e.returncode}):")
    print(e.stderr)
    raise

exit(1)

def get_latest_ios_runtime_root():
    result = subprocess.run(
        ["xcrun", "simctl", "list", "runtimes", "-j"],
        capture_output=True,
        text=True,
        check=True
    )

    data = json.loads(result.stdout)

    ios_runtimes = [
        runtime
        for runtime in data["runtimes"]
        if runtime.get("platform") == "iOS"
        and runtime.get("isAvailable", False)
    ]

    if not ios_runtimes:
        raise RuntimeError("No available iOS runtimes found")

    # Sort by version number
    ios_runtimes.sort(
        key=lambda r: tuple(map(int, r["version"].split("."))),
        reverse=True
    )

    return ios_runtimes[0]["runtimeRoot"]


# load the necessary dicts
path = f"{get_latest_ios_runtime_root()}/System/Library/PrivateFrameworks/SFSymbols.framework"
print(f"{path}/CoreGlyphs.bundle/symbol_categories.plist")
exit(0)

import os
import plistlib
from pathlib import Path


# should find the right path to the bundle where the SF Symbols live
# /Library/Developer/CoreSimulator/Volumes/iOS_23F77/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS 26.5.simruntime/Contents/Resources/RuntimeRoot
volumes = Path("/Library/Developer/CoreSimulator/Volumes")






iosVolumes = [p for p in volumes.iterdir() if "iOS" in p.name]
print(iosVolumes)
runtimes = []
for volume in iosVolumes:
    path = volume / "Library/Developer/CoreSimulator/Profiles/Runtimes/"
    iosruntime = [p for p in path.iterdir() if "iOS" in p.name]
    runtimes.extend(iosruntime)
print(runtimes)
for runtime in runtimes:
    os.listdir(runtime)
exit(1)





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
