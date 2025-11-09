#!/usr/bin/env lua

-- Test profile editor

package.path = package.path .. ";./?.lua"

local editor = require("buflo.gui_sdl.profile_editor")

print("=== Testing Profile Editor ===\n")
print("Opening existing profile: profiles/monthly_invoice.buflo")

local result, modified = editor.run("profiles/monthly_invoice.buflo", "monthly_invoice.buflo")

print("\nEditor closed:")
print("  Result:", result)
print("  Modified:", modified)
