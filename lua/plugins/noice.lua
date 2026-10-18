-- Floating cmdline and message UI
-- https://github.com/folke/noice.nvim

return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  opts = {
    popupmenu = { enabled = false },
    notify = { enabled = false },
    lsp = {
      progress = { enabled = false },
      hover = { enabled = false },
      signature = { enabled = false },
      message = { enabled = false },
    },
    health = { checker = false },
    -- NUI's default border style reads Neovim's winborder.
    views = {
      popup = { border = { style = 'default' } },
      cmdline_popup = { border = { style = 'default' } },
      cmdline_input = { border = { style = 'default' } },
      confirm = { border = { style = 'default' } },
    },
  },
}
