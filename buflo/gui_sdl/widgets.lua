-- buflo/gui_sdl/widgets.lua
-- Basic SDL2 widgets for form building

local M = {}

-- Widget base class
function M.Widget(x, y, w, h)
  return {
    x = x,
    y = y,
    width = w,
    height = h,
    visible = true,
    enabled = true,
    focused = false,
  }
end

-- Label widget
function M.Label(text, x, y, font)
  local self = M.Widget(x, y, 0, 0)
  self.text = text
  self.font = font
  self.color = {r=0, g=0, b=0, a=255}

  function self:render(renderer, ttf)
    if not self.visible then return end

    local surface = self.font:renderUtf8(self.text, "blended", self.color)
    if surface then
      local w, h = surface:getSize()
      self.width = w
      self.height = h
      local texture = renderer:createTextureFromSurface(surface)
      if texture then
        local draw_x = math.floor(self.x)
        local draw_y = math.floor(self.y)
        renderer:copy(texture, nil, {x=draw_x, y=draw_y, w=w, h=h})
      end
    end
  end

  return self
end

-- Text input widget
function M.TextInput(x, y, w, h, font)
  local self = M.Widget(x, y, w, h)
  self.text = ""
  self.font = font
  self.placeholder = ""
  self.cursor_pos = 0

  function self:render(renderer, ttf)
    if not self.visible then return end

    -- Draw background
    local bg_color = self.focused and {r=255, g=255, b=200, a=255} or {r=255, g=255, b=255, a=255}
    renderer:setDrawColor(bg_color)
    renderer:fillRect({x=self.x, y=self.y, w=self.width, h=self.height})

    -- Draw border
    local border_color = self.focused and {r=0, g=120, b=215, a=255} or {r=150, g=150, b=150, a=255}
    renderer:setDrawColor(border_color)
    renderer:drawRect({x=self.x, y=self.y, w=self.width, h=self.height})

    -- Draw text
    local display_text = self.text ~= "" and self.text or self.placeholder
    if display_text ~= "" then
      local text_color = self.text ~= "" and {r=0, g=0, b=0, a=255} or {r=150, g=150, b=150, a=255}
      local surface = self.font:renderUtf8(display_text, "blended", text_color)
      if surface then
        local texture = renderer:createTextureFromSurface(surface)
        if texture then
          local tw, th = surface:getSize()
          local text_x = math.floor(self.x + 5)
          local text_y = math.floor(self.y + (self.height - th)/2)
          local text_rect = {x=text_x, y=text_y, w=math.min(tw, self.width - 10), h=th}
          -- Debug: print first time
          if not self._debug_printed and self.text ~= "" then
            print(string.format("TextInput at field (%d,%d) size (%d,%d), text '%s' at (%d,%d) size (%d,%d)",
              self.x, self.y, self.width, self.height, display_text:sub(1,20), text_x, text_y, tw, th))
            self._debug_printed = true
          end
          renderer:copy(texture, nil, text_rect)
        end
      end
    end
  end

  function self:handleTextInput(text)
    if self.focused and self.enabled then
      self.text = self.text .. text
      return true
    end
    return false
  end

  function self:handleKeyDown(key)
    if not self.focused or not self.enabled then return false end

    local SDL = require("SDL")
    if (key == SDL.key.Backspace or key == 8) and #self.text > 0 then
      self.text = self.text:sub(1, -2)
      return true
    elseif (key == SDL.key.Delete or key == 127) then
      -- Delete key - could implement cursor position later
      return true
    end
    return false
  end

  function self:containsPoint(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
  end

  return self
end

-- Button widget
function M.Button(text, x, y, w, h, font)
  local self = M.Widget(x, y, w, h)
  self.text = text
  self.font = font
  self.callback = nil
  self.hovered = false

  function self:render(renderer, ttf)
    if not self.visible then return end

    -- Draw background
    local bg_color
    if not self.enabled then
      bg_color = {r=200, g=200, b=200, a=255}
    elseif self.hovered then
      bg_color = {r=0, g=140, b=240, a=255}
    else
      bg_color = {r=0, g=120, b=215, a=255}
    end
    renderer:setDrawColor(bg_color)
    renderer:fillRect({x=self.x, y=self.y, w=self.width, h=self.height})

    -- Draw text
    local text_color = {r=255, g=255, b=255, a=255}
    local surface = self.font:renderUtf8(self.text, "blended", text_color)
    if surface then
      local texture = renderer:createTextureFromSurface(surface)
      if texture then
        local tw, th = surface:getSize()
        local text_x = math.floor(self.x + (self.width - tw) / 2)
        local text_y = math.floor(self.y + (self.height - th) / 2)
        -- Debug: print button text coordinates once
        if not self._debug_printed then
          print(string.format("Button '%s' at (%d,%d) size (%d,%d), text at (%d,%d) size (%d,%d)",
            self.text, self.x, self.y, self.width, self.height, text_x, text_y, tw, th))
          self._debug_printed = true
        end
        renderer:copy(texture, nil, {x=text_x, y=text_y, w=tw, h=th})
      end
    end
  end

  function self:containsPoint(px, py)
    return px >= self.x and px <= self.x + self.width and
           py >= self.y and py <= self.y + self.height
  end

  function self:handleClick()
    if self.enabled and self.callback then
      self.callback()
      return true
    end
    return false
  end

  return self
end

-- Multiline text area
function M.TextArea(x, y, w, h, font)
  local self = M.TextInput(x, y, w, h, font)
  self.lines = {""}
  self.current_line = 1

  -- Override render for multiline
  local original_render = self.render
  function self:render(renderer, ttf)
    if not self.visible then return end

    -- Draw background and border
    local bg_color = self.focused and {r=255, g=255, b=200, a=255} or {r=255, g=255, b=255, a=255}
    renderer:setDrawColor(bg_color)
    renderer:fillRect({x=self.x, y=self.y, w=self.width, h=self.height})

    local border_color = self.focused and {r=0, g=120, b=215, a=255} or {r=150, g=150, b=150, a=255}
    renderer:setDrawColor(border_color)
    renderer:drawRect({x=self.x, y=self.y, w=self.width, h=self.height})

    -- Draw lines
    local text_color = {r=0, g=0, b=0, a=255}
    local y_offset = 5
    for i, line in ipairs(self.lines) do
      if line ~= "" then
        local surface = self.font:renderUtf8(line, "blended", text_color)
        if surface then
          local texture = renderer:createTextureFromSurface(surface)
          if texture then
            local lw, lh = surface:getSize()
            renderer:copy(texture, nil, {x=self.x + 5, y=self.y + y_offset,
                                        w=math.min(lw, self.width - 10), h=lh})
            y_offset = y_offset + lh + 2
          end
        end
      else
        y_offset = y_offset + 18
      end
      if y_offset > self.height - 10 then break end
    end
  end

  function self:getText()
    return table.concat(self.lines, "\n")
  end

  function self:setText(text)
    self.lines = {}
    for line in text:gmatch("[^\n]+") do
      table.insert(self.lines, line)
    end
    if #self.lines == 0 then
      self.lines = {""}
    end
    self.current_line = #self.lines
  end

  -- Override text input handling for multiline
  function self:handleTextInput(text)
    if self.focused and self.enabled then
      self.lines[self.current_line] = self.lines[self.current_line] .. text
      return true
    end
    return false
  end

  -- Override key handling for multiline
  function self:handleKeyDown(key)
    if not self.focused or not self.enabled then return false end

    local SDL = require("SDL")
    if (key == SDL.key.Backspace or key == 8) then
      local current = self.lines[self.current_line]
      if #current > 0 then
        self.lines[self.current_line] = current:sub(1, -2)
        return true
      elseif self.current_line > 1 then
        -- Merge with previous line
        local prev = table.remove(self.lines, self.current_line)
        self.current_line = self.current_line - 1
        self.lines[self.current_line] = self.lines[self.current_line] .. (prev or "")
        return true
      end
    elseif (key == SDL.key.Return or key == 13) then
      -- Enter key - create new line
      table.insert(self.lines, self.current_line + 1, "")
      self.current_line = self.current_line + 1
      return true
    end
    return false
  end

  return self
end

return M
