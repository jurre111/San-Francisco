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
print(runtime["path"])