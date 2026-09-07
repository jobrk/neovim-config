local M = {}

M.web_filetypes = {
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
local oxfmt_configs = { '.oxfmtrc.json', '.oxfmtrc.jsonc', 'oxfmt.config.ts' }

local function has_config(directory, names)
  for _, name in ipairs(names) do
    if vim.fn.filereadable(directory .. '/' .. name) == 1 then
      return true
    end
  end
  return false
end

function M.web_formatter(bufnr)
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

function M.lsp_format(bufnr)
  local ft = vim.bo[bufnr].filetype
  return (ft == 'c' or ft == 'cpp' or vim.tbl_contains(M.web_filetypes, ft)) and 'never' or 'fallback'
end

function M.enabled(bufnr)
  return not (vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat)
end

return M
