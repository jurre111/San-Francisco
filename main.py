import plistlib

with open("CoreGlyphs.bundle/symbol_categories.plist", "rb") as f:
    symbol_categories = plistlib.load(f)

with open("CoreGlyphs.bundle/name_availability.plist", "rb") as f:
    name_availability = plistlib.load(f)

symbols = {}

for symbol, value in name_availability["symbols"].items():
    if symbol in symbol_categories:
        categories = symbol_categories[symbol]
    else:
        categories = ["other"]
    dict = {"categories": categories, "availability": value}
    symbols[symbol] = dict
print(symbols)
with open("symbols.plist", "wb") as f:
    plistlib.dump(symbols, f)
