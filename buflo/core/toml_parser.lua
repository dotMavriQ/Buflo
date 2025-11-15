-- buflo/core/toml_parser.lua
-- Lightweight TOML parser for BUFLO v3
-- Parses BUFLO-specific TOML format into internal structure

local M = {}

-- Parse TOML value based on type
local function parse_value(str)
  str = str:match("^%s*(.-)%s*$")  -- trim whitespace

  if str == "true" then
    return true
  elseif str == "false" then
    return false
  elseif str:match('^".*"$') then
    -- String with quotes
    return str:sub(2, -2):gsub('\\"', '"')
  elseif str:match("^%d+%.%d+$") then
    -- Float
    return tonumber(str)
  elseif str:match("^%d+$") then
    -- Integer
    return tonumber(str)
  else
    -- Unquoted string
    return str
  end
end

-- Parse a TOML file into BUFLO structure
function M.parse(content)
  local result = {
    document = {},
    settings = {},
    pages = {{
      name = "main",
      sections = {}
    }}
  }

  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local current_section = nil
  local current_field = nil
  local current_column = nil
  local current_validation = nil
  local in_summary = false
  local in_defaults = false
  local sections = result.pages[1].sections

  for i, line in ipairs(lines) do
    -- Skip comments and empty lines
    if line:match("^%s*#") or line:match("^%s*$") then
      goto continue
    end

    -- Section headers
    if line:match("^%[document%]") then
      current_section = result.document
    elseif line:match("^%[settings%]") then
      current_section = result.settings
    elseif line:match("^%[%[section%]%]") then
      -- New section
      current_section = {
        type = "group",
        fields = {}
      }
      table.insert(sections, current_section)
      current_field = nil
      current_column = nil
      in_summary = false
      in_defaults = false
    elseif line:match("^%[%[section%.column%]%]") then
      -- New column - could be layout column or table column
      -- If section already has a columns array, it's a table
      if current_section and type(current_section.columns) == "table" and not current_section.left then
        -- Table column - columns is an array
        current_field = {}
        table.insert(current_section.columns, current_field)
      else
        -- Layout column - left/right structure
        if not current_section.left then
          current_section.type = "columns"
          current_section.columns = 2
          current_section.left = { fields = {} }
          current_section.right = nil
          current_column = current_section.left
        elseif not current_section.right then
          current_section.right = { fields = {} }
          current_column = current_section.right
        end
        current_field = nil
      end
    elseif line:match("^%[%[section%.column%.field%]%]") then
      -- New field in column
      current_field = {}
      table.insert(current_column.fields, current_field)
    elseif line:match("^%[%[section%.field%]%]") then
      -- New field in section
      current_field = {}
      table.insert(current_section.fields, current_field)
    elseif line:match("^%[section%.summary%]") then
      current_section.summary = {}
      in_summary = true
      in_defaults = false
      current_field = nil
    elseif line:match("^%[section%.defaults%]") then
      current_section.default_data = {}
      in_defaults = true
      in_summary = false
      current_field = nil
    elseif line:match("^%[%[validation%]%]") then
      current_validation = {}
      table.insert(result.validation or {}, current_validation)
      if not result.validation then
        result.validation = { rules = {} }
      end
      table.insert(result.validation.rules, current_validation)
    else
      -- Key-value pair
      local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
      if key and value then
        local parsed_value = parse_value(value)

        if in_summary then
          current_section.summary[key] = parsed_value
        elseif in_defaults then
          if not current_section.default_data[1] then
            current_section.default_data[1] = {}
          end
          current_section.default_data[1][key] = parsed_value
        elseif current_field then
          current_field[key] = parsed_value

          -- Handle special conversions
          if key == "formula" then
            current_field.calculated = true
          end

          -- For table columns, also handle width conversion
          if key == "width" and type(parsed_value) == "number" then
            current_field.width = tostring(parsed_value) .. "%"
          end

          -- If this is an image_upload field in a column, move it to logo key
          if key == "type" and parsed_value == "image_upload" and current_column and not current_column.heading then
            -- Remove from fields array
            for i, f in ipairs(current_column.fields) do
              if f == current_field then
                table.remove(current_column.fields, i)
                break
              end
            end
            -- Put in logo key instead
            current_column.logo = current_field
          end
        elseif current_validation then
          current_validation[key] = parsed_value

          -- Convert rule to condition
          if key == "rule" then
            current_validation.condition = parsed_value
            current_validation.rule = nil
          end
        elseif current_column and key == "heading" then
          current_column.heading = {
            text = parsed_value,
            style = "bold",
            size = 14
          }
        elseif current_section then
          if key == "heading" then
            current_section.heading = {
              text = parsed_value,
              style = "bold"
            }
          elseif key == "type" then
            -- Map simplified types
            if parsed_value == "horizontal" then
              current_section.type = "horizontal_fields"
            elseif parsed_value == "columns" then
              current_section.type = "columns"
            elseif parsed_value == "table" then
              current_section.type = "table"
              current_section.columns = {}
            else
              current_section.type = parsed_value
            end
          else
            current_section[key] = parsed_value
          end
        end
      end
    end

    ::continue::
  end

  -- Post-process: convert column fields to columns array for tables
  for _, section in ipairs(sections) do
    if section.type == "table" and not section.columns then
      section.columns = {}
    end
  end

  -- If no validation rules, add empty validation
  if not result.validation then
    result.validation = { rules = {} }
  end

  return result
end

-- Get all fields from parsed TOML (compatible with v2)
function M.get_all_fields(data)
  local fields = {}

  if data.pages then
    for _, page in ipairs(data.pages) do
      if page.sections then
        for _, section in ipairs(page.sections) do
          -- Handle different section types
          if section.type == "columns" then
            if section.left and section.left.fields then
              for _, field in ipairs(section.left.fields) do
                table.insert(fields, field)
              end
            end
            if section.right and section.right.fields then
              for _, field in ipairs(section.right.fields) do
                table.insert(fields, field)
              end
            end
            -- Handle logo
            if section.right and section.right.logo then
              table.insert(fields, section.right.logo)
            end
          elseif section.type == "horizontal_fields" then
            if section.fields then
              for _, field in ipairs(section.fields) do
                table.insert(fields, field)
              end
            end
          elseif section.type == "table" then
            table.insert(fields, section)
          elseif section.fields then
            for _, field in ipairs(section.fields) do
              table.insert(fields, field)
            end
          end
        end
      end
    end
  end

  return fields
end

return M
