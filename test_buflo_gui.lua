#!/usr/bin/env lua

-- Test loading .buflo profile and form editor

package.path = package.path .. ";./?.lua"

local profile_loader = require("buflo.core.profile")
local log = require("buflo.util.log")

log.set_verbose(true)

print("=== Testing .buflo Profile Loading ===\n")

-- Test loading .buflo file
print("Loading profiles/monthly_invoice.buflo...")
local profile, err = profile_loader.load("profiles/monthly_invoice.buflo", log)

if not profile then
    print("ERROR:", err)
    os.exit(1)
end

print("✓ Profile loaded successfully")
print("  Name:", profile.profile)
print("  Version:", profile.version)
print("  Fields:", #profile.fields)
print()

-- Show field details
print("Fields:")
for i, field in ipairs(profile.fields) do
    print(string.format("  %d. %s (%s) - required=%s",
        i, field.label, field.type, tostring(field.required)))
end
print()

-- Test with GUI
print("Opening form editor GUI...")
local sdl_gui = require("buflo.gui_sdl.main")
local ok = sdl_gui.run(profile, "profiles/monthly_invoice.buflo")

if ok then
    print("✓ GUI completed successfully")
else
    print("✗ GUI exited with error")
end
