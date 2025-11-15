-- BUFLO - Welcome Screen

local welcome = {}
local ui = require("lib.ui")

-- State
local profiles = {}
local selected_profile_index = 0
local buflo_logo = nil
local show_dropdown = false

function welcome.load()
    -- Load buflo logo
    local logo_path = "assets/buflo.png"
    if love.filesystem.getInfo(logo_path) then
        buflo_logo = love.graphics.newImage(logo_path)
    end

    -- Load profile list
    profiles = getProfileList()
    selected_profile_index = 0
end

function welcome.update(dt)
    -- Nothing to update currently
end

function welcome.draw()
    ui.beginFrame()

    local w, h = love.graphics.getDimensions()
    local center_x = w / 2

    -- Draw buflo logo bigger, centered above title
    local logo_y = 40
    if buflo_logo then
        local img_w, img_h = buflo_logo:getDimensions()
        -- Scale to fit width of 300px or original size, whichever is smaller
        local scale = math.min(1, 300 / img_w)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(buflo_logo, center_x, logo_y, 0, scale, scale, img_w / 2, 0)
        logo_y = logo_y + img_h * scale + 20
    end

    -- Title
    love.graphics.setColor(0.9, 0.9, 0.9)
    local title_font = love.graphics.newFont(24)
    love.graphics.setFont(title_font)
    local title = "BUFLO"
    local title_w = title_font:getWidth(title)
    love.graphics.print(title, center_x - title_w / 2, logo_y)

    -- Subtitle
    local normal_font = love.graphics.newFont(14)
    love.graphics.setFont(normal_font)
    local subtitle = "Billing Unified Flow Language & Orchestrator"
    local subtitle_w = normal_font:getWidth(subtitle)
    love.graphics.setColor(0.66, 0.60, 0.53)  -- Gruvbox gray
    love.graphics.print(subtitle, center_x - subtitle_w / 2, logo_y + 40)

    -- Profile dropdown and Load button centered
    local dropdown_y = logo_y + 100
    local dropdown_w = 460
    local dropdown_h = 40
    local load_btn_w = 120
    local total_width = dropdown_w + 10 + load_btn_w
    local dropdown_x = center_x - total_width / 2
    local load_btn_x = dropdown_x + dropdown_w + 10

    ui.label("Select Profile:", dropdown_x, dropdown_y - 25)

    local clicked, new_index = ui.dropdown("profile_dropdown", profiles, selected_profile_index,
                                          dropdown_x, dropdown_y, dropdown_w, dropdown_h)

    if clicked then
        show_dropdown = not show_dropdown
    end

    -- Load button right next to dropdown
    if ui.primaryButton("load_profile", "Load", load_btn_x, dropdown_y, load_btn_w, dropdown_h) then
        if selected_profile_index > 0 then
            switchScreen("form", {profile = profiles[selected_profile_index]})
        end
    end

    -- Action buttons stacked vertically: Create (green), Edit (yellow), Delete (red)
    local button_y = dropdown_y + 80
    local button_w = 300
    local button_h = 45
    local button_spacing = 10
    local button_x = center_x - button_w / 2

    -- Create Profile button (green)
    if ui.successButton("create_profile", "Create Profile", button_x, button_y, button_w, button_h) then
        switchScreen("editor", {mode = "new"})
    end

    -- Edit Profile button (yellow)
    if ui.warningButton("edit_profile", "Edit Profile", button_x, button_y + button_h + button_spacing, button_w, button_h) then
        if selected_profile_index > 0 then
            switchScreen("editor", {mode = "edit", filename = profiles[selected_profile_index]})
        end
    end

    -- Delete Profile button (red)
    if ui.dangerButton("delete_profile", "Delete Profile", button_x, button_y + (button_h + button_spacing) * 2, button_w, button_h) then
        if selected_profile_index > 0 then
            -- Confirm deletion
            local profile_name = profiles[selected_profile_index]
            love.filesystem.remove("profiles/" .. profile_name)
            profiles = getProfileList()
            selected_profile_index = 0
        end
    end

    -- Quit button with spacing from action buttons
    local quit_y = button_y + (button_h + button_spacing) * 3 + 20
    if ui.button("quit", "Quit", center_x - 100, quit_y, 200, 40) then
        love.event.quit()
    end

    -- Draw dropdown list LAST so it appears on top of other elements
    if show_dropdown and #profiles > 0 then
        local list_y = dropdown_y + dropdown_h + 5
        local item_h = 35

        love.graphics.setColor(0.15, 0.15, 0.15)
        love.graphics.rectangle("fill", dropdown_x, list_y, dropdown_w, #profiles * item_h, 4, 4)
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", dropdown_x + 0.5, list_y + 0.5, dropdown_w - 1, #profiles * item_h - 1, 4, 4)

        for i, profile in ipairs(profiles) do
            local item_y = list_y + (i - 1) * item_h
            if ui.button("dropdown_item_" .. i, profile, dropdown_x + 2, item_y + 2, dropdown_w - 4, item_h - 2) then
                selected_profile_index = i
                show_dropdown = false
            end
        end
    end

    ui.endFrame()
end

function welcome.mousepressed(x, y, button)
    -- Close dropdown if clicked outside
    local center_x = love.graphics.getWidth() / 2
    local dropdown_w = 460
    local load_btn_w = 120
    local total_width = dropdown_w + 10 + load_btn_w
    local dropdown_x = center_x - total_width / 2

    -- Calculate dynamic dropdown_y based on logo
    local logo_y = 40
    if buflo_logo then
        local img_w, img_h = buflo_logo:getDimensions()
        local scale = math.min(1, 300 / img_w)
        logo_y = logo_y + img_h * scale + 20
    end
    local dropdown_y = logo_y + 100
    local dropdown_h = 40

    if show_dropdown then
        local list_y = dropdown_y + dropdown_h + 5
        local list_h = #profiles * 35

        if not ui.pointInRect(x, y, dropdown_x, dropdown_y, dropdown_w, dropdown_h) and
           not ui.pointInRect(x, y, dropdown_x, list_y, dropdown_w, list_h) then
            show_dropdown = false
        end
    end
end

return welcome
