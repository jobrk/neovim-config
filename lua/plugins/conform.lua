-- Use oxfmt if the project has it installed, otherwise fall back to prettier.
local function web_formatter(bufnr)
  if require('conform').get_formatter_info('oxfmt', bufnr).available then
    return { 'oxfmt' }
  end
  return { 'prettier' }
end

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 5000,
        lsp_format = lsp_format_opt,
      }
    end,
    formatters_by_ft = {
      graphql = web_formatter,
      javascript = web_formatter,
      javascriptreact = web_formatter,
      json = web_formatter,
      jsonc = web_formatter,
      lua = { 'stylua' },
      typescript = web_formatter,
      typescriptreact = web_formatter,
      -- yaml = { 'prettier' },
    },
  },
}
