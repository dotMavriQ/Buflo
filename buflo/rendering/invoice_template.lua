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
      font-size: 11pt;
      line-height: 1.6;
      color: #333;
      background: white;
      max-width: 210mm;
      margin: 0 auto;
      padding: 20px;
    }

    h1 {
      font-size: 24pt;
      font-weight: 600;
      color: #2c3e50;
      margin-bottom: 10px;
      border-bottom: 3px solid #3498db;
      padding-bottom: 8px;
    }

    h2 {
      font-size: 16pt;
      font-weight: 600;
      color: #34495e;
      margin: 20px 0 10px 0;
    }

    h3 {
      font-size: 13pt;
      font-weight: 600;
      color: #34495e;
      margin: 15px 0 8px 0;
    }

    /* Column layouts */
    .columns-layout {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 40px;
      margin: 20px 0;
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
      gap: 30px;
      margin: 15px 0;
      padding: 12px 15px;
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
      margin: 20px 0;
    }

    .field-row {
      margin: 8px 0;
      line-height: 1.8;
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

    /* Table section */
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
      body {
        margin: 0;
        padding: 15mm 20mm;
      }

      .columns-layout,
      .section-group,
      .horizontal-fields,
      table {
        page-break-inside: avoid;
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
</body>
</html>
]]

  return html
end

return M
