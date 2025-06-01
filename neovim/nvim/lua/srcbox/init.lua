require('srcbox.set')
require('srcbox.lsp')

-- make sure to set `mapleader` before lazy
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require('srcbox.globals')
    require('srcbox.keymaps')
    require('srcbox.statusline')
  end
})

require('srcbox.commands')
require('srcbox.autocmds')

local lazypath = vim.fn.stdpath("data") .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

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

local icons = {
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
}

local no_icons = {
  cmd = '',
  config = '',
  event = '',
  ft = '',
  init = '',
  import = '',
  keys = '',
  lazy = '',
  loaded = '',
  not_loaded = '',
  plugin = '',
  runtime = '',
  require = '',
  source = '',
  start = '',
  task = '',
  list = {
    '●',
    '➜',
    '★',
    '‒',
  },
}

require('lazy').setup({
  import = 'srcbox.packages'
}, {
  dev = {
    path = "~/Documents/ops/code/",
    patterns = { "solviarose" }
  },
  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = { "ice-cave", "default" },
  },
  change_detection = { notify = false },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = 'rounded',
    title = 'Plugins',
    backdrop = 100,
    title_align = 'center',
    icons = icons,
  },
})

vim.keymap.set("n", "<leader>ol", "<cmd>Lazy<cr>")

-- load colorscheme
vim.cmd("colorscheme ice-cave")
