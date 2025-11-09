-- buflo/util/log.lua
-- Leveled logging with verbosity control

local M = {}

M.level = 0 -- 0=quiet, 1=normal, 2=verbose

function M.set_verbose(v)
  M.level = v and 2 or 1
end

function M.info(msg)
  if M.level >= 1 then
    io.stderr:write("[INFO] " .. msg .. "\n")
  end
end

function M.verbose(msg)
  if M.level >= 2 then
    io.stderr:write("[VERBOSE] " .. msg .. "\n")
  end
end

function M.error(msg)
  io.stderr:write("[ERROR] " .. msg .. "\n")
end

function M.warn(msg)
  if M.level >= 1 then
    io.stderr:write("[WARN] " .. msg .. "\n")
  end
end

return M
