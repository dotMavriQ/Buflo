-- buflo/core/render.lua
-- HTML rendering with helper functions

local M = {}

-- HTML escape
local function esc(str)
  if str == nil then return "" end
  str = tostring(str)
  str = str:gsub("&", "&amp;")
  str = str:gsub("<", "&lt;")
  str = str:gsub(">", "&gt;")
  str = str:gsub('"', "&quot;")
  str = str:gsub("'", "&#39;")
  return str
end

-- Format currency
local function fmt_currency(amount, currency)
  currency = currency or "EUR"
  amount = tonumber(amount) or 0
  local formatted = string.format("%.2f", amount)

  if currency == "EUR" then
    return "€" .. formatted
  elseif currency == "USD" then
    return "$" .. formatted
  elseif currency == "GBP" then
    return "£" .. formatted
  else
    return formatted .. " " .. currency
  end
end

-- Format date
local function fmt_date(date_val, fmt)
  fmt = fmt or "%Y-%m-%d"

  if type(date_val) == "number" then
    return os.date(fmt, date_val)
  elseif type(date_val) == "string" then
    return date_val -- already formatted
  else
    return ""
  end
end

-- Sum a field in a table array
local function table_sum(list, key)
  if type(list) ~= "table" then return 0 end

  local sum = 0
  for _, item in ipairs(list) do
    if type(item) == "table" and item[key] then
      sum = sum + (tonumber(item[key]) or 0)
    end
  end
  return sum
end

function M.render(profile, data)
  -- Create helpers table
  local helpers = {
    esc = esc,
    fmt_currency = fmt_currency,
    fmt_date = fmt_date,
    table_sum = table_sum,
  }

  -- Get currency from profile locale if available
  if profile.locale and profile.locale.currency then
    local currency = profile.locale.currency
    helpers.fmt_currency = function(amount)
      return fmt_currency(amount, currency)
    end
  end

  -- Call profile's render function
  local ok, html = pcall(profile.render, data, helpers)
  if not ok then
    return nil, "Render failed: " .. html
  end

  if type(html) ~= "string" then
    return nil, "Render must return a string"
  end

  return html
end

return M
