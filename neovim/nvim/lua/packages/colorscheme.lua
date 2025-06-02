return {
  {
    "mcauley-penney/ice-cave.nvim",
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme("ice-cave")
    end,
    lazy = false,
    priority = 1000
  }
}
