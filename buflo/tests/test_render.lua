-- buflo/tests/test_render.lua
-- Unit tests for rendering module

local render = require("buflo.core.render")

local function test_basic_render()
  local profile = {
    render = function(data, helpers)
      return "<html><body>" .. helpers.esc(data.name) .. "</body></html>"
    end
  }

  local data = {name = "Test"}
  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed: " .. (err or ""))
  assert(html:match("Test"), "Data not interpolated")

  print("✓ Basic render")
end

local function test_html_escape()
  local profile = {
    render = function(data, helpers)
      return helpers.esc(data.unsafe)
    end
  }

  local data = {unsafe = "<script>alert('xss')</script>"}
  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed")
  assert(not html:match("<script>"), "HTML not escaped")
  assert(html:match("&lt;script&gt;"), "HTML escape incorrect")

  print("✓ HTML escaping")
end

local function test_currency_formatting()
  local profile = {
    render = function(data, helpers)
      return helpers.fmt_currency(data.amount)
    end
  }

  local data = {amount = 1234.5}
  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed")
  assert(html:match("1234%.50"), "Currency formatting incorrect")

  print("✓ Currency formatting")
end

local function test_date_formatting()
  local profile = {
    render = function(data, helpers)
      return helpers.fmt_date(data.date, "%Y-%m-%d")
    end
  }

  local data = {date = "2025-11-09"}
  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed")
  assert(html:match("2025%-11%-09"), "Date formatting failed")

  print("✓ Date formatting")
end

local function test_table_sum()
  local profile = {
    render = function(data, helpers)
      local sum = helpers.table_sum(data.items, "amount")
      return tostring(sum)
    end
  }

  local data = {
    items = {
      {amount = 10},
      {amount = 20},
      {amount = 30},
    }
  }

  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed")
  assert(html == "60", "Table sum incorrect: " .. (html or "nil"))

  print("✓ Table sum")
end

local function test_locale_currency()
  local profile = {
    locale = {currency = "USD"},
    render = function(data, helpers)
      return helpers.fmt_currency(100)
    end
  }

  local html, err = render.render(profile, data)

  assert(html ~= nil, "Render failed")
  assert(html:match("%$100%.00"), "Locale currency failed")

  print("✓ Locale currency")
end

-- Run all tests
local function run_tests()
  print("Running render tests...")
  test_basic_render()
  test_html_escape()
  test_currency_formatting()
  test_date_formatting()
  test_table_sum()
  test_locale_currency()
  print("All render tests passed!")
end

run_tests()
