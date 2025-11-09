-- buflo/core/profile.lua
-- Load, sandbox, and validate BPL profiles

local M = {}

-- Sandboxed environment for profile loading
local function create_sandbox()
  local env = {
    -- Safe standard libraries
    math = math,
    string = string,
    table = table,
    tostring = tostring,
    tonumber = tonumber,
    type = type,
    pairs = pairs,
    ipairs = ipairs,
    next = next,
    select = select,
    unpack = unpack or table.unpack,

    -- Safe os functions
    os = {
      date = os.date,
      time = os.time,
      clock = os.clock,
      difftime = os.difftime,
    },

    -- No io, no loadfile, no dofile, no require with arbitrary paths
  }
  env._G = env
  return env
end

function M.load(path, log)
  local fs = require("buflo.util.fs")

  if not fs.exists(path) then
    return nil, "Profile not found: " .. path
  end

  -- Check if it's a .buflo file (new DSL format) or .bpl.lua (old Lua format)
  if path:match("%.buflo$") then
    -- Use new .buflo parser
    local buflo_parser = require("buflo.core.buflo_parser")
    local profile, err = buflo_parser.load(path)
    if not profile then
      return nil, err
    end

    -- Validate the profile structure (simplified validation for .buflo)
    local val_err = M.validate_buflo_schema(profile)
    if val_err then
      return nil, val_err
    end

    -- Store profile path for relative file resolution
    profile._path = path
    profile._dir = fs.dirname(path) or "./"

    if log then
      log.info("Loaded .buflo profile: " .. (profile.profile or "unnamed"))
    end

    return profile
  end  -- Otherwise, use old .bpl.lua format (Lua sandbox)
  local content, err = fs.slurp(path)
  if not content then
    return nil, "Failed to read profile: " .. err
  end

  -- Load the profile in a sandbox
  local chunk, load_err = load(content, "@" .. path, "t", create_sandbox())
  if not chunk then
    return nil, "Failed to parse profile: " .. load_err
  end

  local ok, result = pcall(chunk)
  if not ok then
    return nil, "Failed to execute profile: " .. result
  end

  if type(result) ~= "table" then
    return nil, "Profile must return a table"
  end

  -- Validate required fields
  local validation_err = M.validate_schema(result)
  if validation_err then
    return nil, validation_err
  end

  -- Store profile path for relative file resolution
  result._path = path
  result._dir = fs.dirname(path) or "./"

  if log then
    log.info("Loaded profile: " .. (result.name or "unnamed"))
  end

  return result
end

function M.validate_schema(profile)
  -- Required fields
  if not profile.name or type(profile.name) ~= "string" then
    return "Profile missing required field: name (string)"
  end

  if not profile.version or type(profile.version) ~= "string" then
    return "Profile missing required field: version (string)"
  end

  if not profile.output_pattern or type(profile.output_pattern) ~= "string" then
    return "Profile missing required field: output_pattern (string)"
  end

  if not profile.fields or type(profile.fields) ~= "table" then
    return "Profile missing required field: fields (array)"
  end

  if not profile.render or type(profile.render) ~= "function" then
    return "Profile missing required field: render (function)"
  end

  -- Validate fields array
  for i, field in ipairs(profile.fields) do
    if type(field) ~= "table" then
      return "Field " .. i .. " must be a table"
    end
    if not field.key or type(field.key) ~= "string" then
      return "Field " .. i .. " missing 'key' (string)"
    end
    if not field.label or type(field.label) ~= "string" then
      return "Field " .. i .. " missing 'label' (string)"
    end
    if not field.type or type(field.type) ~= "string" then
      return "Field " .. i .. " missing 'type' (string)"
    end

    local valid_types = {text=1, number=1, date=1, multiline=1, enum=1, file=1, checkbox=1}
    if not valid_types[field.type] then
      return "Field " .. field.key .. " has invalid type: " .. field.type
    end
  end

  return nil
end

function M.get_defaults(profile)
  local defaults = {}

  for _, field in ipairs(profile.fields) do
    if field.default ~= nil then
      if type(field.default) == "function" then
        -- Call default function in sandbox
        local ok, value = pcall(field.default)
        if ok then
          defaults[field.key] = value
        end
      else
        defaults[field.key] = field.default
      end
    end
  end

  return defaults
end

-- Validation for .buflo format profiles
function M.validate_buflo_schema(profile)
  -- Required top-level fields
  if not profile.profile or type(profile.profile) ~= "string" then
    return "Profile missing required field: profile (string)"
  end

  if not profile.version or type(profile.version) ~= "string" then
    return "Profile missing required field: version (string)"
  end

  if not profile.fields or type(profile.fields) ~= "table" then
    return "Profile missing required field: fields (array)"
  end

  if not profile.pages or type(profile.pages) ~= "table" then
    return "Profile missing required field: pages (array)"
  end

  -- Validate fields array
  for i, field in ipairs(profile.fields) do
    if type(field) ~= "table" then
      return "Field " .. i .. " must be a table"
    end
    if not field.key or type(field.key) ~= "string" then
      return "Field " .. i .. " missing 'key' (string)"
    end
    if not field.label or type(field.label) ~= "string" then
      return "Field " .. i .. " missing 'label' (string)"
    end
    if not field.type or type(field.type) ~= "string" then
      return "Field " .. i .. " missing 'type' (string)"
    end

    local valid_types = {text=1, number=1, date=1, email=1, multiline=1, enum=1, file=1, checkbox=1}
    if not valid_types[field.type] then
      return "Field " .. field.key .. " has invalid type: " .. field.type
    end
  end

  -- Validate pages array
  for i, page in ipairs(profile.pages) do
    if type(page) ~= "table" then
      return "Page " .. i .. " must be a table"
    end
    if not page.template or type(page.template) ~= "string" then
      return "Page " .. i .. " missing 'template' (string)"
    end
  end

  return nil  -- No errors
end

function M.validate_data(profile, data)
  -- Run profile's custom validation if present
  if profile.validate then
    local ok, result, msg = pcall(profile.validate, data)
    if not ok then
      return false, "Validation error: " .. result
    end
    if result == false then
      return false, msg or "Validation failed"
    end
  end

  -- Check required fields
  for _, field in ipairs(profile.fields) do
    if field.required then
      local value = data[field.key]
      if value == nil or value == "" then
        return false, "Required field missing: " .. field.label
      end
    end
  end

  return true
end

return M
