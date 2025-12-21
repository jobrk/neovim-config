return {
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' }, -- Lazy load for Java files
    config = function()
      vim.lsp.enable 'jdtls'
    end,
  },
}
