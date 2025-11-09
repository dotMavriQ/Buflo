-- profiles/example_invoice.bpl.lua
-- Example BUFLO profile for Nordhealth-style invoices

return {
  name = "Nordhealth Invoice",
  version = "1.0",
  output_pattern = "out/{{invoice_number}}.pdf",
  trailing_pdf = "profiles/terms-and-conditions.pdf",

  fields = {
    { key="client_name",    label="Client Name",    type="text",      required=true },
    { key="client_email",   label="Client Email",   type="text" },
    { key="invoice_number", label="Invoice Number", type="text",      required=true },
    { key="invoice_date",   label="Invoice Date",   type="date",      required=true, default=function() return os.date("%Y-%m-%d") end },
    { key="daily_rate",     label="Daily Rate",     type="number",    required=true, default=213, min=0, step=1 },
    { key="days",           label="Days",           type="number",    required=true, default=1, min=0, step=1 },
    { key="notes",          label="Notes",          type="multiline" },
    { key="annex",          label="Client Annex",   type="file",      help="Optional annex PDF to append" },
  },

  validate = function(d)
    if (tonumber(d.daily_rate) or 0) <= 0 then
      return false, "Daily rate must be > 0"
    end
    if (tonumber(d.days) or 0) <= 0 then
      return false, "Days must be > 0"
    end
    return true
  end,

  render = function(d, helpers)
    local rate = tonumber(d.daily_rate) or 0
    local days = tonumber(d.days) or 0
    local total = rate * days
    local esc, cur = helpers.esc, helpers.fmt_currency

    return ([[
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Invoice %s</title>
  <style>
    body {
      font-family: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      margin: 40px;
      color: #333;
      line-height: 1.6;
    }
    h1 {
      margin: 0 0 8px;
      color: #2c3e50;
      font-size: 28px;
    }
    table {
      border-collapse: collapse;
      width: 100%%;
      margin: 20px 0;
    }
    th, td {
      border-bottom: 1px solid #eee;
      padding: 12px 8px;
      text-align: left;
    }
    th {
      background: #f8f9fa;
      font-weight: 600;
    }
    .right {
      text-align: right;
    }
    .box {
      border: 1px solid #ddd;
      padding: 16px;
      border-radius: 8px;
      margin: 16px 0;
      background: #fafafa;
    }
    .box strong {
      display: inline-block;
      min-width: 80px;
    }
    .total-box {
      background: #e8f4f8;
      border-color: #3498db;
      font-size: 18px;
      font-weight: 600;
      text-align: right;
    }
    .muted {
      color: #666;
      font-size: 14px;
      font-style: italic;
      margin-top: 20px;
    }
    .header {
      border-bottom: 3px solid #3498db;
      padding-bottom: 10px;
      margin-bottom: 20px;
    }
  </style>
</head>
<body>
  <div class="header">
    <h1>Invoice %s</h1>
  </div>

  <div class="box">
    <strong>Date:</strong> %s<br>
    <strong>Client:</strong> %s<br>
    <strong>Email:</strong> %s
  </div>

  <table>
    <thead>
      <tr>
        <th>Description</th>
        <th class="right">Rate</th>
        <th class="right">Days</th>
        <th class="right">Line Total</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Professional services</td>
        <td class="right">%s</td>
        <td class="right">%d</td>
        <td class="right">%s</td>
      </tr>
    </tbody>
  </table>

  <div class="box total-box">
    <strong>Total Due:</strong> %s
  </div>

  %s

  <div class="muted" style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee;">
    Thank you for your business.
  </div>
</body>
</html>
]]):format(
      esc(d.invoice_number),
      esc(d.invoice_number),
      esc(d.invoice_date),
      esc(d.client_name),
      esc(d.client_email or ""),
      cur(rate),
      days,
      cur(total),
      cur(total),
      d.notes and ("<div class='muted'><strong>Notes:</strong><br>" .. esc(d.notes) .. "</div>") or ""
    )
  end,

  batch = {
    enabled = false,
    source = "data/batch.json",
  },

  locale = {
    currency = "EUR",
    date_fmt = "%Y-%m-%d",
  }
}
