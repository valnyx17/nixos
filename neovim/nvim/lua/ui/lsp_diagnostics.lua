local S = vim.diagnostic.severity
local icons = tools.ui.icons

local lsp_signs = {
  [S.ERROR] = { name = "Error", sym = icons["error"] },
  [S.WARN] = { name = "Warn", sym = icons["warn"] },
  [S.INFO] = { name = "Info", sym = icons["info"] },
  [S.HINT] = { name = "Hint", sym = icons["info"] },
}

local function diagformat(diag)
  local clean_src_names = {
    ["Lua Diagnostics."] = "lua",
    ["Lua Syntax Check."] = "lua",
  }

  local msg
  if not diag.code then return " " end

  msg = diag.message

  if diag.source then
    msg = string.format(
      "%s [%s]",
      msg,
      clean_src_names[diag.source] or diag.source
    )
  end

  return msg
end

vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  virtual_lines = {
    current_line = true,
    format = diagformat,
  },
  virtual_text = {
    prefix = "",
    current_line = false,
    format = diagformat,
  },
  float = {
    header = " ",
    source = "if_many",
    title = " Diagnostics ",
    prefix = function(diag)
      local lsp_sym = lsp_signs[diag.severity].sym
      local prefix = string.format(" %s  ", lsp_sym)

      local severity = vim.diagnostic.severity[diag.severity]
      local diag_hl_name = severity:sub(1, 1) .. severity:sub(2):lower()
      return prefix, "Diagnostic" .. diag_hl_name:gsub("^%l", string.upper)
    end,
  },
  signs = {
    text = {
      [S.ERROR] = icons.error,
      [S.HINT] = icons.info,
      [S.INFO] = icons.info,
      [S.WARN] = icons.warning
    },
  },
})
