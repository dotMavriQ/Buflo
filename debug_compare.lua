-- Debug script to compare v2 vs TOML parsing
local parser_v2 = require("buflo.core.buflo_v2_parser")
local toml_parser = require("buflo.core.toml_parser")

-- Read both files
local v2_content = love.filesystem.read("profiles/nordhealth_mardev.buflo")
local toml_content = love.filesystem.read("profiles/nordhealth_mardev_v3.toml")

-- Parse both
local v2_data = parser_v2.parse(v2_content)
local toml_data = toml_parser.parse(toml_content)

-- Helper to print table structure
local function print_structure(data, prefix)
    prefix = prefix or ""
    if type(data) ~= "table" then
        print(prefix .. tostring(data))
        return
    end

    for k, v in pairs(data) do
        if type(v) == "table" then
            print(prefix .. k .. " = {")
            print_structure(v, prefix .. "  ")
            print(prefix .. "}")
        else
            print(prefix .. k .. " = " .. tostring(v))
        end
    end
end

print("========== V2 STRUCTURE ==========")
if v2_data and v2_data.pages and v2_data.pages[1] and v2_data.pages[1].sections then
    for i, section in ipairs(v2_data.pages[1].sections) do
        print("\nSection " .. i .. ":")
        print_structure(section, "  ")
    end
end

print("\n\n========== TOML STRUCTURE ==========")
if toml_data and toml_data.pages and toml_data.pages[1] and toml_data.pages[1].sections then
    for i, section in ipairs(toml_data.pages[1].sections) do
        print("\nSection " .. i .. ":")
        print_structure(section, "  ")
    end
end
