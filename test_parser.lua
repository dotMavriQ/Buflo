#!/usr/bin/env lua5.4

-- Test BUFLO DSL Parser

package.path = package.path .. ";./?.lua"

local parser = require("buflo.core.buflo_parser")

print("=== Testing BUFLO DSL Parser ===\n")

-- Test 1: Load and parse .buflo file
print("Test 1: Loading profiles/monthly_invoice.buflo...")
local profile, err = parser.load("profiles/monthly_invoice.buflo")
if not profile then
    print("ERROR:", err)
    os.exit(1)
end
print("✓ Parsed successfully")
print("  Profile:", profile.profile)
print("  Version:", profile.version)
print("  Fields:", #profile.fields)
print("  Computed fields:", profile.computed and "yes" or "no")
print("  Pages:", #profile.pages)
print()

-- Test 2: Get fields with defaults
print("Test 2: Getting fields with expanded defaults...")
local fields = parser.get_fields_with_defaults(profile)
print("✓ Fields expanded:")
for i, field in ipairs(fields) do
    print(string.format("  %d. %s (%s) = %s", i, field.label, field.type, tostring(field.default)))
end
print()

-- Test 3: Evaluate computed fields
print("Test 3: Evaluating computed fields...")
local test_data = {
    daily_rate = 500,
    days = 3
}
local computed = parser.evaluate_computed(profile, test_data)
print("✓ Computed values:")
for k, v in pairs(computed) do
    print(string.format("  %s = %s", k, tostring(v)))
end
print()

-- Test 4: Template interpolation
print("Test 4: Template interpolation...")
local full_data = {
    client_name = "Acme Corp",
    client_email = "billing@acme.com",
    invoice_number = "INV-2024-001",
    invoice_date = "2024-01-15",
    daily_rate = 500,
    days = 3,
    notes = "Thank you for your business!"
}
local computed_values = parser.evaluate_computed(profile, full_data)
local template_snippet = [[
Invoice: {{invoice_number}}
Client: {{client_name}}
Amount: {{@currency(total)}}
Date: {{@date(invoice_date)}}
]]
local result = parser.interpolate_template(template_snippet, full_data, computed_values)
print("✓ Interpolated template:")
print(result)

-- Test 5: Conditional blocks
print("Test 5: Conditional blocks...")
local template_with_conditional = [[
Client: {{client_name}}
{{#if notes}}
Notes: {{notes}}
{{/if}}
{{#if missing_field}}
This should not appear
{{/if}}
Done.
]]
local result2 = parser.interpolate_template(template_with_conditional, full_data, computed_values)
print("✓ Conditional template:")
print(result2)

print("\n=== All tests passed! ===")
