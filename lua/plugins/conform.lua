-- Autoformat on save with per-filetype formatters
-- https://github.com/stevearc/conform.nvim

local formatting = require 'formatting'

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  init = function()
    vim.api.nvim_create_user_command('WebFormatter', function(args)
      local value = args.args
      if value ~= 'auto' and value ~= 'oxfmt' and value ~= 'prettier' then
        error 'Choose auto, oxfmt or prettier'
      end
      vim.b.web_formatter = value ~= 'auto' and value or nil
      vim.notify('Web formatter: ' .. formatting.web_formatter(0)[1])
    end, {
      nargs = 1,
      complete = function()
        return { 'auto', 'oxfmt', 'prettier' }
      end,
      desc = 'Choose this buffer’s web formatter',
    })
    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, { desc = 'Disable format-on-save (! for this buffer only)', bang = true })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, { desc = 'Re-enable format-on-save' })
  end,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = formatting.lsp_format(0) }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>tF',
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify('Format on save: ' .. (formatting.enabled(0) and 'on' or 'off') .. (vim.g.disable_autoformat and ' (globally disabled)' or ' (buffer)'))
      end,
      desc = '[T]oggle [F]ormat on save (buffer)',
    },
  },
  opts = function()
    local formatters = {
      go = { 'goimports' },
      lua = { 'stylua' },
      python = { 'ruff_organize_imports', 'ruff_format' },
    }
    for _, ft in ipairs(formatting.web_filetypes) do
      formatters[ft] = formatting.web_formatter
    end
    return {
      notify_on_error = true,
      formatters = {
        oxfmt = { cwd = require('conform.util').root_file(formatting.oxfmt_configs) },
      },
      format_on_save = function(bufnr)
        if formatting.enabled(bufnr) then
          return { timeout_ms = 5000, lsp_format = formatting.lsp_format(bufnr) }
        end
      end,
      formatters_by_ft = formatters,
    }
  end,
}
