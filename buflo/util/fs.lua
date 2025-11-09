-- buflo/util/fs.lua
-- File system utilities: mkdirp, exists, read/write

local M = {}

function M.exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

function M.slurp(path)
  local f, err = io.open(path, "rb")
  if not f then
    return nil, err
  end
  local content = f:read("*all")
  f:close()
  return content
end

function M.writefile(path, content)
  local f, err = io.open(path, "wb")
  if not f then
    return nil, err
  end
  f:write(content)
  f:close()
  return true
end

function M.mkdirp(path)
  -- Create directory recursively
  -- Use mkdir -p on Linux/Unix
  local cmd = string.format("mkdir -p %s 2>&1", M.shell_escape(path))
  local handle = io.popen(cmd)
  if not handle then
    return false, "Failed to execute mkdir"
  end
  local result = handle:read("*all")
  local success, _, code = handle:close()
  if not success or code ~= 0 then
    return false, result
  end
  return true
end

function M.shell_escape(s)
  -- Escape single quotes for shell safety
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function M.dirname(path)
  return path:match("(.*/)")
end

function M.basename(path)
  return path:match("([^/]+)$")
end

function M.temp_path(prefix, suffix)
  local tmp = os.getenv("TMPDIR") or "/tmp"
  local name = string.format("%s/%s_%d_%d%s",
    tmp, prefix or "buflo", os.time(), math.random(10000, 99999), suffix or "")
  return name
end

function M.listdir(path)
  -- List files in a directory
  local files = {}
  local cmd = string.format("ls -1 %s 2>/dev/null", M.shell_escape(path))
  local handle = io.popen(cmd)
  if not handle then
    return files
  end
  for line in handle:lines() do
    table.insert(files, line)
  end
  handle:close()
  return files
end

return M
