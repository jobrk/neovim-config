-- Catppuccin colorscheme (mocha flavour, transparent background)
-- https://github.com/catppuccin/nvim

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'mocha',
    transparent_background = true,
    float = {
      transparent = true,
    },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin'
    vim.cmd.hi 'Comment gui=none'
  end,
}
