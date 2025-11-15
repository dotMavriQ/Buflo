-- BUFLO - Profile Editor Screen (Placeholder)

local editor = {}
local ui = require("lib.ui")

local mode = "new"
local filename = ""
local content = ""

function editor.load(data)
    data = data or {}
    mode = data.mode or "new"
    filename = data.filename or ""

    if mode == "edit" and filename ~= "" then
        local file_content = love.filesystem.read("profiles/" .. filename)
        content = file_content or ""
    else
        -- New profile template
        content = [[# New Invoice Profile
invoice_number: "INV-{{@date:%Y%m%d}}-001"
date: @today
due_date: @calc(date + 30)

# Client Information
client_name: ""
client_email: ""
client_address: ""

# Invoice Items
items: [
    {
        description: "Service or Product"
        quantity: 1
        unit_price: 0.00
        total: @calc(quantity * unit_price)
    }
]

# Totals
subtotal: @calc(sum(items.total))
tax_rate: 0.25
tax: @calc(subtotal * tax_rate)
total: @calc(subtotal + tax)
]]
    end
end

function editor.update(dt)
    -- TODO: Implement editor logic
end

function editor.draw()
    ui.beginFrame()

    local w, h = love.graphics.getDimensions()

    -- Header
    love.graphics.setColor(0.9, 0.9, 0.9)
    local title = mode == "new" and "Create New Profile" or ("Edit: " .. filename)
    love.graphics.print(title, 20, 20)

    -- Editor area (simple for now)
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", 20, 60, w - 40, h - 140)

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", 20.5, 60.5, w - 41, h - 141)

    -- Content preview
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print(content, 30, 70)

    -- Buttons
    if ui.primaryButton("save", "Save", 20, h - 60, 120, 40) then
        -- TODO: Save logic
        switchScreen("welcome")
    end

    if ui.button("cancel", "Cancel", 160, h - 60, 120, 40) then
        switchScreen("welcome")
    end

    ui.endFrame()
end

return editor
