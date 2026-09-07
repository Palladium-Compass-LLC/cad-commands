#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="CADCommands"
BUNDLE_ID="palladiumcompassllc.CADCommands"
DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro Max}"
OUTPUT_DIR="$PROJECT_DIR/AppStoreScreenshots"
DERIVED_DATA="$PROJECT_DIR/.derivedData"

mkdir -p "$OUTPUT_DIR"

echo "Clearing extended attributes (fixes codesign)..."
xattr -cr "$PROJECT_DIR" 2>/dev/null || true
export COPYFILE_DISABLE=1

echo "Building $SCHEME for $DEVICE_NAME..."
xcodebuild \
  -project "$PROJECT_DIR/CADCommands.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  build \
  | tail -5

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/CADCommands.app"
xattr -cr "$APP_PATH" 2>/dev/null || true

echo "Booting simulator..."
xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
open -a Simulator

echo "Installing app..."
xcrun simctl install booted "$APP_PATH"

CONTAINER="$(xcrun simctl get_app_container booted "$BUNDLE_ID" data)"
SOURCE_DIR="$CONTAINER/Documents/AppStoreScreenshots"
rm -rf "$SOURCE_DIR"

echo "Launching screenshot export..."
xcrun simctl terminate booted "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch booted "$BUNDLE_ID" -ExportScreenshots >/dev/null

echo "Waiting for screenshots to finish..."
for _ in $(seq 1 60); do
  COUNT=0
  if [[ -d "$SOURCE_DIR" ]]; then
    COUNT="$(find "$SOURCE_DIR" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
  fi
  if [[ "$COUNT" -ge 6 ]]; then
    break
  fi
  sleep 1
done

FINAL_COUNT=0
if [[ -d "$SOURCE_DIR" ]]; then
  FINAL_COUNT="$(find "$SOURCE_DIR" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
fi

if [[ "$FINAL_COUNT" -lt 6 ]]; then
  echo "Screenshot export did not finish in time."
  exit 1
fi

rm -f "$OUTPUT_DIR"/*.png
cp "$SOURCE_DIR"/*.png "$OUTPUT_DIR/"
echo ""
echo "Screenshots saved to $OUTPUT_DIR:"
ls -la "$OUTPUT_DIR"/*.png
