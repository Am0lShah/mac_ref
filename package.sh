#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#  MacRef – Build & Package Script
#  Usage:  chmod +x package.sh && ./package.sh
#  Output: MacRef.dmg in the project root
# ─────────────────────────────────────────────────────────────────
set -euo pipefail

PROJECT="MacRef.xcodeproj"
SCHEME="MacRef"
ARCHIVE_PATH="./build/MacRef.xcarchive"
EXPORT_PATH="./build/export"
DMG_NAME="MacRef.dmg"
VOLUME_NAME="MacRef"

echo "▶ Cleaning previous build..."
rm -rf ./build
mkdir -p ./build

echo "▶ Archiving (Release, arm64)..."
xcodebuild archive \
  -project "$PROJECT" \
  -scheme   "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=NO \
  | xcpretty || true   # xcpretty is optional; remove '| xcpretty' if not installed

echo "▶ Exporting .app..."
# For a simple local DMG (no signing) use the exportOptions below.
# To notarise, add your Developer ID and set method=developer-id.
cat > /tmp/MacRef_ExportOptions.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

xcodebuild -exportArchive \
  -archivePath   "$ARCHIVE_PATH" \
  -exportPath    "$EXPORT_PATH" \
  -exportOptionsPlist /tmp/MacRef_ExportOptions.plist

APP_PATH="$EXPORT_PATH/$SCHEME.app"

echo "▶ Creating DMG with hdiutil..."
# Temp directory used as DMG source
STAGING="./build/dmg_staging"
mkdir -p "$STAGING"
cp -R "$APP_PATH" "$STAGING/"

# Symlink to /Applications so users can drag-install
ln -sf /Applications "$STAGING/Applications"

hdiutil create \
  -volname  "$VOLUME_NAME" \
  -srcfolder "$STAGING" \
  -ov \
  -format   UDZO \
  "$DMG_NAME"

echo ""
echo "✅  Done!  →  $DMG_NAME"
