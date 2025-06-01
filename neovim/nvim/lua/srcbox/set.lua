vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
local set = vim.opt
local o = vim.o
local g = vim.g
vim.cmd [[
let &t_Cs = "\e[4:3m"
let &t_Ce = "\e[4:0m"
]]
set.hlsearch = true
set.cmdheight = 1
set.guicursor = {
  "n-v:block-Cursor/lCursor",
  "i-c-ci-ve:ver35-DiagnosticOk",
  "r-cr-o:hor20-DiagnosticError"
}
set.iskeyword:remove({ ".", "_", "$" })
set.showtabline = 1
set.laststatus = 3
set.signcolumn = "auto:2"
set.foldcolumn = "auto:1"
set.relativenumber = true
set.number = true
set.mouse = "a"
set.mousescroll = "ver:8,hor:6"
set.mousemoveevent = true
set.tabstop = 4
set.vartabstop = "4" -- all tabs represented as four spaces
set.shiftwidth = 0   -- tabstop
set.softtabstop = -1 -- use shiftwidth
set.expandtab = true -- <Tab> inserts spaces, ^V<Tab> inserts <Tab>
set.ignorecase = true
set.smartcase = true
set.inccommand = "split"
set.splitright = true
set.splitbelow = true
set.linebreak = true
set.breakindent = true
set.wrap = false
set.textwidth = 120
set.breakindentopt = {
  shift = 2
}
set.showbreak = "↪ "
set.updatetime = 200 -- time until swap write, also used for CursorHold
set.completeopt = { "menu", "menuone", "noinsert", "noselect" } -- display always, force user to select and insert
set.backup = true
set.writebackup = true
set.backupdir = { vim.fn.stdpath('state') .. "/backup" }
set.exrc = true
set.concealcursor = ""
set.conceallevel = 2    -- :h cole
set.confirm = true      -- instead of failing, confirm when a ! could be appended to force
set.showmode = false
set.history = 1000      -- cmd history size
set.scrolloff = 8
set.sidescrolloff = 8   -- Makes sure there are always eight lines of context
set.undofile = true
set.smoothscroll = true -- scrolling works with screen lines
set.sessionoptions = {
  -- :h 'sessionoptions'
  "buffers",
  "curdir",
  "folds",
  -- "help",
  "tabpages",
  "winsize",
  -- "globals",
  -- "terminal",
  -- "options",
}
set.wildoptions = set.wildoptions + "fuzzy"
set.whichwrap = set.whichwrap + "<,>,[,],b,s"
set.diffopt = {
  -- :h 'diffopt'
  "vertical",
  "iwhite",
  "hiddenoff",
  "foldcolumn:0",
  "context:4",
  "algorithm:histogram",
  "indent-heuristic",
  "linematch:60",
}
set.cursorline = true
set.foldlevel = 99
set.foldlevelstart = 99
--set.foldmethod = "expr"
--set.foldexpr = "nvim_treesitter#foldexpr()"
set.foldmethod = "indent"
set.foldtext = ""
set.fillchars = {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
  --eob = " ",
  eob = "~",
  -- eob = "╼",
  fold = " ",
  -- foldopen = "",
  foldsep = " ",
  -- foldclose = v.ui.icons.r_chev,
  -- foldopen = v.ui.icons.d_chev,
  foldclose = " ",
  foldopen = " ",
  diff = "╱", -- alts: = ⣿ ░ ─
  msgsep = "━", -- alts:   ‾ ─
  stl = " ", -- alts: ─ ⣿ ░ ▐ ▒▓
  stlnc = " ", -- alts: ─
}
set.list = true
set.listchars = {
  extends = "›", -- alts: … » ▸
  precedes = "‹", -- alts: … « ◂
  trail = "·", -- alts: • BULLET (U+2022, UTF-8: E2 80 A2)
  tab = "  ", -- alts: »  »│ │ →
  nbsp = "◇", -- alts: ⦸ ␣
  eol = nil, -- alts: 󰌑
}
set.timeoutlen = 250
set.termguicolors = true
set.pumheight = 25     -- pop up menu height
set.smartindent = true -- make indenting smarter again
set.showcmd = false    -- Don't show the command in the last line
set.ruler = false      -- Don't show the ruler
set.title = false      -- don't set the title of window to the value of the titlestring
set.belloff = "all"    -- I NEVER WANT TO HEAR THE BELL.
set.visualbell = false
set.ttyfast = true     -- let vim know i am using a fast term
set.autoread = true
set.wildmode = {       -- shell-like autocomplete to unambiguous portions
  "longest",
  "list",
  "full",
}
set.formatoptions = set.formatoptions
    - "a" -- dont autoformat
    - "t" -- dont autoformat my code, have linters for that
    + "c" -- auto wrap comments using textwith
    + "q" -- formmating of comments w/ `gq`
    -- + "l" -- long lines are not broken up
    + "j" -- remove comment leader when joining comments
    + "r" -- continue comment with enter
    - "o" -- but not w/ o and o, dont continue comments
    + "n" -- smart auto indenting inside numbered lists
    - "2" -- this is not grade school anymore
set.shortmess = set.shortmess
    + "A" -- ignore annoying swapfile messages
    + "I" -- no spash screen
    + "O" -- file-read message overrites previous
    + "T" -- truncate non-file messages in middle
    + "W" -- don't echo '[w]/[written]' when writing
    + "a" -- use abbreviations in message '[ro]' instead of '[readonly]'
    + "o" -- overwrite file-written mesage
    + "t" -- truncate file messages at start
    + "c" -- dont show matching messages
set.joinspaces = true
set.clipboard = vim.opt.clipboard + "unnamedplus"
