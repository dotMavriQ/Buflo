-- buflo/tests/test_interpolate.lua
-- Unit tests for interpolation module

local interpolate = require("buflo.core.interpolate")

local function test_basic_interpolation()
  local pattern = "out/{{invoice_number}}.pdf"
  local data = {invoice_number = "2025-001"}
  local result = interpolate.interpolate(pattern, data)

  assert(result == "out/2025-001.pdf", "Basic interpolation failed")
  print("✓ Basic interpolation")
end

local function test_nested_interpolation()
  local pattern = "{{client.name}}_{{year}}.pdf"
  local data = {
    client = {name = "ACME"},
    year = 2025
  }
  local result = interpolate.interpolate(pattern, data)

  assert(result == "ACME_2025.pdf", "Nested interpolation failed")
  print("✓ Nested interpolation")
end

local function test_missing_key()
  local pattern = "{{missing_key}}.pdf"
  local data = {}
  local result = interpolate.interpolate(pattern, data)

  assert(result:match("__MISSING_"), "Missing key not detected")
  assert(interpolate.has_missing(result), "has_missing failed")
  print("✓ Missing key detection")
end

local function test_multiple_placeholders()
  local pattern = "{{year}}/{{month}}/invoice_{{number}}.pdf"
  local data = {year = 2025, month = "11", number = "001"}
  local result = interpolate.interpolate(pattern, data)

  assert(result == "2025/11/invoice_001.pdf", "Multiple placeholders failed")
  print("✓ Multiple placeholders")
end

-- Run all tests
local function run_tests()
  print("Running interpolation tests...")
  test_basic_interpolation()
  test_nested_interpolation()
  test_missing_key()
  test_multiple_placeholders()
  print("All interpolation tests passed!")
end

run_tests()
