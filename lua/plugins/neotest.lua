return {
  'nvim-neotest/neotest',
  requires = {
    {
      'Issafalcon/neotest-dotnet',
    },
  },
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    {
      'Issafalcon/neotest-dotnet',
      lazy = false,
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-dotnet',
      },
    }
  end,
}
