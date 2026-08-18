-- Sticky header showing the enclosing function/class while scrolling
-- https://github.com/nvim-treesitter/nvim-treesitter-context

return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'VeryLazy',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    max_lines = 4,
  },
}
