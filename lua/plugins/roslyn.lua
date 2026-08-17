-- Roslyn language server for C# and Razor
-- https://github.com/seblyng/roslyn.nvim

return {
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  ft = { 'cs', 'razor' },
  opts = {},
}
