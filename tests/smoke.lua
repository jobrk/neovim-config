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

print '\nNeovim smoke test passed'
