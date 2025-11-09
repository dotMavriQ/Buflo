#!/usr/bin/env lua
-- buflo.lua
-- Main CLI entry point for BUFLO

package.path = package.path .. ";./?.lua;./?/init.lua"

local log = require("buflo.util.log")
local profile_loader = require("buflo.core.profile")

-- Parse command-line arguments
local function parse_args(args)
  local options = {
    profile_path = nil,
    batch = false,
    verbose = false,
    dry_run = false,
    preview_html = false,
    outdir = nil,
    data_file = nil,
  }

  local i = 1
  while i <= #args do
    local arg = args[i]

    if arg == "--batch" then
      options.batch = true

    elseif arg == "--verbose" or arg == "-v" then
      options.verbose = true

    elseif arg == "--dry-run" then
      options.dry_run = true

    elseif arg == "--preview-html" then
      options.preview_html = true

    elseif arg:match("^--outdir=") then
      options.outdir = arg:match("^--outdir=(.+)$")

    elseif arg:match("^--data=") then
      options.data_file = arg:match("^--data=(.+)$")

    elseif arg == "--help" or arg == "-h" then
      options.help = true

    elseif not arg:match("^%-") then
      if not options.profile_path then
        options.profile_path = arg
      end
    end

    i = i + 1
  end

  return options
end

local function print_usage()
  print([[
BUFLO — Billing Unified Flow Language & Orchestrator

USAGE:
  lua buflo.lua <profile.bpl.lua> [options]

OPTIONS:
  --batch              Run in batch mode (process multiple records)
  --verbose, -v        Enable verbose logging
  --dry-run            Validate but don't generate PDFs (batch mode only)
  --preview-html       Generate and open HTML preview (GUI mode)
  --outdir=<path>      Override output directory
  --data=<file>        Override batch data source (JSON/CSV)
  --help, -h           Show this help message

EXAMPLES:
  lua buflo.lua profiles/invoice.bpl.lua
  lua buflo.lua profiles/invoice.bpl.lua --batch --verbose
  lua buflo.lua profiles/invoice.bpl.lua --batch --data=data/q4.json

EXIT CODES:
  0  Success
  2  Validation error
  3  Render error
  4  PDF generation error
  5  I/O error
]])
end

local function main(args)
  local options = parse_args(args)

  if options.help then
    print_usage()
    return 0
  end

  -- If no profile specified, show welcome screen
  if not options.profile_path then
    log.info("No profile specified, launching welcome screen")

    -- Try SDL2 welcome screen first
    local ok_sdl, welcome = pcall(require, "buflo.gui_sdl.welcome")
    if ok_sdl then
      local action, profile_path = welcome.run()

      if action == "load" and profile_path then
        -- User selected a profile, load it
        options.profile_path = profile_path
      elseif action == "create" then
        print("Profile creation not yet implemented")
        return 0
      elseif action == "edit" and profile_path then
        print("Profile editing not yet implemented")
        return 0
      elseif action == "delete" then
        print("Profile deletion not yet implemented")
        return 0
      elseif action == "reminder" then
        print("Reminder scheduling not yet implemented")
        return 0
      else
        -- User quit or closed window
        return 0
      end
    else
      -- No GUI available, show help
      log.error("No profile specified and no GUI available")
      print_usage()
      return 1
    end
  end

  -- Set log level
  log.set_verbose(options.verbose)

  -- Load profile
  log.info("Loading profile: " .. options.profile_path)
  local profile, err = profile_loader.load(options.profile_path, log)

  if not profile then
    log.error("Failed to load profile: " .. err)
    return 2
  end

  -- Check dependencies
  local pdf = require("buflo.core.pdf")
  local deps_ok, deps_err = pdf.check_dependencies(log)
  if not deps_ok then
    log.error(deps_err)
    return 5
  end

  -- Determine mode
  if options.batch or (profile.batch and profile.batch.enabled) then
    -- Batch mode
    log.info("Running in batch mode")

    local batch = require("buflo.batch.runner")
    local success, results = batch.run(profile, options)

    if not success then
      log.error("Batch processing failed")
      return 4
    end

    return 0

  else
    -- GUI mode
    log.info("Launching GUI")

    -- Try SDL2 first (more likely to be available)
    local ok_sdl, sdl_gui = pcall(require, "buflo.gui_sdl.main")
    if ok_sdl then
      log.info("Using SDL2 GUI")
      local gui_ok = sdl_gui.run(profile, options.profile_path)
      return gui_ok and 0 or 1
    end

    -- Fall back to IUP
    local ok_iup, iup = pcall(require, "iuplua")
    if ok_iup then
      log.info("Using IUP GUI")
      iup.Open()
      local gui = require("buflo.gui.main")
      local gui_ok = gui.run(profile, options.profile_path)
      iup.Close()
      return gui_ok and 0 or 1
    end

    -- No GUI available
    log.error("No GUI framework available")
    log.error("Install either SDL2 or IUP:")
    log.error("  SDL2: luarocks install --local lua-sdl2")
    log.error("  IUP: sudo dnf install iup iup-lua (Fedora)")
    return 5
  end
end

-- Run main
local exit_code = main(arg)
os.exit(exit_code)
