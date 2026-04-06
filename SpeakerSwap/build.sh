#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="SpeakerSwap"
APP_BUNDLE="${SCRIPT_DIR}/${APP_NAME}.app"
ICON_SET="${SCRIPT_DIR}/AppIcon.iconset"

echo "=== Building ${APP_NAME} ==="

# Step 1: Generate icon
echo "[1/4] Generating icon..."
swiftc -O -o "${SCRIPT_DIR}/generate_icon" "${SCRIPT_DIR}/generate_icon.swift" -framework Cocoa 2>&1
"${SCRIPT_DIR}/generate_icon" "${SCRIPT_DIR}"
rm -f "${SCRIPT_DIR}/generate_icon"

# Create .iconset with all required sizes
rm -rf "${ICON_SET}"
mkdir -p "${ICON_SET}"
SIZES=(16 32 64 128 256 512 1024)
for s in "${SIZES[@]}"; do
    sips -z "$s" "$s" "${SCRIPT_DIR}/icon_1024.png" --out "${ICON_SET}/icon_${s}x${s}.png" > /dev/null 2>&1 || true
done
# Create @2x variants
cp "${ICON_SET}/icon_32x32.png"   "${ICON_SET}/icon_16x16@2x.png"
cp "${ICON_SET}/icon_64x64.png"   "${ICON_SET}/icon_32x32@2x.png"
cp "${ICON_SET}/icon_256x256.png" "${ICON_SET}/icon_128x128@2x.png"
cp "${ICON_SET}/icon_512x512.png" "${ICON_SET}/icon_256x256@2x.png"
cp "${ICON_SET}/icon_1024x1024.png" "${ICON_SET}/icon_512x512@2x.png"
# Remove non-standard sizes
rm -f "${ICON_SET}/icon_64x64.png" "${ICON_SET}/icon_1024x1024.png"

# Convert to .icns
iconutil -c icns "${ICON_SET}" -o "${SCRIPT_DIR}/AppIcon.icns" 2>&1
rm -rf "${ICON_SET}" "${SCRIPT_DIR}/icon_1024.png"
echo "   Icon created."

# Step 2: Compile app
echo "[2/4] Compiling..."
swiftc -O \
    -o "${SCRIPT_DIR}/${APP_NAME}" \
    "${SCRIPT_DIR}/main.swift" \
    -framework Cocoa \
    -framework CoreAudio \
    -framework AudioToolbox
echo "   Compiled."

# Step 3: Create .app bundle
echo "[3/4] Creating app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

mv "${SCRIPT_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp "${SCRIPT_DIR}/Info.plist" "${APP_BUNDLE}/Contents/"
cp "${SCRIPT_DIR}/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"
echo -n "APPL????" > "${APP_BUNDLE}/Contents/PkgInfo"
# Ad-hoc sign so it appears properly in Input Monitoring settings
codesign --force --sign - "${APP_BUNDLE}" 2>/dev/null
echo "   Bundle created & signed."

# Step 4: Deploy
DESKTOP_FOLDER="$HOME/Desktop/Claude Code App"
mkdir -p "${DESKTOP_FOLDER}"
rm -rf "${DESKTOP_FOLDER}/${APP_NAME}.app"
cp -r "${APP_BUNDLE}" "${DESKTOP_FOLDER}/"
echo "[4/4] Deployed to: ${DESKTOP_FOLDER}/${APP_NAME}.app"

echo ""
echo "=== Build complete ==="
echo ""
echo "To run:  open \"${DESKTOP_FOLDER}/${APP_NAME}.app\""
echo ""
echo "The app appears in your menu bar as  L|R"
echo "Click -> Swap Left <-> Right to swap channels."
echo "Use the test tone buttons to verify the swap works."
echo "Channels reset automatically when you quit."
