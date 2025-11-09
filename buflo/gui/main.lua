-- buflo/gui/main.lua
-- Main GUI window with form, actions, and status bar

local iup = require("iuplua")
local M = {}

local form_builder = require("buflo.gui.form")
local profile_loader = require("buflo.core.profile")
local pdf = require("buflo.core.pdf")
local render = require("buflo.core.render")
local fs = require("buflo.util.fs")
local log = require("buflo.util.log")

local STATE_FILE = os.getenv("HOME") .. "/.config/buflo/state.json"

function M.load_state(profile_path)
  if not fs.exists(STATE_FILE) then
    return {}
  end

  local content = fs.slurp(STATE_FILE)
  if not content then
    return {}
  end

  -- Simple JSON decode for state (just key-value pairs)
  local state = {}
  for key, value in content:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
    state[key] = value
  end

  return state
end

function M.save_state(profile_path, data)
  local dir = fs.dirname(STATE_FILE)
  if dir then
    fs.mkdirp(dir)
  end

  -- Simple JSON encode
  local parts = {"{"}
  for key, value in pairs(data) do
    if type(value) == "string" or type(value) == "number" then
      table.insert(parts, string.format('  "%s": "%s",', key, tostring(value)))
    end
  end
  table.insert(parts, "}")

  local json = table.concat(parts, "\n"):gsub(",\n}", "\n}")
  fs.writefile(STATE_FILE, json)
end

function M.create_window(profile, profile_path)
  local widgets
  local status_label
  local form

  -- Load previous state
  local state = M.load_state(profile_path)
  local initial_data = profile_loader.get_defaults(profile)

  -- Merge with saved state
  for k, v in pairs(state) do
    initial_data[k] = v
  end

  -- Build form
  form, widgets = form_builder.build_form(profile, initial_data)

  -- Status bar
  status_label = iup.label{
    title = "Ready",
    expand = "HORIZONTAL",
    padding = "5x5",
  }

  local status_frame = iup.frame{
    status_label,
    margin = "0x0",
  }

  local function set_status(msg, is_error)
    status_label.title = msg
    status_label.fgcolor = is_error and "255 0 0" or "0 128 0"
  end

  local function get_data()
    return form_builder.get_form_data(widgets)
  end

  -- Actions
  local btn_generate = iup.button{
    title = "Generate PDF",
    size = "100x30",
  }

  btn_generate.action = function()
    local data = get_data()

    -- Validate
    local valid, err = profile_loader.validate_data(profile, data)
    if not valid then
      set_status("Validation failed: " .. err, true)
      iup.Message("Validation Error", err)
      return
    end

    -- Generate PDF
    set_status("Generating PDF...", false)
    iup.LoopStep()

    local output_path, pdf_err = pdf.generate_pdf(profile, data, log)

    if not output_path then
      set_status("Failed: " .. pdf_err, true)
      iup.Message("PDF Generation Failed", pdf_err)
      return
    end

    set_status("Success: " .. output_path, false)

    -- Save state
    M.save_state(profile_path, data)

    iup.Message("Success", "PDF generated:\n" .. output_path)
  end

  local btn_preview = iup.button{
    title = "Preview HTML",
    size = "100x30",
  }

  btn_preview.action = function()
    local data = get_data()

    -- Validate
    local valid, err = profile_loader.validate_data(profile, data)
    if not valid then
      set_status("Validation failed: " .. err, true)
      iup.Message("Validation Error", err)
      return
    end

    -- Render HTML
    local html, render_err = render.render(profile, data)
    if not html then
      set_status("Render failed: " .. render_err, true)
      iup.Message("Render Error", render_err)
      return
    end

    -- Save to temp file and open
    local tmp = fs.temp_path("buflo_preview", ".html")
    fs.writefile(tmp, html)

    -- Try to open with xdg-open
    os.execute("xdg-open " .. fs.shell_escape(tmp) .. " &")

    set_status("Preview opened in browser", false)
  end

  local btn_open_output = iup.button{
    title = "Open Output Folder",
    size = "100x30",
  }

  btn_open_output.action = function()
    local out_dir = fs.dirname(profile.output_pattern) or "out"
    if not out_dir:match("^/") then
      out_dir = "./" .. out_dir
    end

    fs.mkdirp(out_dir)
    os.execute("xdg-open " .. fs.shell_escape(out_dir) .. " &")
  end

  local btn_quit = iup.button{
    title = "Quit",
    size = "100x30",
  }

  btn_quit.action = function()
    return iup.CLOSE
  end

  local button_box = iup.hbox{
    btn_generate,
    btn_preview,
    btn_open_output,
    iup.fill{},
    btn_quit,
    gap = 10,
    margin = "10x10",
  }

  -- Main layout
  local main_vbox = iup.vbox{
    form,
    iup.fill{size = "5"},
    button_box,
    status_frame,
    margin = "0x0",
  }

  local dlg = iup.dialog{
    main_vbox,
    title = "BUFLO — " .. profile.name,
    size = "600x",
    resize = "YES",
  }

  dlg.close_cb = function()
    -- Save state on close
    local data = get_data()
    M.save_state(profile_path, data)
    return iup.CLOSE
  end

  return dlg
end

function M.run(profile, profile_path)
  -- Check dependencies
  local ok, err = pdf.check_dependencies(log)
  if not ok then
    iup.Message("Missing Dependencies", err)
    return false
  end

  local dlg = M.create_window(profile, profile_path)
  dlg:showxy(iup.CENTER, iup.CENTER)

  iup.MainLoop()

  return true
end

return M
