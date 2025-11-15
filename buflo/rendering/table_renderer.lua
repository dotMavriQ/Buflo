-- buflo/rendering/table_renderer.lua
-- HTML table renderer for invoice line items

local M = {}

-- Calculate column value (for calculated fields)
local function calculate_column_value(formula, row_data)
  if not formula then return "" end

  -- Simple @calc() evaluator
  -- Formula like "@calc(quantity * rate)"
  local expr = formula:match("@calc%s*%((.+)%)")
  if not expr then return "" end

  -- Replace column IDs with values
  local eval_expr = expr
  for col_id, value in pairs(row_data) do
    local num_value = tonumber(value) or 0
    eval_expr = eval_expr:gsub("%f[%w]" .. col_id .. "%f[%W]", tostring(num_value))
  end

  -- Evaluate simple arithmetic
  local result = load("return " .. eval_expr)
  if result then
    local ok, value = pcall(result)
    if ok and type(value) == "number" then
      return string.format("%.2f", value)
    end
  end

  return ""
end

-- Calculate table summary (for @sum formulas)
local function calculate_summary(formula, rows, columns)
  if not formula then return "" end

  -- @sum(items.column_id)
  local col_id = formula:match("@sum%s*%(%s*items%.([%w_]+)%s*%)")
  if not col_id then return "" end

  local total = 0
  for _, row in ipairs(rows) do
    -- If column is calculated, calculate it first
    local col_def = nil
    for _, col in ipairs(columns) do
      if col.id == col_id then
        col_def = col
        break
      end
    end

    local value
    if col_def and col_def.calculated and col_def.formula then
      value = calculate_column_value(col_def.formula, row)
    else
      value = row[col.id]
    end

    total = total + (tonumber(value) or 0)
  end

  return string.format("%.2f", total)
end

-- Format currency value
local function format_currency(value, currency_symbol)
  currency_symbol = currency_symbol or "€"
  local num = tonumber(value) or 0
  return string.format("%s%.2f", currency_symbol, num)
end

-- Format cell value based on column type
local function format_cell_value(value, column)
  if not value or value == "" then return "" end

  if column.type == "currency" then
    return format_currency(value, column.currency_symbol)
  elseif column.type == "number" then
    local num = tonumber(value) or 0
    return string.format("%.2f", num)
  else
    return tostring(value)
  end
end

-- Render table as HTML
function M.render_table(table_section, field_values)
  -- Get table data from field_values
  local table_data = field_values[table_section.id] or {}

  -- If no data, use default_data or create empty rows
  if #table_data == 0 and table_section.default_data then
    table_data = table_section.default_data
  end

  -- If still no data, show empty table message
  if #table_data == 0 then
    return '<div class="table-empty"><p><em>No items</em></p></div>'
  end

  local html = '<table class="invoice-table">'

  -- Table header
  html = html .. '<thead><tr>'
  for _, col in ipairs(table_section.columns) do
    local width_style = col.width and (' style="width: ' .. col.width .. ';"') or ""
    html = html .. string.format('<th%s>%s</th>', width_style, col.label or col.id)
  end
  html = html .. '</tr></thead>'

  -- Table body
  html = html .. '<tbody>'
  for _, row in ipairs(table_data) do
    html = html .. '<tr>'
    for _, col in ipairs(table_section.columns) do
      local cell_value

      if col.calculated and col.formula then
        -- Calculate value
        cell_value = calculate_column_value(col.formula, row)
        cell_value = format_cell_value(cell_value, col)
      else
        -- Regular value
        cell_value = format_cell_value(row[col.id], col)
      end

      -- Align numbers/currency to the right
      local align_class = ""
      if col.type == "currency" or col.type == "number" or col.calculated then
        align_class = ' class="align-right"'
      end

      html = html .. string.format('<td%s>%s</td>', align_class, cell_value)
    end
    html = html .. '</tr>'
  end
  html = html .. '</tbody>'

  -- Summary row (if defined)
  if table_section.summary then
    html = html .. '<tfoot>'
    html = html .. '<tr class="summary-row">'

    -- Calculate summary value
    local summary_value = calculate_summary(table_section.summary.formula, table_data, table_section.columns)

    -- Find the column to place the summary value in (usually the last calculated column)
    local summary_col_index = #table_section.columns

    for col_idx, col in ipairs(table_section.columns) do
      if col_idx < summary_col_index then
        if col_idx == 1 then
          -- First column gets the label
          html = html .. string.format('<td class="summary-label" colspan="%d">%s</td>',
            summary_col_index - 1,
            table_section.summary.label or "TOTAL")
        end
      else
        -- Last column gets the value
        local formatted_value = format_currency(summary_value, "€")
        html = html .. string.format('<td class="summary-value align-right">%s</td>', formatted_value)
      end
    end

    html = html .. '</tr>'
    html = html .. '</tfoot>'
  end

  html = html .. '</table>'

  return html
end

return M
