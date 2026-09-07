-- Rust LSP extensions and Neotest integration (uses cargo test without nextest).
return {
  'mrcjkb/rustaceanvim',
  version = '^9',
  lazy = false, -- Rustaceanvim loads itself per Rust buffer.
  dependencies = { 'mason-org/mason.nvim', 'mfussenegger/nvim-dap', 'saghen/blink.cmp' },
  init = function()
    vim.g.rustaceanvim = function()
      return {
        server = { capabilities = require('lsp').capabilities() },
        dap = { adapter = require('dap').adapters.codelldb },
      }
    end
  end,
}
