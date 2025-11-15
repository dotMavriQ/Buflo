-- BUFLO - Main LÖVE2D Entry Point

-- Load screens
local welcome_screen = require("screens.welcome")
local editor_screen = require("screens.editor")
local form_screen = require("screens.form")

-- Global state
local current_screen = "welcome"
local screens = {
    welcome = welcome_screen,
    editor = editor_screen,
    form = form_screen
}

-- Initialize
function love.load()
    -- Gruvbox Dark Material background
    love.graphics.setBackgroundColor(0.16, 0.15, 0.14)  -- #282828

    -- Load font
    local font_path = "assets/fonts/AdwaitaMono-Regular.ttf"
    if love.filesystem.getInfo(font_path) then
        love.graphics.setFont(love.graphics.newFont(font_path, 14))
    else
        love.graphics.setFont(love.graphics.newFont(14))
    end

    -- Initialize current screen
    if screens[current_screen].load then
        screens[current_screen].load()
    end
end

-- Update
function love.update(dt)
    if screens[current_screen].update then
        screens[current_screen].update(dt)
    end
end

-- Draw
function love.draw()
    if screens[current_screen].draw then
        screens[current_screen].draw()
    end
end

-- Input callbacks
function love.textinput(text)
    if screens[current_screen].textinput then
        screens[current_screen].textinput(text)
    end
end

function love.keypressed(key, scancode, isrepeat)
    if screens[current_screen].keypressed then
        screens[current_screen].keypressed(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if screens[current_screen].mousepressed then
        screens[current_screen].mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if screens[current_screen].mousereleased then
        screens[current_screen].mousereleased(x, y, button, istouch, presses)
    end
end

function love.wheelmoved(x, y)
    if screens[current_screen].wheelmoved then
        screens[current_screen].wheelmoved(x, y)
    end
end

-- Screen switching
function switchScreen(screen_name, data)
    current_screen = screen_name
    if screens[current_screen].load then
        screens[current_screen].load(data)
    end
end

-- Global helper: Get list of profile files
function getProfileList()
    local profiles = {}
    local items = love.filesystem.getDirectoryItems("profiles")

    for _, item in ipairs(items) do
        if item:match("%.buflo$") or item:match("%.toml$") then
            table.insert(profiles, item)
        end
    end

    table.sort(profiles)
    return profiles
end
