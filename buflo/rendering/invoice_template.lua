-- buflo/rendering/invoice_template.lua
-- Professional A4 invoice HTML template generator

local section_renderer = require("buflo.rendering.section_renderer")

local M = {}

-- Generate CSS for A4 invoice
local function generate_css()
  return [[
    @page {
      size: A4;
      margin: 15mm 20mm 15mm 20mm;
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      font-size: 10pt;
      line-height: 1.4;
      color: #333;
      background: white;
      max-width: 210mm;
      margin: 0 auto;
      padding: 15px;
    }

    /* Page 1 container - contains all invoice content */
    .invoice-page-1 {
      max-height: 267mm; /* A4 height (297mm) minus margins (30mm) */
      overflow: visible;
      page-break-after: always;
    }

    h1 {
      font-size: 20pt;
      font-weight: 600;
      color: #2c3e50;
      margin-bottom: 8px;
      border-bottom: 3px solid #3498db;
      padding-bottom: 6px;
    }

    h2 {
      font-size: 14pt;
      font-weight: 600;
      color: #34495e;
      margin: 12px 0 8px 0;
    }

    h3 {
      font-size: 12pt;
      font-weight: 600;
      color: #34495e;
      margin: 10px 0 6px 0;
    }

    /* Column layouts */
    .columns-layout {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 30px;
      margin: 12px 0;
    }

    .column-left,
    .column-right {
      min-height: 100px;
    }

    .logo-container {
      text-align: right;
      margin-bottom: 15px;
    }

    .invoice-logo {
      max-width: 200px;
      max-height: 100px;
      height: auto;
    }

    /* Horizontal fields */
    .horizontal-fields {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 20px;
      margin: 10px 0;
      padding: 10px 12px;
      background: #f8f9fa;
      border-left: 4px solid #3498db;
      font-weight: 600;
    }

    .field-inline {
      display: flex;
      align-items: center;
      gap: 8px;
      white-space: nowrap;
    }

    .field-inline .field-label {
      color: #555;
      font-weight: 600;
    }

    .field-inline .field-value {
      color: #2c3e50;
      font-weight: 600;
    }

    /* Field rows */
    .section-group {
      margin: 12px 0;
    }

    .field-row {
      margin: 6px 0;
      line-height: 1.6;
    }

    .field-label {
      font-weight: 600;
      color: #555;
      min-width: 120px;
      display: inline-block;
    }

    .field-value {
      color: #333;
    }

    .field-value em {
      color: #999;
      font-style: italic;
    }

    .field-value a {
      color: #3498db;
      text-decoration: none;
    }

    .field-value a:hover {
      text-decoration: underline;
    }

    /* Spacer */
    .spacer {
      clear: both;
    }

    /* Invoice Table */
    .invoice-table {
      width: 100%;
      border-collapse: collapse;
      margin: 12px 0;
      font-size: 9pt;
    }

    .invoice-table thead {
      background: #34495e;
      color: #ffffff;
    }

    .invoice-table th {
      font-weight: 600;
      text-align: left;
      padding: 8px;
      border: none;
      font-size: 9pt;
      color: #ffffff;
    }

    .invoice-table td {
      padding: 7px 8px;
      border-bottom: 1px solid #e0e0e0;
      vertical-align: top;
    }

    .invoice-table tbody tr:hover {
      background: #f8f9fa;
    }

    .invoice-table .align-right {
      text-align: right;
    }

    .invoice-table tfoot {
      border-top: 2px solid #34495e;
    }

    .invoice-table .summary-row {
      background: #f8f9fa;
      font-weight: bold;
      border-top: 2px solid #34495e;
    }

    .invoice-table .summary-row td {
      padding: 10px 8px;
      font-size: 10pt;
      border: none;
    }

    .invoice-table .summary-label {
      text-align: right;
      color: #2c3e50;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      font-weight: 700;
    }

    .invoice-table .summary-value {
      color: #2c3e50;
      font-size: 11pt;
      font-weight: 700;
    }

    .table-empty {
      text-align: center;
      padding: 30px;
      color: #999;
      font-style: italic;
    }

    /* Legacy table section support */
    .table-section {
      margin: 20px 0;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin: 15px 0;
    }

    thead {
      background: #ecf0f1;
    }

    th {
      font-weight: 600;
      text-align: left;
      padding: 10px;
      border: 1px solid #bdc3c7;
      font-size: 10pt;
      color: #34495e;
    }

    td {
      padding: 10px;
      border: 1px solid #ddd;
    }

    tr:nth-child(even) {
      background: #f9f9f9;
    }

    .total-row {
      font-weight: bold;
      background: #ecf0f1 !important;
    }

    .total-row td {
      font-size: 12pt;
      padding: 12px 10px;
    }

    /* Print styles */
    @media print {
      @page {
        size: A4;
        margin: 10mm 15mm;
      }

      html, body {
        width: 210mm;
        height: 297mm;
        margin: 0;
        padding: 0;
      }

      body {
        padding: 10mm 15mm;
        font-size: 9pt;
        line-height: 1.3;
      }

      .invoice-page-1 {
        page-break-after: always;
        page-break-inside: avoid;
      }

      h1 {
        font-size: 18pt;
        margin-bottom: 6px;
        padding-bottom: 4px;
      }

      h2 {
        font-size: 12pt;
        margin: 8px 0 6px 0;
      }

      h3 {
        font-size: 11pt;
        margin: 6px 0 4px 0;
      }

      .columns-layout {
        gap: 20px;
        margin: 8px 0;
      }

      .horizontal-fields {
        margin: 6px 0;
        padding: 6px 10px;
        gap: 15px;
      }

      .section-group {
        margin: 8px 0;
      }

      .field-row {
        margin: 4px 0;
      }

      .invoice-table {
        margin: 8px 0;
        font-size: 8pt;
      }

      .invoice-table th {
        padding: 6px;
        font-size: 8pt;
      }

      .invoice-table td {
        padding: 5px 6px;
      }

      .invoice-table .summary-row td {
        padding: 8px 6px;
        font-size: 9pt;
      }

      .invoice-table .summary-value {
        font-size: 10pt;
      }

      .columns-layout,
      .section-group,
      .horizontal-fields {
        page-break-inside: avoid;
      }

      .invoice-table {
        page-break-inside: auto;
      }

      .invoice-table thead {
        display: table-header-group;
      }

      .invoice-table tfoot {
        display: table-footer-group;
      }

      h1, h2, h3 {
        page-break-after: avoid;
      }
    }
  ]]
end

-- Generate complete HTML invoice
function M.generate_invoice_html(profile_data, field_values)
  local title = (profile_data.document and profile_data.document.title) or "Invoice"

  local html = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>]] .. title .. [[</title>
  <style>
]] .. generate_css() .. [[
  </style>
</head>
<body>
  <div class="invoice-page-1">
    <h1>]] .. title .. [[</h1>
]]

  -- Render all sections from all pages
  if profile_data.pages then
    for _, page in ipairs(profile_data.pages) do
      if page.sections then
        for _, section in ipairs(page.sections) do
          html = html .. section_renderer.render_section(section, field_values)
        end
      end
    end
  end

  html = html .. [[
  </div>
  <!-- Page 2 and beyond can be added here -->
</body>
</html>
]]

  return html
end

return M
