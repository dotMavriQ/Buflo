# BUFLO Release Notes

## Version 3.0 - November 2025

### 🎉 Major Release: TOML Configuration & Complete Rewrite

BUFLO v3.0 is a complete rewrite featuring standardized TOML configuration, interactive table widgets, PDF attachment merging, and a beautiful Gruvbox-themed interface.

---

## 🆕 What's New

### Configuration Format
- **TOML Standard**: Replaced custom DSL with industry-standard TOML format
- **No Learning Curve**: Use familiar TOML syntax for invoice profiles
- **Better Documentation**: Complete specification in TOML_PROFILE_SPEC.md

### Interactive Features
- **Table Widget**: Add/remove rows dynamically for line items
- **Real-time Calculations**: `@calc()` and `@sum()` formulas compute automatically
- **PDF Merging**: Attach external PDFs (timesheets, receipts) to invoices
- **Drag & Drop**: Upload logos and PDFs with drag-and-drop support

### User Interface
- **Gruvbox Dark Theme**: Professional, eye-friendly color scheme
- **Multi-page Forms**: Smart pagination with progress tracking
- **Field Validation**: Email, date, and required field validation
- **HTML Preview**: Preview invoices before generating

### Distribution
- **Cross-Platform**: Linux, Windows, and macOS builds
- **Self-Contained Windows**: No dependencies needed on Windows
- **Easy Installation**: One-command install on Linux

---

## 📦 Download

Choose the right package for your platform:

### Universal (All Platforms)
- **buflo-3.0.love** - Requires LÖVE 11.5+ runtime
- Smallest download (~1.7 MB)
- Works on Linux, Windows, macOS

### Linux
- **buflo-3.0-linux** - Standalone executable
- Requires: `poppler-utils` package
- Install with: `./install.sh`

### Windows
- **buflo-3.0-windows.zip** - Self-contained bundle *(Coming soon)*
- All DLLs included
- Optional: Poppler for PDF merging
- Just unzip and run!

### macOS
- **buflo-3.0-macos.dmg** - Application bundle *(Coming soon)*
- Drag to Applications folder
- Optional: `brew install poppler` for PDF merging

---

## 🚀 Installation

### Universal .love File

**Requirements:**
- LÖVE 11.5+ ([download](https://love2d.org/))
- poppler-utils (for PDF merging)

**Run:**
```bash
love buflo-3.0.love
```

### Linux

**Option 1: Quick Install**
```bash
chmod +x install.sh
./install.sh
buflo
```

**Option 2: Direct Run**
```bash
chmod +x buflo-3.0-linux
./buflo-3.0-linux
```

**Dependencies:**
```bash
# Fedora
sudo dnf install poppler-utils

# Debian/Ubuntu
sudo apt install poppler-utils

# Arch
sudo pacman -S poppler
```

### Windows

1. Extract `buflo-3.0-windows.zip`
2. Run `buflo.exe`
3. *(Optional)* For PDF merging, add poppler to PATH

### macOS

1. Open `buflo-3.0-macos.dmg`
2. Drag BUFLO.app to Applications
3. *(Optional)* `brew install poppler` for PDF merging

---

## 🎯 Quick Start

1. Launch BUFLO
2. Select a profile from the dropdown (try "Diamond Dogs LLC" example)
3. Fill in the form fields
4. Add line items using the table widget
5. Attach PDFs if needed
6. Click "Preview & Print" to generate invoice

---

## 📚 Documentation

- **README.md** - Complete user guide
- **TOML_PROFILE_SPEC.md** - Profile format specification
- **BUILDING.md** - Build from source guide

---

## 🔧 System Requirements

**Minimum:**
- CPU: Any modern processor
- RAM: 512 MB
- Disk: 100 MB
- Display: 1024x768 minimum

**Recommended:**
- Display: 1920x1080 or higher
- For PDF merging: poppler-utils installed

---

## ⚙️ Dependencies

### Included in Builds
- LÖVE 11.5 runtime (bundled in platform-specific builds)
- Lua 5.1 (included with LÖVE)
- All required libraries and assets

### Optional External
- **poppler-utils** - For PDF attachment merging feature
  - Linux: Install via package manager
  - Windows: Download from [poppler-windows](https://github.com/oschwartz10612/poppler-windows/releases/)
  - macOS: `brew install poppler`

**Note:** PDF merging is optional. BUFLO works perfectly without it!

---

## 🔄 Upgrading from v2.x

**Breaking Changes:**
- Custom `.buflo` DSL format removed
- Now uses standard TOML format
- Old `.bpl.lua` format no longer supported

**Migration:**
1. Convert old profiles to TOML format (see TOML_PROFILE_SPEC.md)
2. Use `profiles/diamond_dogs_llc.toml` as reference
3. Test with new format before production use

---

## 🐛 Known Issues

- PDF generation creates HTML preview only (print to PDF from browser)
- Table widget doesn't support copy/paste yet
- No undo/redo in form fields

See [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues) for full list.

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Priority Areas:**
- Direct PDF generation (wkhtmltopdf/weasyprint integration)
- Profile editor with syntax highlighting
- Additional field types and widgets
- Internationalization (i18n)

---

## 📜 License

MIT License - Free for personal and commercial use.

Copyright (c) 2025 BUFLO Contributors

---

## 🙏 Credits

- **LÖVE2D** - Game framework
- **Gruvbox** - Color scheme by morhetz
- **Lua** - Programming language
- **TOML** - Configuration format
- **Poppler** - PDF rendering library

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues)
- **Discussions**: [GitHub Discussions](https://github.com/dotMavriQ/Buflo/discussions)
- **Documentation**: In-repository markdown files

---

## 🎯 What's Next?

**Planned for v3.1:**
- Direct PDF generation
- Profile editor GUI
- Template library
- Export to other formats (CSV, JSON)

**Long-term Roadmap:**
- Email integration
- Multi-language support
- Cloud sync (optional)
- Mobile app

---

**Built with ❤️ for the open source community**

**Download now and start creating beautiful invoices!**
