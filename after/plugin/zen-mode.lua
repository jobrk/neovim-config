vim.keymap.set("n", "<leader>g", ":ZenMode<cr>")

require("zen-mode").setup({
  window = {
    height = 1,
    width = 120,
  },
  plugins = {
    tmux = { enabled = true }
  }
})
