# Building BUFLO Distributions

Complete guide for building distributable packages of BUFLO for all platforms.

## Quick Build

```bash
./build.sh
```

Output in `dist/`:
- `buflo-3.0.love` - Universal (requires LÖVE)
- `buflo-3.0-linux` - Linux executable
- `buflo-3.0-windows.zip` - Windows bundle
- `buflo-3.0-macos.dmg` - macOS app

---

## Prerequisites

### For All Builds

- **zip** command-line tool
- **bash** shell
- Git repository clone

### For Windows Builds

1. Download LÖVE for Windows: https://github.com/love2d/love/releases
2. Extract to `build/love-windows/`:
   ```
   build/
   └── love-windows/
       ├── love.exe
       ├── SDL2.dll
       ├── OpenAL32.dll
       ├── lua51.dll
       ├── mpg123.dll
       └── ... (all other DLLs)
   ```

3. **(Optional)** Download Poppler for Windows: https://github.com/oschwartz10612/poppler-windows/releases
4. Extract to `build/poppler-windows/`:
   ```
   build/
   └── poppler-windows/
       ├── pdftoppm.exe
       ├── pdfinfo.exe
       └── ... (DLLs)
   ```

### For macOS Builds

1. Download LÖVE.app for macOS: https://github.com/love2d/love/releases
2. Extract to `build/love.app`:
   ```
   build/
   └── love.app/
       └── Contents/
           ├── Info.plist
           ├── MacOS/
           └── Resources/
   ```

---

## Detailed Build Process

### 1. Universal .love File

The `.love` file is a renamed `.zip` containing all game files:

```bash
zip -9 -r build/buflo.love . -x "*.git*" -x "profiles/nordhealth*" -x "out/*"
```

**Excluded from distribution:**
- `.git/` - Git metadata
- `profiles/nordhealth*` - Private profiles
- `out/` - Generated PDFs
- `build/` - Build artifacts
- `dist/` - Distribution files
- Documentation files (README.md, etc.)

**Anyone with LÖVE installed can run:**
```bash
love buflo.love
```

---

### 2. Linux Executable

Concatenates LÖVE binary with .love file:

```bash
cat $(which love) build/buflo.love > build/buflo-linux
chmod +x build/buflo-linux
```

**Dependencies users need:**
- poppler-utils (for PDF merging)

**Distribution options:**
1. Standalone `.love` file (smallest, requires LÖVE)
2. Bundled executable (larger, still needs poppler)
3. AppImage (most portable, coming soon)

---

### 3. Windows Bundle

**Structure:**
```
buflo-3.0-windows/
├── buflo.exe           # love.exe + buflo.love concatenated
├── SDL2.dll
├── OpenAL32.dll
├── lua51.dll
├── mpg123.dll
├── msvcp120.dll
├── msvcr120.dll
├── license.txt
└── poppler/            # Optional PDF tools
    ├── pdftoppm.exe
    ├── pdfinfo.exe
    └── *.dll
```

**Build process:**
```bash
# Concatenate executable
cat build/love-windows/love.exe build/buflo.love > build/buflo.exe

# Copy DLLs
cp build/love-windows/*.dll dist/buflo-3.0-windows/
```

**Important:** Windows users don't need to install anything if poppler is included!

---

### 4. macOS Application Bundle

**Structure:**
```
BUFLO.app/
└── Contents/
    ├── Info.plist      # Modified bundle metadata
    ├── MacOS/
    │   └── love        # LÖVE executable
    └── Resources/
        └── buflo.love  # Your game
```

**Build process:**
```bash
# Copy template
cp -r build/love.app build/BUFLO.app

# Install game
cp build/buflo.love build/BUFLO.app/Contents/Resources/

# Update metadata
/usr/libexec/PlistBuddy -c "Set :CFBundleName BUFLO" build/BUFLO.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier life.dotmavriq.buflo" build/BUFLO.app/Contents/Info.plist

# Create DMG
hdiutil create -volname "BUFLO 3.0" -srcfolder build/BUFLO.app -ov -format UDZO dist/buflo-3.0-macos.dmg
```

**Users need:**
- macOS 10.9+
- `brew install poppler` (for PDF merging)

---

## Dependency Matrix

| Platform | Runtime | PDF Merging | Notes |
|----------|---------|-------------|-------|
| **Linux** | LÖVE 11.5+ | poppler-utils | From package manager |
| **Windows** | Bundled | Bundled (optional) | Self-contained .zip |
| **macOS** | Bundled | Homebrew poppler | DMG installer |

---

## Testing Builds

### Test .love file
```bash
love dist/buflo-3.0.love
```

### Test Linux build
```bash
./dist/buflo-3.0-linux
```

### Test Windows build
```powershell
# On Windows VM or Wine
wine dist/buflo-3.0-windows/buflo.exe
```

### Test macOS build
```bash
# On macOS
open dist/buflo-3.0-macos.dmg
# Drag BUFLO.app to Applications
```

---

## Troubleshooting

### "zip: command not found"
```bash
# Fedora/RHEL
sudo dnf install zip

# Debian/Ubuntu
sudo apt install zip

# macOS
brew install zip
```

### "love: not found" during Linux build
Install LÖVE or use the `.love` distribution instead:
```bash
sudo dnf install love  # or apt install love
```

### Windows build missing DLLs
Ensure all files from LÖVE Windows .zip are in `build/love-windows/`:
```bash
ls build/love-windows/
# Should show: love.exe, SDL2.dll, OpenAL32.dll, lua51.dll, etc.
```

### macOS DMG creation fails
Requires macOS host. Alternative for Linux/Windows users:
```bash
# Just distribute the .app folder as .tar.gz
tar -czf dist/buflo-3.0-macos.tar.gz -C build BUFLO.app
```

---

## Release Checklist

- [ ] Update version in `build.sh`
- [ ] Update version in `conf.lua`
- [ ] Update version in README.md
- [ ] Run `./build.sh` and verify all builds
- [ ] Test each platform build
- [ ] Create git tag: `git tag v3.0`
- [ ] Push tag: `git push origin v3.0`
- [ ] Create GitHub release
- [ ] Upload distribution files
- [ ] Update download links in README

---

## File Sizes (Approximate)

- **buflo.love**: ~500 KB
- **buflo-linux**: ~2 MB (with LÖVE embedded)
- **buflo-windows.zip**: ~10 MB (with DLLs)
- **buflo-macos.dmg**: ~15 MB (complete app)

---

## Advanced: Custom Builds

### Exclude specific profiles
Edit `build.sh` and add to `EXCLUDE_PATTERNS`:
```bash
EXCLUDE_PATTERNS=(
  ...
  "profiles/my_private_profile.toml"
)
```

### Include default profiles
Create `profiles/examples/` directory before building:
```bash
mkdir -p profiles/examples
cp profiles/diamond_dogs_llc.toml profiles/examples/
```

### Add branding
Replace `assets/buflo.png` with your logo before building.

---

## Continuous Integration

### GitHub Actions Example
```yaml
name: Build Distributions
on: [push, release]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: ./build.sh
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: distributions
          path: dist/
```

---

**For questions or issues, see:** https://github.com/dotMavriQ/Buflo/issues
