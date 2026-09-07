-- Test runner with .NET, Go, Python, Rust, Jest, and Vitest adapters
-- https://github.com/nvim-neotest/neotest

local adapter_specs = {
  { plugin = 'Issafalcon/neotest-dotnet', module = 'neotest-dotnet' },
  { plugin = 'nvim-neotest/neotest-jest', module = 'neotest-jest' },
  { plugin = 'marilari88/neotest-vitest', module = 'neotest-vitest' },
  { plugin = 'fredrikaverpil/neotest-golang', module = 'neotest-golang' },
  { plugin = 'nvim-neotest/neotest-python', module = 'neotest-python' },
  { plugin = 'mrcjkb/rustaceanvim', module = 'rustaceanvim.neotest' },
}

local dependencies = {
  'nvim-neotest/nvim-nio',
  'nvim-lua/plenary.nvim',
  'nvim-treesitter/nvim-treesitter',
}
for _, adapter in ipairs(adapter_specs) do
  dependencies[#dependencies + 1] = adapter.plugin
end

return {
  'nvim-neotest/neotest',
  event = 'VeryLazy',
  dependencies = dependencies,
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
        require('neotest').run.run(vim.uv.cwd())
      end,
      desc = 'Test: run all',
    },
    {
      '<leader>td',
      function()
        local adapters = {
          python = 'python',
          rust = 'codelldb',
          go = 'go',
          cs = 'coreclr',
          javascript = 'pwa-node',
          javascriptreact = 'pwa-node',
          typescript = 'pwa-node',
          typescriptreact = 'pwa-node',
        }
        local adapter = adapters[vim.bo.filetype]
        if not adapter or not require('dap').adapters[adapter] then
          vim.notify('Test debugging is not configured for ' .. vim.bo.filetype, vim.log.levels.WARN)
          return
        end
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
    local adapters = vim.tbl_map(function(adapter)
      return require(adapter.module)
    end, adapter_specs)
    require('neotest').setup {
      adapters = adapters,
    }
  end,
}
