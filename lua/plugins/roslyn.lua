-- Roslyn language server for C# and Razor
-- https://github.com/seblyng/roslyn.nvim
-- Server settings live in after/lsp/roslyn.lua.

return {
  'seblyng/roslyn.nvim',
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  ft = { 'cs', 'razor' },
  opts = {},
}
