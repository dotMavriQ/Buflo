-- buflo/core/interpolate.lua
-- Pattern interpolation: "out/{{key}}.pdf" with data table

local M = {}

function M.interpolate(pattern, data)
  if not pattern then return nil end
  if not data then return pattern end

  local result = pattern:gsub("{{([^}]+)}}", function(key)
    -- Support nested keys like {{client.name}}
    local value = data
    for part in key:gmatch("[^.]+") do
      part = part:match("^%s*(.-)%s*$") -- trim whitespace
      if type(value) == "table" then
        value = value[part]
      else
        value = nil
        break
      end
    end

    if value == nil then
      return "__MISSING_" .. key .. "__"
    end

    return tostring(value)
  end)

  return result
end

function M.has_missing(str)
  return str and str:match("__MISSING_") ~= nil
end

return M
