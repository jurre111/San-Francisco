#!/bin/bash
set -euo pipefail

APP_NAME=$1
APP_MARKETING_VERSION=$2
APP_BUILD_VERSION=$3
APP_COMMIT_HASH=$4

echo $APP_COMMIT_HASH

rm -rf build/
mkdir -p build

echo "Build Started!"
echo

xcodebuild \
  -project "$APP_NAME.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Debug \
  -sdk iphoneos \
  -arch arm64e \
  MARKETING_VERSION="$APP_MARKETING_VERSION" \
  CURRENT_PROJECT_VERSION="$APP_BUILD_VERSION" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  archive \
  -archivePath "$PWD/build/$APP_NAME.xcarchive" 2>&1 | xcpretty

APP_PATH="$PWD/build/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app"
if [ ! -d "$APP_PATH" ]; then
  echo "Build Failed!"
  exit 1
fi
rm -rf "$PWD/Payload"
mkdir -p "$PWD/Payload"
cp -R "$APP_PATH" "$PWD/Payload/"

plutil -insert NSLocationWhenInUseUsageDescription -string "This app needs your location to display your position on the map." "$PWD/Payload/$APP_NAME.app/Info.plist"
plutil -insert CommitHash -string $APP_COMMIT_HASH "$PWD/Payload/$APP_NAME.app/Info.plist"
cp symbols.plist "$PWD/Payload/$APP_NAME.app/symbols.plist"
cp categories.plist "$PWD/Payload/$APP_NAME.app/categories.plist"
cp name_aliases.plist "$PWD/Payload/$APP_NAME.app/name_aliases.plist"

if ! command -v ldid >/dev/null 2>&1; then
  echo "ERROR: ldid not installed. Install with: brew install ldid" >&2
  exit 1
fi
ldid -S "$PWD/Payload/$APP_NAME.app/$APP_NAME"
/usr/bin/zip -qry "$APP_NAME.ipa" Payload

echo
echo "build successful!"
echo "ipa at: $APP_NAME.ipa"
exit 0