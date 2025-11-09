-- buflo/tests/test_profile.lua
-- Unit tests for profile loading and validation

local profile_loader = require("buflo.core.profile")
local fs = require("buflo.util.fs")

local function test_valid_profile()
  local profile_code = [[
return {
  name = "Test Invoice",
  version = "1.0",
  output_pattern = "out/{{number}}.pdf",
  fields = {
    {key="number", label="Number", type="text", required=true},
  },
  render = function(data, helpers)
    return "<html><body>" .. helpers.esc(data.number) .. "</body></html>"
  end
}
]]

  local tmp_profile = "/tmp/test_profile.bpl.lua"
  fs.writefile(tmp_profile, profile_code)

  local profile, err = profile_loader.load(tmp_profile)

  assert(profile ~= nil, "Failed to load valid profile: " .. (err or ""))
  assert(profile.name == "Test Invoice", "Profile name mismatch")
  assert(#profile.fields == 1, "Fields not loaded")

  os.remove(tmp_profile)
  print("✓ Valid profile loading")
end

local function test_sandboxing()
  -- Profile should NOT be able to access io
  local malicious_code = [[
return {
  name = "Malicious",
  version = "1.0",
  output_pattern = "out/test.pdf",
  fields = {{key="test", label="Test", type="text"}},
  render = function(data)
    io.open("/etc/passwd", "r") -- This should fail
    return "<html></html>"
  end
}
]]

  local tmp_profile = "/tmp/test_malicious.bpl.lua"
  fs.writefile(tmp_profile, malicious_code)

  local profile, err = profile_loader.load(tmp_profile)

  -- Profile should load (sandboxing happens at load time, not render)
  -- But render will fail when called
  assert(profile ~= nil, "Profile should load")

  local render_mod = require("buflo.core.render")
  local html, render_err = render_mod.render(profile, {test="value"})

  -- Should fail because io is not available
  assert(html == nil, "Sandboxing failed: io should not be accessible")

  os.remove(tmp_profile)
  print("✓ Sandboxing (io blocked)")
end

local function test_missing_required_fields()
  local bad_profile = [[
return {
  name = "Bad Profile",
  -- missing version, output_pattern, fields, render
}
]]

  local tmp_profile = "/tmp/test_bad.bpl.lua"
  fs.writefile(tmp_profile, bad_profile)

  local profile, err = profile_loader.load(tmp_profile)

  assert(profile == nil, "Should reject incomplete profile")
  assert(err:match("version") or err:match("output_pattern"), "Should report missing field")

  os.remove(tmp_profile)
  print("✓ Missing required fields detection")
end

local function test_defaults()
  local profile = {
    fields = {
      {key="static", default="value"},
      {key="dynamic", default=function() return "computed" end},
      {key="no_default"},
    }
  }

  local defaults = profile_loader.get_defaults(profile)

  assert(defaults.static == "value", "Static default failed")
  assert(defaults.dynamic == "computed", "Dynamic default failed")
  assert(defaults.no_default == nil, "Should not have default")

  print("✓ Default values")
end

local function test_validation()
  local profile = {
    fields = {
      {key="required_field", label="Required", type="text", required=true},
      {key="optional_field", label="Optional", type="text"},
    },
    validate = function(data)
      if data.required_field == "bad" then
        return false, "Invalid value"
      end
      return true
    end
  }

  local ok1, err1 = profile_loader.validate_data(profile, {})
  assert(not ok1, "Should fail on missing required field")

  local ok2, err2 = profile_loader.validate_data(profile, {required_field="good"})
  assert(ok2, "Should pass validation: " .. (err2 or ""))

  local ok3, err3 = profile_loader.validate_data(profile, {required_field="bad"})
  assert(not ok3, "Custom validation should fail")
  assert(err3:match("Invalid"), "Should return custom error message")

  print("✓ Data validation")
end

-- Run all tests
local function run_tests()
  print("Running profile tests...")
  test_valid_profile()
  test_sandboxing()
  test_missing_required_fields()
  test_defaults()
  test_validation()
  print("All profile tests passed!")
end

run_tests()
