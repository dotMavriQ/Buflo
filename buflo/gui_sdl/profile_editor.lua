-- buflo/gui_sdl/profile_editor.lua
-- Profile editor with syntax highlighting for .buflo files

local M = {}

local SDL = require("SDL")
local ttf = require("SDL.ttf")

-- Syntax highlighting colors
local COLORS = {
  background = {r=30, g=30, b=30, a=255},
  text = {r=220, g=220, b=220, a=255},
  comment = {r=106, g=153, b=85, a=255},      -- Green for #comments
  key = {r=156, g=220, b=254, a=255},          -- Light blue for keys
  string = {r=206, g=145, b=120, a=255},       -- Orange for strings
  number = {r=181, g=206, b=168, a=255},       -- Light green for numbers
  special = {r=220, g=220, b=170, a=255},      -- Yellow for @today, @uuid, etc.
  punctuation = {r=212, g=212, b=212, a=255},  -- Light gray for {}, [], :, ,
  error = {r=244, g=71, b=71, a=255},          -- Red for errors
  line_number = {r=80, g=80, b=80, a=255},     -- Dark gray for line numbers
  cursor = {r=255, g=255, b=255, a=255},       -- White cursor
  selection = {r=38, g=79, b=120, a=128},      -- Blue selection (with alpha)
  current_line = {r=40, g=40, b=40, a=255},    -- Slightly lighter background for current line
}

-- Tokenize .buflo content for syntax highlighting
local function tokenize_buflo(text)
  local tokens = {}
  local i = 1
  local line = 1
  local col = 1

  while i <= #text do
    local char = text:sub(i, i)
    local token_start = i
    local token_line = line
    local token_col = col

    -- Newlines
    if char == "\n" then
      table.insert(tokens, {
        type = "newline",
        value = "\n",
        line = line,
        col = col,
        start_pos = i,
        end_pos = i
      })
      line = line + 1
      col = 1
      i = i + 1

    -- Whitespace (spaces, tabs)
    elseif char:match("%s") then
      local ws = {}
      while i <= #text and text:sub(i, i):match("%s") and text:sub(i, i) ~= "\n" do
        table.insert(ws, text:sub(i, i))
        col = col + 1
        i = i + 1
      end
      table.insert(tokens, {
        type = "whitespace",
        value = table.concat(ws),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Comments (# to end of line)
    elseif char == "#" then
      local comment = {}
      while i <= #text and text:sub(i, i) ~= "\n" do
        table.insert(comment, text:sub(i, i))
        i = i + 1
      end
      table.insert(tokens, {
        type = "comment",
        value = table.concat(comment),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })
      col = col + #comment

    -- Multi-line strings (""")
    elseif text:sub(i, i+2) == '"""' then
      local str = {'"""'}
      i = i + 3
      col = col + 3
      local found_end = false

      while i <= #text do
        if text:sub(i, i+2) == '"""' then
          table.insert(str, '"""')
          i = i + 3
          found_end = true
          break
        end
        if text:sub(i, i) == "\n" then
          line = line + 1
          col = 1
        else
          col = col + 1
        end
        table.insert(str, text:sub(i, i))
        i = i + 1
      end

      table.insert(tokens, {
        type = found_end and "string" or "error",
        value = table.concat(str),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Regular strings (" or ')
    elseif char == '"' or char == "'" then
      local quote = char
      local str = {char}
      i = i + 1
      col = col + 1
      local found_end = false

      while i <= #text and text:sub(i, i) ~= quote do
        if text:sub(i, i) == "\\" and i < #text then
          table.insert(str, text:sub(i, i))
          i = i + 1
          col = col + 1
          if i <= #text then
            table.insert(str, text:sub(i, i))
            i = i + 1
            col = col + 1
          end
        elseif text:sub(i, i) == "\n" then
          break  -- Unterminated string
        else
          table.insert(str, text:sub(i, i))
          i = i + 1
          col = col + 1
        end
      end

      if i <= #text and text:sub(i, i) == quote then
        table.insert(str, quote)
        i = i + 1
        col = col + 1
        found_end = true
      end

      table.insert(tokens, {
        type = found_end and "string" or "error",
        value = table.concat(str),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Numbers
    elseif char:match("[0-9]") or (char == "-" and i < #text and text:sub(i+1, i+1):match("[0-9]")) then
      local num = {}
      if char == "-" then
        table.insert(num, char)
        i = i + 1
        col = col + 1
      end
      while i <= #text and text:sub(i, i):match("[0-9]") do
        table.insert(num, text:sub(i, i))
        i = i + 1
        col = col + 1
      end
      if i <= #text and text:sub(i, i) == "." then
        table.insert(num, ".")
        i = i + 1
        col = col + 1
        while i <= #text and text:sub(i, i):match("[0-9]") do
          table.insert(num, text:sub(i, i))
          i = i + 1
          col = col + 1
        end
      end
      table.insert(tokens, {
        type = "number",
        value = table.concat(num),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Special values (@today, @uuid, @calc, etc.)
    elseif char == "@" then
      local special = {"@"}
      i = i + 1
      col = col + 1

      -- Get identifier
      while i <= #text and text:sub(i, i):match("[a-zA-Z_]") do
        table.insert(special, text:sub(i, i))
        i = i + 1
        col = col + 1
      end

      -- Check for @calc(...)
      if text:sub(i, i) == "(" then
        local depth = 0
        repeat
          table.insert(special, text:sub(i, i))
          if text:sub(i, i) == "(" then depth = depth + 1
          elseif text:sub(i, i) == ")" then depth = depth - 1 end
          i = i + 1
          col = col + 1
        until depth == 0 or i > #text
      end

      table.insert(tokens, {
        type = "special",
        value = table.concat(special),
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Identifiers and keywords (unquoted keys)
    elseif char:match("[a-zA-Z_]") then
      local ident = {}
      while i <= #text and text:sub(i, i):match("[a-zA-Z0-9_]") do
        table.insert(ident, text:sub(i, i))
        i = i + 1
        col = col + 1
      end
      local value = table.concat(ident)

      -- Check if it's followed by a colon (then it's a key)
      local next_non_ws = i
      while next_non_ws <= #text and text:sub(next_non_ws, next_non_ws):match("%s") and text:sub(next_non_ws, next_non_ws) ~= "\n" do
        next_non_ws = next_non_ws + 1
      end

      local token_type = "text"
      if next_non_ws <= #text and text:sub(next_non_ws, next_non_ws) == ":" then
        token_type = "key"
      elseif value == "true" or value == "false" or value == "null" then
        token_type = "special"
      end

      table.insert(tokens, {
        type = token_type,
        value = value,
        line = token_line,
        col = token_col,
        start_pos = token_start,
        end_pos = i - 1
      })

    -- Punctuation
    elseif char:match("[{}%[%]:,]") then
      table.insert(tokens, {
        type = "punctuation",
        value = char,
        line = token_line,
        col = token_col,
        start_pos = i,
        end_pos = i
      })
      i = i + 1
      col = col + 1

    -- Unknown character
    else
      table.insert(tokens, {
        type = "error",
        value = char,
        line = token_line,
        col = token_col,
        start_pos = i,
        end_pos = i
      })
      i = i + 1
      col = col + 1
    end
  end

  return tokens
end

-- Editor state
local function create_editor_state(content)
  return {
    content = content or "",
    lines = {},  -- Will be populated
    cursor_line = 1,
    cursor_col = 1,
    cursor_pos = 1,  -- Character position in content
    scroll_offset = 0,  -- Line scroll offset
    selection_start = nil,
    selection_end = nil,
    modified = false,
    tokens = {},
  }
end

-- Split content into lines
local function update_lines(state)
  state.lines = {}
  local current_line = {}

  for i = 1, #state.content do
    local char = state.content:sub(i, i)
    if char == "\n" then
      table.insert(state.lines, table.concat(current_line))
      current_line = {}
    else
      table.insert(current_line, char)
    end
  end

  -- Add last line
  table.insert(state.lines, table.concat(current_line))

  -- Ensure at least one empty line
  if #state.lines == 0 then
    state.lines = {""}
  end

  -- Re-tokenize
  state.tokens = tokenize_buflo(state.content)
end

-- Convert cursor position to line/col
local function pos_to_line_col(state, pos)
  local line = 1
  local col = 1

  for i = 1, math.min(pos - 1, #state.content) do
    if state.content:sub(i, i) == "\n" then
      line = line + 1
      col = 1
    else
      col = col + 1
    end
  end

  return line, col
end

-- Convert line/col to position
local function line_col_to_pos(state, line, col)
  local pos = 1

  for l = 1, math.min(line - 1, #state.lines) do
    pos = pos + #state.lines[l] + 1  -- +1 for newline
  end

  pos = pos + math.min(col - 1, #(state.lines[line] or ""))

  return pos
end

function M.run(filepath, profile_name)
  -- Load existing file or create new
  local content = ""
  if filepath then
    local file = io.open(filepath, "r")
    if file then
      content = file:read("*all")
      file:close()
    end
  else
    -- Template for new profile
    content = [[{
  profile: "New Profile",
  version: "1.0",
  description: "Description here",

  fields: [
    {
      key: "field1",
      label: "Field 1",
      type: "text",
      required: true
    }
  ],

  computed: {
    # Add computed fields here
  },

  output: {
    filename: "output_{{field1}}.pdf",
    directory: "out/"
  },

  pages: [
    {
      name: "Page 1",
      template: """
<!DOCTYPE html>
<html>
<head><title>Document</title></head>
<body>
  <h1>{{field1}}</h1>
</body>
</html>
      """
    }
  ]
}
]]
  end

  -- Initialize SDL
  local ret, err = SDL.init({SDL.flags.Video})
  if not ret then
    print("Could not initialize SDL: " .. err)
    return false
  end

  ret, err = ttf.init()
  if not ret then
    print("Could not initialize SDL_ttf: " .. err)
    SDL.quit()
    return false
  end

  -- Create window
  local window_width = 1000
  local window_height = 700
  local title = "BUFLO Profile Editor"
  if profile_name then
    title = title .. " — " .. profile_name
  end

  local window, err = SDL.createWindow{
    title = title,
    width = window_width,
    height = window_height,
    flags = {SDL.window.Resizable}
  }

  if not window then
    print("Could not create window: " .. err)
    ttf.quit()
    SDL.quit()
    return false
  end

  local renderer, err = SDL.createRenderer(window, 0, 0)
  if not renderer then
    print("Could not create renderer: " .. err)
    ttf.quit()
    SDL.quit()
    return false
  end

  renderer:setDrawBlendMode(SDL.blendMode.Blend)

  -- Load monospace font
  local font_paths = {
    "/usr/share/fonts/adwaita-mono-fonts/AdwaitaMono-Regular.ttf",
    "/usr/share/fonts/liberation-mono-fonts/LiberationMono-Regular.ttf",
    "/usr/share/fonts/dejavu-sans-mono-fonts/DejaVuSansMono.ttf",
    "/usr/share/fonts/google-droid-sans-mono-fonts/DroidSansMono.ttf",
  }

  local font
  for _, path in ipairs(font_paths) do
    font = ttf.open(path, 14)
    if font then break end
  end

  if not font then
    print("Could not load monospace font")
    ttf.quit()
    SDL.quit()
    return false
  end

  -- Editor state
  local state = create_editor_state(content)
  update_lines(state)

  -- UI state
  local line_number_width = 60
  local char_width = 9  -- Approximate character width for monospace font
  local line_height = 18
  local top_margin = 5
  local left_margin = line_number_width + 10
  local cursor_blink = true
  local cursor_timer = 0

  -- Main loop
  local running = true
  local result = "cancel"
  local saved_filepath = filepath  -- Track where to save

  while running do
    cursor_timer = cursor_timer + 16
    if cursor_timer > 500 then
      cursor_blink = not cursor_blink
      cursor_timer = 0
    end

    -- Event handling
    for event in SDL.pollEvent() do
      if event.type == SDL.event.Quit then
        running = false

      elseif event.type == SDL.event.TextInput then
        -- Insert text at cursor
        local text = event.text
        local before = state.content:sub(1, state.cursor_pos - 1)
        local after = state.content:sub(state.cursor_pos)
        state.content = before .. text .. after
        state.cursor_pos = state.cursor_pos + #text
        state.modified = true
        update_lines(state)
        cursor_blink = true
        cursor_timer = 0

      elseif event.type == SDL.event.KeyDown then
        local key = event.keysym.sym
        local mod = event.keysym.mod
        local ctrl = (mod & SDL.keymod.Ctrl) ~= 0
        local shift = (mod & SDL.keymod.Shift) ~= 0

        if ctrl and key == SDL.key.s then
          -- Save
          local save_to = saved_filepath
          if not save_to then
            -- TODO: Prompt for filename
            save_to = "profiles/new_profile.buflo"
          end

          local file = io.open(save_to, "w")
          if file then
            file:write(state.content)
            file:close()
            state.modified = false
            saved_filepath = save_to
            result = "saved"
          end

        elseif ctrl and key == SDL.key.q or key == SDL.key.Escape then
          running = false

        elseif key == SDL.key.Backspace then
          if state.cursor_pos > 1 then
            local before = state.content:sub(1, state.cursor_pos - 2)
            local after = state.content:sub(state.cursor_pos)
            state.content = before .. after
            state.cursor_pos = state.cursor_pos - 1
            state.modified = true
            update_lines(state)
          end
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Delete then
          if state.cursor_pos <= #state.content then
            local before = state.content:sub(1, state.cursor_pos - 1)
            local after = state.content:sub(state.cursor_pos + 1)
            state.content = before .. after
            state.modified = true
            update_lines(state)
          end

        elseif key == SDL.key.Return then
          -- Insert newline
          local before = state.content:sub(1, state.cursor_pos - 1)
          local after = state.content:sub(state.cursor_pos)
          state.content = before .. "\n" .. after
          state.cursor_pos = state.cursor_pos + 1
          state.modified = true
          update_lines(state)
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Left then
          if state.cursor_pos > 1 then
            state.cursor_pos = state.cursor_pos - 1
          end
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Right then
          if state.cursor_pos <= #state.content then
            state.cursor_pos = state.cursor_pos + 1
          end
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Up then
          local line, col = pos_to_line_col(state, state.cursor_pos)
          if line > 1 then
            local new_line = line - 1
            local target_col = math.min(col, #state.lines[new_line] + 1)
            state.cursor_pos = line_col_to_pos(state, new_line, target_col)
          end
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Down then
          local line, col = pos_to_line_col(state, state.cursor_pos)
          if line < #state.lines then
            local new_line = line + 1
            local target_col = math.min(col, #state.lines[new_line] + 1)
            state.cursor_pos = line_col_to_pos(state, new_line, target_col)
          end
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.Home then
          -- Go to start of line
          local line, col = pos_to_line_col(state, state.cursor_pos)
          state.cursor_pos = line_col_to_pos(state, line, 1)
          cursor_blink = true
          cursor_timer = 0

        elseif key == SDL.key.End then
          -- Go to end of line
          local line, col = pos_to_line_col(state, state.cursor_pos)
          state.cursor_pos = line_col_to_pos(state, line, #state.lines[line] + 1)
          cursor_blink = true
          cursor_timer = 0
        end
      end
    end

    -- Render
    renderer:setDrawColor(COLORS.background)
    renderer:clear()

    -- Calculate visible lines
    local cursor_line, cursor_col = pos_to_line_col(state, state.cursor_pos)
    local visible_lines = math.floor((window_height - top_margin * 2) / line_height)

    -- Adjust scroll to keep cursor visible
    if cursor_line < state.scroll_offset + 1 then
      state.scroll_offset = cursor_line - 1
    elseif cursor_line > state.scroll_offset + visible_lines then
      state.scroll_offset = cursor_line - visible_lines
    end
    state.scroll_offset = math.max(0, state.scroll_offset)

    -- Render lines with syntax highlighting
    local y = top_margin

    for line_idx = state.scroll_offset + 1, math.min(#state.lines, state.scroll_offset + visible_lines) do
      -- Highlight current line background
      if line_idx == cursor_line then
        renderer:setDrawColor(COLORS.current_line)
        renderer:fillRect({x=0, y=y, w=window_width, h=line_height})
      end

      -- Render line number
      local line_num_text = string.format("%4d", line_idx)
      local ln_surface = font:renderUtf8(line_num_text, "blended", COLORS.line_number)
      if ln_surface then
        local ln_texture = renderer:createTextureFromSurface(ln_surface)
        if ln_texture then
          local _, _, w, h = ln_texture:query()
          renderer:copy(ln_texture, nil, {x=10, y=y + 2, w=w, h=h})
        end
      end

      -- Render line content with syntax highlighting
      local line_text = state.lines[line_idx]
      local x = left_margin

      -- Find tokens for this line
      for _, token in ipairs(state.tokens) do
        if token.line == line_idx and token.type ~= "newline" then
          local color = COLORS[token.type] or COLORS.text
          local token_surface = font:renderUtf8(token.value, "blended", color)

          if token_surface then
            local token_texture = renderer:createTextureFromSurface(token_surface)
            if token_texture then
              local _, _, w, h = token_texture:query()
              renderer:copy(token_texture, nil, {x=x, y=y + 2, w=w, h=h})
              x = x + w
            end
          end
        end
      end

      -- Render cursor on current line
      if line_idx == cursor_line and cursor_blink then
        local cursor_x = left_margin + (cursor_col - 1) * char_width
        renderer:setDrawColor(COLORS.cursor)
        renderer:fillRect({x=cursor_x, y=y + 2, w=2, h=line_height - 4})
      end

      y = y + line_height
    end

    -- Render status bar at bottom
    local status_bg_y = window_height - 25
    renderer:setDrawColor({r=50, g=50, b=50, a=255})
    renderer:fillRect({x=0, y=status_bg_y, w=window_width, h=25})

    local status_text = string.format("Line %d, Col %d  |  %d lines  |  %s%s",
      cursor_line, cursor_col, #state.lines,
      state.modified and "● " or "",
      saved_filepath or "Unsaved")

    local status_surface = font:renderUtf8(status_text, "blended", {r=200, g=200, b=200, a=255})
    if status_surface then
      local status_texture = renderer:createTextureFromSurface(status_surface)
      if status_texture then
        local _, _, w, h = status_texture:query()
        renderer:copy(status_texture, nil, {x=10, y=status_bg_y + 4, w=w, h=h})
      end
    end

    renderer:present()
    SDL.delay(16)
  end

  -- Cleanup
  ttf.quit()
  SDL.quit()

  return result, state.modified
end

return M
