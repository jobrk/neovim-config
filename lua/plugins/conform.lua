-- Autoformat on save with per-filetype formatters
-- https://github.com/stevearc/conform.nvim

local web_filetypes = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'less',
  'markdown',
  'scss',
  'svelte',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

local prettier_configs = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.json5',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  '.prettierrc.ts',
  '.prettierrc.cts',
  '.prettierrc.mts',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
  'prettier.config.ts',
  'prettier.config.cts',
  'prettier.config.mts',
}
local oxfmt_configs = { '.oxfmtrc.json', '.oxfmtrc.jsonc', 'oxfmt.config.ts', 'oxfmt.config.mts' }

local function has_config(directory, names)
  for _, name in ipairs(names) do
    if vim.fn.filereadable(directory .. '/' .. name) == 1 then
      return true
    end
  end
  return false
end

local function web_formatter(bufnr)
  local override = vim.b[bufnr].web_formatter
  if override == 'prettier' or override == 'oxfmt' then
    return { override }
  end
  local directory = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  while directory and directory ~= '' do
    local package_file = directory .. '/package.json'
    local package_prettier = false
    if vim.fn.filereadable(package_file) == 1 then
      local ok, package = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_file), '\n'))
      package_prettier = ok and type(package) == 'table' and package.prettier ~= nil
    end
    -- Nearest explicit config wins; Prettier wins ties. Installed binaries
    -- alone do not override a project's formatting convention.
    if package_prettier or has_config(directory, prettier_configs) then
      return { 'prettier' }
    end
    if has_config(directory, oxfmt_configs) then
      return { 'oxfmt' }
    end
    if vim.uv.fs_stat(directory .. '/.git') then
      break
    end
    local parent = vim.fs.dirname(directory)
    if parent == directory then
      break
    end
    directory = parent
  end
  return { 'prettier' }
end

local function lsp_format(bufnr)
  local ft = vim.bo[bufnr].filetype
  return (ft == 'c' or ft == 'cpp' or vim.tbl_contains(web_filetypes, ft)) and 'never' or 'fallback'
end

local function autoformat_enabled(bufnr)
  return not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat)
end

return {
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
      vim.notify('Web formatter: ' .. web_formatter(0)[1])
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
        require('conform').format { async = true, lsp_format = lsp_format(0) }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      '<leader>tF',
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        vim.notify('Format on save: ' .. (autoformat_enabled(0) and 'on' or 'off') .. (vim.g.disable_autoformat and ' (globally disabled)' or ' (buffer)'))
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
    for _, ft in ipairs(web_filetypes) do
      formatters[ft] = web_formatter
    end
    return {
      formatters = {
        oxfmt = { cwd = require('conform.util').root_file(oxfmt_configs) },
      },
      format_on_save = function(bufnr)
        if autoformat_enabled(bufnr) then
          return { timeout_ms = 5000, lsp_format = lsp_format(bufnr) }
        end
      end,
      formatters_by_ft = formatters,
    }
  end,
}
