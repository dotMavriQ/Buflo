-- BUFLO - Simple UI Library for LÖVE2D

local ui = {}

-- UI State
ui.hot_widget = nil      -- Widget mouse is over
ui.active_widget = nil   -- Widget being interacted with
ui.focused_widget = nil  -- Widget with keyboard focus

-- Colors - Gruvbox Dark Material Theme
ui.colors = {
    -- Backgrounds
    bg = {0.16, 0.15, 0.14},           -- #282828 - Gruvbox dark0_hard
    bg_soft = {0.20, 0.19, 0.17},      -- #32302f - Gruvbox dark0
    bg_hover = {0.24, 0.22, 0.20},     -- #3c3836 - Gruvbox dark1
    bg_active = {0.31, 0.28, 0.25},    -- #504945 - Gruvbox dark2

    -- UI Elements
    border = {0.44, 0.40, 0.36},       -- #665c54 - Gruvbox dark4
    border_focus = {0.98, 0.74, 0.26}, -- #fabd2f - Gruvbox yellow

    -- Text
    text = {0.92, 0.86, 0.70},         -- #ebdbb2 - Gruvbox fg
    text_dim = {0.66, 0.60, 0.53},     -- #a89984 - Gruvbox gray
    text_disabled = {0.44, 0.40, 0.36}, -- #665c54 - Gruvbox dark4

    -- Brand Colors (Gruvbox accents)
    primary = {0.51, 0.65, 0.42},      -- #83a598 - Gruvbox blue (adjusted)
    primary_hover = {0.61, 0.75, 0.52}, -- Lighter blue

    success = {0.72, 0.73, 0.42},      -- #b8bb26 - Gruvbox green
    success_hover = {0.82, 0.83, 0.52}, -- Lighter green

    warning = {0.98, 0.74, 0.26},      -- #fabd2f - Gruvbox yellow
    warning_hover = {1.0, 0.84, 0.36},  -- Lighter yellow

    danger = {0.98, 0.29, 0.27},       -- #fb4934 - Gruvbox red
    danger_hover = {1.0, 0.39, 0.37},   -- Lighter red

    -- Special
    accent = {0.83, 0.60, 0.44},       -- #d3869b - Gruvbox purple
    orange = {0.97, 0.53, 0.24},       -- #fe8019 - Gruvbox orange
}

-- Helper: Check if point is in rectangle
function ui.pointInRect(px, py, x, y, w, h)
    return px >= x and px < x + w and py >= y and py < y + h
end

-- Button widget
function ui.button(id, text, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_active = ui.active_widget == id
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.bg
    if is_active then
        bg_color = ui.colors.bg_active
    elseif is_hot then
        bg_color = ui.colors.bg_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) then
        ui.active_widget = id
    elseif is_active and not love.mouse.isDown(1) then
        if is_hot then
            clicked = true
        end
        ui.active_widget = nil
    end

    -- Draw button
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    love.graphics.setColor(ui.colors.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1, 4, 4)

    -- Draw text
    love.graphics.setColor(ui.colors.text)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    love.graphics.print(text,
        math.floor(x + (w - text_width) / 2),
        math.floor(y + (h - text_height) / 2))

    return clicked
end

-- Primary button (highlighted)
function ui.primaryButton(id, text, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_active = ui.active_widget == id
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.primary
    if is_active then
        bg_color = {0.16, 0.49, 0.88}
    elseif is_hot then
        bg_color = ui.colors.primary_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) then
        ui.active_widget = id
    elseif is_active and not love.mouse.isDown(1) then
        if is_hot then
            clicked = true
        end
        ui.active_widget = nil
    end

    -- Draw button
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    love.graphics.print(text,
        math.floor(x + (w - text_width) / 2),
        math.floor(y + (h - text_height) / 2))

    return clicked
end

-- Success button (green)
function ui.successButton(id, text, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_active = ui.active_widget == id
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.success
    if is_active then
        bg_color = {0.10, 0.67, 0.31}
    elseif is_hot then
        bg_color = ui.colors.success_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) then
        ui.active_widget = id
    elseif is_active and not love.mouse.isDown(1) then
        if is_hot then
            clicked = true
        end
        ui.active_widget = nil
    end

    -- Draw button
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    love.graphics.print(text,
        math.floor(x + (w - text_width) / 2),
        math.floor(y + (h - text_height) / 2))

    return clicked
end

-- Warning button (yellow)
function ui.warningButton(id, text, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_active = ui.active_widget == id
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.warning
    if is_active then
        bg_color = {0.86, 0.63, 0.10}
    elseif is_hot then
        bg_color = ui.colors.warning_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) then
        ui.active_widget = id
    elseif is_active and not love.mouse.isDown(1) then
        if is_hot then
            clicked = true
        end
        ui.active_widget = nil
    end

    -- Draw button
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    love.graphics.print(text,
        math.floor(x + (w - text_width) / 2),
        math.floor(y + (h - text_height) / 2))

    return clicked
end

-- Danger button (red)
function ui.dangerButton(id, text, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_active = ui.active_widget == id
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.danger
    if is_active then
        bg_color = {0.76, 0.10, 0.17}
    elseif is_hot then
        bg_color = ui.colors.danger_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) then
        ui.active_widget = id
    elseif is_active and not love.mouse.isDown(1) then
        if is_hot then
            clicked = true
        end
        ui.active_widget = nil
    end

    -- Draw button
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Draw text
    love.graphics.setColor(1, 1, 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(text)
    local text_height = font:getHeight()
    love.graphics.print(text,
        math.floor(x + (w - text_width) / 2),
        math.floor(y + (h - text_height) / 2))

    return clicked
end

-- Label
function ui.label(text, x, y, color)
    color = color or ui.colors.text
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

-- Dropdown/Combobox
function ui.dropdown(id, items, selected_index, x, y, w, h)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local clicked = false

    -- Visual state
    local bg_color = ui.colors.bg
    if is_hot then
        bg_color = ui.colors.bg_hover
        ui.hot_widget = id
    end

    -- Check for click
    if is_hot and love.mouse.isDown(1) and ui.active_widget ~= id then
        ui.active_widget = id
        clicked = true
    end

    -- Reset active state when mouse released
    if ui.active_widget == id and not love.mouse.isDown(1) then
        ui.active_widget = nil
    end

    -- Draw dropdown box
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    love.graphics.setColor(ui.colors.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1, 4, 4)

    -- Draw selected item or placeholder
    love.graphics.setColor(ui.colors.text)
    local display_text = selected_index > 0 and items[selected_index] or "Select profile..."
    love.graphics.print(display_text, x + 10, y + (h - love.graphics.getFont():getHeight()) / 2)

    -- Draw arrow
    love.graphics.print("▼", x + w - 25, y + (h - love.graphics.getFont():getHeight()) / 2)

    return clicked, selected_index
end

-- Text input field
function ui.textInput(id, text, x, y, w, h, placeholder)
    local mx, my = love.mouse.getPosition()
    local is_hot = ui.pointInRect(mx, my, x, y, w, h)
    local is_focused = ui.focused_widget == id

    -- Handle focus
    if is_hot and love.mouse.isDown(1) then
        ui.focused_widget = id
    end

    -- Visual state
    local bg_color = ui.colors.bg_soft
    local border_color = ui.colors.border
    if is_focused then
        border_color = ui.colors.border_focus
        bg_color = ui.colors.bg_hover
    elseif is_hot then
        bg_color = ui.colors.bg_hover
    end

    -- Draw input box
    love.graphics.setColor(bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    love.graphics.setColor(border_color)
    love.graphics.setLineWidth(is_focused and 2 or 1)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1, 4, 4)

    -- Draw text or placeholder
    local display_text = text
    local text_color = ui.colors.text

    if text == "" and placeholder and not is_focused then
        display_text = placeholder
        text_color = ui.colors.text_dim
    end

    love.graphics.setColor(text_color)
    local font = love.graphics.getFont()
    love.graphics.print(display_text, x + 10, y + (h - font:getHeight()) / 2)

    -- Draw cursor if focused
    if is_focused and math.floor(love.timer.getTime() * 2) % 2 == 0 then
        local cursor_x = x + 10 + font:getWidth(text)
        love.graphics.setColor(ui.colors.warning)
        love.graphics.rectangle("fill", cursor_x, y + 8, 2, h - 16)
    end

    return text, is_focused
end

-- Reset UI state each frame
function ui.beginFrame()
    ui.hot_widget = nil
end

function ui.endFrame()
    -- Cleanup can go here if needed
end

return ui
