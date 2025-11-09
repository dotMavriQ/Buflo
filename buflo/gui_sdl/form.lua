-- buflo/gui_sdl/form.lua
-- Dynamic form builder for SDL2

local M = {}
local widgets = require("buflo.gui_sdl.widgets")

function M.build_form(profile, initial_data, x, y, width, font, ttf, renderer)
  local form = {
    fields = {},
    widgets = {},
    y_offset = y,
    x = x,
    width = width,
    font = font,
  }

  -- Create widgets for each field
  for _, field in ipairs(profile.fields) do
    local label = widgets.Label(field.label .. (field.required and " *" or "") .. ":",
                                x, form.y_offset, font)
    table.insert(form.widgets, label)

    form.y_offset = form.y_offset + 25

    local widget
    local initial = initial_data and initial_data[field.key] or
                   (field.default and
                    (type(field.default) == "function" and field.default() or field.default))

    if field.type == "multiline" then
      widget = widgets.TextArea(x, form.y_offset, width - 20, 80, font)
      if initial then widget:setText(tostring(initial)) end
      form.y_offset = form.y_offset + 85
    else
      widget = widgets.TextInput(x, form.y_offset, width - 20, 30, font)
      if initial then widget.text = tostring(initial) end
      if field.placeholder then widget.placeholder = field.placeholder end
      form.y_offset = form.y_offset + 35
    end

    form.fields[field.key] = {
      widget = widget,
      field = field,
    }
    table.insert(form.widgets, widget)

    form.y_offset = form.y_offset + 5
  end

  function form:render(renderer, ttf)
    for _, widget in ipairs(self.widgets) do
      widget:render(renderer, ttf)
    end
  end

  function form:get_data()
    local data = {}
    for key, entry in pairs(self.fields) do
      local widget = entry.widget
      local field = entry.field

      local value
      if widget.getText then
        value = widget:getText()
      else
        value = widget.text
      end

      -- Type conversion
      if field.type == "number" and value ~= "" then
        value = tonumber(value) or value
      elseif field.type == "checkbox" then
        value = widget.checked or false
      end

      data[key] = value
    end
    return data
  end

  function form:handle_click(x, y)
    -- Update focus
    for _, entry in pairs(self.fields) do
      local widget = entry.widget
      if widget.containsPoint and widget:containsPoint(x, y) then
        -- Set this as focused
        for _, other in pairs(self.fields) do
          other.widget.focused = false
        end
        widget.focused = true
        return true
      end
    end
    return false
  end

  function form:handle_text_input(text)
    for _, entry in pairs(self.fields) do
      if entry.widget.handleTextInput and entry.widget:handleTextInput(text) then
        return true
      end
    end
    return false
  end

  function form:handle_key_down(key)
    for _, entry in pairs(self.fields) do
      if entry.widget.handleKeyDown and entry.widget:handleKeyDown(key) then
        return true
      end
    end
    return false
  end

  function form:focus_next_field()
    -- Find currently focused field
    local current_idx = nil
    for i, widget in ipairs(self.widgets) do
      if widget.focused then
        current_idx = i
        widget.focused = false
        break
      end
    end

    -- Focus next input field (skip labels)
    local start = current_idx or 0
    for i = start + 1, #self.widgets do
      local widget = self.widgets[i]
      if widget.handleTextInput then  -- It's an input field
        widget.focused = true
        return true
      end
    end

    -- Wrap around to first input field
    for i = 1, start do
      local widget = self.widgets[i]
      if widget.handleTextInput then
        widget.focused = true
        return true
      end
    end

    return false
  end

  return form
end

return M
