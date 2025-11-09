#!/usr/bin/env lua
local SDL = require("SDL")
local ttf = require("SDL.ttf")

SDL.init({SDL.flags.Video})
ttf.init()

local window = SDL.createWindow{
  title = "Button Test",
  width = 400,
  height = 200,
}

local renderer = SDL.createRenderer(window, 0, 0)
local font = ttf.open("/usr/share/fonts/adwaita-sans-fonts/AdwaitaSans-Regular.ttf", 14)

print("Font loaded:", font ~= nil)

local running = true
while running do
  for event in SDL.pollEvent() do
    if event.type == SDL.event.Quit then
      running = false
    end
  end

  -- Clear
  renderer:setDrawColor({r=240, g=240, b=240, a=255})
  renderer:clear()

  -- Draw button background
  renderer:setDrawColor({r=0, g=120, b=215, a=255})
  renderer:fillRect({x=50, y=50, w=150, h=40})

  -- Draw button text
  local surface = font:renderUtf8("Test Button", "blended", {r=255, g=255, b=255, a=255})
  if surface then
    print("Surface created, size:", surface:getSize())
    local texture = renderer:createTextureFromSurface(surface)
    if texture then
      print("Texture created")
      local tw, th = surface:getSize()
      print("Text size:", tw, th)
      local text_x = 50 + (150 - tw) / 2
      local text_y = 50 + (40 - th) / 2
      print("Drawing at:", text_x, text_y, tw, th)
      renderer:copy(texture, nil, {x=text_x, y=text_y, w=tw, h=th})
    else
      print("Failed to create texture")
    end
  else
    print("Failed to create surface")
  end

  renderer:present()
  SDL.delay(100)
end

renderer:destroy()
window:destroy()
ttf.quit()
SDL.quit()
