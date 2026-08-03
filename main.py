import plistlib
import json
import subprocess


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

path = f"{get_latest_ios_runtime_root()}/System/Library/PrivateFrameworks/SFSymbols.framework"

with open(f"{path}/CoreGlyphs.bundle/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open(f"{path}/CoreGlyphs.bundle/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

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
