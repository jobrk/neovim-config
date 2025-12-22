return {
  'nvim-neotest/neotest',
  requires = {
    {
      'Issafalcon/neotest-dotnet',
      'nvim-neotest/neotest-jest',
      'marilari88/neotest-vitest',
      'rcasia/neotest-java',
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
    'nvim-neotest/neotest-jest',
    'marilari88/neotest-vitest',
    'rcasia/neotest-java',
  },
  keys = {
    {
      '<leader>tt',
      function()
        require('neotest').run.run()
      end,
      desc = 'Test: run nearest',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Test: run file',
    },
    {
      '<leader>ta',
      function()
        require('neotest').run.run(vim.loop.cwd())
      end,
      desc = 'Test: run all',
    },
    {
      '<leader>td',
      function()
        require('neotest').run.run { strategy = 'dap' }
      end,
      desc = 'Test: debug nearest',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Test: toggle summary',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open { enter = true, auto_close = true }
      end,
      desc = 'Test: show output',
    },
    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = 'Test: toggle output panel',
    },
    {
      '<leader>tw',
      function()
        require('neotest').watch.toggle(vim.fn.expand '%')
      end,
      desc = 'Test: watch file',
    },
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-dotnet',
        require 'neotest-jest',
        require 'neotest-vitest',
        require 'neotest-java',
      },
    }
  end,
}
