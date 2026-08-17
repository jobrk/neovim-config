-- Eclipse JDT language server extensions for Java
-- https://github.com/mfussenegger/nvim-jdtls

return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' },
  config = function()
    vim.lsp.enable 'jdtls'
  end,
}
