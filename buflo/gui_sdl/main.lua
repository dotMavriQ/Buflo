-- buflo/gui_sdl/main.lua
-- Main SDL2 GUI window for BUFLO

local M = {}

local SDL = require("SDL")
local ttf = require("SDL.ttf")
local widgets = require("buflo.gui_sdl.widgets")
local form_builder = require("buflo.gui_sdl.form")
local profile_loader = require("buflo.core.profile")
local pdf = require("buflo.core.pdf")
local render = require("buflo.core.render")
local log = require("buflo.util.log")

function M.run(profile, profile_path)
  -- Check dependencies
  local ok, err = pdf.check_dependencies(log)
  if not ok then
    print("Error: " .. err)
    return false
  end

  -- Initialize SDL
  local ret, err = SDL.init({SDL.flags.Video})
  if not ret then
    print("Could not initialize SDL: " .. err)
    return false
  end

  -- Initialize TTF
  ret, err = ttf.init()
  if not ret then
    print("Could not initialize SDL_ttf: " .. err)
    SDL.quit()
    return false
  end

  -- Create window
  local window_width = 700
  local window_height = 600
  local profile_name = profile.name or profile.profile or "BUFLO"
  local window, err = SDL.createWindow{
    title = "BUFLO — " .. profile_name,
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

  -- Create renderer
  local renderer, err = SDL.createRenderer(window, 0, 0)
  if not renderer then
    print("Could not create renderer: " .. err)
    window:destroy()
    ttf.quit()
    SDL.quit()
    return false
  end

  -- Set blend mode for proper alpha blending
  renderer:setDrawBlendMode(SDL.blendMode.Blend)

  -- Load font (try system fonts)
  local font_paths = {
    "/usr/share/fonts/adwaita-sans-fonts/AdwaitaSans-Regular.ttf",
    "/usr/share/fonts/google-droid-sans-fonts/DroidSans.ttf",
    "/usr/share/fonts/google-carlito-fonts/Carlito-Regular.ttf",
    "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf",
    "/usr/share/fonts/liberation-sans/LiberationSans-Regular.ttf",
  }

  local font
  for _, path in ipairs(font_paths) do
    font = ttf.open(path, 14)
    if font then
      log.info("Loaded font: " .. path)
      break
    end
  end

  if not font then
    print("Could not load font - tried:")
    for _, path in ipairs(font_paths) do
      print("  " .. path)
    end
    if renderer then renderer:destroy() end
    if window then window:destroy() end
    ttf.quit()
    SDL.quit()
    return false
  end

  -- Get defaults (handle both .bpl.lua and .buflo formats)
  local defaults
  if profile._path and profile._path:match("%.buflo$") then
    -- For .buflo profiles, use parser to expand special values in defaults
    local buflo_parser = require("buflo.core.buflo_parser")
    local expanded_fields = buflo_parser.get_fields_with_defaults(profile)

    -- Extract defaults from expanded fields
    defaults = {}
    for _, field in ipairs(expanded_fields) do
      if field.default ~= nil then
        defaults[field.key] = field.default
      end
    end
  else
    -- For .bpl.lua profiles, use original method
    defaults = profile_loader.get_defaults(profile)
  end

  -- Build form
  local form = form_builder.build_form(profile, defaults, 20, 70, window_width - 40, font, ttf, renderer)

  -- Create buttons
  local button_y = window_height - 60
  local btn_generate = widgets.Button("Generate PDF", 20, button_y, 150, 40, font)
  local btn_preview = widgets.Button("Preview HTML", 190, button_y, 150, 40, font)
  local btn_quit = widgets.Button("Quit", window_width - 170, button_y, 150, 40, font)

  log.info("Created buttons: " .. btn_generate.text .. ", " .. btn_preview.text .. ", " .. btn_quit.text)

  -- Status message
  local status_text = "Ready"
  local status_color = {r=0, g=128, b=0, a=255}

  -- Button callbacks
  btn_generate.callback = function()
    local data = form:get_data()

    -- Validate
    local valid, valid_err = profile_loader.validate_data(profile, data)
    if not valid then
      status_text = "Error: " .. valid_err
      status_color = {r=255, g=0, b=0, a=255}
      return
    end

    -- Generate PDF
    status_text = "Generating PDF..."
    status_color = {r=0, g=120, b=215, a=255}

    local output_path, pdf_err = pdf.generate_pdf(profile, data, log)

    if not output_path then
      status_text = "Failed: " .. pdf_err
      status_color = {r=255, g=0, b=0, a=255}
    else
      status_text = "Success: " .. output_path
      status_color = {r=0, g=128, b=0, a=255}
    end
  end

  btn_preview.callback = function()
    local data = form:get_data()

    -- Validate
    local valid, valid_err = profile_loader.validate_data(profile, data)
    if not valid then
      status_text = "Error: " .. valid_err
      status_color = {r=255, g=0, b=0, a=255}
      return
    end

    -- Render HTML
    local html, render_err = render.render(profile, data)
    if not html then
      status_text = "Render error: " .. render_err
      status_color = {r=255, g=0, b=0, a=255}
      return
    end

    -- Save and open
    local fs = require("buflo.util.fs")
    local tmp = fs.temp_path("buflo_preview", ".html")
    fs.writefile(tmp, html)
    os.execute("xdg-open " .. fs.shell_escape(tmp) .. " &")

    status_text = "Preview opened in browser"
    status_color = {r=0, g=128, b=0, a=255}
  end

  btn_quit.callback = function()
    return "quit"
  end

  -- Enable text input
  SDL.startTextInput()

  -- Main loop
  local running = true
  while running do
    -- Handle events
    for event in SDL.pollEvent() do
      if event.type == SDL.event.Quit then
        running = false

      elseif event.type == SDL.event.MouseButtonDown then
        local x, y = event.x, event.y

        -- Check buttons
        if btn_generate:containsPoint(x, y) then
          local result = btn_generate:handleClick()
          if result == "quit" then running = false end
        elseif btn_preview:containsPoint(x, y) then
          local result = btn_preview:handleClick()
          if result == "quit" then running = false end
        elseif btn_quit:containsPoint(x, y) then
          local result = btn_quit:handleClick()
          if result == "quit" then running = false end
        else
          -- Check form fields
          form:handle_click(x, y)
        end

      elseif event.type == SDL.event.MouseMotion then
        local x, y = event.x, event.y
        btn_generate.hovered = btn_generate:containsPoint(x, y)
        btn_preview.hovered = btn_preview:containsPoint(x, y)
        btn_quit.hovered = btn_quit:containsPoint(x, y)

      elseif event.type == SDL.event.TextInput then
        form:handle_text_input(event.text)

      elseif event.type == SDL.event.KeyDown then
        local SDL_local = SDL
        -- Handle Tab for field navigation
        if event.keysym.sym == SDL_local.key.Tab then
          form:focus_next_field()
        else
          form:handle_key_down(event.keysym.sym)
        end
      end
    end

    -- Render
    renderer:setDrawColor({r=240, g=240, b=240, a=255})
    renderer:clear()

    -- Title
    local title_surface = font:renderUtf8("BUFLO — " .. profile_name, "blended", {r=0, g=0, b=0, a=255})
    if title_surface then
      local title_texture = renderer:createTextureFromSurface(title_surface)
      if title_texture then
        local tw, th = title_surface:getSize()
        renderer:copy(title_texture, nil, {x=20, y=20, w=tw, h=th})
      end
    end

    -- Form
    form:render(renderer, ttf)

    -- Buttons
    btn_generate:render(renderer, ttf)
    btn_preview:render(renderer, ttf)
    btn_quit:render(renderer, ttf)

    -- Status bar
    renderer:setDrawColor({r=220, g=220, b=220, a=255})
    renderer:fillRect({x=0, y=window_height - 25, w=window_width, h=25})

    local status_surface = font:renderUtf8(status_text, "blended", status_color)
    if status_surface then
      local status_texture = renderer:createTextureFromSurface(status_surface)
      if status_texture then
        local sw, sh = status_surface:getSize()
        renderer:copy(status_texture, nil, {x=10, y=window_height - 20, w=sw, h=sh})
      end
    end    renderer:present()
    SDL.delay(16) -- ~60 FPS
  end

  -- Cleanup
  SDL.stopTextInput()
  renderer:destroy()
  window:destroy()
  ttf.quit()
  SDL.quit()

  return true
end

return M
