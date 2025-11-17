-- BUFLO - Form Flow Screen

local form = {}
local ui = require("lib.ui")
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
local pdf_validated = false  -- Track if PDF has been validated

-- Platform helpers
local function is_windows()
    return love.system and love.system.getOS and love.system.getOS() == "Windows"
end

local function get_temp_dir()
    if is_windows() then
        return os.getenv("TEMP") or os.getenv("TMP") or "."
    else
        return "/tmp"
    end
end

function form.load(data)
    data = data or {}
    profile_name = data.profile or ""
    current_page = 1
    field_values = {}
    validation_errors = {}
    pdf_validated = false  -- Reset PDF validation state

    if profile_name ~= "" then
        -- Load and parse TOML profile
        local content = love.filesystem.read("profiles/" .. profile_name)
        if content then
            profile_data = toml_parser.parse(content)

            if profile_data then
                -- Get all fields - we'll paginate dynamically based on screen height
                all_fields = toml_parser.get_all_fields(profile_data)

                -- Dynamic pagination based on screen height
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
    elseif field.type == "pdf_attachment" then
        -- PDF attachment upload (similar to image_upload)
        local button_text = value ~= "" and "[*] Change PDF..." or "[+] Choose PDF..."
        if ui.button("pick_" .. field.id, button_text, x, y, w, h) then
            field_values[field.id .. "_picking"] = not field_values[field.id .. "_picking"]
        end

        local y_offset = y + h + 8

        -- Show current file if selected and not picking
        if value ~= "" and not field_values[field.id .. "_picking"] then
            love.graphics.setColor(ui.colors.success)
            local short_path = value:match("([^/]+)$") or value
            love.graphics.print("[*] Selected: " .. short_path, x, y_offset, 0, 0.9)
        end

        -- Show input field when in picking mode
        if field_values[field.id .. "_picking"] then
            love.graphics.setColor(ui.colors.text_dim)
            love.graphics.print("Paste path or drag & drop PDF file:", x, y_offset, 0, 0.85)
            local input_id = field.id .. "_input"
            local new_value, is_focused = ui.textInput(input_id, field_values[input_id] or "", x, y_offset + 22, w, h * 0.8, "/path/to/document.pdf")
        end

        return h + 85
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
        -- On final page, check if PDF is attached
        local has_pdf = false
        local pdf_path = nil

        for field_id, value in pairs(field_values) do
            if field_id:match("_pdf$") and value ~= "" and value ~= nil then
                has_pdf = true
                pdf_path = value
                break
            end
        end

        -- Show status message if PDF is validated
        if pdf_validated then
            love.graphics.setColor(ui.colors.success)
            local status_text = "✓ Merge successful, time to Preview & Print"
            local button_x_start = w - 40 - 200 - 10 - 150
            love.graphics.print(status_text, button_x_start, button_y - 30)
        end

        -- Show buttons based on PDF state
        local button_x_start = w - 40 - 200 - 10 - 150

        -- Merge PDFs button (only enabled when PDF is attached and not yet validated)
        if has_pdf and not pdf_validated then
            if ui.accentButton("merge_pdf", "🔗 Merge PDFs", button_x_start, button_y, 150, button_h) then
                if pdf_path then
                    -- Validate PDF by trying to convert it
                    local temp_prefix = tostring(os.time()) .. math.random(1000, 9999)
                    local tmp_dir = get_temp_dir()

                    local out_prefix, sep
                    if is_windows() then
                        sep = "\\"
                        out_prefix = tmp_dir .. sep .. "test_" .. temp_prefix
                    else
                        sep = "/"
                        out_prefix = tmp_dir .. sep .. "test_" .. temp_prefix
                    end

                    local test_cmd
                    if is_windows() then
                        -- Windows: double-quote paths, no single quotes, let PATH find pdftoppm
                        test_cmd = string.format(
                            'pdftoppm -png -r 150 -f 1 -l 1 "%s" "%s" 2>&1',
                            pdf_path,
                            out_prefix
                        )
                    else
                        -- Original POSIX-style behavior preserved for Linux/macOS
                        test_cmd = string.format(
                            "pdftoppm -png -r 150 -f 1 -l 1 '%s' '%s' 2>&1",
                            pdf_path,
                            out_prefix
                        )
                    end

                    print("Running PDF validation: " .. test_cmd)
                    local handle = io.popen(test_cmd)
                    local result = ""
                    if handle then
                        result = handle:read("*a")
                        handle:close()
                    end

                    if result:match("Error") or result:match("Unable") or result:match("failed") then
                        print("PDF validation failed: " .. result)
                        pdf_validated = false
                    else
                        print("PDF validated successfully: " .. pdf_path)
                        pdf_validated = true

                        -- Clean up test files (platform-specific)
                        if is_windows() then
                            -- Use cmd.exe del with wildcard, best-effort cleanup
                            local cleanup_cmd = string.format('del /Q "%s*.png" 2>nul', out_prefix)
                            os.execute(cleanup_cmd)
                        else
                            os.execute("rm -f '" .. out_prefix .. "'*.png")
                        end
                    end
                end
            end
        else
            -- Disabled Merge button (already validated or no PDF)
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", button_x_start, button_y, 150, button_h, 4, 4)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", button_x_start + 0.5, button_y + 0.5, 150 - 1, button_h - 1, 4, 4)
            love.graphics.setColor(0.6, 0.6, 0.6)
            local font = love.graphics.getFont()
            local text = "🔗 Merge PDFs"
            local text_width = font:getWidth(text)
            love.graphics.print(text, button_x_start + (150 - text_width) / 2, button_y + (button_h - font:getHeight()) / 2)
        end

        -- Preview & Print button (only enabled when PDF is validated)
        if pdf_validated then
            if ui.warningButton("preview", "👁 Preview & Print", w - 40 - 200, button_y, 200, button_h) then
                if validate_page() then
                    -- Generate HTML preview
                    local html_content = generate_html_preview()
                    local preview_file = "preview_" .. profile_name:gsub("%.toml$", "") .. ".html"
                    love.filesystem.write(preview_file, html_content)

                    -- Open in browser (user can use Ctrl+P to print)
                    local save_dir = love.filesystem.getSaveDirectory()
                    local preview_path = save_dir .. "/" .. preview_file
                    print("Preview saved to:", preview_path)
                    print("Use Ctrl+P or Cmd+P in your browser to print")
                    love.system.openURL("file://" .. preview_path)
                end
            end
        else
            -- Disabled button
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", w - 40 - 200, button_y, 200, button_h, 4, 4)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("line", w - 40 - 200 + 0.5, button_y + 0.5, 200 - 1, button_h - 1, 4, 4)
            love.graphics.setColor(0.6, 0.6, 0.6)
            local font = love.graphics.getFont()
            local text = "👁 Preview & Print"
            local text_width = font:getWidth(text)
            love.graphics.print(text, w - 40 - 200 + (200 - text_width) / 2, button_y + (button_h - font:getHeight()) / 2)
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

    -- Check file type
    local is_image = filepath:match("%.png$") or filepath:match("%.jpg$") or
                     filepath:match("%.jpeg$") or filepath:match("%.gif$") or
                     filepath:match("%.bmp$")
    local is_pdf = filepath:match("%.pdf$")

    if not is_image and not is_pdf then
        print("Dropped file is not an image or PDF: " .. filepath)
        return
    end

    -- Find fields that are currently in picking mode
    for field_id, is_picking in pairs(field_values) do
        if field_id:match("_picking$") and is_picking then
            local base_id = field_id:gsub("_picking$", "")
            field_values[base_id] = filepath
            field_values[field_id] = false  -- Close picking mode
            field_values[base_id .. "_input"] = ""  -- Clear input field
            print("File set for field " .. base_id .. ": " .. filepath)
            return
        end
    end

    -- If no field is in picking mode, find appropriate field by type
    for _, field in ipairs(all_fields) do
        if is_image and field.type == "image_upload" then
            field_values[field.id] = filepath
            print("Image set for field " .. field.id .. ": " .. filepath)
            return
        elseif is_pdf and field.type == "pdf_attachment" then
            field_values[field.id] = filepath
            print("PDF set for field " .. field.id .. ": " .. filepath)
            return
        end
    end

    print("No suitable field found for dropped file")
end

return form
