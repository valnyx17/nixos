vim.loader.enable()

-- make sure to set `mapleader` before lazy
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- bootstrap package manager
local lazypath = vim.fn.stdpath("data") .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  print("Setting up lazy.nvim...")
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--single-branch", lazyrepo, lazypath })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.runtimepath:prepend(lazypath)

-- providers
-- :h provider.txt
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
  cache_enabled = 1
}

-- extui
require("vim._extui").enable({
  enable = true,
  msg = {
    pos = "cmd",
    box = {
      timeout = 4000,
    }
  }
})

-- turn off deprecation messages
vim.depecrate = function() end

require("globals")
require("set")
require("lsp")
require("maps")
require("aucmd")
require("cmd")
require("filetype")

require('lazy').setup("packages", {
  defaults = { lazy = false },
  install = { missing = false },
  change_detection = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "rPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    title_align = 'center',
    backdrop = 100,
    icons = tools.ui.lazy_icons,
  },
})

vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>", { desc = "Open Lazy" })

-- load colorscheme
vim.cmd("colorscheme ice-cave")
require("ui")
