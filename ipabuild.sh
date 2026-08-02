#!/bin/bash
set -euo pipefail

APP_NAME=$1

rm -rf build/
mkdir -p build

echo "Build Started!"
echo

xcodebuild \
  -project $APP_NAME.xcodeproj \
  -scheme "$APP_NAME" \
  -configuration Debug \
  -sdk iphoneos \
  -arch arm64e \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  archive \
  -archivePath "$PWD/build/$APP_NAME.xcarchive" 2>&1 # | xcpretty

APP_PATH="$PWD/build/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app"
if [ ! -d "$APP_PATH" ]; then
  echo "Build Failed!"
  exit 1
fi
rm -rf "$PWD/Payload"
mkdir -p "$PWD/Payload"
cp -R "$APP_PATH" "$PWD/Payload/"

plutil -insert NSLocationWhenInUseUsageDescription -string "This app needs your location to display your position on the map." "$PWD/Payload/$APP_NAME.app/Info.plist"
cp symbols.plist "$PWD/Payload/$APP_NAME.app/symbols.plist"

if ! command -v ldid >/dev/null 2>&1; then
  echo "ERROR: ldid not installed. Install with: brew install ldid" >&2
  exit 1
fi
ldid -S "$PWD/Payload/$APP_NAME.app/$APP_NAME"
/usr/bin/zip -qry $APP_NAME.ipa Payload

echo
echo "build successful!"
echo "ipa at: $APP_NAME.ipa"
exit 0