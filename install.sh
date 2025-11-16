#!/bin/bash
# BUFLO Local Installation Script for Linux

set -e

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
SHARE_DIR="$PREFIX/share/buflo"
DESKTOP_DIR="$PREFIX/share/applications"
ICON_DIR="$PREFIX/share/icons/hicolor/256x256/apps"

echo "🦬 Installing BUFLO..."
echo "   Prefix: $PREFIX"

# Create directories
mkdir -p "$BIN_DIR" "$SHARE_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# Build .love file
echo "📦 Building..."
./build.sh

# Install .love file
cp build/buflo.love "$SHARE_DIR/"
echo "   ✅ Installed: $SHARE_DIR/buflo.love"

# Create launcher script
cat > "$BIN_DIR/buflo" << 'EOF'
#!/bin/bash
# BUFLO Launcher
love "$HOME/.local/share/buflo/buflo.love" "$@"
EOF

chmod +x "$BIN_DIR/buflo"
echo "   ✅ Installed: $BIN_DIR/buflo"

# Install icon
if [ -f "assets/buflo.png" ]; then
  cp "assets/buflo.png" "$ICON_DIR/buflo.png"
  echo "   ✅ Installed: $ICON_DIR/buflo.png"
fi

# Create .desktop file
cat > "$DESKTOP_DIR/buflo.desktop" << EOF
[Desktop Entry]
Name=BUFLO
Comment=Billing Unified Flow Language & Orchestrator
Exec=$BIN_DIR/buflo
Icon=buflo
Terminal=false
Type=Application
Categories=Office;Finance;
EOF

echo "   ✅ Installed: $DESKTOP_DIR/buflo.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
  update-desktop-database "$DESKTOP_DIR"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 Usage:"
echo "   buflo                    # Launch GUI"
echo "   love ~/.local/share/buflo/buflo.love    # Alternative"
echo ""
echo "📋 Requirements:"
echo "   • LÖVE 11.5+ (love package)"
echo "   • poppler-utils (for PDF merging)"
echo ""
echo "🗑️  Uninstall:"
echo "   rm $BIN_DIR/buflo"
echo "   rm -rf $SHARE_DIR"
echo "   rm $DESKTOP_DIR/buflo.desktop"
echo "   rm $ICON_DIR/buflo.png"
