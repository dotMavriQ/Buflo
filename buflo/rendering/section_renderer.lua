-- buflo/rendering/section_renderer.lua
-- Renders sections according to DSL layout specifications

local table_renderer = require("buflo.rendering.table_renderer")

local M = {}

-- Render a heading
local function render_heading(heading, level)
  level = level or 3
  local style = ""
  if heading.style and heading.style:match("bold") then
    style = style .. "font-weight: bold; "
  end
  if heading.size then
    style = style .. "font-size: " .. heading.size .. "pt; "
  end
  if heading.color then
    style = style .. "color: " .. heading.color .. "; "
  end

  return string.format('<h%d style="%s">%s</h%d>', level, style, heading.text or "", level)
end

-- Render a single field value
local function render_field_value(field, value)
  local is_empty = value == "" or value == nil
  local display_value = is_empty and "<em>(Not filled)</em>" or value

  -- Apply field-specific formatting
  if not is_empty then
    if field.type == "email" then
      display_value = string.format('<a href="mailto:%s">%s</a>', value, value)
    elseif field.type == "tel" then
      display_value = string.format('<a href="tel:%s">%s</a>', value, value)
    elseif field.type == "number" or field.type == "currency" then
      -- Format numbers with thousand separators
      display_value = string.format("%.2f", tonumber(value) or 0):gsub("(%d)(%d%d%d)$", "%1,%2")
    end
  end

  return display_value
end

-- Render fields in a vertical group
function M.render_group(section, field_values)
  local html = '<div class="section-group">'

  if section.heading then
    html = html .. render_heading(section.heading)
  end

  if section.fields then
    for _, field in ipairs(section.fields) do
      if field.id and field.type ~= "spacer" then
        local label = field.label or field.id
        -- Remove trailing colon if it exists, we'll add it in formatting
        label = label:gsub(":+%s*$", "")
        local value = field_values[field.id] or ""
        local display_value = render_field_value(field, value)

        html = html .. string.format([[
          <div class="field-row">
            <span class="field-label">%s:</span>
            <span class="field-value">%s</span>
          </div>
        ]], label, display_value)
      end
    end
  end

  html = html .. '</div>'
  return html
end

-- Render fields in a horizontal layout
function M.render_horizontal_fields(section, field_values)
  local html = '<div class="horizontal-fields">'

  if section.fields then
    for _, field in ipairs(section.fields) do
      if field.id and field.type ~= "spacer" then
        local label = field.label or field.id
        -- Remove trailing colon if it exists
        label = label:gsub(":+%s*$", "")
        local value = field_values[field.id] or ""
        local display_value = render_field_value(field, value)

        html = html .. string.format([[
          <div class="field-inline">
            <span class="field-label">%s:</span>
            <span class="field-value">%s</span>
          </div>
        ]], label, display_value)
      end
    end
  end

  html = html .. '</div>'
  return html
end

-- Render a two-column layout
function M.render_columns(section, field_values)
  local html = '<div class="columns-layout">'

  -- Left column
  if section.left then
    html = html .. '<div class="column-left">'

    if section.left.heading then
      html = html .. render_heading(section.left.heading)
    end

    if section.left.fields then
      for _, field in ipairs(section.left.fields) do
        if field.id and field.type ~= "spacer" then
          local label = field.label or field.id
          -- Remove trailing colon if it exists
          label = label:gsub(":+%s*$", "")
          local value = field_values[field.id] or ""
          local display_value = render_field_value(field, value)

          html = html .. string.format([[
            <div class="field-row">
              <span class="field-label">%s:</span>
              <span class="field-value">%s</span>
            </div>
          ]], label, display_value)
        end
      end
    end

    html = html .. '</div>'
  end

  -- Right column
  if section.right then
    html = html .. '<div class="column-right">'

    -- Check if right column has a logo
    if section.right.logo then
      local logo = section.right.logo
      local logo_value = field_values[logo.id] or logo.default or ""
      if logo_value ~= "" then
        html = html .. string.format([[
          <div class="logo-container">
            <img src="%s" alt="Logo" class="invoice-logo">
          </div>
        ]], logo_value)
      end
    end

    if section.right.heading then
      html = html .. render_heading(section.right.heading)
    end

    if section.right.fields then
      for _, field in ipairs(section.right.fields) do
        if field.id and field.type ~= "spacer" then
          local label = field.label or field.id
          -- Remove trailing colon if it exists
          label = label:gsub(":+%s*$", "")
          local value = field_values[field.id] or ""
          local display_value = render_field_value(field, value)

          html = html .. string.format([[
            <div class="field-row">
              <span class="field-label">%s:</span>
              <span class="field-value">%s</span>
            </div>
          ]], label, display_value)
        end
      end
    end

    html = html .. '</div>'
  end

  html = html .. '</div>'
  return html
end

-- Render a spacer
function M.render_spacer(section)
  local height = section.height or 20
  return string.format('<div class="spacer" style="height: %dpx;"></div>', height)
end

-- Render a table section (placeholder for now)
function M.render_table(section, field_values)
  return table_renderer.render_table(section, field_values)
end

-- Main section dispatcher
function M.render_section(section, field_values)
  if not section then return "" end

  local section_type = section.type or "group"

  if section_type == "columns" then
    return M.render_columns(section, field_values)
  elseif section_type == "horizontal_fields" then
    return M.render_horizontal_fields(section, field_values)
  elseif section_type == "group" then
    return M.render_group(section, field_values)
  elseif section_type == "spacer" then
    return M.render_spacer(section)
  elseif section_type == "table" then
    return M.render_table(section, field_values)
  else
    -- Fallback to group rendering
    return M.render_group(section, field_values)
  end
end

return M
