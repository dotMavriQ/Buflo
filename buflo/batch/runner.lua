-- buflo/batch/runner.lua
-- Batch processing: load data from JSON/CSV and generate multiple PDFs

local M = {}

local fs = require("buflo.util.fs")
local pdf = require("buflo.core.pdf")
local log = require("buflo.util.log")

-- Simple JSON array parser (no dependencies)
local function parse_json_array(content)
  local items = {}

  -- Remove outer brackets and whitespace
  content = content:match("^%s*%[(.*)%]%s*$")
  if not content then
    return nil, "Invalid JSON: not an array"
  end

  -- Split by objects
  local depth = 0
  local current = ""
  local in_string = false
  local escape = false

  for i = 1, #content do
    local char = content:sub(i, i)

    if escape then
      current = current .. char
      escape = false
    elseif char == "\\" then
      current = current .. char
      escape = true
    elseif char == '"' then
      current = current .. char
      in_string = not in_string
    elseif not in_string then
      if char == "{" then
        depth = depth + 1
        current = current .. char
      elseif char == "}" then
        current = current .. char
        depth = depth - 1

        if depth == 0 then
          -- Parse this object
          local obj = {}
          for key, value in current:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
            obj[key] = value
          end
          for key, value in current:gmatch('"([^"]+)"%s*:%s*(%d+%.?%d*)') do
            obj[key] = tonumber(value)
          end
          for key, value in current:gmatch('"([^"]+)"%s*:%s*(true)') do
            obj[key] = true
          end
          for key, value in current:gmatch('"([^"]+)"%s*:%s*(false)') do
            obj[key] = false
          end

          table.insert(items, obj)
          current = ""
        end
      elseif char:match("%S") then
        current = current .. char
      end
    else
      current = current .. char
    end
  end

  return items
end

-- Simple CSV parser
local function parse_csv(content)
  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  if #lines == 0 then
    return nil, "Empty CSV"
  end

  -- Parse header
  local headers = {}
  for field in lines[1]:gmatch('([^,]+)') do
    field = field:match("^%s*(.-)%s*$") -- trim
    field = field:gsub('^"(.*)"$', '%1') -- remove quotes
    table.insert(headers, field)
  end

  -- Parse rows
  local items = {}
  for i = 2, #lines do
    local row = {}
    local field_idx = 1

    for field in lines[i]:gmatch('([^,]+)') do
      field = field:match("^%s*(.-)%s*$") -- trim
      field = field:gsub('^"(.*)"$', '%1') -- remove quotes

      local key = headers[field_idx]
      if key then
        -- Try to convert to number
        local num = tonumber(field)
        row[key] = num or field
      end

      field_idx = field_idx + 1
    end

    table.insert(items, row)
  end

  return items
end

function M.load_data(source_path)
  if not fs.exists(source_path) then
    return nil, "Data file not found: " .. source_path
  end

  local content, err = fs.slurp(source_path)
  if not content then
    return nil, "Failed to read data file: " .. err
  end

  -- Detect format
  local ext = source_path:match("%.([^.]+)$")

  if ext == "json" then
    return parse_json_array(content)
  elseif ext == "csv" then
    return parse_csv(content)
  else
    return nil, "Unsupported data format: " .. (ext or "unknown")
  end
end

function M.run(profile, options)
  options = options or {}

  -- Determine data source
  local source = options.data_file or
                 (profile.batch and profile.batch.source) or
                 "data/batch.json"

  log.info("Loading batch data from: " .. source)

  local items, err = M.load_data(source)
  if not items then
    log.error(err)
    return false, err
  end

  log.info("Loaded " .. #items .. " items")

  -- Process each item
  local results = {
    total = #items,
    success = 0,
    failed = 0,
    errors = {}
  }

  for i, row in ipairs(items) do
    log.info(string.format("Processing item %d/%d", i, #items))

    -- Apply batch mapping if defined
    local data = row
    if profile.batch and profile.batch.map then
      local ok, mapped = pcall(profile.batch.map, row)
      if ok then
        data = mapped
      else
        log.warn("Batch map function failed for item " .. i .. ": " .. mapped)
      end
    end

    -- Validate
    local profile_mod = require("buflo.core.profile")
    local valid, valid_err = profile_mod.validate_data(profile, data)
    if not valid then
      results.failed = results.failed + 1
      table.insert(results.errors, {
        item = i,
        error = "Validation failed: " .. valid_err
      })
      log.error("Item " .. i .. " validation failed: " .. valid_err)
      goto continue
    end

    -- Generate PDF
    if not options.dry_run then
      local output_path, pdf_err = pdf.generate_pdf(profile, data, log)

      if not output_path then
        results.failed = results.failed + 1
        table.insert(results.errors, {
          item = i,
          error = pdf_err
        })
        log.error("Item " .. i .. " failed: " .. pdf_err)
      else
        results.success = results.success + 1
        log.info("Generated: " .. output_path)
      end
    else
      results.success = results.success + 1
      log.info("Dry run: would generate PDF for item " .. i)
    end

    ::continue::
  end

  -- Summary
  log.info("=" .. string.rep("=", 50))
  log.info("Batch processing complete")
  log.info(string.format("Total: %d | Success: %d | Failed: %d",
    results.total, results.success, results.failed))

  if #results.errors > 0 then
    log.info("Errors:")
    for _, err_info in ipairs(results.errors) do
      log.info(string.format("  Item %d: %s", err_info.item, err_info.error))
    end
  end

  return results.failed == 0, results
end

return M
