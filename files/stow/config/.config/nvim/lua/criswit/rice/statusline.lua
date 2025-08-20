local M = {}

-- Get LSP status with server names
function M.get_lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return ""
  end
  
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  
  return "LSP [" .. table.concat(client_names, ", ") .. "]"
end

-- Get macro recording indicator
function M.get_macro_recording()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return ""
  else
    return "REC @" .. recording_register
  end
end

-- Get git diff statistics with icons
function M.get_git_diff()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns then
    return ""
  end
  
  local added = gitsigns.added or 0
  local changed = gitsigns.changed or 0  
  local removed = gitsigns.removed or 0
  
  local diff_info = {}
  if added > 0 then
    table.insert(diff_info, "+" .. added)
  end
  if changed > 0 then
    table.insert(diff_info, "~" .. changed)
  end
  if removed > 0 then
    table.insert(diff_info, "-" .. removed)
  end
  
  return table.concat(diff_info, " ")
end

-- Get current buffer information
function M.get_buffer_info()
  local buf_count = #vim.api.nvim_list_bufs()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  
  if buf_name == "" then
    return "[No Name]"
  end
  
  return vim.fn.fnamemodify(buf_name, ":t")
end

-- Get diagnostics count
function M.get_diagnostics_count()
  local diagnostics = vim.diagnostic.get(0)
  local error_count = 0
  local warn_count = 0
  local info_count = 0
  local hint_count = 0
  
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      error_count = error_count + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      warn_count = warn_count + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      info_count = info_count + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      hint_count = hint_count + 1
    end
  end
  
  local result = {}
  if error_count > 0 then
    table.insert(result, "E:" .. error_count)
  end
  if warn_count > 0 then
    table.insert(result, "W:" .. warn_count)
  end
  if info_count > 0 then
    table.insert(result, "I:" .. info_count)
  end
  if hint_count > 0 then
    table.insert(result, "H:" .. hint_count)
  end
  
  return table.concat(result, " ")
end

return M