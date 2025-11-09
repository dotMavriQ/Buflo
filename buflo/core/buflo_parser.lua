-- BUFLO DSL Parser
-- Parses .buflo files with relaxed JSON syntax

local M = {}

-- Tokenizer for BUFLO DSL
local function tokenize(text)
    local tokens = {}
    local i = 1
    local line = 1
    local col = 1

    while i <= #text do
        local char = text:sub(i, i)

        -- Skip whitespace
        if char:match("%s") then
            if char == "\n" then
                line = line + 1
                col = 1
            else
                col = col + 1
            end
            i = i + 1

        -- Comments (# to end of line)
        elseif char == "#" then
            while i <= #text and text:sub(i, i) ~= "\n" do
                i = i + 1
            end

        -- Multi-line strings (""")
        elseif text:sub(i, i+2) == '"""' then
            i = i + 3
            local start = i
            local value = {}
            while i <= #text do
                if text:sub(i, i+2) == '"""' then
                    table.insert(tokens, {type = "string", value = table.concat(value), line = line, col = col})
                    i = i + 3
                    break
                end
                if text:sub(i, i) == "\n" then
                    line = line + 1
                    col = 1
                end
                table.insert(value, text:sub(i, i))
                i = i + 1
            end

        -- Regular strings (" or ')
        elseif char == '"' or char == "'" then
            local quote = char
            i = i + 1
            local value = {}
            while i <= #text and text:sub(i, i) ~= quote do
                if text:sub(i, i) == "\\" and i < #text then
                    i = i + 1
                    local escape = text:sub(i, i)
                    if escape == "n" then table.insert(value, "\n")
                    elseif escape == "t" then table.insert(value, "\t")
                    elseif escape == "\\" then table.insert(value, "\\")
                    else table.insert(value, escape)
                    end
                else
                    table.insert(value, text:sub(i, i))
                end
                i = i + 1
            end
            table.insert(tokens, {type = "string", value = table.concat(value), line = line, col = col})
            i = i + 1
            col = col + 1

        -- Numbers
        elseif char:match("[0-9%-]") then
            local start = i
            if char == "-" then i = i + 1 end
            while i <= #text and text:sub(i, i):match("[0-9]") do
                i = i + 1
            end
            if i <= #text and text:sub(i, i) == "." then
                i = i + 1
                while i <= #text and text:sub(i, i):match("[0-9]") do
                    i = i + 1
                end
            end
            local value = tonumber(text:sub(start, i-1))
            table.insert(tokens, {type = "number", value = value, line = line, col = col})
            col = col + (i - start)

        -- Special values (@today, @uuid, @calc(...))
        elseif char == "@" then
            local start = i
            i = i + 1
            while i <= #text and text:sub(i, i):match("[a-zA-Z_]") do
                i = i + 1
            end
            local keyword = text:sub(start+1, i-1)

            -- Check for @calc(...)
            if keyword == "calc" and i <= #text and text:sub(i, i) == "(" then
                i = i + 1
                local depth = 1
                local expr_start = i
                while i <= #text and depth > 0 do
                    if text:sub(i, i) == "(" then depth = depth + 1
                    elseif text:sub(i, i) == ")" then depth = depth - 1
                    end
                    i = i + 1
                end
                local expr = text:sub(expr_start, i-2)
                table.insert(tokens, {type = "special", value = "@calc", expr = expr, line = line, col = col})
            else
                table.insert(tokens, {type = "special", value = "@"..keyword, line = line, col = col})
            end
            col = col + (i - start)

        -- Identifiers (unquoted keys)
        elseif char:match("[a-zA-Z_]") then
            local start = i
            while i <= #text and text:sub(i, i):match("[a-zA-Z0-9_]") do
                i = i + 1
            end
            local value = text:sub(start, i-1)
            -- Check for boolean keywords
            if value == "true" then
                table.insert(tokens, {type = "boolean", value = true, line = line, col = col})
            elseif value == "false" then
                table.insert(tokens, {type = "boolean", value = false, line = line, col = col})
            elseif value == "null" then
                table.insert(tokens, {type = "null", value = nil, line = line, col = col})
            else
                table.insert(tokens, {type = "identifier", value = value, line = line, col = col})
            end
            col = col + (i - start)

        -- Punctuation
        elseif char == "{" then
            table.insert(tokens, {type = "lbrace", value = "{", line = line, col = col})
            i = i + 1
            col = col + 1
        elseif char == "}" then
            table.insert(tokens, {type = "rbrace", value = "}", line = line, col = col})
            i = i + 1
            col = col + 1
        elseif char == "[" then
            table.insert(tokens, {type = "lbracket", value = "[", line = line, col = col})
            i = i + 1
            col = col + 1
        elseif char == "]" then
            table.insert(tokens, {type = "rbracket", value = "]", line = line, col = col})
            i = i + 1
            col = col + 1
        elseif char == ":" then
            table.insert(tokens, {type = "colon", value = ":", line = line, col = col})
            i = i + 1
            col = col + 1
        elseif char == "," then
            table.insert(tokens, {type = "comma", value = ",", line = line, col = col})
            i = i + 1
            col = col + 1
        else
            error(string.format("Unexpected character '%s' at line %d, col %d", char, line, col))
        end
    end

    return tokens
end

-- Recursive descent parser
local function parse_value(tokens, pos)
    local token = tokens[pos]

    if not token then
        error("Unexpected end of input")
    end

    -- Object
    if token.type == "lbrace" then
        local obj = {}
        pos = pos + 1

        while tokens[pos] and tokens[pos].type ~= "rbrace" do
            -- Parse key
            local key_token = tokens[pos]
            local key
            if key_token.type == "identifier" or key_token.type == "string" then
                key = key_token.value
                pos = pos + 1
            else
                error(string.format("Expected key at line %d, col %d", key_token.line, key_token.col))
            end

            -- Expect colon
            if not tokens[pos] or tokens[pos].type ~= "colon" then
                error(string.format("Expected ':' at line %d", key_token.line))
            end
            pos = pos + 1

            -- Parse value
            local value, new_pos = parse_value(tokens, pos)
            obj[key] = value
            pos = new_pos

            -- Optional comma
            if tokens[pos] and tokens[pos].type == "comma" then
                pos = pos + 1
            end
        end

        if not tokens[pos] or tokens[pos].type ~= "rbrace" then
            error(string.format("Expected '}' at line %d", token.line))
        end
        return obj, pos + 1

    -- Array
    elseif token.type == "lbracket" then
        local arr = {}
        pos = pos + 1

        while tokens[pos] and tokens[pos].type ~= "rbracket" do
            local value, new_pos = parse_value(tokens, pos)
            table.insert(arr, value)
            pos = new_pos

            -- Optional comma
            if tokens[pos] and tokens[pos].type == "comma" then
                pos = pos + 1
            end
        end

        if not tokens[pos] or tokens[pos].type ~= "rbracket" then
            error(string.format("Expected ']' at line %d", token.line))
        end
        return arr, pos + 1

    -- Primitives
    elseif token.type == "string" then
        return token.value, pos + 1
    elseif token.type == "number" then
        return token.value, pos + 1
    elseif token.type == "boolean" then
        return token.value, pos + 1
    elseif token.type == "null" then
        return nil, pos + 1
    elseif token.type == "special" then
        -- Return as special value object for later expansion
        if token.expr then
            return {_buflo_special = token.value, _buflo_expr = token.expr}, pos + 1
        else
            return {_buflo_special = token.value}, pos + 1
        end
    else
        error(string.format("Unexpected token type '%s' at line %d, col %d", token.type, token.line, token.col))
    end
end

-- Parse BUFLO DSL text into Lua table
function M.parse(text)
    local tokens = tokenize(text)
    local result, pos = parse_value(tokens, 1)

    if pos <= #tokens then
        error(string.format("Unexpected tokens after end of input at line %d", tokens[pos].line))
    end

    return result
end

-- Load and parse a .buflo file
function M.load(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return nil, "Cannot open file: " .. filepath
    end

    local content = file:read("*all")
    file:close()

    local ok, result = pcall(M.parse, content)
    if not ok then
        return nil, "Parse error: " .. result
    end

    return result
end

-- Expand special values in parsed profile
function M.expand_special_values(profile, data)
    data = data or {}

    -- Helper to expand a single value
    local function expand_value(val)
        if type(val) == "table" and val._buflo_special then
            local special = val._buflo_special

            if special == "@today" then
                return os.date("%Y-%m-%d")
            elseif special == "@now" then
                return os.date("%Y-%m-%d %H:%M:%S")
            elseif special == "@uuid" then
                -- Simple UUID v4 generator
                local random = math.random
                local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
                return string.gsub(template, '[xy]', function(c)
                    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                    return string.format('%x', v)
                end)
            elseif special == "@calc" then
                -- Evaluate arithmetic expression with data context
                local expr = val._buflo_expr
                -- Create safe environment for evaluation
                local env = {
                    math = math,
                    tonumber = tonumber,
                    tostring = tostring,
                }
                -- Add data fields to environment
                for k, v in pairs(data) do
                    env[k] = v
                end
                -- Parse and evaluate expression
                local func, err = load("return " .. expr, "calc", "t", env)
                if not func then
                    error("Failed to evaluate @calc(" .. expr .. "): " .. err)
                end
                local ok, result = pcall(func)
                if not ok then
                    error("Error evaluating @calc(" .. expr .. "): " .. result)
                end
                return result
            end

            return val
        elseif type(val) == "table" then
            local expanded = {}
            for k, v in pairs(val) do
                expanded[k] = expand_value(v)
            end
            return expanded
        else
            return val
        end
    end

    return expand_value(profile)
end

-- Get form fields with defaults expanded
function M.get_fields_with_defaults(profile)
    local fields = profile.fields or {}
    local expanded = {}

    for i, field in ipairs(fields) do
        local f = {}
        for k, v in pairs(field) do
            f[k] = v
        end

        -- Expand special values in default
        if f.default and type(f.default) == "table" and f.default._buflo_special then
            f.default = M.expand_special_values(f.default, {})
        end

        table.insert(expanded, f)
    end

    return expanded
end

-- Evaluate computed fields with form data
function M.evaluate_computed(profile, data)
    local computed = profile.computed or {}
    local results = {}

    -- Create environment with form data
    local env = {}
    for k, v in pairs(data) do
        env[k] = v
    end

    -- Need to evaluate in dependency order
    -- For now, do multiple passes until all are resolved
    local remaining = {}
    for k, v in pairs(computed) do
        remaining[k] = v
    end

    local max_passes = 10
    local pass = 0
    while next(remaining) and pass < max_passes do
        pass = pass + 1
        local resolved_this_pass = {}

        for key, value in pairs(remaining) do
            if type(value) == "table" and value._buflo_special == "@calc" then
                local expr = value._buflo_expr
                local func, err = load("return " .. expr, "computed."..key, "t", env)
                if not func then
                    error("Failed to evaluate computed field '" .. key .. "': " .. err)
                end
                local ok, result = pcall(func)
                if ok then
                    results[key] = result
                    env[key] = result  -- Make available for other computed fields
                    table.insert(resolved_this_pass, key)
                end
                -- If not ok, try again in next pass
            else
                results[key] = value
                env[key] = value
                table.insert(resolved_this_pass, key)
            end
        end

        -- Remove resolved fields
        for _, key in ipairs(resolved_this_pass) do
            remaining[key] = nil
        end

        -- If we didn't resolve anything this pass, we have circular dependencies or errors
        if #resolved_this_pass == 0 and next(remaining) then
            local unresolved = {}
            for k in pairs(remaining) do
                table.insert(unresolved, k)
            end
            error("Cannot resolve computed fields (circular dependency or error): " .. table.concat(unresolved, ", "))
        end
    end

    return results
end

-- Interpolate template with data and helpers
function M.interpolate_template(template, data, computed)
    local all_data = {}

    -- Merge form data
    for k, v in pairs(data) do
        all_data[k] = v
    end

    -- Merge computed data
    for k, v in pairs(computed or {}) do
        all_data[k] = v
    end

    -- Helper functions
    local helpers = {
        currency = function(amount)
            return string.format("$%.2f", amount or 0)
        end,
        date = function(date_str)
            -- Simple date formatting (could be enhanced)
            return date_str or os.date("%Y-%m-%d")
        end,
        sum = function(...)
            local total = 0
            for _, v in ipairs({...}) do
                total = total + (tonumber(v) or 0)
            end
            return total
        end
    }

    local result = template

    -- Handle conditional blocks {{#if field}}...{{/if}} FIRST (before variable substitution)
    -- Use multiple passes to handle nested conditionals
    local max_iterations = 10
    for iteration = 1, max_iterations do
        local before = result
        result = result:gsub("{{#if%s+([^}]+)}}(.-){{/if}}", function(field, content)
            field = field:gsub("^%s+", ""):gsub("%s+$", "")
            local value = all_data[field]
            local should_show = value ~= nil and value ~= "" and value ~= false
            if should_show then
                return content
            else
                return ""
            end
        end)
        if result == before then break end  -- No more replacements
    end

    -- Now replace {{field}} and {{@helper(...)}}
    result = result:gsub("{{%s*([^}#/]+)%s*}}", function(expr)
        expr = expr:gsub("^%s+", ""):gsub("%s+$", "")  -- trim

        -- Check for helper function call
        local helper_name, args = expr:match("^@(%w+)%((.*)%)$")
        if helper_name and helpers[helper_name] then
            -- Parse arguments (simple split by comma)
            local arg_values = {}
            for arg in args:gmatch("[^,]+") do
                arg = arg:gsub("^%s+", ""):gsub("%s+$", "")
                -- Try to resolve as variable or keep as literal
                local val = all_data[arg] or arg
                table.insert(arg_values, val)
            end
            local ok, result = pcall(helpers[helper_name], table.unpack(arg_values))
            if ok then
                return tostring(result)
            else
                return "{{ERROR: " .. result .. "}}"
            end
        else
            -- Simple variable substitution
            return tostring(all_data[expr] or "")
        end
    end)

    return result
end

return M
