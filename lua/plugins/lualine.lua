return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require("lualine").setup({
      sections = {
        lualine_a = {
          {
            require("noice").api.status.mode.get,
            cond = require("noice").api.status.mode.has,
          },
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype' },
        lualine_y = { 'location' },
        lualine_z = {},
      },
    })
  end
}
