_G.tools = {
  ui = {
    lazy_icons = {
      cmd = '󰝶 ',
      config = '󰮎 ',
      event = '󰲼 ',
      ft = '󱨧 ',
      init = '󰮍 ',
      import = '󰳞 ',
      keys = '󱞇 ',
      lazy = '',
      loaded = '󰦕 ',
      not_loaded = '󰦖 ',
      plugin = '󰗐 ',
      runtime = '󰪞 ',
      require = '󰗐 ',
      source = '󰮍 ',
      start = '󰣿 ',
      task = '󰾩 ',
      list = {
        '●',
        '➜',
        '★',
        '‒',
      },
    },
    icons = {
      branch = "",
      bullet = "•",
      open_bullet = "○",
      ok = "✔",
      d_chev = "∨",
      ellipses = "…",
      node = "╼",
      document = "≡",
      lock = "",
      r_chev = ">",
      warning = " ",
      error = " ",
      info = " ",
    },
  }
}

---@param c string
local function hexToRgb(c)
  c = string.lower(c)
  return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@param foreground string foreground color
---@param background string background color
---@param alpha number|string number between 0 and 1. 0 results in bg, 1 results in fg
local function blend(foreground, background, alpha)
  alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
  local bg = hexToRgb(background)
  local fg = hexToRgb(foreground)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

tools.bg = "#000000"
tools.fg = "#ffffff"

function tools.darken(hex, amount, bg)
  if vim.o.background == "dark" then
    -- if the background is dark, lighten instead
    return blend(hex, bg or tools.fg, amount)
  end
  return blend(hex, bg or tools.bg, amount)
end

function tools.lighten(hex, amount, fg)
  if vim.o.background == "light" then
    -- if the background is light, darken instead
    return blend(hex, fg or tools.bg, amount)
  end
  return blend(hex, fg or tools.fg, amount)
end

function tools.hl_str(hl, str)
  return "%#" .. hl .. "#" .. str .. "%*"
end

---Get a hl group's hex
---@param hl_group string
---@return table
function tools.get_hl_hex(hl_group)
  assert(hl_group, "Error: must have hl group name")

  local hl = vim.api.nvim_get_hl(0, { name = hl_group })

  return {
    fg = hl.fg and ("#%06x"):format(hl.fg) or nil,
    bg = hl.bg and ("#%06x"):format(hl.bg) or nil,
  }
end

local function get_cwd()
  local function realpath(path)
    if path == "" or path == nil then
      return nil
    end
    return vim.loop.fs_realpath(path) or path
  end

  return realpath(vim.loop.cwd()) or ""
end

-- files and directories -----------------------------
local branch_cache = setmetatable({}, { __mode = "k" })
local remote_cache = setmetatable({}, { __mode = "k" })

---@return fun():string
function tools.pretty_dirpath()
  return function()
    local path = vim.fn.expand("%:p") --[[@as string]]

    if path == "" then
      return ""
    end
    local cwd = get_cwd()

    if path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, "[\\/]")
    table.remove(parts)
    if #parts > 3 then
      parts = { parts[1], "… ", parts[#parts - 1], parts[#parts] }
    end

    return #parts > 0 and (table.concat(parts, sep)) or ""
  end
end

--- get the path to the root of the current file. The
-- root can be anything we define, such as ".git",
-- "Makefile", etc.
-- see https://www.reddit.com/r/neovim/comments/zy5s0l/you_dont_need_vimrooter_usually_or_how_to_set_up/
-- @tparam  path: file to get root of
-- @treturn path to the root of the filepath parameter
tools.get_path_root = function(path)
  if path == "" then return end

  local root = vim.b.path_root
  if root then return root end

  local root_items = {
    ".git",
  }

  root = vim.fs.root(path, root_items)
  if root == nil then return nil end
  if root then vim.b.path_root = root end
  return root
end

local function git_cmd(root, ...)
  -- tiny helper that returns stdout or nil+err
  local job = vim.system({ "git", "-C", root, ... }, { text = true }):wait()
  if job.code ~= 0 then return nil, job.stderr end
  return vim.trim(job.stdout)
end

-- get the name of the remote repository
tools.get_git_remote_name = function(root)
  if not root then return nil end
  if remote_cache[root] then return remote_cache[root] end

  local out = git_cmd(root, "config", "--get", "remote.origin.url")
  if not out then return nil end

  -- normalise to short repo name
  out = out:gsub(":", "/"):gsub("%.git$", ""):match("([^/]+/[^/]+)$")

  remote_cache[root] = out
  return out
end

function tools.get_git_branch(root)
  if not root then return nil end
  if branch_cache[root] then return branch_cache[root] end

  local out = git_cmd(root, "rev-parse", "--abbrev-ref", "HEAD")
  if out == "HEAD" then
    local commit = git_cmd(root, "rev-parse", "--short", "HEAD")
    commit = tools.hl_str("Comment", "(" .. commit .. ")")
    out = string.format("%s %s", out, commit)
  end

  branch_cache[root] = out

  return out
end

-- LSP -----------------------------
tools.diagnostics_available = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  local diagnostics = vim.lsp.protocol.Methods.textDocument_publishDiagnostics

  for _, cfg in pairs(clients) do
    if cfg:supports_method(diagnostics) then return true end
  end

  return false
end
