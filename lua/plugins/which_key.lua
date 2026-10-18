-- Key discovery for leader actions, native prefixes and text objects.
local spec = {
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument & [D]ebug' },
  { '<leader>j', group = '[J]ava' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>s', group = '[S]earch & [S]ession' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>t', group = '[T]oggle & [T]ests' },
  { '<leader>h', mode = { 'n', 'x' }, group = 'Git [H]unk' },
}

-- Custom MiniAi objects from mini.lua, including next/previous variants.
for prefix, label in pairs { a = 'around', i = 'inside', an = 'around next', ['in'] = 'inside next', al = 'around previous', il = 'inside previous' } do
  spec[#spec + 1] = { prefix, mode = { 'o', 'x' }, group = label }
  for key, description in pairs { f = 'function definition', c = 'class', u = 'function call' } do
    spec[#spec + 1] = { prefix .. key, mode = { 'o', 'x' }, desc = description }
  end
end

return {
  'folke/which-key.nvim',
  version = '^3',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      mode = { 'n', 'x' },
      desc = 'Show buffer-local keymaps',
    },
  },
  opts = {
    preset = 'classic',
    delay = 200,
    triggers = {
      { '<leader>', mode = 'nx' },
      { 'g', mode = 'nx' },
      { 'z', mode = 'nx' },
      { '[', mode = 'nx' },
      { ']', mode = 'nx' },
      { '<C-w>', mode = 'n' },
      { '<auto>', mode = 'xo' },
    },
    -- Wait for another key after entering visual/operator-pending mode.
    -- After pausing on d/y, a/i opens the text-object guide. Fast sequences
    -- go straight to MiniAi, whose expression mappings read the object key.
    defer = function()
      return true
    end,
    spec = spec,
    show_help = false,
    show_keys = false, -- The border title already shows the active prefix.
    win = {
      border = vim.o.winborder,
      padding = { 0, 1 },
      no_overlap = false, -- Keep the bottom panel intact when the cursor is low.
      height = { min = 1, max = math.huge }, -- Fit rows instead of clipping to 25.
    },
    -- A maximum matters: one long description must not force a single column.
    layout = { width = { min = 20, max = 28 }, spacing = 2 },
  },
}
