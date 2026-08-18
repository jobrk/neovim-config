-- Autoformat on save with per-filetype formatters
-- https://github.com/stevearc/conform.nvim

-- Use oxfmt only when the project opts into it (has an oxfmt config file or
-- a project-local oxfmt install). Otherwise fall back to prettier so that
-- repos with prettier.config.js / .prettierrc keep using prettier.
--
-- `conform.get_formatter_info('oxfmt').available` returns true whenever the
-- binary is on PATH, which is always the case here because Mason installs
-- oxfmt into ~/.local/share/nvim/mason/bin — so it can't be used to detect
-- project intent.
local oxfmt_config_files = {
  '.oxfmtrc.json',
  '.oxfmtrc.jsonc',
  'oxfmt.config.ts',
  'oxfmt.config.mts',
  'oxfmt.config.cts',
  'oxfmt.config.js',
  'oxfmt.config.mjs',
  'oxfmt.config.cjs',
}

local function project_uses_oxfmt(bufnr)
  local dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  if not dirname or dirname == '' then
    return false
  end
  if vim.fs.root(dirname, oxfmt_config_files) then
    return true
  end
  -- Project-local install (node_modules/.bin/oxfmt) inside the buffer's tree.
  local node_bin = vim.fs.find('node_modules/.bin/oxfmt', { upward = true, path = dirname })[1]
  return node_bin ~= nil and vim.fn.executable(node_bin) == 1
end

local function web_formatter(bufnr)
  if project_uses_oxfmt(bufnr) then
    return { 'oxfmt' }
  end
  return { 'prettier' }
end

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  init = function()
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
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>tF',
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify('Format on save: ' .. (vim.b.disable_autoformat and 'off' or 'on') .. ' (buffer)')
      end,
      desc = '[T]oggle [F]ormat on save (buffer)',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
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
      go = { 'goimports' },
      graphql = web_formatter,
      javascript = web_formatter,
      javascriptreact = web_formatter,
      json = web_formatter,
      jsonc = web_formatter,
      lua = { 'stylua' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      typescript = web_formatter,
      typescriptreact = web_formatter,
      -- yaml = { 'prettier' },
    },
  },
}
