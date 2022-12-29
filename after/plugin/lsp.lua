require("neodev").setup({})

local lsp = require('lsp-zero')

lsp.preset('recommended')

lsp.ensure_installed({
  'tsserver',
  'eslint',
  'sumneko_lua',
  'rust_analyzer',
})

lsp.configure('sumneko_lua', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      },
      workspace = {
        checkThirdParty = false,
      },
    }
  }
})

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
})
