return {
  'catppuccin/nvim',
  version = 'v1.10.0',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'macchiato',
    transparent_background = true,
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme 'catppuccin'
    vim.cmd.hi 'Comment gui=none'
  end,
}
