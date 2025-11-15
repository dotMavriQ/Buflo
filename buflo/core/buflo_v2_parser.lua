-- BUFLO v2 Parser - JSON-like DSL Parser

local parser = {}

-- Forward declarations
local parse_value, parse_array, parse_object

-- Helper: Parse JSON-like value
parse_value = function(str)
    str = str:match("^%s*(.-)%s*$") -- trim

    -- Boolean
    if str == "true" then return true end
    if str == "false" then return false end

    -- Number
    local num = tonumber(str)
    if num then return num end

    -- String (remove quotes)
    if str:match('^".-"$') or str:match("^'.-'$") then
        return str:sub(2, -2)
    end

    -- Array or object (recursive parse needed)
    if str:match("^%[") or str:match("^{") then
        return str -- Return as string for now, will parse later
    end

    return str
end

-- Helper: Parse array
parse_array = function(str)
    local result = {}
    local depth = 0
    local current = ""
    local in_string = false
    local string_char = nil

    -- Remove outer brackets
    str = str:match("^%[%s*(.-)%s*%]$")
    if not str then return result end

    for i = 1, #str do
        local char = str:sub(i, i)
        local next_char = str:sub(i+1, i+1)

        if (char == '"' or char == "'") and not in_string then
            in_string = true
            string_char = char
            current = current .. char
        elseif char == string_char and in_string then
            in_string = false
            string_char = nil
            current = current .. char
        elseif not in_string then
            if char == "{" then
                depth = depth + 1
                current = current .. char
            elseif char == "}" then
                depth = depth - 1
                current = current .. char

                -- If we're back to depth 0 and the next non-whitespace is { or we're at the end,
                -- this is the end of an array element
                if depth == 0 then
                    local rest = str:sub(i+1):match("^%s*(.*)$")
                    if rest == "" or rest:match("^{") or rest:match("^%]") then
                        local clean_current = current:match("^%s*(.-)%s*$")
                        if clean_current:match("^{") then
                            table.insert(result, parse_object(clean_current:match("^{%s*(.-)%s*}$")))
                        elseif clean_current:match("^%[") then
                            table.insert(result, parse_array(clean_current))
                        elseif clean_current ~= "" then
                            table.insert(result, parse_value(clean_current))
                        end
                        current = ""
                    end
                end
            elseif char == "[" then
                depth = depth + 1
                current = current .. char
            elseif char == "]" then
                depth = depth - 1
                current = current .. char
            elseif char == "," and depth == 0 then
                -- Comma-separated elements (optional in our DSL)
                local clean_current = current:match("^%s*(.-)%s*$")
                if clean_current:match("^{") then
                    table.insert(result, parse_object(clean_current:match("^{%s*(.-)%s*}$")))
                elseif clean_current:match("^%[") then
                    table.insert(result, parse_array(clean_current))
                elseif clean_current ~= "" then
                    table.insert(result, parse_value(clean_current))
                end
                current = ""
            else
                current = current .. char
            end
        else
            current = current .. char
        end
    end

    -- Handle last element if exists
    if current ~= "" then
        local clean_current = current:match("^%s*(.-)%s*$")
        if clean_current:match("^{") then
            table.insert(result, parse_object(clean_current:match("^{%s*(.-)%s*}$")))
        elseif clean_current:match("^%[") then
            table.insert(result, parse_array(clean_current))
        elseif clean_current ~= "" then
            table.insert(result, parse_value(clean_current))
        end
    end

    return result
end

-- Parse object/dictionary
parse_object = function(content)
    local obj = {}
    local depth = 0
    local in_string = false
    local string_char = nil
    local key = ""
    local value = ""
    local in_key = true

    for i = 1, #content do
        local char = content:sub(i, i)

        -- Handle strings
        if (char == '"' or char == "'") and not in_string then
            in_string = true
            string_char = char
            if in_key then
                key = key .. char
            else
                value = value .. char
            end
        elseif char == string_char and in_string then
            in_string = false
            string_char = nil
            if in_key then
                key = key .. char
            else
                value = value .. char
            end
        elseif not in_string then
            -- Track nesting depth
            if char == "{" or char == "[" then
                depth = depth + 1
                if not in_key then value = value .. char end
            elseif char == "}" or char == "]" then
                depth = depth - 1
                if not in_key then value = value .. char end
            elseif char == ":" and depth == 0 and in_key then
                in_key = false
            elseif char == "\n" and depth == 0 and not in_key and value ~= "" then
                -- End of key-value pair
                local clean_key = key:match("^%s*(.-)%s*$"):gsub('^["\']', ''):gsub('["\']$', '')
                local clean_value = value:match("^%s*(.-)%s*$")

                -- Parse nested objects/arrays
                if clean_value:match("^{") then
                    obj[clean_key] = parse_object(clean_value:match("^{%s*(.-)%s*}$"))
                elseif clean_value:match("^%[") then
                    obj[clean_key] = parse_array(clean_value)
                else
                    obj[clean_key] = parse_value(clean_value)
                end

                key = ""
                value = ""
                in_key = true
            else
                if in_key then
                    key = key .. char
                else
                    value = value .. char
                end
            end
        else
            -- Inside string
            if in_key then
                key = key .. char
            else
                value = value .. char
            end
        end
    end

    -- Handle last key-value pair if exists
    if key ~= "" and value ~= "" then
        local clean_key = key:match("^%s*(.-)%s*$"):gsub('^["\']', ''):gsub('["\']$', '')
        local clean_value = value:match("^%s*(.-)%s*$")

        if clean_value:match("^{") then
            obj[clean_key] = parse_object(clean_value:match("^{%s*(.-)%s*}$"))
        elseif clean_value:match("^%[") then
            obj[clean_key] = parse_array(clean_value)
        else
            obj[clean_key] = parse_value(clean_value)
        end
    end

    return obj
end

-- Main parse function
function parser.parse(content)
    -- Remove comments
    content = content:gsub("#[^\n]*", "")

    -- Find main object
    local main_content = content:match("{%s*(.-)%s*}%s*$")
    if not main_content then
        return nil, "Invalid BUFLO format: no main object found"
    end

    local result = parse_object(main_content)
    return result
end

-- Get fields from parsed profile in flat list
function parser.get_all_fields(profile)
    local fields = {}

    if not profile.pages then return fields end

    for _, page in ipairs(profile.pages) do
        if page.sections then
            for _, section in ipairs(page.sections) do
                parser.extract_fields_from_section(section, fields)
            end
        end
    end

    return fields
end

-- Recursively extract fields from section
function parser.extract_fields_from_section(section, fields)
    -- Direct fields array
    if section.fields then
        for _, field in ipairs(section.fields) do
            table.insert(fields, field)
        end
    end

    -- Column layouts
    if section.left then
        if section.left.fields then
            for _, field in ipairs(section.left.fields) do
                table.insert(fields, field)
            end
        end
    end

    if section.right then
        if section.right.logo then
            table.insert(fields, section.right.logo)
        end
        if section.right.fields then
            for _, field in ipairs(section.right.fields) do
                table.insert(fields, field)
            end
        end
    end

    -- Table columns (only if it's an array, not a number)
    if section.type == "table" and type(section.columns) == "table" then
        for _, col in ipairs(section.columns) do
            table.insert(fields, col)
        end
    end
end

-- Create pagination groups (6-8 fields per page)
function parser.paginate_fields(fields, fields_per_page)
    fields_per_page = fields_per_page or 7
    local pages = {}
    local current_page = {}

    for _, field in ipairs(fields) do
        -- Skip spacers and other non-input types
        if field.type ~= "spacer" then
            table.insert(current_page, field)

            if #current_page >= fields_per_page then
                table.insert(pages, current_page)
                current_page = {}
            end
        end
    end

    -- Add remaining fields
    if #current_page > 0 then
        table.insert(pages, current_page)
    end

    return pages
end

return parser
