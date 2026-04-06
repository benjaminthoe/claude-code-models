#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="SpeedBoost"
BUNDLE_ID="com.local.speedboost"
EXTENSION_DIR="$SCRIPT_DIR/extension"
# Build in /tmp to avoid iCloud Drive extended attributes breaking code signing
BUILD_DIR="/tmp/SpeedBoost-build"
DEPLOY_DIR="$HOME/Desktop/Claude Code App"

echo "========================================="
echo "  SpeedBoost Safari Extension Builder"
echo "========================================="
echo ""

# ─── Step 0: Check prerequisites ───
echo "[1/5] Checking prerequisites..."

XCODE_PATH="$(xcode-select -p 2>/dev/null || echo "")"
if [[ -z "$XCODE_PATH" ]] || [[ ! "$XCODE_PATH" == *"Xcode"* ]]; then
    echo ""
    echo "ERROR: Full Xcode.app is required (not just Command Line Tools)."
    echo ""
    echo "  Current developer path: ${XCODE_PATH:-'(none)'}"
    echo ""
    echo "  To fix this:"
    echo "    1. Install Xcode from the Mac App Store"
    echo "    2. Open Xcode once to accept the license"
    echo "    3. Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "    4. Re-run this script"
    echo ""
    exit 1
fi

CONVERTER=""
CONVERTER="$(xcrun --find safari-web-extension-converter 2>/dev/null)" || true
if [[ -z "$CONVERTER" ]]; then
    CONVERTER="$(find /Applications/Xcode.app -name safari-web-extension-converter -type f 2>/dev/null | head -1)" || true
fi
if [[ -z "$CONVERTER" ]]; then
    echo "ERROR: safari-web-extension-converter not found."
    echo "  Make sure Xcode is properly installed and selected."
    exit 1
fi

echo "  Xcode: $XCODE_PATH"
echo "  Converter: $CONVERTER"
echo ""

# ─── Step 1: Generate placeholder icons ───
echo "[2/5] Generating icons..."

python3 - "$EXTENSION_DIR/images" <<'PYEOF'
import sys, struct, zlib, os

outdir = sys.argv[1]
os.makedirs(outdir, exist_ok=True)

def make_png(size, filepath):
    """Generate a cyan circle icon as valid PNG."""
    # RGBA pixels
    pixels = []
    cx, cy, r = size // 2, size // 2, size // 2 - 2
    for y in range(size):
        row = []
        for x in range(size):
            dx, dy = x - cx, y - cy
            dist = (dx * dx + dy * dy) ** 0.5
            if dist <= r:
                # Cyan gradient
                alpha = 255
                if dist > r - 1.5:
                    alpha = int(255 * (r - dist) / 1.5)
                    alpha = max(0, min(255, alpha))
                # Gradient from cyan to purple
                t = dist / r
                red = int(0 + t * 123)
                green = int(212 - t * 165)
                blue = int(255)
                row.extend([red, green, blue, alpha])
            else:
                row.extend([0, 0, 0, 0])
        pixels.append(bytes([0] + row))  # filter byte + row data

    raw = b''.join(pixels)
    compressed = zlib.compress(raw)

    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)

    ihdr = struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0)
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', ihdr)
    png += chunk(b'IDAT', compressed)
    png += chunk(b'IEND', b'')

    with open(filepath, 'wb') as f:
        f.write(png)
    print(f"  Generated: {os.path.basename(filepath)} ({size}x{size})")

for size in [48, 96, 128]:
    path = os.path.join(outdir, f'icon-{size}.png')
    if not os.path.exists(path):
        make_png(size, path)
    else:
        print(f"  Exists: icon-{size}.png")
PYEOF

echo ""

# ─── Step 2: Convert web extension to Safari app ───
echo "[3/5] Converting to Safari Web Extension..."

rm -rf "$BUILD_DIR"

# Copy extension to /tmp to strip iCloud xattrs
EXTENSION_COPY="/tmp/SpeedBoost-ext"
rm -rf "$EXTENSION_COPY"
cp -R "$EXTENSION_DIR" "$EXTENSION_COPY"
xattr -cr "$EXTENSION_COPY"

"$CONVERTER" "$EXTENSION_COPY" \
    --project-location "$BUILD_DIR" \
    --app-name "$APP_NAME" \
    --bundle-identifier "$BUNDLE_ID" \
    --swift \
    --macos-only \
    --copy-resources \
    --no-open \
    --force

echo ""

# ─── Step 3: Build with xcodebuild ───
echo "[4/5] Building with xcodebuild..."

# Find the generated xcodeproj
XCODEPROJ=$(find "$BUILD_DIR" -name "*.xcodeproj" -maxdepth 2 | head -1)
if [[ -z "$XCODEPROJ" ]]; then
    echo "ERROR: No .xcodeproj found in $BUILD_DIR"
    exit 1
fi
echo "  Project: $XCODEPROJ"

# Fix bundle ID case mismatch (converter may capitalize app name)
sed -i '' "s/com\.local\.SpeedBoost/com.local.speedboost/g" "$XCODEPROJ/project.pbxproj"

# Auto-detect scheme
SCHEME=$(xcodebuild -project "$XCODEPROJ" -list 2>/dev/null | \
    awk '/Schemes:/{found=1; next} found && /^[[:space:]]+.+/{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print; exit}')

if [[ -z "$SCHEME" ]]; then
    SCHEME="$APP_NAME (macOS)"
fi
echo "  Scheme: $SCHEME"

xattr -cr "$BUILD_DIR"

xcodebuild \
    -project "$XCODEPROJ" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=YES \
    ONLY_ACTIVE_ARCH=YES \
    build 2>&1 | tail -5

echo ""

# ─── Step 4: Deploy ───
echo "[5/5] Deploying..."

BUILT_APP=$(find "$BUILD_DIR/DerivedData" -name "$APP_NAME.app" -type d | head -1)
if [[ -z "$BUILT_APP" ]]; then
    echo "ERROR: Built app not found in DerivedData"
    echo "  Check xcodebuild output above for errors."
    exit 1
fi

mkdir -p "$DEPLOY_DIR"
rm -rf "$DEPLOY_DIR/$APP_NAME.app"
cp -R "$BUILT_APP" "$DEPLOY_DIR/"

echo "  Deployed to: $DEPLOY_DIR/$APP_NAME.app"
echo ""

# ─── Done ───
echo "========================================="
echo "  BUILD SUCCESSFUL"
echo "========================================="
echo ""
echo "  To enable the extension:"
echo ""
echo "  1. Open $APP_NAME.app:"
echo "     open \"$DEPLOY_DIR/$APP_NAME.app\""
echo ""
echo "  2. In Safari, go to:"
echo "     Safari > Settings > Extensions"
echo "     Enable '$APP_NAME'"
echo ""
echo "  3. If needed, enable unsigned extensions:"
echo "     Safari > Develop > Allow Unsigned Extensions"
echo "     (Enable Develop menu in Safari > Settings > Advanced)"
echo ""
echo "  4. Visit missav.ai — enjoy faster loading!"
echo ""
