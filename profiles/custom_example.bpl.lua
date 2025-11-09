-- profiles/custom_example.bpl.lua
-- Template for creating your own invoice profiles
-- Copy this file and modify to suit your needs

return {
  -- REQUIRED: Display name for this profile
  name = "My Custom Invoice",

  -- REQUIRED: Version number
  version = "1.0",

  -- REQUIRED: Output path pattern with {{placeholders}}
  -- Variables from 'data' can be used here
  output_pattern = "out/{{company}}_{{invoice_number}}.pdf",

  -- OPTIONAL: PDF to append after the invoice (terms, conditions, etc.)
  -- Can be a string path or a function that returns a path
  trailing_pdf = nil,  -- e.g., "profiles/my_terms.pdf"

  -- OPTIONAL: Locale settings
  locale = {
    currency = "USD",      -- EUR, USD, GBP, or custom
    date_fmt = "%Y-%m-%d", -- strftime format
  },

  -- REQUIRED: Field definitions for the form
  -- These generate the GUI form automatically
  fields = {
    -- Text field example
    {
      key = "company",
      label = "Company Name",
      type = "text",
      required = true,
      default = "My Company Inc.",
      placeholder = "Enter company name",
      help = "The name of your company",
    },

    -- Number field example
    {
      key = "invoice_number",
      label = "Invoice Number",
      type = "text",
      required = true,
      default = function()
        -- Dynamic default using date
        return "INV-" .. os.date("%Y%m%d")
      end,
    },

    -- Date field example
    {
      key = "invoice_date",
      label = "Invoice Date",
      type = "date",
      required = true,
      default = function()
        return os.date("%Y-%m-%d")
      end,
    },

    -- Number with validation
    {
      key = "hours",
      label = "Hours Worked",
      type = "number",
      required = true,
      default = 1,
      min = 0,
      max = 1000,
      step = 0.5,
    },

    -- Number field for rate
    {
      key = "hourly_rate",
      label = "Hourly Rate",
      type = "number",
      required = true,
      default = 100,
      min = 0,
    },

    -- Multiline text
    {
      key = "description",
      label = "Work Description",
      type = "multiline",
      required = false,
      help = "Describe the work performed",
    },

    -- Dropdown/enum
    {
      key = "payment_terms",
      label = "Payment Terms",
      type = "enum",
      required = true,
      default = "Net 30",
      enum = {"Due on Receipt", "Net 15", "Net 30", "Net 60"},
    },

    -- File picker
    {
      key = "logo",
      label = "Company Logo",
      type = "file",
      required = false,
      mode = "open",
      filter = "*.png;*.jpg;*.svg",
      help = "Optional company logo to include",
    },

    -- Checkbox
    {
      key = "include_tax",
      label = "Include Tax",
      type = "checkbox",
      default = false,
    },
  },

  -- OPTIONAL: Custom validation function
  -- Called before rendering to validate data
  -- Return: true or (false, "error message")
  validate = function(data)
    local hours = tonumber(data.hours) or 0
    local rate = tonumber(data.hourly_rate) or 0

    if hours <= 0 then
      return false, "Hours must be greater than 0"
    end

    if rate <= 0 then
      return false, "Hourly rate must be greater than 0"
    end

    if hours > 744 then  -- Max hours in a 31-day month
      return false, "Hours seem unrealistic (max 744 per month)"
    end

    return true
  end,

  -- REQUIRED: Render function
  -- Takes: data (form values), helpers (utility functions)
  -- Returns: HTML string
  render = function(data, helpers)
    -- Calculate totals
    local hours = tonumber(data.hours) or 0
    local rate = tonumber(data.hourly_rate) or 0
    local subtotal = hours * rate
    local tax = data.include_tax and (subtotal * 0.20) or 0
    local total = subtotal + tax

    -- Helper functions available:
    -- helpers.esc(str) - HTML escape
    -- helpers.fmt_currency(amount) - Format as currency
    -- helpers.fmt_date(date) - Format date
    -- helpers.table_sum(array, key) - Sum array field

    local esc = helpers.esc
    local cur = helpers.fmt_currency

    -- Return HTML string
    return string.format([[
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice %s</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 40px 20px;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 40px;
      padding-bottom: 20px;
      border-bottom: 3px solid #2c3e50;
    }
    .company {
      font-size: 24px;
      font-weight: bold;
      color: #2c3e50;
    }
    .invoice-info {
      text-align: right;
      color: #666;
    }
    .invoice-info .number {
      font-size: 20px;
      font-weight: bold;
      color: #2c3e50;
    }
    table {
      width: 100%%;
      border-collapse: collapse;
      margin: 30px 0;
    }
    thead {
      background: #34495e;
      color: white;
    }
    th, td {
      padding: 12px;
      text-align: left;
      border-bottom: 1px solid #ddd;
    }
    th {
      font-weight: 600;
    }
    .right { text-align: right; }
    .total-row {
      background: #ecf0f1;
      font-weight: bold;
    }
    .grand-total {
      background: #34495e;
      color: white;
      font-size: 18px;
    }
    .notes {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 5px;
      margin: 20px 0;
    }
    .notes h3 {
      margin-bottom: 10px;
      color: #2c3e50;
    }
    .footer {
      margin-top: 40px;
      padding-top: 20px;
      border-top: 1px solid #ddd;
      text-align: center;
      color: #666;
      font-size: 14px;
    }
  </style>
</head>
<body>
  <div class="header">
    <div class="company">%s</div>
    <div class="invoice-info">
      <div class="number">%s</div>
      <div>Date: %s</div>
      <div>Terms: %s</div>
    </div>
  </div>

  %s

  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th class="right">Hours</th>
        <th class="right">Rate</th>
        <th class="right">Amount</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Professional Services</td>
        <td class="right">%.2f</td>
        <td class="right">%s</td>
        <td class="right">%s</td>
      </tr>
      %s
      <tr class="total-row">
        <td colspan="3">Subtotal</td>
        <td class="right">%s</td>
      </tr>
      <tr class="grand-total">
        <td colspan="3">TOTAL DUE</td>
        <td class="right">%s</td>
      </tr>
    </tbody>
  </table>

  <div class="footer">
    <p>Thank you for your business!</p>
    <p>Payment is due according to the terms specified above.</p>
  </div>
</body>
</html>
]],
      esc(data.invoice_number),
      esc(data.company),
      esc(data.invoice_number),
      esc(data.invoice_date),
      esc(data.payment_terms),
      -- Include description if provided
      data.description and data.description ~= ""
        and string.format('<div class="notes"><h3>Work Description</h3><p>%s</p></div>',
            esc(data.description))
        or "",
      hours,
      cur(rate),
      cur(subtotal),
      -- Include tax row if applicable
      data.include_tax
        and string.format('<tr><td colspan="3">Tax (20%%)</td><td class="right">%s</td></tr>',
            cur(tax))
        or "",
      cur(subtotal),
      cur(total)
    )
  end,

  -- OPTIONAL: Batch processing configuration
  batch = {
    enabled = false,
    source = "data/custom_batch.json",

    -- Optional: Transform batch row to field data
    map = function(row)
      -- If your batch data doesn't match field names exactly,
      -- transform it here
      return {
        company = row.client_company or row.company,
        invoice_number = row.id or row.invoice_number,
        invoice_date = row.date or os.date("%Y-%m-%d"),
        hours = row.hours or 0,
        hourly_rate = row.rate or 0,
        description = row.notes or "",
        payment_terms = row.terms or "Net 30",
        include_tax = row.taxable or false,
      }
    end
  },
}
