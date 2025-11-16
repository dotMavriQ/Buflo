#!/bin/bash
# BUFLO Build Script
# Creates distributable packages for Linux, Windows, and macOS

set -e

VERSION="3.0"
BUILD_DIR="build"
DIST_DIR="dist"

echo "🦬 Building BUFLO v${VERSION}..."

# Clean previous builds
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Files to exclude from .love package
EXCLUDE_PATTERNS=(
  "*.git*"
  "profiles/nordhealth*"
  "out/*"
  "build/*"
  "dist/*"
  ".gitignore"
  "*.md"
  "build.sh"
  "install.sh"
)

# Build exclude arguments for zip
EXCLUDE_ARGS=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS="$EXCLUDE_ARGS -x $pattern"
done

# Create .love file (platform-independent)
echo "📦 Creating buflo.love..."
cd "$(dirname "$0")"
zip -9 -r "$BUILD_DIR/buflo.love" . $EXCLUDE_ARGS

echo "✅ Created: $BUILD_DIR/buflo.love"

# Linux builds
echo ""
echo "🐧 Building for Linux..."

# Standalone .love (requires LÖVE installed)
cp "$BUILD_DIR/buflo.love" "$DIST_DIR/buflo-${VERSION}.love"
echo "   ✅ buflo-${VERSION}.love (requires: love, poppler-utils)"

# Bundled executable (if love binary exists)
if command -v love &> /dev/null; then
  LOVE_BIN=$(which love)
  cat "$LOVE_BIN" "$BUILD_DIR/buflo.love" > "$BUILD_DIR/buflo-linux"
  chmod +x "$BUILD_DIR/buflo-linux"
  cp "$BUILD_DIR/buflo-linux" "$DIST_DIR/buflo-${VERSION}-linux"
  echo "   ✅ buflo-${VERSION}-linux (bundled, still needs poppler-utils)"
fi

# Windows build (requires Windows LÖVE in build/love-windows/)
echo ""
echo "🪟 Building for Windows..."
WINDOWS_LOVE_DIR="$BUILD_DIR/love-windows"

if [ -d "$WINDOWS_LOVE_DIR" ]; then
  # Concatenate .love with love.exe
  cat "$WINDOWS_LOVE_DIR/love.exe" "$BUILD_DIR/buflo.love" > "$BUILD_DIR/buflo.exe"

  # Create distribution directory
  WIN_DIST="$DIST_DIR/buflo-${VERSION}-windows"
  mkdir -p "$WIN_DIST"

  # Copy executable and all DLLs
  cp "$BUILD_DIR/buflo.exe" "$WIN_DIST/"
  cp "$WINDOWS_LOVE_DIR"/*.dll "$WIN_DIST/"
  cp "$WINDOWS_LOVE_DIR/license.txt" "$WIN_DIST/"

  # Copy poppler binaries if available
  if [ -d "$BUILD_DIR/poppler-windows" ]; then
    mkdir -p "$WIN_DIST/poppler"
    cp -r "$BUILD_DIR/poppler-windows"/* "$WIN_DIST/poppler/"
    echo "   ✅ Included poppler binaries"
  else
    echo "   ⚠️  Poppler not found. Users must install separately."
  fi

  # Create zip archive
  cd "$DIST_DIR"
  zip -9 -r "buflo-${VERSION}-windows.zip" "buflo-${VERSION}-windows"
  cd ..

  echo "   ✅ buflo-${VERSION}-windows.zip"
else
  echo "   ⚠️  Windows LÖVE not found at $WINDOWS_LOVE_DIR"
  echo "   📥 Download from: https://github.com/love2d/love/releases"
  echo "   📝 Extract to: $WINDOWS_LOVE_DIR"
fi

# macOS build
echo ""
echo "🍎 Building for macOS..."
MACOS_LOVE_APP="$BUILD_DIR/love.app"

if [ -d "$MACOS_LOVE_APP" ]; then
  # Copy LÖVE.app template
  BUFLO_APP="$BUILD_DIR/BUFLO.app"
  cp -r "$MACOS_LOVE_APP" "$BUFLO_APP"

  # Copy .love into app bundle
  cp "$BUILD_DIR/buflo.love" "$BUFLO_APP/Contents/Resources/"

  # Update Info.plist
  /usr/libexec/PlistBuddy -c "Set :CFBundleName BUFLO" "$BUFLO_APP/Contents/Info.plist" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier life.dotmavriq.buflo" "$BUFLO_APP/Contents/Info.plist" 2>/dev/null || true

  # Create DMG
  hdiutil create -volname "BUFLO ${VERSION}" -srcfolder "$BUFLO_APP" -ov -format UDZO "$DIST_DIR/buflo-${VERSION}-macos.dmg"

  echo "   ✅ buflo-${VERSION}-macos.dmg"
else
  echo "   ⚠️  LÖVE.app not found at $MACOS_LOVE_APP"
  echo "   📥 Download from: https://github.com/love2d/love/releases"
  echo "   📝 Extract to: $MACOS_LOVE_APP"
fi

echo ""
echo "🎉 Build complete!"
echo "📂 Distribution files in: $DIST_DIR/"
ls -lh "$DIST_DIR/"

echo ""
echo "📝 Distribution notes:"
echo "   • .love file requires LÖVE runtime on target system"
echo "   • Linux binary requires poppler-utils (pdftoppm)"
echo "   • Windows .zip includes all DLLs, needs poppler for PDF merging"
echo "   • macOS .dmg is self-contained, users may need to install poppler via Homebrew"
