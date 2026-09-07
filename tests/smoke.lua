local function step(message)
  print('\n==> ' .. message)
end

step 'Checking installed and locked plugins'
local lazy = require 'lazy.core.config'
local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath 'config' .. '/lazy-lock.json'), '\n'))
for name, plugin in pairs(lazy.plugins) do
  assert(vim.uv.fs_stat(plugin.dir), 'Missing plugin: ' .. name)
  assert(lock[name], 'Plugin is not locked: ' .. name)
  local head = vim.system({ 'git', '-C', plugin.dir, 'rev-parse', 'HEAD' }, { text = true }):wait()
  assert(head.code == 0 and vim.trim(head.stdout) == lock[name].commit, 'Plugin differs from lockfile: ' .. name)
end

step 'Checking Mason tools and debugger executables'
local tooling = require 'tooling'
local registry = require 'mason-registry'
for _, name in ipairs(tooling.mason) do
  assert(registry.get_package(name):is_installed(), 'Missing Mason tool: ' .. name)
end
require('lazy').load { plugins = { 'nvim-dap', 'neotest', 'which-key.nvim', 'telescope.nvim', 'conform.nvim' } }
assert(registry.get_package('netcoredbg'):get_installed_version() == tooling.netcoredbg_version, 'netcoredbg must use the native release')
assert(
  vim.wait(1000, function()
    return require('which-key.config').loaded
  end),
  'Key guide did not initialize'
)
local dap = require 'dap'
for _, name in ipairs { 'python', 'pwa-node', 'codelldb', 'coreclr', 'go' } do
  assert(dap.adapters[name], 'Missing DAP adapter: ' .. name)
end
for _, command in ipairs { dap.adapters.python.command, 'js-debug-adapter', 'codelldb', 'netcoredbg', 'dlv' } do
  assert(vim.fn.executable(command) == 1, 'Missing debugger executable: ' .. command)
end
assert(type(require 'rustaceanvim.neotest') == 'table', 'Rust test adapter is unavailable')
assert(not lazy.plugins['neotest-rust'], 'Archived Rust adapter is still configured')

step 'Checking parser revisions and compiling installed queries'
local parser_config = require 'nvim-treesitter.config'
local parsers = require 'nvim-treesitter.parsers'
for _, lang in ipairs(tooling.treesitter) do
  vim.treesitter.language.inspect(lang)
  local revision_file = parser_config.get_install_dir 'parser-info' .. '/' .. lang .. '.revision'
  assert(vim.fn.filereadable(revision_file) == 1, 'Parser is not provisioned in the managed directory: ' .. lang)
  assert(vim.fn.readfile(revision_file)[1] == parsers[lang].install_info.revision, 'Outdated parser: ' .. lang)
  for _, query in ipairs { 'highlights', 'injections', 'indents', 'folds', 'locals', 'textobjects' } do
    local ok, err = pcall(vim.treesitter.query.get, lang, query)
    assert(ok, lang .. '/' .. query .. ': ' .. tostring(err))
  end
end
assert(vim.filetype.match { filename = 'smoke.yml' } == 'yaml')
assert(#vim.treesitter.get_string_parser('key: value\n', 'yaml'):parse() > 0)

step 'Checking explicit LSP activation and Vue integration'
for _, name in ipairs(tooling.lsp) do
  assert(vim.lsp.is_enabled(name), 'Expected LSP is disabled: ' .. name)
end
for _, name in ipairs { 'texlab', 'stylua', 'oxfmt', 'rust_analyzer', 'jdtls' } do
  assert(not vim.lsp.is_enabled(name), 'Unexpected automatic LSP: ' .. name)
end
assert(vim.tbl_contains(vim.lsp.config.ts_ls.filetypes, 'vue'), 'TypeScript is not enabled for Vue')
local vue_plugin = vim.lsp.config.ts_ls.init_options.plugins[1]
assert(vue_plugin.name == '@vue/typescript-plugin')
assert(vim.uv.fs_stat(vue_plugin.location), 'Vue TypeScript plugin location does not exist')

step 'Checking UI, key guide and editing policy'
local ui, keymap_policy = require 'ui', require 'keymap_policy'
assert(vim.o.winborder == ui.border.style and lazy.options.ui.border == ui.border.style)
local which_key = require('which-key.config').options
assert(which_key.delay == keymap_policy.hint_delay_ms)
assert(vim.o.timeoutlen == keymap_policy.mapping_timeout_ms)
assert(vim.o.expandtab and vim.o.shiftwidth == 2 and vim.o.softtabstop == 2)
assert(vim.o.swapfile and vim.o.writebackup and vim.o.undofile)
local telescope = require('telescope.config').values
assert(vim.deep_equal(telescope.borderchars, ui.telescope_borderchars()))
assert(vim.deep_equal(telescope.file_ignore_patterns, require('search').telescope_ignore_patterns()))

step 'Checking formatter selection and buffer/client lifecycle regressions'
dofile 'tests/behavior.lua'
step 'Checking key guide popups and live input in an attached UI'
dofile 'tests/keyguide.lua'
print '\nNeovim smoke test passed'
