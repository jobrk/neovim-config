vim.keymap.set("n", "<leader>g", ":ZenMode<cr>")

require("zen-mode").setup({
  height = 1,
  width = 100,
  tmux = { enabled = false }
})
