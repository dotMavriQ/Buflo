-- buflo/gui_sdl/welcome.lua
-- Welcome screen for BUFLO with profile selection

local M = {}

local SDL = require("SDL")
local ttf = require("SDL.ttf")
local img = require("SDL.image")
local widgets = require("buflo.gui_sdl.widgets")
local log = require("buflo.util.log")
local fs = require("buflo.util.fs")

function M.run()
  -- Initialize SDL
  local ret, err = SDL.init({SDL.flags.Video})
  if not ret then
    print("Could not initialize SDL: " .. err)
    return nil, "SDL initialization failed"
  end

  -- Initialize TTF
  ret, err = ttf.init()
  if not ret then
    print("Could not initialize SDL_ttf: " .. err)
    SDL.quit()
    return nil, "TTF initialization failed"
  end

  -- Initialize IMG
  ret, err = img.init({img.flags.PNG})
  if not ret then
    print("Could not initialize SDL_image: " .. err)
    ttf.quit()
    SDL.quit()
    return nil, "Image initialization failed"
  end

  -- Create window
  local window_width = 700
  local window_height = 700
  local window, err = SDL.createWindow{
    title = "BUFLO — Billing Unified Flow Language & Orchestrator",
    width = window_width,
    height = window_height,
  }

  if not window then
    print("Could not create window: " .. err)
    img.quit()
    ttf.quit()
    SDL.quit()
    return nil, "Window creation failed"
  end

  -- Create renderer
  local renderer, err = SDL.createRenderer(window, 0, 0)
  if not renderer then
    print("Could not create renderer: " .. err)
    window:destroy()
    img.quit()
    ttf.quit()
    SDL.quit()
    return nil, "Renderer creation failed"
  end

  -- Set blend mode
  renderer:setDrawBlendMode(SDL.blendMode.Blend)

  -- Load fonts
  local font_paths = {
    "/usr/share/fonts/adwaita-sans-fonts/AdwaitaSans-Regular.ttf",
    "/usr/share/fonts/google-droid-sans-fonts/DroidSans.ttf",
    "/usr/share/fonts/google-carlito-fonts/Carlito-Regular.ttf",
  }

  local font_regular, font_large
  for _, path in ipairs(font_paths) do
    font_regular = ttf.open(path, 14)
    if font_regular then
      font_large = ttf.open(path, 24)
      log.info("Loaded font: " .. path)
      break
    end
  end

  if not font_regular then
    print("Could not load font")
    renderer:destroy()
    window:destroy()
    img.quit()
    ttf.quit()
    SDL.quit()
    return nil, "Font loading failed"
  end

  -- Load buffalo image
  local buffalo_texture = nil
  local buffalo_surface = img.load("buflo.png")
  if buffalo_surface then
    buffalo_texture = renderer:createTextureFromSurface(buffalo_surface)
    log.info("Loaded buffalo image")
  else
    log.warn("Could not load buflo.png")
  end

-- Scan profiles directory for .buflo files
local function scan_profiles()
    local fs = require("buflo.util.fs")
    local files = fs.listdir("./profiles")
    local profiles = {}

    for _, file in ipairs(files) do
        if file:match("%.buflo$") then
            table.insert(profiles, file)
        end
    end

    table.sort(profiles)
    return profiles
end  local profiles = scan_profiles()
  local selected_profile_idx = 1

  -- Create buttons aligned with sections
  -- Section 1 (y=300, h=100) - Load button centered below, but outside the box
  local btn_load = widgets.Button("Load Profile", 250, 408, 200, 35, font_regular)

  -- Section 2 (y=425, h=90) - Three management buttons side by side
  local btn_create = widgets.Button("Create New Profile", 65, 455, 170, 35, font_regular)
  local btn_edit = widgets.Button("Edit Profile", 250, 455, 170, 35, font_regular)
  local btn_delete = widgets.Button("Delete Profile", 435, 455, 170, 35, font_regular)

  -- Section 3 (y=540, h=80) - Reminder button centered
  local btn_reminder = widgets.Button("Schedule Reminder", 200, 570, 300, 35, font_regular)

  -- Quit button at bottom
  local btn_quit = widgets.Button("Quit", 300, 640, 100, 35, font_regular)  -- Button callbacks
  local selected_profile = nil

  btn_load.callback = function()
    if #profiles > 0 then
      selected_profile = "profiles/" .. profiles[selected_profile_idx]
      return "load"
    end
  end

  btn_create.callback = function()
    -- Open profile editor for new file
    local editor = require("buflo.gui_sdl.profile_editor")
    local result, modified = editor.run(nil, "New Profile")

    if result == "saved" then
      -- Rescan profiles
      profiles = scan_profiles()
      if #profiles > 0 then
        selected_profile_idx = #profiles  -- Select the newly created one
      end
    end

    return nil  -- Stay on welcome screen
  end

  btn_edit.callback = function()
    if #profiles > 0 then
      local filepath = "profiles/" .. profiles[selected_profile_idx]
      local editor = require("buflo.gui_sdl.profile_editor")
      local result, modified = editor.run(filepath, profiles[selected_profile_idx])

      if result == "saved" then
        -- Rescan in case filename changed
        profiles = scan_profiles()
      end
    end
    return nil  -- Stay on welcome screen
  end

  btn_delete.callback = function()
    if #profiles > 0 then
      -- TODO: Show confirmation dialog
      local filepath = "profiles/" .. profiles[selected_profile_idx]
      os.remove(filepath)

      -- Rescan profiles
      profiles = scan_profiles()
      if selected_profile_idx > #profiles then
        selected_profile_idx = math.max(1, #profiles)
      end
    end
    return nil  -- Stay on welcome screen
  end

  btn_reminder.callback = function()
    return "reminder"
  end

  btn_quit.callback = function()
    return "quit"
  end

  -- Main loop
  local running = true
  local result = nil

  while running do
    -- Handle events
    for event in SDL.pollEvent() do
      if event.type == SDL.event.Quit then
        running = false

      elseif event.type == SDL.event.MouseButtonDown then
        local x, y = event.x, event.y

        -- Check buttons
        if btn_load:containsPoint(x, y) then
          result = btn_load:handleClick()
          if result then running = false end
        elseif btn_create:containsPoint(x, y) then
          result = btn_create:handleClick()
          if result then running = false end
        elseif btn_edit:containsPoint(x, y) then
          result = btn_edit:handleClick()
          if result then running = false end
        elseif btn_delete:containsPoint(x, y) then
          result = btn_delete:handleClick()
          if result then running = false end
        elseif btn_reminder:containsPoint(x, y) then
          result = btn_reminder:handleClick()
          if result then running = false end
        elseif btn_quit:containsPoint(x, y) then
          result = btn_quit:handleClick()
          if result then running = false end
        end

      elseif event.type == SDL.event.MouseMotion then
        local x, y = event.x, event.y
        btn_load.hovered = btn_load:containsPoint(x, y)
        btn_create.hovered = btn_create:containsPoint(x, y)
        btn_edit.hovered = btn_edit:containsPoint(x, y)
        btn_delete.hovered = btn_delete:containsPoint(x, y)
        btn_reminder.hovered = btn_reminder:containsPoint(x, y)
        btn_quit.hovered = btn_quit:containsPoint(x, y)

      elseif event.type == SDL.event.KeyDown then
        if event.keysym.sym == SDL.key.Up and selected_profile_idx > 1 then
          selected_profile_idx = selected_profile_idx - 1
        elseif event.keysym.sym == SDL.key.Down and selected_profile_idx < #profiles then
          selected_profile_idx = selected_profile_idx + 1
        elseif event.keysym.sym == SDL.key.Return then
          if #profiles > 0 then
            selected_profile = "profiles/" .. profiles[selected_profile_idx]
            result = "load"
            running = false
          end
        end
      end
    end

    -- Render
    renderer:setDrawColor({r=245, g=245, b=245, a=255})
    renderer:clear()

    -- Draw buffalo image
    if buffalo_texture then
      local img_w, img_h = 150, 150
      local img_x = (window_width - img_w) / 2
      renderer:copy(buffalo_texture, nil, {x=img_x, y=30, w=img_w, h=img_h})
    end

    -- Draw title
    local title_y = buffalo_texture and 190 or 40
    local title_surface = font_large:renderUtf8("BUFLO", "blended", {r=0, g=0, b=0, a=255})
    if title_surface then
      local title_texture = renderer:createTextureFromSurface(title_surface)
      if title_texture then
        local tw, th = title_surface:getSize()
        renderer:copy(title_texture, nil, {x=(window_width-tw)/2, y=title_y, w=tw, h=th})
      end
    end

    -- Draw subtitle
    local subtitle_surface = font_regular:renderUtf8("Billing Unified Flow Language & Orchestrator", "blended", {r=80, g=80, b=80, a=255})
    if subtitle_surface then
      local subtitle_texture = renderer:createTextureFromSurface(subtitle_surface)
      if subtitle_texture then
        local sw, sh = subtitle_surface:getSize()
        renderer:copy(subtitle_texture, nil, {x=(window_width-sw)/2, y=title_y+40, w=sw, h=sh})
      end
    end

    -- Draw version
    local version_surface = font_regular:renderUtf8("Version 1.0.0", "blended", {r=120, g=120, b=120, a=255})
    if version_surface then
      local version_texture = renderer:createTextureFromSurface(version_surface)
      if version_texture then
        local vw, vh = version_surface:getSize()
        renderer:copy(version_texture, nil, {x=(window_width-vw)/2, y=title_y+65, w=vw, h=vh})
      end
    end

    -- Draw profile section
    local section1_y = 300
    renderer:setDrawColor({r=255, g=255, b=255, a=255})
    renderer:fillRect({x=50, y=section1_y, w=600, h=100})
    renderer:setDrawColor({r=200, g=200, b=200, a=255})
    renderer:drawRect({x=50, y=section1_y, w=600, h=100})

    local profile_label = font_regular:renderUtf8("📄 Select Profile:", "blended", {r=0, g=0, b=0, a=255})
    if profile_label then
      local pl_tex = renderer:createTextureFromSurface(profile_label)
      if pl_tex then
        local pw, ph = profile_label:getSize()
        renderer:copy(pl_tex, nil, {x=65, y=section1_y+10, w=pw, h=ph})
      end
    end

    -- Draw profile list
    if #profiles > 0 then
      local profile_text = profiles[selected_profile_idx]
      local prof_surface = font_regular:renderUtf8(profile_text, "blended", {r=0, g=0, b=0, a=255})
      if prof_surface then
        local prof_tex = renderer:createTextureFromSurface(prof_surface)
        if prof_tex then
          local prw, prh = prof_surface:getSize()
          renderer:copy(prof_tex, nil, {x=65, y=section1_y+38, w=prw, h=prh})
        end
      end

      -- Draw arrow hint
      local hint_surface = font_regular:renderUtf8("(Use ↑↓ arrows or click Load)", "blended", {r=100, g=100, b=100, a=255})
      if hint_surface then
        local hint_tex = renderer:createTextureFromSurface(hint_surface)
        if hint_tex then
          local hw, hh = hint_surface:getSize()
          renderer:copy(hint_tex, nil, {x=65, y=section1_y+63, w=hw, h=hh})
        end
      end
    else
      local no_prof = font_regular:renderUtf8("No profiles found in ./profiles/", "blended", {r=150, g=0, b=0, a=255})
      if no_prof then
        local np_tex = renderer:createTextureFromSurface(no_prof)
        if np_tex then
          local npw, nph = no_prof:getSize()
          renderer:copy(np_tex, nil, {x=65, y=section1_y+38, w=npw, h=nph})
        end
      end
    end

    -- Profile editing section
    local section2_y = 425
    renderer:setDrawColor({r=255, g=255, b=255, a=255})
    renderer:fillRect({x=50, y=section2_y, w=600, h=90})
    renderer:setDrawColor({r=200, g=200, b=200, a=255})
    renderer:drawRect({x=50, y=section2_y, w=600, h=90})

    local edit_label = font_regular:renderUtf8("✏️  Profile Management:", "blended", {r=0, g=0, b=0, a=255})
    if edit_label then
      local el_tex = renderer:createTextureFromSurface(edit_label)
      if el_tex then
        local ew, eh = edit_label:getSize()
        renderer:copy(el_tex, nil, {x=65, y=section2_y+10, w=ew, h=eh})
      end
    end

    -- Reminder section
    local section3_y = 540
    renderer:setDrawColor({r=255, g=255, b=255, a=255})
    renderer:fillRect({x=50, y=section3_y, w=600, h=80})
    renderer:setDrawColor({r=200, g=200, b=200, a=255})
    renderer:drawRect({x=50, y=section3_y, w=600, h=80})

    local remind_label = font_regular:renderUtf8("⏰ Reminders:", "blended", {r=0, g=0, b=0, a=255})
    if remind_label then
      local rl_tex = renderer:createTextureFromSurface(remind_label)
      if rl_tex then
        local rw, rh = remind_label:getSize()
        renderer:copy(rl_tex, nil, {x=65, y=section3_y+10, w=rw, h=rh})
      end
    end

    -- Draw all buttons (after sections so they appear on top)
    btn_load:render(renderer, ttf)
    btn_create:render(renderer, ttf)
    btn_edit:render(renderer, ttf)
    btn_delete:render(renderer, ttf)
    btn_reminder:render(renderer, ttf)
    btn_quit:render(renderer, ttf)

    renderer:present()
    SDL.delay(16) -- ~60 FPS
  end

  -- Cleanup (SDL objects are garbage collected automatically)
  img.quit()
  ttf.quit()
  SDL.quit()

  return result, selected_profile
end

return M
