require("catppuccin").setup({
  flavour = "macchiato",
  integrations = {
    treesitter = true
  }
})

vim.cmd.colorscheme("catppuccin")
