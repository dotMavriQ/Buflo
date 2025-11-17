# BUFLO — Billing Unified Flow Language & Orchestrator

<img src="assets/buflo.png" alt="buflo logo" width="30%">

A modern desktop billing application written in Lua with LÖVE2D. Create professional invoices using simple configuration files (based on TOML), with dynamic forms, table widgets, PDF attachment merging, and a beautiful Gruvbox-themed interface.

**Current Version**: 3.0 (LÖVE2D GUI with TOML profiles)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Quick Start

```bash
# Install dependencies (Fedora)
sudo dnf install lua love poppler-utils

# Or (Debian/Ubuntu)
sudo apt install lua5.4 love poppler-utils

# Launch BUFLO
cd /path/to/Buflo
love .
```

Select a profile from the dropdown and start creating invoices!

---

## ✨ Features

- **🎨 Beautiful GUI**: LÖVE2D-based interface with Gruvbox Dark Material theme
- **📝 TOML Configuration**: Simple, standard TOML format - no custom DSL
- **🔄 Dynamic Forms**: Multi-page forms with smart pagination
- **📊 Interactive Tables**: Add/remove rows, auto-calculate amounts and totals
- **🧮 Calculated Fields**: `@calc()` and `@sum()` formulas for automatic calculations
- **✅ Validation**: Required fields, email/phone formats, custom rules
- **🖼️ Image Support**: Logo uploads with drag-and-drop
- **📄 PDF Merging**: Attach and merge external PDFs (like timesheets) with your invoices
- **🎯 Progress Tracking**: Visual progress bar through form pages
- **👁️ HTML Preview**: See rendered output with print support
- **🎨 Print Preview**: Gruvbox dark background with beautiful A4 page separation
- **🖥️ Cross-Platform**: Full support for Linux, macOS, and Windows with platform-specific optimizations

---

## 📦 Installation

### System Requirements

- **Lua 5.4+**
- **LÖVE 11.5+** (Mysterious Mysteries)
- **poppler-utils** (for PDF merging with `pdftoppm`)
- **Git** (for cloning)

### Linux

**Fedora:**
```bash
sudo dnf install lua love poppler-utils git
```

**Debian/Ubuntu:**
```bash
sudo apt install lua5.4 love poppler-utils git
```

**Arch:**
```bash
sudo pacman -S lua love poppler git
```

### macOS

```bash
brew install lua love poppler git
```

### Windows

**PowerShell (Run as Administrator):**

```powershell
# 1. Install Lua (download from lua.org and add to PATH)
# 2. Download and install LÖVE from love2d.org

# 3. Install Poppler (pdftoppm) for PDF merging
mkdir $HOME\tools

Invoke-WebRequest `
  -Uri "https://github.com/oschwartz10612/poppler-windows/releases/download/v24.02.0-0/Release-24.02.0-0.zip" `
  -OutFile "$HOME\tools\poppler.zip"

Expand-Archive "$HOME\tools\poppler.zip" -DestinationPath "$HOME\tools\poppler" -Force

# 4. Add Poppler to PATH
$pp = Get-ChildItem "$HOME\tools\poppler" -Recurse -Filter pdftoppm.exe |
      Select-Object -First 1 -ExpandProperty DirectoryName

$env:Path += ";$pp"

# Add to permanent PATH (run in new PowerShell session)
[Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)

# 5. Verify installation
pdftoppm -v

# 6. Install Git from git-scm.com
```

**Note**: BUFLO automatically detects Windows and uses Windows-specific commands (`dir`, `del`, `mkdir`) instead of Linux commands (`ls`, `rm`, `mkdir -p`). All path handling, quoting, and temp directory management is platform-aware.

### Clone Repository

```bash
git clone https://github.com/dotMavriQ/Buflo.git
cd Buflo
```

### Verify Installation

```bash
lua -v          # Should show Lua 5.4+
love --version  # Should show LÖVE 11.5+
pdftoppm -v     # Should show Poppler version
```

### Quick Install (Linux)

```bash
./install.sh    # Installs to ~/.local/bin/buflo
```

---

## 📦 Distribution & Building

### Create Distributable Packages

```bash
./build.sh
```

This creates:
- **buflo-3.0.love** - Platform-independent (requires LÖVE runtime)
- **buflo-3.0-linux** - Linux executable (requires poppler-utils)
- **buflo-3.0-windows.zip** - Windows bundle with DLLs
- **buflo-3.0-macos.dmg** - macOS application

### Platform-Specific Dependencies

**All Platforms:**
- LÖVE 11.5+ runtime (included in bundled builds)

**For PDF Merging Feature:**
- **Linux**: `poppler-utils` package
- **Windows**: Poppler binaries - download from [poppler-windows](https://github.com/oschwartz10612/poppler-windows/releases/) and add to PATH
- **macOS**: `brew install poppler`

**Note**: PDF merging is optional. Without poppler, you can still create invoices and view HTML previews. BUFLO automatically detects the platform and uses appropriate commands for Windows (`dir`, `del`, `mkdir`) vs Linux/macOS (`ls`, `rm`, `mkdir -p`).

### Windows Distribution Details

The Windows `.zip` includes:
- `buflo.exe` - Main executable
- All required LÖVE DLLs (`SDL2.dll`, `OpenAL32.dll`, `lua51.dll`, etc.)
- `poppler/` folder with PDF tools (if included during build)

**Users just unzip and run `buflo.exe`!**

---

## 🎮 Usage

### Launch Welcome Screen

```bash
cd /path/to/Buflo
love .
```

The welcome screen allows you to:
- **Load Profile**: Select from dropdown and open form
- **Create Profile**: Start a new `.toml` file (coming soon)
- **Edit Profile**: Modify existing profile (coming soon)
- **Delete Profile**: Remove profile from disk (coming soon)

### Fill Out Invoice Form

1. **Navigate Pages**: Use Next/Previous buttons
2. **Fill Required Fields**: Marked with red asterisk (*)
3. **Upload Images**: Click [+] to choose logo
4. **Attach PDF**: Drop PDF file or click to browse (for merging external documents)
5. **Add Table Rows**: Click "+ Add Row" for line items
6. **Review Progress**: Yellow bar shows completion
7. **Merge PDFs**: Click purple "Merge PDFs" button to validate PDF attachment
8. **Preview & Print**: Click yellow "Preview & Print" button to generate HTML preview

### Form Field Types

- **Text**: Single-line input (name, address, etc.)
- **Number**: Numeric values (quantities, rates)
- **Currency**: Monetary amounts with calculations
- **Date**: Date picker (invoice date, due date)
- **Email**: Email with validation
- **Tel**: Phone number
- **Image Upload**: File picker for logos with drag-and-drop
- **PDF Attachment**: File picker for external PDFs to merge
- **Table**: Repeating rows with calculated columns

### Keyboard Shortcuts

- **Tab**: Next field
- **Shift+Tab**: Previous field
- **Enter**: Next page (if valid)
- **Esc**: Quit application

---

## 📚 Creating Profiles

Profiles are defined in TOML format. See [TOML_PROFILE_SPEC.md](TOML_PROFILE_SPEC.md) for complete documentation.

### Basic Example

```toml
[document]
title = "Simple Invoice"
version = "3.0"

[settings]
currency = "€"
date_format = "YYYY-MM-DD"

[[section]]
heading = "Client Information"

[[section.field]]
id = "client_name"
label = "Client Name"
type = "text"
required = true

[[section.field]]
id = "invoice_date"
label = "Invoice Date"
type = "date"
required = true
default = "2025-11-16"
```

### Table with Calculations

```toml
[[section]]
type = "table"
id = "line_items"

[[section.column]]
id = "description"
label = "Description"
width = "40%"

[[section.column]]
id = "quantity"
label = "Quantity"
type = "number"
width = "20%"

[[section.column]]
id = "rate"
label = "Rate (€)"
type = "currency"
width = "20%"

[[section.column]]
id = "amount"
label = "Amount (€)"
type = "currency"
width = "20%"
formula = "@calc(quantity * rate)"

[section.summary]
label = "TOTAL"
formula = "@sum(items.amount)"
```

### PDF Attachment

```toml
[[section]]
heading = "Attachments"

[[section.field]]
id = "timesheet_pdf"
label = "Attach Timesheet PDF"
type = "pdf_attachment"
required = true
placeholder = "Drop PDF file here or click to browse"
```

---

## 🏗️ Architecture

### Project Structure

```
Buflo/
├── main.lua                    # Application entry point
├── conf.lua                    # LÖVE configuration
├── lib/
│   └── ui.lua                  # UI widgets with Gruvbox theme
├── screens/
│   ├── welcome.lua             # Welcome screen with profile selector
│   ├── form.lua                # Multi-page form flow
│   └── editor.lua              # Profile editor (placeholder)
├── buflo/
│   ├── core/
│   │   └── toml_parser.lua     # TOML parser
│   └── rendering/
│       ├── invoice_template.lua  # HTML generation
│       ├── section_renderer.lua  # Section rendering
│       └── table_renderer.lua    # Table rendering
├── ui/
│   └── table_widget.lua        # Interactive table widget
├── profiles/
│   └── *.toml                  # TOML invoice profiles
└── assets/
    └── buflo.png               # Logo
```

### Component Overview

**LÖVE2D Framework:**
- `conf.lua`: Window configuration (1024x768, resizable)
- `main.lua`: Screen management, input routing, global helpers

**UI Library (`lib/ui.lua`):**
- Gruvbox Dark Material color palette
- Widgets: buttons (primary, success, warning, danger, accent), text inputs, labels
- State management: hot/active/focused widgets
- Consistent styling across all components

**Screens:**
- **Welcome**: Profile selection and management
- **Form**: Multi-page form with dynamic pagination, validation, progress tracking
- **Editor**: (Placeholder) Profile editing

**Parser (`buflo/core/toml_parser.lua`):**
- Standard TOML parsing
- Extracts fields from sections
- Handles nested structures (columns, tables)

**Rendering (`buflo/rendering/`):**
- `invoice_template.lua`: HTML generation with PDF merging
- `section_renderer.lua`: Renders different section types
- `table_renderer.lua`: Renders tables with calculations

**Utilities:**
- `table_widget.lua`: Interactive table editing

### Data Flow

```
.toml file
    ↓
TOML Parser → Profile structure
    ↓
Form Screen → Dynamic pages with tables
    ↓
User Input → Validation → Calculations
    ↓
Collected Data → HTML Preview with merged PDFs
    ↓
Browser Print → PDF
```

### Gruvbox Theme

All UI components use the Gruvbox Dark Material palette:
- **Backgrounds**: #282828 (dark0_hard), #32302f (dark0), #3c3836 (dark1), #504945 (dark2)
- **Text**: #ebdbb2 (fg), #a89984 (gray), #665c54 (disabled)
- **Borders**: #665c54 (normal), #fabd2f (focus - yellow)
- **Buttons**:
  - Primary: #83a598 (blue)
  - Success: #b8bb26 (green)
  - Warning: #fabd2f (yellow)
  - Danger: #fb4934 (red)
  - Accent: #d3869b (purple)

---

## 🔧 Development

### Running from Source

```bash
cd /path/to/Buflo
love .
```

### Code Style

- **Indentation**: 2 spaces
- **Naming**: snake_case for variables/functions, UPPER_CASE for constants
- **Comments**: Explain "why", not "what"
- **Line length**: Aim for 100 characters max

### Testing

**Manual Testing:**
```bash
love .  # Launch and interact with GUI
```

**Profile Validation:**
- Ensure all required fields have `required = true`
- Verify field IDs are unique
- Check image upload paths are accessible
- Test PDF merging with external documents

### Debugging

Enable LÖVE debug output:
```bash
love . 2>&1 | tee debug.log
```

Common issues:
- **Font missing**: Falls back to default
- **Parser errors**: Check `.toml` syntax
- **Widget not responding**: Check z-order and hit detection
- **PDF validation fails**: Ensure `pdftoppm` is installed and in PATH

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request on GitHub.

### Areas to Contribute

**High Priority:**
- 📄 Direct PDF generation (wkhtmltopdf, weasyprint, or native)
- ✏️ Profile editor with TOML syntax highlighting
- 📋 Summary review screen before PDF generation
- 🔍 Search functionality in profile list

**Medium Priority:**
- 📁 Profile categories/tags
- 🎨 Theme customization
- 🌐 Internationalization (i18n)
- ↩️ Undo/redo in editor
- 📝 Create/Edit/Delete profile operations from GUI

**Nice to Have:**
- 🔢 More field types (color picker, slider, rating)
- 📧 Email integration (send invoices)
- 💾 Export to other formats (JSON, CSV, ODS)
- 📊 Invoice analytics/reports
- 🔗 QR code generation for payment links

---

## 🚧 Current Status

### What's Working (v3.0)

✅ **Complete and Production-Ready:**
- LÖVE2D GUI with Gruvbox Dark Material theme
- TOML profile parsing with full syntax support
- Multi-page form flow with smart pagination
- Dynamic field rendering (all field types)
- Interactive table widget with add/remove rows
- Field calculations (`@calc()` for formulas, `@sum()` for totals)
- Field validation (required fields, email format)
- Progress tracking with visual bar
- HTML preview generation with Gruvbox dark theme
- PDF attachment merging (converts PDF pages to images)
- Profile management (load, list)
- Image upload with drag-and-drop
- Print preview with BUFLO watermark and page counter
- Two-step PDF validation workflow
- Responsive UI with proper layout

### Planned Features

🔮 **Future Releases:**
- Direct PDF generation (HTML → PDF conversion)
- Profile editor with TOML syntax highlighting
- Summary review screen
- Profile templates library
- Export formats (JSON, CSV)
- Email integration
- Multi-language support
- Theme customization
- Create/Edit/Delete profile operations from GUI

---

## � Troubleshooting

### Windows: PDF Merging Not Working

**Problem**: "Merge PDFs" button fails or shows errors

**Solution**:
1. Verify `pdftoppm` is installed and in PATH:
   ```powershell
   pdftoppm -v
   ```

2. If not found, reinstall Poppler:
   ```powershell
   $pp = Get-ChildItem "$HOME\tools\poppler" -Recurse -Filter pdftoppm.exe |
         Select-Object -First 1 -ExpandProperty DirectoryName
   $env:Path += ";$pp"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::User)
   ```

3. Test manually:
   ```powershell
   pdftoppm -png -r 150 -f 1 -l 1 "C:\path\to\test.pdf" "$env:TEMP\buflo_test"
   ```

4. Check if PNG was created:
   ```powershell
   Get-ChildItem "$env:TEMP\buflo_test*.png"
   ```

**Note**: BUFLO uses Windows-specific commands internally:
- `%TEMP%` instead of `/tmp`
- `dir /b /on` instead of `ls | sort -V`
- `del /Q` instead of `rm -f`
- `mkdir` instead of `mkdir -p`
- Double quotes `"` instead of single quotes `'`

### Linux: Permission Errors

**Problem**: Cannot write to `/tmp` or execute commands

**Solution**:
```bash
# Check /tmp permissions
ls -ld /tmp

# Verify poppler-utils
pdftoppm -v

# Test PDF conversion
pdftoppm -png -r 150 -f 1 -l 1 /path/to/test.pdf /tmp/buflo_test
```

### All Platforms: LÖVE Not Found

**Problem**: `love` command not recognized

**Solution**:
- **Linux**: Install via package manager (`sudo apt install love`)
- **macOS**: `brew install love`
- **Windows**: Download from [love2d.org](https://love2d.org/) and add to PATH

---

## �📜 License

MIT License - see [LICENSE](LICENSE) file for details.

Copyright (c) 2025 BUFLO Contributors

---

## 🙏 Acknowledgments

- **LÖVE2D** - Amazing Lua game framework ([love2d.org](https://love2d.org/))
- **Gruvbox** - Beautiful color scheme by morhetz ([github.com/morhetz/gruvbox](https://github.com/morhetz/gruvbox))
- **Lua** - Elegant and powerful scripting language ([lua.org](https://www.lua.org/))
- **TOML** - Clear minimal configuration language ([toml.io](https://toml.io/))
- **Poppler** - PDF rendering library ([poppler.freedesktop.org](https://poppler.freedesktop.org/))

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues)
- **Documentation**: [TOML_PROFILE_SPEC.md](TOML_PROFILE_SPEC.md)

---

**Built with ❤️ for the Lua and open source community**
