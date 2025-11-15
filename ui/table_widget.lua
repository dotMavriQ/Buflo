-- ui/table_widget.lua
-- Interactive table widget for invoice line items

local ui = require("lib.ui")

local M = {}

-- Table state management
local table_states = {}
local cell_input_buffer = {}  -- Buffer for cell text input

-- Helper: safely iterate over columns array, skipping nils
local function iter_columns(columns)
    local result = {}
    if not columns or type(columns) ~= "table" then
        return result
    end
    for i = 1, #columns do
        if columns[i] then
            table.insert(result, columns[i])
        end
    end
    return result
end

-- Initialize table state for a field
local function init_table_state(field_id, table_def)
    if not field_id then
        print("ERROR: field_id is nil!")
        return
    end

    if not table_states[field_id] then
        -- Debug: check table structure
        if not table_def then
            print("ERROR: table_def is nil!")
            return
        end

        if not table_def.columns then
            print("ERROR: table_def.columns is nil for field " .. tostring(field_id))
            table_def.columns = {}
        elseif type(table_def.columns) ~= "table" then
            print("ERROR: table_def.columns is not a table, type: " .. type(table_def.columns))
            table_def.columns = {}
        end

        -- Debug: Print column information
        print("\n=== TABLE COLUMNS DEBUG for " .. field_id .. " ===")
        for i, col in ipairs(table_def.columns) do
            if col then
                print(string.format("Column %d: id=%s, label=%s, type=%s, calculated=%s, formula=%s",
                    i, tostring(col.id), tostring(col.label), tostring(col.type),
                    tostring(col.calculated), tostring(col.formula)))
            end
        end
        print("=== END DEBUG ===\n")

        table_states[field_id] = {
            rows = {},
            focused_cell = nil,  -- {row_index, col_id}
            scroll_offset = 0,
            edit_buffer = {}  -- Temporary input values
        }

        -- Initialize with default rows or minimum rows
        local default_rows = table_def.default_data or {}
        local min_rows = table_def.min_rows or 1

        if #default_rows > 0 then
            for i, row_data in ipairs(default_rows) do
                table.insert(table_states[field_id].rows, row_data)
            end
        else
            -- Create empty rows up to min_rows
            for i = 1, min_rows do
                local empty_row = {}
                if table_def.columns and type(table_def.columns) == "table" then
                    for col_idx = 1, #table_def.columns do
                        local col = table_def.columns[col_idx]
                        if col and type(col) == "table" and col.id then
                            empty_row[col.id] = col.default or ""
                        end
                    end
                end
                table.insert(table_states[field_id].rows, empty_row)
            end
        end
    end
end

-- Calculate column value (for calculated fields)
local function calculate_column_value(formula, row_data)
    if not formula then return "" end

    -- Simple @calc() evaluator
    -- Formula like "@calc(quantity * rate)"
    local expr = formula:match("@calc%s*%((.+)%)")
    if not expr then return "" end

    -- Replace column IDs with values
    local eval_expr = expr
    for col_id, value in pairs(row_data) do
        local num_value = tonumber(value) or 0
        eval_expr = eval_expr:gsub("%f[%w]" .. col_id .. "%f[%W]", tostring(num_value))
    end

    -- Evaluate simple arithmetic
    local result = load("return " .. eval_expr)
    if result then
        local ok, value = pcall(result)
        if ok and type(value) == "number" then
            return string.format("%.2f", value)
        end
    end

    return ""
end

-- Calculate table summary (for @sum formulas)
local function calculate_summary(formula, rows, columns)
    if not formula then return "" end

    -- @sum(items.column_id)
    local col_id = formula:match("@sum%s*%(%s*items%.([%w_]+)%s*%)")
    if not col_id then return "" end

    local total = 0
    for _, row in ipairs(rows) do
        -- If column is calculated, calculate it first
        local col_def = nil
        for _, col in ipairs(columns) do
            if col.id == col_id then
                col_def = col
                break
            end
        end

        local value
        if col_def and col_def.calculated and col_def.formula then
            value = calculate_column_value(col_def.formula, row)
        else
            value = row[col_id]
        end

        total = total + (tonumber(value) or 0)
    end

    return string.format("%.2f", total)
end

-- Render table widget
function M.render(field_id, table_def, x, y, width)
    -- Safety check and debug
    if not table_def.columns then
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Error: Table has no columns defined", x, y)
        return 40
    end

    if #table_def.columns == 0 then
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.print("Error: Table columns array is empty", x, y)
        return 40
    end

    -- Check if columns have IDs
    for i, col in ipairs(table_def.columns) do
        if not col or not col.id then
            love.graphics.setColor(0.8, 0.2, 0.2)
            love.graphics.print("Error: Column " .. i .. " missing ID", x, y)
            return 40
        end
    end

    init_table_state(field_id, table_def)
    local state = table_states[field_id]

    local row_height = 35
    local header_height = 40
    local button_height = 30
    local padding = 8

    -- Calculate column widths
    local column_widths = {}
    local total_width = width - 2 * padding
    local safe_columns = iter_columns(table_def.columns)
    for _, col in ipairs(safe_columns) do
        local col_width = col.width and (tonumber(col.width:match("(%d+)%%")) / 100 * total_width) or (total_width / #safe_columns)
        table.insert(column_widths, col_width)
    end

    local current_y = y

    -- Draw table border
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("line", x, current_y, width, header_height + #state.rows * row_height + button_height + 10)

    -- Draw header
    love.graphics.setColor(0.95, 0.95, 0.95)
    love.graphics.rectangle("fill", x + 1, current_y + 1, width - 2, header_height - 2)

    local col_x = x + padding
    for i, col in ipairs(safe_columns) do
        love.graphics.setColor(0.2, 0.2, 0.2)
        local font = love.graphics.getFont()
        love.graphics.print(col.label or col.id, col_x, current_y + 12, 0, 0.9)
        col_x = col_x + column_widths[i]
    end

    current_y = current_y + header_height

    -- First, update ALL row data from input buffers (so calculations work)
    for row_idx, row in ipairs(state.rows) do
        for col_idx, col in ipairs(safe_columns) do
            if not col.calculated then
                local input_id = field_id .. "_" .. row_idx .. "_" .. col.id
                if cell_input_buffer[input_id] then
                    row[col.id] = cell_input_buffer[input_id]
                end
            end
        end
    end

    -- Draw rows
    for row_idx, row in ipairs(state.rows) do
        local row_y = current_y + (row_idx - 1) * row_height

        -- Alternate row background
        if row_idx % 2 == 0 then
            love.graphics.setColor(0.98, 0.98, 0.98)
            love.graphics.rectangle("fill", x + 1, row_y, width - 2, row_height)
        end

        -- Draw cells
        local col_x = x + padding
        for col_idx, col in ipairs(safe_columns) do
            local cell_width = column_widths[col_idx] - padding
            local cell_x = col_x
            local cell_y = row_y + 8

            -- Get cell value
            local cell_value
            if col.calculated and col.formula then
                cell_value = calculate_column_value(col.formula, row)
            else
                cell_value = tostring(row[col.id] or col.default or "")
            end

            -- Draw cell
            if col.calculated then
                -- Read-only calculated cell
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.print(cell_value, cell_x, cell_y, 0, 0.85)
            else
                -- Editable cell - use mini text input
                local input_id = field_id .. "_" .. row_idx .. "_" .. col.id

                -- Initialize buffer from row data if not exists or if not focused
                if not cell_input_buffer[input_id] or ui.focused_widget ~= input_id then
                    cell_input_buffer[input_id] = cell_value
                end

                -- Get display value from buffer
                local display_value = cell_input_buffer[input_id]
                local new_value, is_focused = ui.textInput(input_id, display_value, cell_x, cell_y - 4, cell_width, 24, col.placeholder or "")
            end

            col_x = col_x + column_widths[col_idx]
        end

        -- Delete row button (if more than min_rows)
        local min_rows = table_def.min_rows or 1
        if #state.rows > min_rows then
            local delete_x = x + width - 30
            local delete_y = row_y + 5
            if ui.button("delete_" .. field_id .. "_" .. row_idx, "×", delete_x, delete_y, 25, 25) then
                table.remove(state.rows, row_idx)
            end
        end
    end

    current_y = current_y + #state.rows * row_height

    -- Add row button
    local max_rows = table_def.max_rows or 99
    if #state.rows < max_rows then
        local button_width = 150
        local button_x = x + padding
        local button_y = current_y + 5

        if ui.button("add_" .. field_id, "+ Add Row", button_x, button_y, button_width, button_height) then
            -- Add empty row
            local new_row = {}
            for _, col in ipairs(table_def.columns) do
                new_row[col.id] = col.default or ""
            end
            table.insert(state.rows, new_row)
        end
    end

    current_y = current_y + button_height + 10

    -- Summary row (if defined)
    if table_def.summary then
        love.graphics.setColor(0.95, 0.95, 0.95)
        love.graphics.rectangle("fill", x + 1, current_y, width - 2, 35)

        local summary_value = calculate_summary(table_def.summary.formula, state.rows, table_def.columns)

        love.graphics.setColor(0.2, 0.2, 0.2)
        local label = table_def.summary.label or "TOTAL"
        love.graphics.print(label, x + padding, current_y + 10, 0, 1.0)

        love.graphics.setColor(0.1, 0.1, 0.1)
        local font = love.graphics.getFont()
        local text_width = font:getWidth(summary_value)
        love.graphics.print(summary_value, x + width - padding - text_width - 10, current_y + 10, 0, 1.1)

        current_y = current_y + 35
    end

    -- Return total height used
    return current_y - y
end

-- Get table data for a field
function M.get_data(field_id)
    if not table_states[field_id] then
        return {}
    end
    return table_states[field_id].rows
end

-- Set table data for a field
function M.set_data(field_id, rows)
    if not table_states[field_id] then
        table_states[field_id] = {
            rows = {},
            focused_cell = nil,
            scroll_offset = 0,
            edit_buffer = {}
        }
    end
    table_states[field_id].rows = rows
end

-- Clear table state (for reset)
function M.clear(field_id)
    table_states[field_id] = nil
    -- Clear input buffers for this table
    for key in pairs(cell_input_buffer) do
        if key:match("^" .. field_id .. "_") then
            cell_input_buffer[key] = nil
        end
    end
end

-- Handle text input for table cells
function M.handle_textinput(text)
    if ui.focused_widget and ui.focused_widget:match("_.+_.+") then
        -- This is a table cell ID (format: tableid_rownum_colid)
        local current_value = cell_input_buffer[ui.focused_widget] or ""
        cell_input_buffer[ui.focused_widget] = current_value .. text
        return true  -- Handled
    end
    return false  -- Not a table cell
end

-- Handle keyboard input for table cells
function M.handle_keypressed(key)
    if ui.focused_widget and ui.focused_widget:match("_.+_.+") then
        -- This is a table cell ID
        if key == "backspace" then
            local current_value = cell_input_buffer[ui.focused_widget] or ""
            if #current_value > 0 then
                cell_input_buffer[ui.focused_widget] = current_value:sub(1, -2)
            end
            return true  -- Handled
        end
    end
    return false  -- Not handled
end

return M
