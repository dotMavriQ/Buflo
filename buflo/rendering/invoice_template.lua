-- buflo/rendering/invoice_template.lua
-- Professional A4 invoice HTML template generator

local section_renderer = require("buflo.rendering.section_renderer")

local M = {}

-- Generate CSS for A4 invoice
local function generate_css()
  return [[
    @page {
      size: A4;
      margin: 0;
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    html {
      background: #282828; /* Gruvbox dark background */
    }

    body {
      font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      background: #282828; /* Gruvbox dark background */
      margin: 0;
      padding: 40px 0 100px 0;
      min-height: 100vh;
    }

    /* Print button and page counter */
    .print-controls {
      position: fixed;
      bottom: 20px;
      right: 20px;
      display: flex;
      flex-direction: column;
      gap: 15px;
      align-items: flex-end;
      z-index: 1000;
    }

    .buflo-watermark {
      opacity: 0.15;
      filter: invert(1);
      pointer-events: none;
      user-select: none;
      max-width: 180px;
      margin-bottom: 10px;
    }

    .controls-row {
      display: flex;
      gap: 15px;
      align-items: center;
    }

    .page-counter {
      background: #3c3836; /* Gruvbox dark gray */
      color: #ebdbb2; /* Gruvbox light */
      padding: 12px 20px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 600;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
    }

    .print-button {
      background: #d79921; /* Gruvbox yellow */
      color: #282828;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
      transition: all 0.2s ease;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .print-button:hover {
      background: #fabd2f; /* Gruvbox light yellow */
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.5);
    }

    .print-button:active {
      transform: translateY(0);
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
    }

    /* A4 page container with shadow */
    .page {
      width: 210mm;
      min-height: 297mm;
      background: white;
      margin: 0 auto 20mm auto;
      padding: 15mm 20mm;
      box-shadow: 0 0 20px rgba(0, 0, 0, 0.5);
      position: relative;
      font-size: 10pt;
      line-height: 1.4;
      color: #333;
    }

    .page:last-child {
      margin-bottom: 40px;
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
        margin: 0;
      }

      html, body {
        background: white !important;
        margin: 0;
        padding: 0;
      }

      .print-controls {
        display: none !important;
      }

      .page {
        width: 210mm;
        height: 297mm;
        margin: 0;
        padding: 15mm 20mm;
        box-shadow: none;
        page-break-after: always;
        page-break-inside: avoid;
        font-size: 9pt;
        line-height: 1.3;
      }

      .page:last-child {
        margin-bottom: 0;
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

-- Load and encode BUFLO logo as base64
local function get_buflo_logo_base64()
  local logo_path = "assets/buflo.png"
  local logo_data = love.filesystem.read(logo_path)
  if logo_data then
    -- Convert to base64
    local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function base64_encode(data)
      return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
      end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64:sub(c+1,c+1)
      end)..({ '', '==', '=' })[#data%3+1])
    end
    return base64_encode(logo_data)
  end
  return nil
end

-- Generate complete HTML invoice
function M.generate_invoice_html(profile_data, field_values)
  local title = (profile_data.document and profile_data.document.title) or "Invoice"
  local logo_base64 = get_buflo_logo_base64()

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
  <div class="page">
    <h1>]] .. title .. [[</h1>
]]

  -- Render all sections from all pages (excluding attachment sections)
  if profile_data.pages then
    for _, page in ipairs(profile_data.pages) do
      if page.sections then
        for _, section in ipairs(page.sections) do
          -- Skip sections that only contain pdf_attachment fields
          local has_pdf_attachment = false
          if section.fields then
            for _, field in ipairs(section.fields) do
              if field.type == "pdf_attachment" then
                has_pdf_attachment = true
                break
              end
            end
          end

          if not has_pdf_attachment then
            html = html .. section_renderer.render_section(section, field_values)
          end
        end
      end
    end
  end

  html = html .. [[
  </div>
]]

  -- Add PDF attachment pages if any
  local page_count = 1
  for field_id, value in pairs(field_values) do
    -- Check if this is a PDF attachment field with a value
    if field_id:match("_pdf$") and value ~= "" and value ~= nil then
      print("Processing PDF attachment: " .. value)

      -- Convert PDF pages to images using pdftoppm
      local temp_prefix = tostring(os.time())
      local output_dir = "/tmp/buflo_pdf_" .. temp_prefix
      os.execute("mkdir -p '" .. output_dir .. "'")

      -- Escape the file path properly
      local escaped_value = value:gsub("'", "'\\''")

      -- Convert PDF to PNG images at 150 DPI (good quality for A4)
      local cmd = string.format("pdftoppm -png -r 150 '%s' '%s/page' 2>&1", escaped_value, output_dir)
      print("Running command: " .. cmd)
      local handle = io.popen(cmd)
      local result_output = ""
      if handle then
        result_output = handle:read("*all")
        handle:close()
        print("pdftoppm output: " .. result_output)
      end

      -- Find all generated PNG files
      local pages = {}
      local find_cmd = string.format("ls '%s'/page-*.png 2>/dev/null | sort -V", output_dir)
      print("Finding pages: " .. find_cmd)
      local list_handle = io.popen(find_cmd)
      if list_handle then
        for page_file in list_handle:lines() do
          print("Found page: " .. page_file)
          table.insert(pages, page_file)
        end
        list_handle:close()
      end

      print("Total pages found: " .. #pages)

      if #pages > 0 then
        -- Embed each page as base64 image
        for _, page_file in ipairs(pages) do
          page_count = page_count + 1

          -- Read and encode image
          local img_handle = io.open(page_file, "rb")
          if img_handle then
            local img_data = img_handle:read("*all")
            img_handle:close()

            -- Base64 encode
            local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            local function base64_encode(data)
              return ((data:gsub('.', function(x)
                local r,b='',x:byte()
                for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
                return r;
              end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
                if (#x < 6) then return '' end
                local c=0
                for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
                return b64:sub(c+1,c+1)
              end)..({ '', '==', '=' })[#data%3+1])
            end

            local img_base64 = base64_encode(img_data)
            print("Encoded page " .. page_count .. ", size: " .. #img_base64)

            html = html .. [[
  <div class="page">
    <img src="data:image/png;base64,]] .. img_base64 .. [[" style="width: 100%; height: 100%; object-fit: contain;" alt="PDF Page ]] .. (page_count - 1) .. [[">
  </div>
]]
          end
        end

        -- Cleanup temp files
        os.execute("rm -rf '" .. output_dir .. "'")
      else
        -- Fallback: show error if no pages were generated
        page_count = page_count + 1
        local filename = value:match("([^/]+)$") or value
        html = html .. [[
  <div class="page">
    <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%; text-align: center;">
      <div style="font-size: 48px; margin-bottom: 20px;">⚠️</div>
      <h2 style="color: #666; margin-bottom: 10px;">PDF Conversion Failed</h2>
      <p style="color: #999; font-size: 12pt;">]] .. filename .. [[</p>
      <p style="color: #999; font-size: 10pt; margin-top: 20px; font-style: italic;">
        Check terminal for error details
      </p>
    </div>
  </div>
]]
      end
    end
  end  html = html .. [[

  <!-- Print controls -->
  <div class="print-controls">
]]

  -- Add BUFLO watermark if logo is available
  if logo_base64 then
    html = html .. [[
    <img src="data:image/png;base64,]] .. logo_base64 .. [[" alt="BUFLO" class="buflo-watermark">
]]
  end

  html = html .. [[
    <div class="controls-row">
      <div class="page-counter">
        📄 Page ]] .. page_count .. [[

      </div>
      <button class="print-button" onclick="window.print()">
        🖨️ Print Document
      </button>
    </div>
  </div>

  <script>
    // Update page counter with actual count
    const pageCount = document.querySelectorAll('.page').length;
    document.querySelector('.page-counter').textContent = '📄 Pages: ' + pageCount;
  </script>
</body>
</html>
]]  return html
end

return M
