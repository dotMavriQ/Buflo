#!/usr/bin/env lua
local SDL = require("SDL")
local ttf = require("SDL.ttf")

SDL.init({SDL.flags.Video})
ttf.init()

local font = ttf.open("/usr/share/fonts/adwaita-sans-fonts/AdwaitaSans-Regular.ttf", 14)
print("Font loaded:", font ~= nil)

-- Test rendering
local surface = font:renderUtf8("Test Button", "blended", {r=255, g=255, b=255, a=255})
print("Surface created:", surface ~= nil)

if surface then
  local w, h = surface:getSize()
  print("Surface size:", w, h)
  print("Width:", w, "Height:", h)
end

ttf.quit()
SDL.quit()
