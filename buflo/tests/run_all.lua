-- buflo/tests/run_all.lua
-- Test runner

print("=" .. string.rep("=", 60))
print("BUFLO Test Suite")
print("=" .. string.rep("=", 60))
print()

local tests = {
  "buflo/tests/test_interpolate.lua",
  "buflo/tests/test_profile.lua",
  "buflo/tests/test_render.lua",
}

local passed = 0
local failed = 0

for _, test_file in ipairs(tests) do
  print("Running " .. test_file .. "...")
  local ok, err = pcall(dofile, test_file)

  if ok then
    passed = passed + 1
    print()
  else
    failed = failed + 1
    print("FAILED: " .. err)
    print()
  end
end

print("=" .. string.rep("=", 60))
print(string.format("Results: %d passed, %d failed", passed, failed))
print("=" .. string.rep("=", 60))

os.exit(failed == 0 and 0 or 1)
