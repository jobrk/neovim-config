return {
  'folke/zen-mode.nvim',
  cmd = 'ZenMode',
  keys = {
    {
      '<leader>z',
      ':ZenMode<CR>',
      desc = '[z]en Mode',
      silent = true,
    },
  },
  opts = {
    window = {
      height = 1,
      width = 140,
    },
    plugins = {
      tmux = { enabled = true },
    },
  },
}
