# BUFLO — Billing Unified Flow Language & Orchestrator# BUFLO — Billing Unified Flow Language & Orchestrator



![buflo logo](assets/buflo.png)![buflo logo](https://github.com/dotMavriQ/Buflo/blob/main/buflo.png?raw=true)



A modern desktop billing application written in Lua with LÖVE2D. Create professional invoices using a simple JSON-like DSL, with dynamic forms, validation, and a beautiful Gruvbox-themed interface.A modern desktop billing application written in Lua with LÖVE2D. Create professional invoices using a simple JSON-like DSL, with dynamic forms, validation, and a beautiful Gruvbox-themed interface.



**Current Version**: 2.0 (LÖVE2D GUI with Gruvbox Dark Material theme)**Current Version**: 2.0 (LÖVE2D GUI with Gruvbox Dark Material theme)



[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)



## 🚀 Quick Start## 🚀 Quick Start



```bash```bash

# Install dependencies (Fedora)# Install dependencies (Fedora)

sudo dnf install lua lovesudo dnf install lua love



# Or (Debian/Ubuntu)# Or (Debian/Ubuntu)

sudo apt install lua5.4 lovesudo apt install lua5.4 love



# Launch BUFLO# Launch BUFLO

cd /path/to/Buflocd /path/to/Buflo

love .love .

``````



Select a profile from the dropdown and start creating invoices!Select a profile from the dropdown and start creating invoices!



---Select a profile from the dropdown and start creating invoices!



## 📑 Table of Contents---



- [Features](#-features)## 📑 Table of Contents

- [Installation](#-installation)

- [Usage](#-usage)- [Features](#-features)

- [BUFLO DSL Reference](#-buflo-dsl-reference)- [Installation](#-installation)

- [Architecture](#-architecture)- [Usage](#-usage)

- [Development](#-development)- [BUFLO DSL Reference](#-buflo-dsl-reference)

- [Contributing](#-contributing)- [Architecture](#-architecture)

- [Current Status & Roadmap](#-current-status--roadmap)- [Development](#-development)

- [License](#-license)- [Contributing](#-contributing)

- [License](#-license)

---

---

## ✨ Features

## ✨ Features

- **🎨 Beautiful GUI**: LÖVE2D-based interface with Gruvbox Dark Material theme

- **📝 JSON-like DSL**: Simple `.buflo` format - no code required- **🎨 Beautiful GUI**: LÖVE2D-based interface with Gruvbox Dark Material theme

- **🔄 Dynamic Forms**: Multi-page forms with smart pagination- **📝 JSON-like DSL**: Simple `.buflo` format - no code required

- **✅ Validation**: Required fields, email/phone formats, custom rules- **🔄 Dynamic Forms**: Multi-page forms with smart pagination

- **🖼️ Image Support**: Logo and attachment uploads- **✅ Validation**: Required fields, email/phone formats, custom rules

- **📊 Calculated Fields**: Auto-compute totals, taxes, and more (coming soon)- **🖼️ Image Support**: Logo and attachment uploads

- **🎯 Progress Tracking**: Visual progress bar through form pages- **📊 Calculated Fields**: Auto-compute totals, taxes, and more

- **👁️ HTML Preview**: See rendered output before generation- **🎯 Progress Tracking**: Visual progress bar through form pages

- **Cross-Platform**: Runs on Linux, macOS, Windows- **👁️ HTML Preview**: See rendered output before generation

- **🌈 Syntax Highlighting**: (Coming soon for profile editor)

---- **Cross-Platform**: Runs on Linux, macOS, Windows



## 📦 Installation- **Cross-Platform**: Runs on Linux, macOS, Windows



### System Requirements---



- **Lua 5.4+**## 📦 Installation

- **LÖVE 11.5+** (Mysterious Mysteries)

- **Git** (for cloning)### System Requirements



### Linux- **Lua 5.4+**

- **LÖVE 11.5+** (Mysterious Mysteries)

**Fedora:**- **Git** (for cloning)

```bash

sudo dnf install lua love git### Linux

```

**Fedora:**

**Debian/Ubuntu:**```bash

```bashsudo dnf install lua love git

sudo apt install lua5.4 love git```

```

**Debian/Ubuntu:**

**Arch:**```bash

```bashsudo apt install lua5.4 love git

sudo pacman -S lua love git```

```

**Arch:**

### macOS```bash

sudo pacman -S lua love git

```bash```

brew install lua love git

```### macOS



### Windows```bash

brew install lua love git

1. Download Lua from [lua.org](https://www.lua.org/download.html)```

2. Download LÖVE from [love2d.org](https://love2d.org/)

3. Install Git from [git-scm.com](https://git-scm.com/)### Windows



### Clone Repository1. Download Lua from [lua.org](https://www.lua.org/download.html)

2. Download LÖVE from [love2d.org](https://love2d.org/)

```bash3. Install Git from [git-scm.com](https://git-scm.com/)

git clone https://github.com/dotMavriQ/Buflo.git

cd Buflo### Clone Repository

```

```bash

### Verify Installationgit clone https://github.com/YOUR_USERNAME/Buflo.git

cd Buflo

```bash```

lua -v          # Should show Lua 5.4+

love --version  # Should show LÖVE 11.5+### Verify Installation

```

```bash

---lua -v          # Should show Lua 5.4+

love --version  # Should show LÖVE 11.5+

## 🎮 Usage```



### Launch Welcome Screen---



```bash## 🎮 Usage

cd /path/to/Buflo

love .### Launch Welcome Screen

```

```bash

The welcome screen allows you to:cd /path/to/Buflo

- **Load Profile**: Select from dropdown and open formlove .

- **Create Profile**: Start a new `.buflo` file (coming soon)```

- **Edit Profile**: Modify existing profile (coming soon)

- **Delete Profile**: Remove profile from disk (coming soon)The welcome screen allows you to:

- **Load Profile**: Select from dropdown and open form

### Fill Out Invoice Form- **Create Profile**: Start a new `.buflo` file

- **Edit Profile**: Modify existing profile

1. **Navigate Pages**: Use Next/Previous buttons- **Delete Profile**: Remove profile from disk

2. **Fill Required Fields**: Marked with red asterisk (*)

3. **Upload Images**: Click [+] to choose logo/attachments### Fill Out Invoice Form

4. **Review Progress**: Yellow bar shows completion

5. **Submit**: Click "Generate HTML" to preview1. **Navigate Pages**: Use Next/Previous buttons

2. **Fill Required Fields**: Marked with red asterisk (*)

### Form Field Types3. **Upload Images**: Click [+] to choose logo/attachments

4. **Review Progress**: Yellow bar shows completion

- **Text**: Single-line input (name, address, etc.)5. **Submit**: Click "Generate HTML" to preview

- **Textarea**: Multi-line input (descriptions, notes)

- **Number**: Numeric values (quantities, rates)### Form Field Types

- **Date**: Date picker (invoice date, due date)

- **Email**: Email with validation- **Text**: Single-line input (name, address, etc.)

- **Image Upload**: File picker for logos/attachments- **Textarea**: Multi-line input (descriptions, notes)

- **Number**: Numeric values (quantities, rates)

### Keyboard Shortcuts- **Date**: Date picker (invoice date, due date)

- **Email**: Email with validation

- **Tab**: Next field- **Image Upload**: File picker for logos/attachments

- **Shift+Tab**: Previous field

- **Enter**: Next page (if valid)### Keyboard Shortcuts

- **Esc**: Quit application

- **Tab**: Next field

---- **Shift+Tab**: Previous field

- **Enter**: Next page (if valid)

## 📚 BUFLO DSL Reference- **Esc**: Quit application



The `.buflo` format is a simple JSON-like configuration language for defining invoice layouts.---



### Basic Structure## 📚 BUFLO DSL Reference



```javascriptThe `.buflo` format is a simple JSON-like configuration language for defining invoice layouts.

{

  # Document metadata### Basic Structure

  document: {

    title: "My Invoice"```javascript

    version: "1.0"{

  }  # Document metadata

  document: {

  # Pages contain sections with fields    title: "My Invoice"

  pages: [    version: "1.0"

    {  }

      name: "invoice_page"

      sections: [  # Pages contain sections with fields

        {  pages: [

          type: "group"    {

          heading: "Client Information"      name: "invoice_page"

          fields: [      sections: [

            {        {

              id: "client_name"          type: "group"

              label: "Client Name"          heading: "Client Information"

              type: "text"          fields: [

              required: true            {

            }              id: "client_name"

          ]              label: "Client Name"

        }              type: "text"

      ]              required: true

    }            }

  ]          ]

}        }

```      ]

    }

### Field Types Reference  ]

}

| Type | Description | Example |```

|------|-------------|---------|

| `text` | Single-line text | Name, address |### Field Types Reference

| `textarea` | Multi-line text | Descriptions, notes |

| `number` | Numeric input | Quantity, rate || Type | Description | Example |

| `date` | Date picker | Invoice date ||------|-------------|---------|

| `email` | Email with validation | client@example.com || `text` | Single-line text | Name, address |

| `tel` | Phone number | +1-555-0100 || `textarea` | Multi-line text | Descriptions, notes |

| `image_upload` | File picker | Logo, attachments || `number` | Numeric input | Quantity, rate |

| `select` | Dropdown menu | Month, category || `date` | Date picker | Invoice date |

| `email` | Email with validation | client@example.com |

### Section Types| `tel` | Phone number | +1-555-0100 |

| `image_upload` | File picker | Logo, attachments |

| Type | Description | Usage || `select` | Dropdown menu | Month, category |

|------|-------------|-------|

| `group` | Vertical stack of fields | Standard form sections |### Section Types

| `columns` | Multi-column layout | Side-by-side content |

| `horizontal_fields` | Inline fields | Invoice number, date, etc. || Type | Description | Usage |

| `table` | Repeating rows | Line items (coming soon) ||------|-------------|-------|

| `spacer` | Empty space | Add vertical spacing || `group` | Vertical stack of fields | Standard form sections |

| `columns` | Multi-column layout | Side-by-side content |

### Special Values| `horizontal_fields` | Inline fields | Invoice number, date, etc. |

| `table` | Repeating rows | Line items |

```javascript| `spacer` | Empty space | Add vertical spacing |

{

  id: "invoice_date"### Special Values

  type: "date"

  default: "@today"        # Current date```javascript

}{

  id: "invoice_date"

{  type: "date"

  id: "invoice_number"  default: "@today"        # Current date

  type: "text"}

  default: "@uuid"         # Random UUID

}{

  id: "invoice_number"

{  type: "text"

  id: "total"  default: "@uuid"         # Random UUID

  type: "number"}

  calculated: true

  formula: "@calc(subtotal + tax)"  # Computed value (coming soon){

}  id: "total"

```  type: "number"

  calculated: true

Available special values:  formula: "@calc(subtotal + tax)"  # Computed value

- `@today` - Current date (YYYY-MM-DD)}

- `@now` - Current timestamp```

- `@uuid` - Random UUID v4

- `@year` - Current yearAvailable special values:

- `@calc(expression)` - Calculate value (coming soon)- `@today` - Current date (YYYY-MM-DD)

- `@sum(array.field)` - Sum array field (coming soon)- `@now` - Current timestamp

- `@uuid` - Random UUID v4

### Validation Rules- `@year` - Current year

- `@calc(expression)` - Calculate value

```javascript- `@sum(array.field)` - Sum array field

{

  id: "email"### Validation Rules

  type: "email"

  required: true```javascript

  validation: "email"      # Built-in email validation{

}  id: "email"

  type: "email"

{  required: true

  id: "vat_number"  validation: "email"      # Built-in email validation

  type: "text"}

  required: true

  format: "vat"           # VAT format validation{

}  id: "vat_number"

  type: "text"

{  required: true

  id: "quantity"  format: "vat"           # VAT format validation

  type: "number"}

  required: true

  min: 1                  # Minimum value{

  max: 100                # Maximum value  id: "quantity"

}  type: "number"

```  required: true

  min: 1                  # Minimum value

### Complete Example  max: 100                # Maximum value

}

See `profiles/nordhealth_mardev.buflo` and `profiles/consulting_invoice.buflo` for full examples with:```

- Multi-section layouts

- Calculated fields (coming soon)### Complete Example

- Image uploads

- Table structures (coming soon)See `profiles/nordhealth_mardev.buflo` and `profiles/consulting_invoice.buflo` for full examples with:

- Validation rules- Multi-section layouts

- Calculated fields

### Complete DSL Specification- Image uploads

- Table structures

For the full specification including layout directives, styling options, and advanced features, see [BUFLO_DSL_V2_SPEC.md](BUFLO_DSL_V2_SPEC.md).- Validation rules



Key features of the DSL:### DSL Specification

- **JSON-like syntax** with relaxed rules (comments, trailing commas, unquoted keys)

- **Multi-line strings** with `"""`For the complete DSL specification including layout directives, styling options, and advanced features, see the [Full DSL Specification](#full-dsl-specification) section below.

- **Special value generators** (@today, @uuid, @calc, @sum)

- **Layout directives** (columns, horizontal_fields, table, spacer)---

- **Styling properties** (bold, italic, size, color, align)

- **Validation rules** (required, min/max, format, pattern)```

- **Calculated fields** with dependency resolutionbuflo/

- **Repeating sections** for tables/line items├── buflo.lua                    # Main CLI entry point

├── profiles/

---│   ├── *.buflo                 # JSON-like profile format (recommended)

│   └── *.bpl.lua               # Lua profile format (legacy)

## 🏗️ Architecture├── buflo/

│   ├── core/

### Project Structure│   │   ├── buflo_parser.lua    # .buflo DSL parser ✨NEW

│   │   ├── profile.lua         # Profile loader (both formats)

```│   │   ├── render.lua          # HTML rendering with helpers

buflo/│   │   └── pdf.lua             # PDF generation

├── conf.lua                     # LÖVE configuration│   ├── gui_sdl/                # SDL2 GUI (fully working!)

├── main.lua                     # Application entry point│   │   ├── welcome.lua         # Welcome screen with profile selection

├── lib/│   │   ├── main.lua            # Form editor

│   └── ui.lua                  # UI widgets with Gruvbox theme (371 lines)│   │   ├── form.lua            # Dynamic form builder

├── screens/│   │   └── widgets.lua         # UI widgets

│   ├── welcome.lua             # Welcome screen with profile selector (175 lines)│   ├── batch/

│   ├── form.lua                # Multi-page form flow (449 lines)│   │   └── runner.lua          # Batch processing

│   └── editor.lua              # Profile editor (placeholder, 80 lines)│   └── util/

├── buflo/│       ├── log.lua             # Leveled logging

│   ├── core/│       └── fs.lua              # File system utilities

│   │   └── buflo_v2_parser.lua # DSL parser (280 lines)├── data/                        # Batch data (JSON/CSV)

│   └── util/├── out/                         # Generated PDFs

│       ├── fs.lua              # File system utilities└── tests/

│       ├── log.lua             # Logging    ├── test_parser.lua          # .buflo parser tests ✨NEW

│       └── shell.lua           # Shell command execution    └── test_buflo_gui.lua       # GUI integration tests ✨NEW

├── profiles/```

│   ├── nordhealth_mardev.buflo      # Example invoice (26 fields)

│   └── consulting_invoice.buflo     # Template## Installation

├── assets/

│   ├── buflo.png               # Logo (300px)### Dependencies

│   └── fonts/

│       └── AdwaitaMono-Regular.ttf**Fedora:**

└── BUFLO_DSL_V2_SPEC.md        # Complete DSL documentation```bash

```sudo dnf install lua SDL2-devel SDL2_ttf-devel SDL2_image-devel



### Component Overview# For PDF generation (optional - only needed for final output)

sudo dnf install wkhtmltopdf qpdf

**LÖVE2D Framework:**```

- `conf.lua`: Window configuration (1024x768, resizable)

- `main.lua`: Screen management, input routing, global helpers**Debian/Ubuntu:**

```bash

**UI Library (`lib/ui.lua`):**sudo apt install lua5.4 libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev

- Gruvbox Dark Material color palette (16 colors)

- Widgets: buttons, text inputs, dropdowns, labels# For PDF generation (optional)

- State management: hot/active/focused widgetssudo apt install wkhtmltopdf qpdf

- Consistent styling across all components```



**Screens:**### SDL2 Lua Bindings

- **Welcome**: Profile selection, CRUD operations (placeholder), navigation

- **Form**: Multi-page form with dynamic pagination, validation, progress tracking```bash

- **Editor**: (Placeholder) Will provide syntax-highlighted DSL editing# Install lua-sdl2 (easy!)

luarocks install --local lua-sdl2

**Parser (`buflo/core/buflo_v2_parser.lua`):**

- Tokenizes JSON-like `.buflo` syntax# Add to PATH (one-time setup)

- Recursive descent parsing for nested structuresecho 'eval $(luarocks path --bin)' >> ~/.bashrc

- Handles arrays, objects, multi-line stringssource ~/.bashrc

- Extracts all fields from pages/sections/columns/tables```



**Utilities:**That's it! The GUI will work perfectly.

- `fs.lua`: File operations (for future PDF generation)

- `log.lua`: Leveled logging (verbose, info, error)## Usage

- `shell.lua`: Command execution (for PDF tools)

### Welcome Screen (GUI)

### Data Flow

Launch without arguments to see the welcome screen:

``````bash

.buflo filelua buflo.lua

    ↓```

Parser → Profile structure

    ↓Features:

Form Screen → Dynamic pages- 🦬 Buffalo mascot (because BUFLO!)

    ↓- Profile selector dropdown (scans `profiles/` directory)

User Input → Validation- Load, Create, Edit, Delete profile buttons

    ↓- Schedule Reminder button

Collected Data → HTML Preview- Beautiful SDL2 interface

    ↓

(Future) → PDF Generation### Direct Profile Loading (GUI)

```

Load a specific profile directly:

### Dynamic Pagination```bash

lua buflo.lua profiles/monthly_invoice.buflo

The form screen intelligently calculates fields per page based on:```

- Available screen height (768px - 120px header - 120px buttons - 40px margin = 508px)

- Field type heights:The form editor will:

  - Text: 85px (label + input + spacing)1. Auto-generate form fields from profile

  - Textarea: 110px (larger input area)2. Populate defaults (e.g., @today → current date, @uuid → random ID)

  - Image upload: 125px (button + toggle input)3. Allow editing and validation

4. Generate PDF or preview HTML

This ensures optimal layout without scrolling issues.

### Batch Mode

### Gruvbox Theme

Process multiple invoices from JSON or CSV:

All UI components use the Gruvbox Dark Material palette:```bash

- **Backgrounds**: #282828 (dark0_hard), #32302f (dark0), #3c3836 (dark1), #504945 (dark2)lua buflo.lua profiles/monthly_invoice.buflo --batch --verbose

- **Text**: #ebdbb2 (fg), #a89984 (gray), #665c54 (disabled)```

- **Borders**: #665c54 (normal), #fabd2f (focus - yellow)

- **Accents**: #83a598 (blue), #b8bb26 (green), #fabd2f (yellow), #fb4934 (red), #d3869b (purple), #fe8019 (orange)Override data source:

```bash

---lua buflo.lua profiles/monthly_invoice.buflo --batch --data=data/q4_invoices.json

```

## 🔧 Development

Dry run (validate without generating):

### Running from Source```bash

lua buflo.lua profiles/monthly_invoice.buflo --batch --dry-run

```bash```

cd /path/to/Buflo

love .### CLI Options

```

```

### Code Style--batch              Run in batch mode

--verbose, -v        Enable verbose logging

- **Indentation**: 2 spaces--dry-run            Validate but don't generate PDFs

- **Naming**: snake_case for variables/functions, UPPER_CASE for constants--outdir=<path>      Override output directory

- **Comments**: Explain "why", not "what"--data=<file>        Override batch data source

- **Line length**: Aim for 100 characters max--help, -h           Show help message

```

### Adding New Features

### Exit Codes

**New Field Type:**

1. Edit `screens/form.lua`- `0` — Success

2. Add case in `render_field()` function- `1` — General error

3. Handle input in `textinput()` callback- `2` — Validation error

4. Update height calculation in `calculate_field_height()`- `3` — Render error

- `4` — PDF generation error

**New Widget:**- `5` — I/O error

1. Add to `lib/ui.lua`

2. Follow existing widget patterns (hot/active/focused)## Profile Formats

3. Return clicked state for buttons, new value for inputs

4. Apply Gruvbox colors consistently### Format 1: .buflo (Recommended - No Code Required!)



**New Screen:**Simple JSON-like format that's easy to read and write. Perfect for non-programmers.

1. Create file in `screens/`

2. Define `load()`, `update()`, `draw()`, input callbacks**Example: `profiles/monthly_invoice.buflo`**

3. Register in `main.lua` screens table

4. Use `switchScreen(name, data)` to navigate```javascript

{

### Testing  # Profile metadata

  profile: "Monthly Consulting Invoice",

**Manual Testing:**  version: "1.0",

```bash  description: "Standard monthly billing for consulting services",

love .  # Launch and interact with GUI

```  # Form fields (what the user fills in)

  fields: [

**Parser Testing:**    {

```bash      key: "client_name",

lua -e "      label: "Client Name",

local parser = require('buflo.core.buflo_v2_parser')      type: "text",

local content = io.open('profiles/nordhealth_mardev.buflo'):read('*all')      required: true,

local result = parser.parse(content)      placeholder: "Enter client company name"

local fields = parser.get_all_fields(result)    },

print('Fields found:', #fields)    {

"      key: "client_email",

```      label: "Client Email",

      type: "email",

**Profile Validation:**      placeholder: "client@example.com"

- Ensure all required fields have `required: true`    },

- Test special values (@today, @uuid) expand correctly    {

- Verify field IDs are unique      key: "invoice_number",

- Check image upload paths are accessible      label: "Invoice Number",

      type: "text",

### Debugging      required: true,

      default: @uuid                    # ← Auto-generates random UUID

Enable LÖVE debug output:    },

```bash    {

love . 2>&1 | tee debug.log      key: "invoice_date",

```      label: "Invoice Date",

      type: "date",

Common issues:      required: true,

- **Font missing**: Falls back to default, copy font to `assets/fonts/`      default: @today                   # ← Auto-fills today's date

- **Parser errors**: Check `.buflo` syntax (commas, quotes, brackets)    },

- **Widget not responding**: Check z-order and hit detection in `mousepressed()`    {

      key: "daily_rate",

---      label: "Daily Rate",

      type: "number",

## 🤝 Contributing      required: true,

      default: 500

Contributions are welcome! Here's how to get started:    },

    {

### Getting Started      key: "days",

      label: "Days Worked",

1. **Fork** the repository on GitHub      type: "number",

2. **Clone** your fork:      required: true,

   ```bash      default: 1

   git clone https://github.com/YOUR_USERNAME/Buflo.git    },

   cd Buflo    {

   ```      key: "notes",

3. **Create** a feature branch:      label: "Additional Notes",

   ```bash      type: "multiline",

   git checkout -b feature/your-feature-name      placeholder: "Any special terms or notes..."

   ```    }

4. **Make** your changes  ],

5. **Test** thoroughly:

   ```bash  # Computed values (calculated automatically)

   love .  # Test GUI  computed: {

   ```    subtotal: @calc(daily_rate * days),          # Multiply rate × days

6. **Commit** with a descriptive message:    tax: @calc(subtotal * 0.25),                 # 25% tax on subtotal

   ```bash    total: @calc(subtotal + tax)                 # Final total

   git commit -m "Add feature: your feature description"  },

   ```

7. **Push** to your fork:  # Output configuration

   ```bash  output: {

   git push origin feature/your-feature-name    filename: "invoice_{{invoice_number}}.pdf",  # Use {{}} for variables

   ```    directory: "out/"

8. **Open** a Pull Request on GitHub  },



### Areas to Contribute  # PDF pages (can have multiple pages)

  pages: [

**High Priority:**    {

- 📊 Table/repeating sections widget for line items      name: "Invoice",

- 📄 PDF generation integration (wkhtmltopdf, weasyprint, or native)      template: """

- ✏️ Profile editor with syntax highlighting<!DOCTYPE html>

- 📋 Summary review screen before PDF generation<html>

- 🧮 Calculated fields (@calc, @sum)<head>

  <meta charset="UTF-8">

**Medium Priority:**  <style>

- 🔍 Search functionality in profile list    body { font-family: Arial, sans-serif; margin: 40px; }

- 📁 Profile categories/tags    .header { text-align: center; border-bottom: 3px solid #0066cc; }

- 🎨 Theme customization    .header h1 { color: #0066cc; font-size: 2.5em; }

- 🌐 Internationalization (i18n)    .invoice-table { width: 100%; border-collapse: collapse; margin: 30px 0; }

- ↩️ Undo/redo in editor    .invoice-table th { background-color: #0066cc; color: white; padding: 15px; }

- 📝 Create/Edit/Delete profile operations    .invoice-table td { border: 1px solid #ddd; padding: 12px; }

    .total-row { font-weight: bold; font-size: 1.2em; }

**Nice to Have:**  </style>

- 🔢 More field types (color picker, slider, rating)</head>

- 📧 Email integration (send invoices)<body>

- 💾 Export to other formats (JSON, CSV, ODS)  <div class="header">

- 📊 Invoice analytics/reports    <h1>INVOICE</h1>

- 🔗 QR code generation for payment links    <div>Invoice #{{invoice_number}}</div>

- 🔄 Batch processing mode  </div>



### Code Review Checklist  <div style="margin: 40px 0;">

    <p><strong>Bill To:</strong> {{client_name}}</p>

Before submitting:    <p><strong>Email:</strong> {{client_email}}</p>

- [ ] Code follows style guide (2 spaces, snake_case)    <p><strong>Date:</strong> {{@date(invoice_date)}}</p>

- [ ] No console errors or warnings  </div>

- [ ] Gruvbox theme colors used consistently

- [ ] Comments added for complex logic  <table class="invoice-table">

- [ ] Tested on at least one platform    <thead>

- [ ] No breaking changes to existing profiles      <tr>

- [ ] README updated if adding features        <th>Description</th>

        <th style="text-align: right;">Rate</th>

### Questions?        <th style="text-align: center;">Quantity</th>

        <th style="text-align: right;">Amount</th>

Open an issue for discussion before starting major work. We're happy to help!      </tr>

    </thead>

For detailed contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).    <tbody>

      <tr>

---        <td>Professional Consulting Services</td>

        <td style="text-align: right;">{{@currency(daily_rate)}}</td>

## 🚧 Current Status & Roadmap        <td style="text-align: center;">{{days}} days</td>

        <td style="text-align: right;">{{@currency(subtotal)}}</td>

### What's Working (v2.0)      </tr>

      <tr>

✅ **Complete and Production-Ready:**        <td colspan="3" style="text-align: right;">Subtotal:</td>

- LÖVE2D GUI with Gruvbox Dark Material theme        <td style="text-align: right;">{{@currency(subtotal)}}</td>

- `.buflo` DSL v2 parser with full syntax support      </tr>

- Multi-page form flow with smart pagination      <tr>

- Dynamic field rendering (text, textarea, number, date, email, image_upload)        <td colspan="3" style="text-align: right;">Tax (25%):</td>

- Field validation (required fields, email format)        <td style="text-align: right;">{{@currency(tax)}}</td>

- Progress tracking with visual bar      </tr>

- HTML preview generation      <tr class="total-row">

- Profile management (load, list)        <td colspan="3" style="text-align: right;">TOTAL DUE:</td>

- 26-field complex invoice profile working perfectly        <td style="text-align: right;">{{@currency(total)}}</td>

- Image upload with file path input      </tr>

- Responsive UI with proper layout    </tbody>

  </table>

### In Progress

  {{#if notes}}

⏳ **Next Sprint:**  <div style="margin-top: 40px; padding: 20px; background: #f9f9f9; border-left: 4px solid #0066cc;">

- Table/repeating sections widget for line items    <h3>Additional Notes</h3>

- PDF generation (wkhtmltopdf or weasyprint integration)    <p>{{notes}}</p>

- Profile editor with syntax highlighting  </div>

- Summary review screen  {{/if}}

- Calculated fields (@calc, @sum)

  <div style="margin-top: 60px; text-align: center; color: #999;">

### Planned Features    <p>Thank you for your business!</p>

    <p>Generated with BUFLO on {{@date(@today)}}</p>

🔮 **Future Releases:**  </div>

- Batch processing mode</body>

- Reminder system for recurring invoices</html>

- Profile templates library      """

- Export formats (JSON, CSV)    }

- Invoice analytics  ]

- Email integration}

- Multi-language support```

- Theme customization

- Create/Edit/Delete profile operations#### .buflo Format Features



### Migration Notes**Syntax:**

- JSON-like but more relaxed

**From SDL2 to LÖVE2D (Completed Nov 2025):**- Comments with `#`

- ✅ Complete rewrite using LÖVE2D framework- Unquoted keys allowed: `key: "value"` or `"key": "value"`

- ✅ All SDL2 code removed (5,356 lines)- Trailing commas permitted

- ✅ Gruvbox theme applied throughout- Multi-line strings with `"""`

- ✅ Dynamic pagination implemented

- ✅ Image upload redesigned with ASCII markers**Special Values:**

- ✅ Repository cleaned and organized- `@today` — Current date (YYYY-MM-DD)

- `@now` — Current timestamp (YYYY-MM-DD HH:MM:SS)

**Breaking Changes:**- `@uuid` — Random UUID v4

- Old `.bpl.lua` format deprecated (use `.buflo` DSL v2)- `@calc(expression)` — Calculate arithmetic (e.g., `@calc(rate * hours)`)

- Batch processing temporarily disabled (will return)

- PDF generation not yet integrated (HTML preview works)**Template Syntax:**

- `{{field}}` — Insert field value

---- `{{@currency(amount)}}` — Format as currency ($1,234.56)

- `{{@date(field)}}` — Format as date

## 📝 Changelog- `{{@sum(field1, field2)}}` — Sum multiple fields

- `{{#if field}}...{{/if}}` — Conditional blocks (only show if field has value)

### v2.0 (November 2025) - LÖVE2D Rewrite

**Field Types:**

**Added:**- `text` — Single-line text input

- LÖVE2D framework integration- `number` — Numeric input

- Gruvbox Dark Material theme (16 colors)- `date` — Date picker

- Custom UI library (`lib/ui.lua`)- `email` — Email validation

- Dynamic pagination based on screen height- `multiline` — Multi-line text area

- Smart field height calculation- `enum` — Dropdown selection

- ASCII markers for image upload ([+]/[*])- `file` — File picker

- Progress bar with "X of Y" format- `checkbox` — Boolean checkbox

- HTML preview before PDF generation

**Computed Fields:**

**Changed:**- Automatically evaluated with dependency resolution

- Complete GUI rewrite (SDL2 → LÖVE2D)- Use `@calc(expression)` for calculations

- Form flow now multi-page with validation- Can reference form fields and other computed values

- Parser handles arrays without comma separators- Not shown in form (calculated in background)

- Image upload always reserves 125px (no layout shift)

**Multiple Pages:**

**Removed:**```javascript

- SDL2 dependencies and code (5,356 lines)pages: [

- Old `.bpl.lua` parser and related modules  { name: "Invoice", template: """...""" },

- Batch processing (temporary)  { name: "Terms", template: """...""" },

- Old profile format support  { name: "Appendix", template: """...""" }

]

**Fixed:**```

- Parser finding all 26 fields (was 4 due to array bug)

- Pagination overflow issues### Format 2: .bpl.lua (Legacy - Lua-based)

- Emoji rendering (replaced with ASCII)

- Service field showing as tall textarea### Format 2: .bpl.lua (Legacy - Lua-based)



---Profiles are Lua modules that return a table. They execute in a sandboxed environment (no `io`, `os.execute`, etc.).



## 📜 License**Minimal Profile:**



MIT License - see [LICENSE](LICENSE) file for details.```lua

return {

Copyright (c) 2025 BUFLO Contributors  name = "Simple Invoice",

  version = "1.0",

---  output_pattern = "out/{{invoice_number}}.pdf",



## 🙏 Acknowledgments  fields = {

    {key="invoice_number", label="Invoice #", type="text", required=true},

- **LÖVE2D** - Amazing Lua game framework ([love2d.org](https://love2d.org/))    {key="amount", label="Amount", type="number", required=true},

- **Gruvbox** - Beautiful color scheme by morhetz ([github.com/morhetz/gruvbox](https://github.com/morhetz/gruvbox))  },

- **Lua** - Elegant and powerful scripting language ([lua.org](https://www.lua.org/))

- **Open Source Community** - For inspiration and tools  render = function(data, helpers)

    return string.format([[

---      <html><body>

        <h1>Invoice %s</h1>

## 📞 Support        <p>Amount: %s</p>

      </body></html>

- **Issues**: [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues)    ]], helpers.esc(data.invoice_number), helpers.fmt_currency(data.amount))

- **Discussions**: [GitHub Discussions](https://github.com/dotMavriQ/Buflo/discussions)  end

- **Documentation**: }

  - [BUFLO_DSL_V2_SPEC.md](BUFLO_DSL_V2_SPEC.md) - Complete DSL specification```

  - [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

### Profile Schema

---

**Required Fields:**

## 💡 Tips & Tricks- `name` (string) — Profile display name

- `version` (string) — Profile version

**Faster Form Filling:**- `output_pattern` (string) — Output path with `{{placeholders}}`

- Use Tab to navigate between fields- `fields` (array) — Field definitions for form generation

- Required fields are marked with red *- `render` (function) — Renders HTML from data

- Image uploads can be toggled between button and text input

- Press Enter on last page to submit**Optional Fields:**

- `trailing_pdf` (string|function) — PDF to append after main invoice

**Creating Profiles:**- `validate` (function) — Custom validation logic

- Start with `consulting_invoice.buflo` template- `batch` (table) — Batch processing configuration

- Copy and modify field IDs and labels- `locale` (table) — Locale settings (currency, date format)

- Test with small forms first- `assets` (table) — CSS/images to include

- Use validation to prevent errors

### Field Types

**Customizing Theme:**

- Edit `lib/ui.lua` colors table```lua

- Gruvbox colors are pre-definedfields = {

- Restart LÖVE after changes  {key="text_field", label="Text", type="text", required=true, default="value"},

  {key="number_field", label="Number", type="number", min=0, max=1000, step=1},

**Debugging:**  {key="date_field", label="Date", type="date", default=function() return os.date("%Y-%m-%d") end},

- Check terminal output for parser errors  {key="notes", label="Notes", type="multiline"},

- Use `lua -e "..."` to test parser directly  {key="category", label="Category", type="enum", enum={"A", "B", "C"}},

- GTK warnings are harmless (LÖVE-related)  {key="attachment", label="File", type="file", mode="open", filter="*.pdf"},

  {key="accepted", label="Accepted", type="checkbox"},

---}

```

## 🐛 Known Issues

### Render Helpers

- PDF generation not yet integrated (HTML preview works)

- Table/repeating sections not implementedAvailable in `render(data, helpers)`:

- Profile editor is placeholder

- Batch mode temporarily disabled- `helpers.esc(str)` — HTML escape

- Create/Edit/Delete profile operations not yet implemented- `helpers.fmt_currency(amount, currency)` — Format as currency

- Calculated fields (@calc, @sum) not yet working- `helpers.fmt_date(date, format)` — Format date

- Some GTK warnings on Linux (harmless, LÖVE-related)- `helpers.table_sum(array, key)` — Sum field in array



Report issues at: [GitHub Issues](https://github.com/dotMavriQ/Buflo/issues)### Interpolation



---Any string with `{{key}}` is replaced by `data[key]`:



## 🎯 Project Goals```lua

output_pattern = "out/{{client.name}}_{{invoice_number}}.pdf"

BUFLO aims to make invoice generation:```

- **Simple**: No coding required, just fill forms

- **Beautiful**: Professional-looking output with Gruvbox themeSupports nested keys: `{{client.address.city}}`

- **Flexible**: Customizable via DSL

- **Fast**: Quick form filling with smart defaultsMissing keys produce: `__MISSING_key__`

- **Reliable**: Validation prevents errors

- **Open**: MIT licensed, community-driven### Batch Processing



---```lua

batch = {

**Built with ❤️ for the Lua and open source community**  enabled = true,

  source = "data/invoices.json",
  map = function(row)
    -- Transform row if needed
    return {
      invoice_number = row.id,
      amount = row.total,
    }
  end
}
```

Batch data formats:

**JSON:**
```json
[
  {"invoice_number": "2025-001", "amount": 1500},
  {"invoice_number": "2025-002", "amount": 2000}
]
```

**CSV:**
```csv
invoice_number,amount,client_name
2025-001,1500,"ACME Corp"
2025-002,2000,"Globex"
```

## Examples

### Generate Single Invoice (GUI)

```bash
lua buflo.lua profiles/example_invoice.bpl.lua
```

Fill in the form, click **Generate PDF**. Output: `out/2025-001.pdf`

### Batch Generate from JSON

```bash
lua buflo.lua profiles/example_invoice.bpl.lua --batch --data=data/batch.json --verbose
```

Generates one PDF per JSON object.

### Preview HTML Before PDF

In GUI mode, click **Preview HTML** to open rendered HTML in browser.

### Custom Output Directory

```bash
lua buflo.lua profiles/invoice.bpl.lua --outdir=invoices/2025
```

## Testing

Run parser tests:
```bash
lua test_parser.lua
```

Test GUI with .buflo profile:
```bash
lua test_buflo_gui.lua
```

All tests passing: ✅
- .buflo parser (tokenization, parsing, special values)
- Computed field evaluation with dependencies
- Template interpolation with helpers
- Conditional blocks
- GUI integration with both profile formats

## Quick Start

**1. Install dependencies:**
```bash
sudo dnf install lua SDL2-devel SDL2_ttf-devel SDL2_image-devel
luarocks install --local lua-sdl2
```

**2. Launch BUFLO:**
```bash
lua buflo.lua
```

**3. Select a profile** from the dropdown and click **Load Profile**

**4. Fill in the form** (defaults auto-populated)

**5. Click "Generate PDF"** to create your invoice!

## What's Working

✅ **SDL2 GUI** - Beautiful form editor with welcome screen
✅ **.buflo DSL** - Complete parser with special values, computed fields, templates
✅ **Profile Editor** - Full-featured code editor with syntax highlighting! 🎨
✅ **Profile Loading** - Auto-detects format (.buflo or .bpl.lua)
✅ **Form Generation** - Dynamic forms from profile fields
✅ **Default Values** - @today, @uuid, @calc() all working
✅ **Template Interpolation** - {{field}}, {{@helper()}}, {{#if}} blocks
✅ **Computed Fields** - Dependency resolution (subtotal → tax → total)
✅ **Welcome Screen** - Profile selection, CRUD operations, buffalo mascot 🦬

### Profile Editor Features ✨NEW

The integrated profile editor includes:
- **Syntax Highlighting** - Color-coded tokens (comments, strings, keys, numbers, special values)
- **Line Numbers** - Easy navigation with line/column display
- **Full Text Editing** - Insert, delete, cursor movement (arrows, Home/End)
- **Blinking Cursor** - Visual feedback for current position
- **Current Line Highlight** - Easy to see where you're editing
- **Status Bar** - Shows line/col position, file status, modified indicator
- **Keyboard Shortcuts**:
  - `Ctrl+S` - Save file
  - `Ctrl+Q` or `Esc` - Close editor
  - `Arrow Keys` - Navigate text
  - `Home/End` - Jump to start/end of line
  - `Backspace/Delete` - Remove characters
  - `Enter` - New line

**Color Scheme** (Dark Theme):
- Background: Dark gray (#1E1E1E)
- Comments: Green (#6A9955)
- Keys: Light blue (#9CDCFE)
- Strings: Orange (#CE9178)
- Numbers: Light green (#B5CEA8)
- Special values (@today, @uuid): Yellow (#DCDCAA)
- Errors: Red (#F44747)## What's Next (Future Work)

- ~~**Profile Editor**~~ ✅ DONE! - Full-featured editor with syntax highlighting
- **PDF Generation** - Integrate wkhtmltopdf for actual PDF output
- **Batch Mode** - Support .buflo format in batch processing
- **Reminder System** - Schedule recurring billing reminders
- **Migration Tool** - Convert .bpl.lua files to .buflo format
- **Search/Replace** - Find and replace text in editor
- **Undo/Redo** - Edit history in profile editor

## Implementation Details

### Parser Architecture

The .buflo parser (`buflo/core/buflo_parser.lua`) uses:
- **Tokenizer**: Handles comments, multi-line strings, special values
- **Recursive Descent Parser**: Builds nested structures
- **Multi-pass Evaluation**: Resolves computed field dependencies (up to 10 passes)
- **Template Engine**: Processes conditionals first, then variable substitution

### Special Value Expansion

Special values are stored as tables during parsing:
```lua
{_buflo_special = "@today"}
{_buflo_special = "@calc", _buflo_expr = "rate * days"}
```

Expanded on-demand when:
1. Getting field defaults for GUI form
2. Rendering templates for PDF generation

### Computed Field Dependencies

Example dependency chain:
```javascript
computed: {
  subtotal: @calc(rate * hours),      # No dependencies
  tax: @calc(subtotal * 0.25),        # Depends on subtotal
  total: @calc(subtotal + tax)        # Depends on both
}
```

Algorithm evaluates in multiple passes until all fields resolve or detects circular dependencies.

### Template Interpolation Order

1. **Process conditionals** ({{#if field}}...{{/if}})
2. **Then substitute variables** ({{field}}, {{@helper()}})

This prevents conditional tags from being consumed by variable substitution pattern.

## Security

- **Sandboxed Execution**: Profiles run in a restricted environment
- **No Network Access**: No external calls at runtime
- **No File System Access**: Profiles cannot read/write arbitrary files
- **No Command Execution**: `os.execute` is not available

Safe functions: `math`, `string`, `table`, `os.date`, `os.time`

## Development

### Adding a New Field Type

1. Edit `buflo/gui/form.lua`
2. Add widget creation in `create_field_widget()`
3. Handle value extraction in `get_form_data()`

### Creating Custom Profiles

1. Copy `profiles/example_invoice.bpl.lua`
2. Modify fields, render function, and validation
3. Test with: `lua buflo.lua your_profile.bpl.lua`

### Debugging

Enable verbose mode:
```bash
lua buflo.lua profiles/invoice.bpl.lua --verbose
```

Check logs in stderr for detailed execution info.

## Troubleshooting

### "Missing required tools: wkhtmltopdf"

Install dependencies:
```bash
sudo dnf install wkhtmltopdf qpdf  # Fedora
sudo apt install wkhtmltopdf qpdf  # Debian/Ubuntu
```

### "Failed to load IUP"

IUP is required for GUI mode. Install from [Tecgraf](https://sourceforge.net/projects/iup/files/) or use batch mode:
```bash
lua buflo.lua profiles/invoice.bpl.lua --batch
```

### Batch processing fails

Verify data format:
- JSON: Must be an array of objects
- CSV: First row must be headers
- All required fields must be present

### PDF not generated

Check:
1. Output directory exists (auto-created if possible)
2. No missing placeholders in `output_pattern`
3. Validation passes (use `--verbose` to see errors)

## License

This project is provided as-is for billing and invoice generation purposes.

## Contributing

Contributions welcome! Focus areas:
- Additional field types (color picker, dropdown with search)
- More render helpers (QR codes, barcodes)
- Export formats (ODS, XLSX)
- Internationalization (i18n)

## Authors

Built with ❤️ for the Lua community.

---

## Current Status (November 2025)

**BUFLO is production-ready with the new .buflo DSL format!**

### What We Built
- ✅ Complete .buflo DSL parser (468 lines, fully tested)
- ✅ SDL2 GUI with welcome screen and form editor
- ✅ Profile auto-detection (.buflo vs .bpl.lua)
- ✅ Special values (@today, @uuid, @calc)
- ✅ Computed fields with dependency resolution
- ✅ Template interpolation with helpers and conditionals
- ✅ Example invoice profile (monthly_invoice.buflo)
- ✅ Comprehensive tests (all passing)

### Files Added/Modified
```
NEW FILES:
profiles/monthly_invoice.buflo          # Example .buflo profile (192 lines)
buflo/core/buflo_parser.lua            # DSL parser (468 lines)
buflo/gui_sdl/profile_editor.lua       # Code editor with syntax highlighting (690+ lines) ✨NEW
test_parser.lua                        # Parser tests (87 lines)
test_buflo_gui.lua                     # GUI integration test (42 lines)
test_editor.lua                        # Editor test (17 lines) ✨NEW

MODIFIED:
README.md                              # This file (comprehensive documentation)
buflo.lua                              # Added .buflo support
buflo/core/profile.lua                 # Auto-detect format, added validate_buflo_schema
buflo/gui_sdl/main.lua                 # Handle .buflo defaults expansion
buflo/gui_sdl/welcome.lua              # Scan for .buflo files, integrated editor buttons
```

### Test Results
```bash
$ lua test_parser.lua
=== Testing BUFLO DSL Parser ===
Test 1: Loading profiles/monthly_invoice.buflo... ✓
Test 2: Getting fields with expanded defaults... ✓
Test 3: Evaluating computed fields... ✓
Test 4: Template interpolation... ✓
Test 5: Conditional blocks... ✓
=== All tests passed! ===
```

### Next Session TODO
1. Integrate wkhtmltopdf for PDF generation from .buflo templates
2. Implement batch mode support for .buflo profiles
3. Create profile editor GUI (syntax highlighting, validation)
4. Build migration tool (.bpl.lua → .buflo converter)

**The foundation is solid. The DSL is working perfectly. The editor is beautiful and functional. Time to generate some PDFs!** 🎉

---

## Editor Screenshot Description

The profile editor features a dark theme with:
- **Line numbers** on the left in gray
- **Syntax highlighting** with distinct colors:
  - Green comments starting with `#`
  - Light blue keys (profile, fields, computed, etc.)
  - Orange strings in quotes
  - Yellow special values (@today, @uuid, @calc)
  - Light green numbers
- **Current line highlight** in slightly lighter gray
- **Blinking cursor** showing edit position
- **Status bar** at bottom showing line/col, total lines, and modified status

All accessible from the welcome screen via "Create New Profile" or "Edit Profile" buttons!

![buflo logo](https://github.com/dotMavriQ/Buflo/blob/main/buflo.png?raw=true)
