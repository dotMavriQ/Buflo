-- buflo/util/shell.lua
-- Execute shell commands with exit code and stderr capture

local M = {}

function M.exec(cmd, log)
  if log then
    log.verbose("Executing: " .. cmd)
  end

  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return false, "Failed to execute command", 1
  end

  local output = handle:read("*all")
  local success, exit_type, code = handle:close()

  if exit_type == "exit" then
    code = code or 0
  else
    code = 1
  end

  if log then
    if code == 0 then
      log.verbose("Command succeeded")
      if #output > 0 then
        log.verbose("Output: " .. output)
      end
    else
      log.error("Command failed with exit code " .. code)
      if #output > 0 then
        log.error("Output: " .. output)
      end
    end
  end

  return code == 0, output, code
end

function M.check_command(cmd)
  -- Check if a command exists using 'which'
  local handle = io.popen("which " .. cmd .. " 2>/dev/null")
  if not handle then
    return false
  end
  local result = handle:read("*all")
  handle:close()
  return result and #result > 0
end

return M
