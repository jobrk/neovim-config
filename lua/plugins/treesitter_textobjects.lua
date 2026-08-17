-- Treesitter textobject queries and structural motions (]f, ]C, ...);
-- selection textobjects (af, ic, ...) are wired through mini.ai
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects

local function move_to(dir, query)
  return function()
    require('nvim-treesitter-textobjects.move')['goto_' .. dir](query, 'textobjects')
  end
end

return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  branch = 'main',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  keys = {
    { ']f', move_to('next_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next function start' },
    { '[f', move_to('previous_start', '@function.outer'), mode = { 'n', 'x', 'o' }, desc = 'Previous function start' },
    { ']C', move_to('next_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Next class start' },
    { '[C', move_to('previous_start', '@class.outer'), mode = { 'n', 'x', 'o' }, desc = 'Previous class start' },
    { ']a', move_to('next_start', '@parameter.inner'), mode = { 'n', 'x', 'o' }, desc = 'Next argument' },
    { '[a', move_to('previous_start', '@parameter.inner'), mode = { 'n', 'x', 'o' }, desc = 'Previous argument' },
  },
  opts = {},
}
