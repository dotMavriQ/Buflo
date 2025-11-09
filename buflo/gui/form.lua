-- buflo/gui/form.lua
-- Dynamic form builder from profile.fields

local iup = require("iuplua")
local M = {}

function M.create_field_widget(field, current_value)
  local widget
  local value = current_value or ""

  if field.type == "text" then
    widget = iup.text{
      value = value,
      expand = "HORIZONTAL",
      tip = field.help or field.placeholder,
    }

  elseif field.type == "number" then
    widget = iup.text{
      value = tostring(value),
      expand = "HORIZONTAL",
      mask = "/d*",
      tip = field.help,
    }

  elseif field.type == "date" then
    widget = iup.text{
      value = value,
      expand = "HORIZONTAL",
      mask = "/d/d/d/d-/d/d-/d/d",
      tip = field.help or "YYYY-MM-DD",
    }

  elseif field.type == "multiline" then
    widget = iup.multiline{
      value = value,
      expand = "HORIZONTAL",
      visiblelines = 4,
      tip = field.help,
    }

  elseif field.type == "enum" then
    local items = {}
    if field.enum then
      for i, opt in ipairs(field.enum) do
        if type(opt) == "string" then
          items[i] = opt
        elseif type(opt) == "table" and opt.label then
          items[i] = opt.label
        end
      end
    end

    widget = iup.list{
      dropdown = "YES",
      expand = "HORIZONTAL",
      value = 1,
      tip = field.help,
    }
    for i, item in ipairs(items) do
      widget[tostring(i)] = item
    end

  elseif field.type == "file" then
    local text = iup.text{
      value = value,
      expand = "HORIZONTAL",
      readonly = "YES",
    }

    local button = iup.button{
      title = "Browse...",
      size = "60x",
    }

    button.action = function()
      local dlg = iup.filedlg{
        dialogtype = field.mode == "save" and "SAVE" or "OPEN",
        title = "Select " .. field.label,
        filter = field.filter or "*.*",
        filterinfo = "All files",
      }
      dlg:popup(iup.CENTER, iup.CENTER)

      if dlg.status ~= "-1" then
        text.value = dlg.value
      end
      dlg:destroy()
    end

    widget = iup.hbox{
      text,
      button,
      gap = 5,
    }
    widget.get_value = function() return text.value end
    widget.set_value = function(v) text.value = v end

  elseif field.type == "checkbox" then
    widget = iup.toggle{
      title = "",
      value = (value == "1" or value == true or value == "true") and "ON" or "OFF",
      tip = field.help,
    }

  else
    widget = iup.text{
      value = value,
      expand = "HORIZONTAL",
    }
  end

  return widget
end

function M.build_form(profile, initial_data)
  local fields = profile.fields
  local widgets = {}
  local form_items = {}

  for _, field in ipairs(fields) do
    local label = iup.label{
      title = field.label .. (field.required and " *" or "") .. ":",
      size = "120x",
    }

    local initial = initial_data and initial_data[field.key] or
                    (field.default and
                     (type(field.default) == "function" and field.default() or field.default))

    local widget = M.create_field_widget(field, initial)
    widgets[field.key] = {widget = widget, field = field}

    table.insert(form_items, iup.hbox{
      label,
      widget,
      gap = 10,
      alignment = "ACENTER",
    })
  end

  local form = iup.vbox{
    unpack(form_items),
    gap = 8,
    margin = "10x10",
  }

  return form, widgets
end

function M.get_form_data(widgets)
  local data = {}

  for key, entry in pairs(widgets) do
    local widget = entry.widget
    local field = entry.field
    local value

    if widget.get_value then
      value = widget.get_value()
    elseif field.type == "checkbox" then
      value = widget.value == "ON"
    else
      value = widget.value
    end

    -- Type conversion
    if field.type == "number" then
      value = tonumber(value) or value
    elseif field.type == "checkbox" then
      -- already boolean
    elseif field.type == "enum" and field.enum then
      -- Get actual value from enum
      local idx = tonumber(widget.value)
      if idx and field.enum[idx] then
        local opt = field.enum[idx]
        if type(opt) == "table" and opt.value then
          value = opt.value
        else
          value = opt
        end
      end
    end

    data[key] = value
  end

  return data
end

function M.set_form_data(widgets, data)
  for key, entry in pairs(widgets) do
    local widget = entry.widget
    local field = entry.field
    local value = data[key]

    if value ~= nil then
      if widget.set_value then
        widget.set_value(value)
      elseif field.type == "checkbox" then
        widget.value = (value == true or value == "1" or value == "true") and "ON" or "OFF"
      else
        widget.value = tostring(value)
      end
    end
  end
end

return M
