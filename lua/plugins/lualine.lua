-- Statusline with git, diagnostics, and noice macro-recording status
-- https://github.com/nvim-lualine/lualine.nvim

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    sections = {
      lualine_a = {
        {
          function()
            return require('noice').api.status.mode.get()
          end,
          cond = function()
            return package.loaded.noice ~= nil and require('noice').api.status.mode.has()
          end,
        },
      },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { 'filename' },
      lualine_x = { 'filetype' },
      lualine_y = { 'location' },
      lualine_z = {},
    },
  },
}
