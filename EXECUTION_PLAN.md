# BUFLO Invoice Formatting - Execution Plan

## Current State Analysis

### What We Have ✅
- ✅ LÖVE2D GUI with form flow
- ✅ `.buflo` DSL v2 parser
- ✅ Multi-page form with validation
- ✅ Field collection (26 fields working)
- ✅ Basic HTML preview (but ugly - just boxes with text)

### The Problem ❌
**Current HTML output is a long vertical list of field boxes** - not an actual formatted invoice that resembles a professional PDF.

The example PDFs show:
- **Professional invoice layout** on A4 page
- **Structured sections** (header, billing details, line items, totals)
- **Multi-column layouts** (Invoice To / Logo on right)
- **Tables** for line items with columns
- **Proper typography** and spacing
- **Page boundaries** - fits on A4
- **Print-ready formatting**

### Reference Documents
- `examples/NHJJ0004_Jonatan_Jansson_Sept_2025.pdf` - Target format (real invoice)
- `examples/Nordhealth Marketing & Development Invoice.pdf` - Current ugly output
- `profiles/nordhealth_mardev.buflo` - DSL definition
- `BUFLO_DSL_V2_SPEC.md` - DSL specification with layout directives

---

## Execution Plan

### Phase 1: HTML/CSS Template Engine (Week 1)
**Goal**: Generate properly formatted HTML that matches invoice layout specs

#### 1.1 Create Professional Invoice Template
- [ ] Build A4-sized HTML template (210mm x 297mm)
- [ ] Add CSS for print media (@page, @media print)
- [ ] Implement page margins and safe zones
- [ ] Set up professional typography (fonts, sizes, weights)
- [ ] Add invoice header styling
- [ ] Create footer with page numbers

**Files to modify**:
- `screens/form.lua` - Replace `generate_html_preview()` function
- Create `buflo/rendering/invoice_template.lua` - Template engine

#### 1.2 Implement Section Rendering
- [ ] **Columns section** renderer (left/right layout)
- [ ] **Group section** renderer (vertical stack)
- [ ] **Horizontal fields** renderer (inline fields)
- [ ] **Spacer** renderer (vertical spacing)
- [ ] **Heading** renderer (section titles)

**New module**: `buflo/rendering/section_renderer.lua`

#### 1.3 Implement Field Rendering
- [ ] Text field → styled output
- [ ] Textarea → multi-line text block
- [ ] Number → formatted number
- [ ] Date → formatted date
- [ ] Email → styled email
- [ ] Image upload → embedded image or placeholder

**New module**: `buflo/rendering/field_renderer.lua`

---

### Phase 2: Table/Repeating Sections (Week 2)
**Goal**: Implement line items table with calculations

#### 2.1 Table Widget in Form
- [ ] Create table input widget in `screens/form.lua`
- [ ] Add/remove row buttons
- [ ] Column inputs (Description, Quantity, Rate, Amount)
- [ ] Calculate amounts (Quantity × Rate)
- [ ] Store table data in `field_values`

#### 2.2 Table Rendering in HTML
- [ ] Generate HTML `<table>` from table data
- [ ] Apply professional table styling (borders, headers, alternating rows)
- [ ] Render summary row (subtotal/total)
- [ ] Handle empty tables gracefully

**New module**: `buflo/rendering/table_renderer.lua`

---

### Phase 3: Calculated Fields (Week 2)
**Goal**: Implement @calc() and @sum() for totals

#### 3.1 Expression Evaluator
- [ ] Parse @calc(expression) syntax
- [ ] Evaluate arithmetic expressions (×, +, -, ÷, %)
- [ ] Reference field values (e.g., `quantity * rate`)
- [ ] Handle @sum(array.field) for table columns
- [ ] Dependency resolution (subtotal → tax → total)

**New module**: `buflo/core/calculator.lua`

#### 3.2 Integration
- [ ] Auto-calculate during form filling
- [ ] Display calculated fields in form (read-only)
- [ ] Include in HTML output
- [ ] Validate calculations before PDF generation

---

### Phase 4: Layout Engine (Week 3)
**Goal**: Respect DSL layout directives and fit content to A4

#### 4.1 Layout System
- [ ] Parse section `type` (columns, group, horizontal_fields, table, spacer)
- [ ] Implement column layouts (left/right, configurable gaps)
- [ ] Calculate element positioning
- [ ] Handle auto_fit: resize to fit A4
- [ ] Respect margins and padding

**New module**: `buflo/rendering/layout_engine.lua`

#### 4.2 Styling System
- [ ] Apply `style` properties (bold, italic, underline)
- [ ] Apply `size` properties (font sizes)
- [ ] Apply `color` properties (text colors)
- [ ] Apply `align` properties (left, center, right)
- [ ] Respect `gap`, `spacing`, `margin`, `padding`

**New module**: `buflo/rendering/style_engine.lua`

---

### Phase 5: PDF Generation (Week 3)
**Goal**: Convert HTML to professional PDF

#### 5.1 PDF Generation Options

**Option A: wkhtmltopdf** (External tool)
- Pros: High quality, widely used
- Cons: External dependency
- Implementation:
  ```lua
  -- buflo/rendering/pdf_generator.lua
  function generate_pdf(html_content, output_path)
    -- Save HTML to temp file
    -- Run: wkhtmltopdf --page-size A4 --margin-top 10mm temp.html output.pdf
    -- Clean up temp file
  end
  ```

**Option B: weasyprint** (Python-based)
- Pros: Excellent CSS support, better page breaks
- Cons: Requires Python
- Implementation: Similar to wkhtmltopdf

**Option C: Native Lua (Future)**
- Use LuaLaTeX or PDF library
- Most complex but no external dependencies

**Decision**: Start with wkhtmltopdf, add weasyprint support later

#### 5.2 Integration
- [ ] Add PDF generation to form submit flow
- [ ] Show progress indicator during generation
- [ ] Open PDF automatically after generation
- [ ] Error handling (missing dependencies, generation failures)

---

### Phase 6: Profile Template System (Week 4)
**Goal**: Pre-defined templates for common invoice types

#### 6.1 Template Library
- [ ] Create `templates/` directory
- [ ] Standard Invoice template
- [ ] Consulting Invoice template
- [ ] Product Sales Invoice template
- [ ] Time Sheet Invoice template

#### 6.2 Template Manager
- [ ] GUI for selecting template
- [ ] Copy template to `profiles/`
- [ ] Customize template fields
- [ ] Save customized profile

---

### Phase 7: Polish & Testing (Week 4)
**Goal**: Production-ready invoice generation

#### 7.1 Testing
- [ ] Test with nordhealth_mardev.buflo
- [ ] Test with consulting_invoice.buflo
- [ ] Create 5+ test invoices
- [ ] Verify A4 page sizing
- [ ] Test with different data (long text, many line items, etc.)
- [ ] Cross-platform testing (Linux, macOS, Windows)

#### 7.2 Error Handling
- [ ] Handle missing fields gracefully
- [ ] Validate before PDF generation
- [ ] Show helpful error messages
- [ ] Prevent data loss on errors

#### 7.3 Documentation
- [ ] Update README with PDF generation instructions
- [ ] Add template creation guide
- [ ] Document layout directives
- [ ] Create video tutorial

---

## Technical Architecture

### Module Structure

```
buflo/
├── rendering/                    # NEW: HTML/PDF rendering
│   ├── invoice_template.lua     # Base invoice HTML/CSS
│   ├── section_renderer.lua     # Render sections
│   ├── field_renderer.lua       # Render fields
│   ├── table_renderer.lua       # Render tables
│   ├── layout_engine.lua        # Calculate layouts
│   ├── style_engine.lua         # Apply styles
│   └── pdf_generator.lua        # HTML → PDF
├── core/
│   ├── buflo_v2_parser.lua      # Existing parser
│   └── calculator.lua           # NEW: @calc/@sum evaluator
└── util/
    ├── fs.lua                    # File operations
    ├── log.lua                   # Logging
    └── shell.lua                 # Command execution (for PDF tools)

screens/
└── form.lua                      # MODIFY: Use new rendering system
```

### Data Flow

```
1. User fills form
   ↓
2. Field values collected
   ↓
3. Calculated fields evaluated (@calc, @sum)
   ↓
4. Section renderer generates HTML snippets
   ↓
5. Layout engine combines sections
   ↓
6. Style engine applies CSS
   ↓
7. Invoice template wraps content
   ↓
8. HTML saved to file
   ↓
9. PDF generator (wkhtmltopdf) converts HTML → PDF
   ↓
10. Open PDF in viewer
```

---

## Sample HTML Structure (Target)

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice #NHJJ0004</title>
  <style>
    @page {
      size: A4;
      margin: 15mm 20mm 15mm 20mm;
    }
    body {
      font-family: Helvetica, Arial, sans-serif;
      font-size: 11pt;
      line-height: 1.4;
      color: #333;
    }
    .invoice-header {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 40px;
      margin-bottom: 30px;
    }
    .logo {
      text-align: right;
    }
    .invoice-details {
      display: flex;
      justify-content: space-between;
      margin: 20px 0;
      font-weight: bold;
    }
    table.line-items {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
    }
    table.line-items th {
      background: #f0f0f0;
      border: 1px solid #ccc;
      padding: 8px;
      text-align: left;
      font-weight: bold;
    }
    table.line-items td {
      border: 1px solid #ccc;
      padding: 8px;
    }
    .total-row {
      font-weight: bold;
      background: #f9f9f9;
    }
  </style>
</head>
<body>
  <div class="invoice-header">
    <div class="invoice-to">
      <h3>Invoice to:</h3>
      <p><strong>Nordhealth Therapy Finland Oy</strong></p>
      <p>Bulevardi 21, 00180 Helsinki, Finland</p>
      <p>VAT: FI12345678</p>
    </div>
    <div class="logo">
      <img src="logo.png" alt="Logo" style="max-width: 200px;">
    </div>
  </div>

  <div class="invoice-details">
    <span>Invoice no.: NHJJ0004</span>
    <span>Invoice date: 2025-09-30</span>
    <span>Due date: 2025-10-30</span>
  </div>

  <h3>Period: September 2025</h3>

  <table class="line-items">
    <thead>
      <tr>
        <th>Description</th>
        <th style="text-align: right;">Quantity</th>
        <th style="text-align: right;">Rate (€)</th>
        <th style="text-align: right;">Amount (€)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Professional consulting services</td>
        <td style="text-align: right;">22 days</td>
        <td style="text-align: right;">213.00</td>
        <td style="text-align: right;">4,686.00</td>
      </tr>
      <tr class="total-row">
        <td colspan="3" style="text-align: right;">TOTAL</td>
        <td style="text-align: right;">€4,686.00</td>
      </tr>
    </tbody>
  </table>

  <div class="bank-details">
    <h3>BANK DETAILS</h3>
    <p><strong>Bank:</strong> ActivoBank Portugal</p>
    <p><strong>IBAN:</strong> PT50 0023 0000 4567 8901 2345 6</p>
    <p><strong>BIC:</strong> CTTVPTPL</p>
  </div>
</body>
</html>
```

---

## Priority Order

### Immediate (This Week)
1. ✅ Create this execution plan
2. 🔥 Replace `generate_html_preview()` with professional template
3. 🔥 Implement section-based rendering (columns, groups)
4. 🔥 Test with nordhealth_mardev.buflo

### Next Week
1. Table widget for line items
2. Calculated fields (@calc, @sum)
3. PDF generation integration (wkhtmltopdf)

### Week After
1. Layout engine (auto-fit A4)
2. Style engine (apply DSL styling properties)
3. Template library

### Final Week
1. Testing & bug fixes
2. Documentation
3. Demo video

---

## Success Criteria

✅ Invoice HTML looks professional (like example PDFs)
✅ Fits on A4 page (210mm × 297mm)
✅ Multi-column layouts work (columns section type)
✅ Tables render properly with calculations
✅ PDF generation works (wkhtmltopdf)
✅ Can generate invoice from nordhealth_mardev.buflo
✅ Output matches `NHJJ0004_Jonatan_Jansson_Sept_2025.pdf` in structure/formatting

---

## Notes

- **The DSL already specifies the layout** - we just need to respect it in rendering
- **Auto-fit is critical** - content must fit A4, not overflow
- **Print-ready is the goal** - PDF should be ready to send/print
- **Progressive enhancement** - Start with basic HTML, add features incrementally
- **Test early, test often** - Generate PDFs frequently to catch issues

---

## Questions to Resolve

1. Should we support multi-page invoices or always fit to 1 page?
   - **Suggestion**: Start with 1-page auto-fit, add multi-page later
2. Image embedding - base64 or file paths?
   - **Suggestion**: Start with file paths, add base64 option later
3. Currency formatting - use settings.currency from profile?
   - **Yes** - respect profile settings
4. Date formatting - use settings.date_format from profile?
   - **Yes** - respect profile settings

---

**Let's start with Phase 1.1 - Professional Invoice Template!**
