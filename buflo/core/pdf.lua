-- buflo/core/pdf.lua
-- PDF generation and merging pipeline

local M = {}

local fs = require("buflo.util.fs")
local shell = require("buflo.util.shell")

function M.check_dependencies(log)
  local missing = {}

  if not shell.check_command("wkhtmltopdf") then
    table.insert(missing, "wkhtmltopdf")
  end

  if not shell.check_command("qpdf") then
    table.insert(missing, "qpdf")
  end

  if #missing > 0 then
    local msg = "Missing required tools: " .. table.concat(missing, ", ") .. "\n"
    msg = msg .. "Install with: sudo dnf install " .. table.concat(missing, " ")
    msg = msg .. "\n  or: sudo apt install " .. table.concat(missing, " ")
    return false, msg
  end

  return true
end

function M.html_to_pdf(html, output_pdf, log)
  -- Write HTML to temp file
  local tmp_html = fs.temp_path("buflo_html", ".html")
  local ok, err = fs.writefile(tmp_html, html)
  if not ok then
    return false, "Failed to write temp HTML: " .. (err or "unknown error")
  end

  -- Ensure output directory exists
  local out_dir = fs.dirname(output_pdf)
  if out_dir then
    fs.mkdirp(out_dir)
  end

  -- Run wkhtmltopdf
  local cmd = string.format("wkhtmltopdf --quiet --enable-local-file-access %s %s",
    fs.shell_escape(tmp_html),
    fs.shell_escape(output_pdf))

  local success, output, code = shell.exec(cmd, log)

  -- Clean up temp HTML
  os.remove(tmp_html)

  if not success then
    return false, "wkhtmltopdf failed (exit " .. code .. "): " .. (output or "")
  end

  if not fs.exists(output_pdf) then
    return false, "PDF was not created"
  end

  return true
end

function M.merge_pdfs(pdf_list, output_pdf, log)
  -- Use qpdf to merge multiple PDFs
  -- qpdf --empty --pages file1.pdf file2.pdf -- output.pdf

  if #pdf_list == 0 then
    return false, "No PDFs to merge"
  end

  if #pdf_list == 1 then
    -- Just copy the single PDF
    local content, err = fs.slurp(pdf_list[1])
    if not content then
      return false, "Failed to read PDF: " .. err
    end
    return fs.writefile(output_pdf, content)
  end

  -- Build qpdf command
  local cmd_parts = {"qpdf --empty --pages"}
  for _, pdf in ipairs(pdf_list) do
    if not fs.exists(pdf) then
      return false, "PDF not found: " .. pdf
    end
    table.insert(cmd_parts, fs.shell_escape(pdf))
  end
  table.insert(cmd_parts, "--")
  table.insert(cmd_parts, fs.shell_escape(output_pdf))

  local cmd = table.concat(cmd_parts, " ")
  local success, output, code = shell.exec(cmd, log)

  if not success then
    return false, "qpdf failed (exit " .. code .. "): " .. (output or "")
  end

  if not fs.exists(output_pdf) then
    return false, "Merged PDF was not created"
  end

  return true
end

function M.generate_pdf(profile, data, log)
  local render = require("buflo.core.render")
  local interpolate = require("buflo.core.interpolate")

  -- Render HTML
  local html, err = render.render(profile, data)
  if not html then
    return nil, "Render failed: " .. err
  end

  -- Determine output path
  local output_path = interpolate.interpolate(profile.output_pattern, data)
  if interpolate.has_missing(output_path) then
    return nil, "Output path has missing placeholders: " .. output_path
  end

  -- Generate base PDF
  local tmp_pdf = fs.temp_path("buflo_base", ".pdf")
  local ok, pdf_err = M.html_to_pdf(html, tmp_pdf, log)
  if not ok then
    return nil, pdf_err
  end

  -- Handle trailing PDF if specified
  local trailing_pdf = nil
  if profile.trailing_pdf then
    if type(profile.trailing_pdf) == "function" then
      local func_ok, result = pcall(profile.trailing_pdf, data)
      if func_ok and result then
        trailing_pdf = result
      end
    else
      trailing_pdf = profile.trailing_pdf
    end

    -- Resolve relative to profile directory
    if trailing_pdf and not trailing_pdf:match("^/") then
      trailing_pdf = profile._dir .. trailing_pdf
    end
  end

  -- Handle annex from data (if field exists)
  local annex_pdf = data.annex
  if annex_pdf and annex_pdf ~= "" and not fs.exists(annex_pdf) then
    os.remove(tmp_pdf)
    return nil, "Annex PDF not found: " .. annex_pdf
  end

  -- Merge PDFs if needed
  local pdfs_to_merge = {tmp_pdf}

  if trailing_pdf and trailing_pdf ~= "" and fs.exists(trailing_pdf) then
    table.insert(pdfs_to_merge, trailing_pdf)
  end

  if annex_pdf and annex_pdf ~= "" and fs.exists(annex_pdf) then
    table.insert(pdfs_to_merge, annex_pdf)
  end

  local final_ok, final_err
  if #pdfs_to_merge > 1 then
    final_ok, final_err = M.merge_pdfs(pdfs_to_merge, output_path, log)
  else
    -- Just move the temp PDF
    local content, read_err = fs.slurp(tmp_pdf)
    if not content then
      os.remove(tmp_pdf)
      return nil, "Failed to read temp PDF: " .. read_err
    end
    final_ok, final_err = fs.writefile(output_path, content)
  end

  -- Clean up temp PDF
  os.remove(tmp_pdf)

  if not final_ok then
    return nil, final_err
  end

  return output_path
end

return M
