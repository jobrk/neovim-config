local function step(message)
  print('\n==> ' .. message)
end

local function assert_empty(items, message)
  table.sort(items)
  assert(#items == 0, message .. ': ' .. table.concat(items, ', '))
end

step 'Checking plugins'
local missing_plugins = {}
for name, plugin in pairs(require('lazy.core.config').plugins) do
  if plugin.enabled ~= false and plugin.dir and not vim.uv.fs_stat(plugin.dir) then
    table.insert(missing_plugins, name)
  end
end
assert_empty(missing_plugins, 'missing plugins')
print '    all configured plugins are installed'

step 'Checking Mason tools'
local registry = require 'mason-registry'
local missing_tools = {}
for _, name in ipairs(require('tooling').mason) do
  local ok, package = pcall(registry.get_package, name)
  if not ok or not package:is_installed() then
    table.insert(missing_tools, name)
  end
end
assert_empty(missing_tools, 'missing Mason tools')
print '    all configured Mason tools are installed'

step 'Checking Tree-sitter parsers'
local missing_parsers = vim.tbl_filter(function(parser)
  return not pcall(vim.treesitter.language.inspect, parser)
end, require('tooling').treesitter)
assert_empty(missing_parsers, 'missing Tree-sitter parsers')
print '    all configured Tree-sitter parsers are installed'

step 'Checking YAML detection and parsing'
assert(vim.filetype.match { filename = 'smoke.yml' } == 'yaml', '.yml was not detected as YAML')
local yaml_parser = vim.treesitter.get_string_parser('key: value\n', 'yaml')
assert(#yaml_parser:parse() > 0, 'YAML parser returned no syntax tree')
print '    .yml files are detected and parsed as YAML'

step 'Checking shared UI and keymap policy'
local ui = require 'ui'
local keymap_policy = require 'keymap_policy'
local lazy_config = require 'lazy.core.config'
assert(vim.o.winborder == ui.border.style, 'winborder does not follow the shared UI policy')
assert(lazy_config.options.ui.border == ui.border.style, 'lazy.nvim border does not follow the shared UI policy')
assert(vim.deep_equal(require('telescope.config').values.borderchars, ui.telescope_borderchars()), 'Telescope border does not follow the shared UI policy')
for _, view in pairs(lazy_config.plugins['noice.nvim'].opts.views) do
  assert(view.border.style == ui.border.style, 'Noice border does not follow the shared UI policy')
end
assert(lazy_config.plugins['neo-tree.nvim'].opts.popup_border_style == '', 'neo-tree no longer inherits winborder')
assert(vim.o.timeoutlen == keymap_policy.mapping_timeout_ms, 'timeoutlen does not follow the shared keymap policy')
assert(MiniClue.config.window.delay == keymap_policy.clue_delay_ms, 'mini.clue delay does not follow the shared keymap policy')
assert(keymap_policy.clue_delay_ms < keymap_policy.mapping_timeout_ms, 'clues are not shown before mapping timeout')
assert(#keymap_policy.clues() == 8, 'leader groups were not expanded for every configured mode')
for _, trigger in ipairs(MiniClue.config.triggers) do
  assert(trigger.keys == '<Leader>', 'mini.clue intercepts non-leader prefix ' .. trigger.keys)
end
assert(#MiniClue.config.triggers == 2, 'mini.clue should only query normal and visual leader mappings')
print '    borders, mapping timeout, clue delay, and leader-only groups share policy'

step 'Checking eager-after-startup keymap targets'
local expected_plugin_keys = {
  neotest = { '<leader>tO', '<leader>ta', '<leader>td', '<leader>tf', '<leader>to', '<leader>ts', '<leader>tt', '<leader>tw' },
  ['nvim-dap'] = {
    '<leader>dB',
    '<leader>db',
    '<leader>dc',
    '<leader>dh',
    '<leader>di',
    '<leader>dj',
    '<leader>dk',
    '<leader>dn',
    '<leader>do',
    '<leader>dp',
    '<leader>dq',
    '<leader>dr',
  },
}
for plugin_name, expected_keys in pairs(expected_plugin_keys) do
  local plugin = lazy_config.plugins[plugin_name]
  local events = type(plugin.event) == 'table' and plugin.event or { plugin.event }
  assert(vim.tbl_contains(events, 'VeryLazy'), plugin_name .. ' is not preloaded after startup')
  local actual_keys = vim.tbl_map(function(spec)
    return spec[1]
  end, plugin.keys)
  table.sort(actual_keys)
  assert(vim.deep_equal(actual_keys, expected_keys), plugin_name .. ' keymap contract changed')
end
print '    Neotest and DAP preload after startup without changing their keymaps'

step 'Checking exact-prefix keymap contract'
local expected_prefixes = {
  n = { 'gc', 's', 'sF', 'sd', 'sf', 'sh', 'sr' },
  x = { 'a', 'i', 's', 'sF', 'sf' },
  o = { 'a', 'i', 's', 'sF', 'sf' },
}
for mode, expected in pairs(expected_prefixes) do
  local mappings_by_lhs = {}
  for _, mapping in ipairs(vim.api.nvim_get_keymap(mode)) do
    mappings_by_lhs[mapping.lhsraw or mapping.lhs] = mapping
  end
  for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
    mappings_by_lhs[mapping.lhsraw or mapping.lhs] = mapping
  end

  local mappings = vim.tbl_values(mappings_by_lhs)
  local actual = {}
  for _, mapping in ipairs(mappings) do
    local lhs = mapping.lhsraw or mapping.lhs
    if not vim.startswith(mapping.lhs, '<Plug>') then
      for _, candidate in ipairs(mappings) do
        local candidate_lhs = candidate.lhsraw or candidate.lhs
        if lhs ~= candidate_lhs and vim.startswith(candidate_lhs, lhs) and not vim.startswith(candidate.lhs, '<Plug>') then
          actual[#actual + 1] = lhs
          break
        end
      end
    end
  end
  table.sort(actual)
  assert(vim.deep_equal(actual, expected), mode .. '-mode exact-prefix mappings changed: ' .. vim.inspect(actual))
end
print '    every intentional exact-prefix mapping is unchanged'

step 'Checking shared search exclusions'
local search = require 'search'
local rg_globs = search.rg_exclude_globs()
local ignore_patterns = search.telescope_ignore_patterns()
local telescope_rg_arguments = require('telescope.config').values.vimgrep_arguments
for _, dir in ipairs(search.excluded_dirs) do
  assert(vim.tbl_contains(rg_globs, '--glob=!**/' .. dir .. '/*'), 'missing ripgrep exclusion for ' .. dir)
  assert(vim.tbl_contains(telescope_rg_arguments, '--glob=!**/' .. dir .. '/*'), 'Telescope grep does not consume the exclusion for ' .. dir)
  assert(vim.tbl_contains(ignore_patterns, vim.pesc(dir) .. '/'), 'missing Telescope exclusion for ' .. dir)
end
print '    file and grep searches share every excluded directory'

step 'Checking responsive clue layout'
local clue_layout = require 'mini_clue'
local clue_lines = {}
for index = 1, 18 do
  clue_lines[index] = ('item%02d'):format(index)
end
local wide_layout = clue_layout.layout(clue_lines, 76)
assert(wide_layout.rows == 6 and wide_layout.columns == 3, 'wide clue layout is not a six-row, three-column grid')
assert(wide_layout.lines[1]:find('item01', 1, true), 'first clue is not in the first grid row')
assert(wide_layout.lines[1]:find('item07', 1, true), 'seventh clue is not in the second grid column')
assert(wide_layout.lines[1]:find('item13', 1, true), 'thirteenth clue is not in the third grid column')
local narrow_layout = clue_layout.layout(clue_lines, 20)
assert(narrow_layout.rows == 18 and narrow_layout.columns == 1, 'narrow clue layout does not fall back to one column')
local truncated_layout = clue_layout.layout({ string.rep('x', 40) }, 24)
assert(truncated_layout.lines[1]:find('…', 1, true), 'long clue labels are not truncated')
print '    clue layout is column-major, bounded, truncating, and responsive'

step 'Checking shared LSP and tooling policy'
assert(type(require('lsp').capabilities()) == 'table', 'shared LSP capabilities are unavailable')
local tooling = require 'tooling'
assert(tooling.mason_dap[1] == tooling.debug_adapters.go, 'Mason DAP does not use the named Go adapter')
assert(vim.tbl_contains(tooling.mason, tooling.debug_adapters.go), 'Go debug adapter is absent from the Mason inventory')
assert(vim.tbl_contains(tooling.mason, tooling.debug_adapters.dotnet), '.NET debug adapter is absent from the Mason inventory')
print '    LSP capabilities and debug adapter identities share policy'

print '\nNeovim smoke test passed'
