vim.cmd.packadd('packer.nvim')

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use { 'catppuccin/nvim', as = 'catppuccin' }
  use 'folke/zen-mode.nvim'
  use { 'mg979/vim-visual-multi', branch = 'master' }
  use { 'neoclide/coc.nvim', branch = 'release' }
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lualine/lualine.nvim'
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.3',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons',
    },
  }
  use { 'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end }
  use 'nvim-treesitter/playground'
  use 'ryanoasis/vim-devicons'
  use 'tpope/vim-commentary'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-sensible'
  use 'tpope/vim-surround'
end)
