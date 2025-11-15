-- BUFLO - Form Flow Screen

local form = {}
local ui = require("lib.ui")
local parser_v2 = require("buflo.core.buflo_v2_parser")
local toml_parser = require("buflo.core.toml_parser")
local invoice_template = require("buflo.rendering.invoice_template")
local table_widget = require("ui.table_widget")

-- State
local profile_name = ""
local profile_data = {}
local form_pages = {}
local current_page = 1
local field_values = {}
local validation_errors = {}
local all_fields = {}  -- Store all fields for access in callbacks

function form.load(data)
    data = data or {}
    profile_name = data.profile or ""
    current_page = 1
    field_values = {}
    validation_errors = {}

    if profile_name ~= "" then
        -- Load and parse profile
        local content = love.filesystem.read("profiles/" .. profile_name)
        if content then
            -- Detect format and use appropriate parser
            local parser = parser_v2  -- default to v2
            if profile_name:match("%.toml$") then
                parser = toml_parser
            end

            profile_data = parser.parse(content)

            if profile_data then
                -- Get all fields - we'll paginate dynamically based on screen height
                all_fields = parser.get_all_fields(profile_data)

                -- Dynamic pagination based on available screen height
                form_pages = create_dynamic_pages(all_fields)

                -- Initialize field values with defaults
                for _, field in ipairs(all_fields) do
                    if field.id and field.default then
                        field_values[field.id] = field.default
                    end
                end
            end
        end
    end
end

function form.update(dt)
    -- Handle any dynamic updates here
end

-- Calculate field height based on type (considers current state)
local function calculate_field_height(field)
    local base_height = 40
    local label_height = 30
    local spacing = 15

    if field.type == "image_upload" then
        -- Always reserve space for expanded state to prevent layout shift
        -- Button + message + text input
        return label_height + base_height + 85 + spacing
    elseif field.type == "textarea" then
        return label_height + (base_height * 2) + spacing
    else
        return label_height + base_height + spacing
    end
end

-- Create pages dynamically based on available screen height
function create_dynamic_pages(all_fields)
    local pages = {}
    local current_page = {}

    -- Get screen dimensions
    local screen_w, screen_h = love.graphics.getDimensions()

    -- Calculate available height for form fields
    local header_height = 120  -- Title + progress bar
    local button_height = 120  -- Navigation buttons at bottom
    local available_height = screen_h - header_height - button_height - 40 -- 40px safety margin

    local current_height = 0

    for _, field in ipairs(all_fields) do
        if field.type ~= "spacer" then
            local field_height = calculate_field_height(field)

            -- Check if adding this field would exceed available height
            if current_height + field_height > available_height and #current_page > 0 then
                -- Start a new page
                table.insert(pages, current_page)
                current_page = {}
                current_height = 0
            end

            table.insert(current_page, field)
            current_height = current_height + field_height
        end
    end

    -- Add the last page if it has fields
    if #current_page > 0 then
        table.insert(pages, current_page)
    end

    return pages
end

-- Generate HTML preview from field values
local function generate_html_preview()
    -- Use the new invoice template renderer
    return invoice_template.generate_invoice_html(profile_data, field_values)
end

-- Validate current page fields
local function validate_page()
    validation_errors = {}
    local page_fields = form_pages[current_page] or {}
    local is_valid = true

    for _, field in ipairs(page_fields) do
        if field.required then
            local value = field_values[field.id] or ""
            if value == "" or value == nil then
                validation_errors[field.id] = "This field is required"
                is_valid = false
            end
        end

        -- Email validation
        if field.type == "email" and field_values[field.id] then
            local email = field_values[field.id]
            if email ~= "" and not email:match("^[%w%._%+-]+@[%w%._%+-]+%.%w+$") then
                validation_errors[field.id] = "Invalid email format"
                is_valid = false
            end
        end
    end

    return is_valid
end

-- Render a single field
local function render_field(field, x, y, w, h)
    -- Always show label - use label, or fallback to id, or show field type
    local label = field.label or field.id or ("Field: " .. (field.type or "unknown"))
    if field.required then
        label = label .. " *"
    end

    -- Add field type hint if no label
    if not field.label and field.type then
        label = label .. " (" .. field.type .. ")"
    end

    ui.label(label, x, y - 25, ui.colors.text)

    -- Show validation error
    if validation_errors[field.id] then
        ui.label(validation_errors[field.id], x, y + h + 2, ui.colors.danger)
    end

    -- Field input based on type
    local value = field_values[field.id] or field.default or ""

    if field.type == "image_upload" then
        -- File picker button for image upload
        local button_text = value ~= "" and "[*] Change Image..." or "[+] Choose Image..."
        if ui.button("pick_" .. field.id, button_text, x, y, w, h) then
            -- Use LÖVE's native file dialog (requires love.system.openURL workaround)
            -- For now, toggle input mode for paste
            field_values[field.id .. "_picking"] = not field_values[field.id .. "_picking"]
        end

        -- Always reserve space, but show/hide based on state
        local y_offset = y + h + 8

        -- Show current file if selected and not picking
        if value ~= "" and not field_values[field.id .. "_picking"] then
            love.graphics.setColor(ui.colors.success)
            local short_path = value:match("([^/]+)$") or value  -- Show just filename
            love.graphics.print("[*] Selected: " .. short_path, x, y_offset, 0, 0.9)
        end

        -- Show input field when in picking mode
        if field_values[field.id .. "_picking"] then
            love.graphics.setColor(ui.colors.text_dim)
            love.graphics.print("Paste path or drag & drop image file:", x, y_offset, 0, 0.85)
            local input_id = field.id .. "_input"
            local new_value, is_focused = ui.textInput(input_id, field_values[input_id] or "", x, y_offset + 22, w, h * 0.8, "/path/to/image.png")

            -- The textinput and keypressed handlers will update field_values[input_id]
            -- Enter key confirmation happens in keypressed handler
        end

        return h + 85  -- Fixed height to prevent layout shift
    elseif field.type == "table" then
        -- Table widget for line items
        local table_height = table_widget.render(field.id, field, x, y, w)
        -- Store table data in field_values
        field_values[field.id] = table_widget.get_data(field.id)
        return table_height
    elseif field.type == "textarea" then
        -- Multi-line text
        local new_value, is_focused = ui.textInput(field.id, value, x, y, w, h * 2, field.placeholder)
        field_values[field.id] = new_value
        return h * 2
    elseif field.type == "select" then
        -- Dropdown (simplified - just show as text for now)
        local new_value, is_focused = ui.textInput(field.id, value, x, y, w, h, "Select...")
        field_values[field.id] = new_value
        return h
    else
        -- Default: text input (works for text, date, email, tel, number, currency)
        local placeholder = field.placeholder or ""
        if field.type == "date" then
            placeholder = placeholder ~= "" and placeholder or "YYYY-MM-DD"
        elseif field.type == "email" then
            placeholder = placeholder ~= "" and placeholder or "email@example.com"
        elseif field.type == "tel" then
            placeholder = placeholder ~= "" and placeholder or "Phone number"
        elseif field.type == "currency" or field.type == "number" then
            placeholder = placeholder ~= "" and placeholder or "0"
        end

        local new_value, is_focused = ui.textInput(field.id, value, x, y, w, h, placeholder)
        field_values[field.id] = new_value
        return h
    end
end

function form.draw()
    ui.beginFrame()

    local w, h = love.graphics.getDimensions()
    local center_x = w / 2

    -- Header
    love.graphics.setColor(ui.colors.text)
    local title = profile_data.document and profile_data.document.title or "Invoice Form"
    love.graphics.print(title, 40, 30, 0, 1.5)

    -- Progress indicator
    local progress_text = string.format("%d of %d", current_page, #form_pages)
    love.graphics.setColor(ui.colors.text_dim)
    love.graphics.print(progress_text, w - 100, 35)

    -- Progress bar
    local progress_w = 300
    local progress_h = 6
    local progress_x = center_x - progress_w / 2
    local progress_y = 80

    love.graphics.setColor(ui.colors.bg_active)
    love.graphics.rectangle("fill", progress_x, progress_y, progress_w, progress_h, 3, 3)

    local progress_filled = (current_page / #form_pages) * progress_w
    love.graphics.setColor(ui.colors.warning)
    love.graphics.rectangle("fill", progress_x, progress_y, progress_filled, progress_h, 3, 3)

    -- Form area (no scrolling, pagination handles overflow)
    local form_x = 100
    local form_y = 120
    local form_w = w - 200
    local form_h = h - form_y - 120  -- Space for buttons at bottom
    local field_h = 40
    local field_spacing = 80

    -- Render current page fields
    local page_fields = form_pages[current_page] or {}
    local y_offset = form_y

    for _, field in ipairs(page_fields) do
        local field_height = render_field(field, form_x, y_offset, form_w - 40, field_h)
        y_offset = y_offset + field_height + field_spacing
    end

    -- Navigation buttons at bottom
    local button_y = h - 100
    local button_w = 150
    local button_h = 45

    -- Previous button
    if current_page > 1 then
        if ui.button("prev", "← Previous", 40, button_y, button_w, button_h) then
            current_page = current_page - 1
            validation_errors = {}
        end
    end

    -- Next/Submit button
    if current_page < #form_pages then
        if ui.primaryButton("next", "Next →", w - 40 - button_w, button_y, button_w, button_h) then
            if validate_page() then
                current_page = current_page + 1
                validation_errors = {}
            end
        end
    else
        -- On final page, show Preview and Generate PDF buttons
        if ui.warningButton("preview", "👁 Preview HTML", w - 40 - button_w * 2 - 10, button_y, button_w, button_h) then
            if validate_page() then
                -- Generate HTML preview
                local html_content = generate_html_preview()
                local preview_file = "preview_" .. profile_name:gsub("%.buflo$", ""):gsub("%.toml$", "") .. ".html"
                love.filesystem.write(preview_file, html_content)

                -- Open in browser
                local save_dir = love.filesystem.getSaveDirectory()
                local preview_path = save_dir .. "/" .. preview_file
                print("Preview saved to:", preview_path)
                love.system.openURL("file://" .. preview_path)
            end
        end

        if ui.successButton("submit", "Generate PDF", w - 40 - button_w, button_y, button_w, button_h) then
            if validate_page() then
                -- TODO: Generate PDF directly
                print("Generating PDF with data:")
                for k, v in pairs(field_values) do
                    print(k, v)
                end
            end
        end
    end

    -- Cancel button
    if ui.button("cancel", "Cancel", center_x - 75, button_y, button_w, button_h) then
        switchScreen("welcome")
    end

    ui.endFrame()
end

function form.textinput(text)
    -- Let table widget handle table cell input first
    if table_widget.handle_textinput(text) then
        return
    end

    -- Handle text input for focused field
    if ui.focused_widget then
        local current_value = field_values[ui.focused_widget] or ""
        field_values[ui.focused_widget] = current_value .. text
    end
end

function form.keypressed(key, scancode, isrepeat)
    -- Let table widget handle table cell keyboard input first
    if table_widget.handle_keypressed(key) then
        return
    end

    -- Handle backspace for focused field
    if ui.focused_widget and key == "backspace" then
        local current_value = field_values[ui.focused_widget] or ""
        if #current_value > 0 then
            field_values[ui.focused_widget] = current_value:sub(1, -2)
        end
    end

    -- Handle Enter key for image upload path confirmation
    if key == "return" or key == "kpenter" then
        if ui.focused_widget and ui.focused_widget:match("_input$") then
            local base_id = ui.focused_widget:gsub("_input$", "")
            local input_value = field_values[ui.focused_widget] or ""
            if input_value ~= "" then
                field_values[base_id] = input_value
                field_values[base_id .. "_picking"] = false
                field_values[ui.focused_widget] = ""  -- Clear the input
                ui.focused_widget = nil
            end
        end
    end

    -- Tab to next field
    if key == "tab" then
        -- TODO: Implement tab navigation
    end
end

-- Handle file drag and drop
function form.filedropped(file)
    -- Get the dropped file path
    local filepath = file:getFilename()

    -- Check if it's an image file
    local is_image = filepath:match("%.png$") or filepath:match("%.jpg$") or
                     filepath:match("%.jpeg$") or filepath:match("%.gif$") or
                     filepath:match("%.bmp$")

    if not is_image then
        print("Dropped file is not an image: " .. filepath)
        return
    end

    -- Find image upload fields that are currently in picking mode
    for field_id, is_picking in pairs(field_values) do
        if field_id:match("_picking$") and is_picking then
            local base_id = field_id:gsub("_picking$", "")
            field_values[base_id] = filepath
            field_values[field_id] = false  -- Close picking mode
            field_values[base_id .. "_input"] = ""  -- Clear input field
            print("Image set for field " .. base_id .. ": " .. filepath)
            return
        end
    end

    -- If no field is in picking mode, find the first image_upload field and set it
    for _, field in ipairs(all_fields) do
        if field.type == "image_upload" then
            field_values[field.id] = filepath
            print("Image set for field " .. field.id .. ": " .. filepath)
            return
        end
    end

    print("No image upload field found for dropped file")
end

return form
