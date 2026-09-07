-- Key discovery for leader actions, native prefixes and text objects.
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
    delay = require('keymap_policy').hint_delay_ms,
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
    plugins = {
      marks = true,
      registers = true,
      spelling = { enabled = true },
    },
    spec = require('keymap_policy').which_key_spec(),
    win = { border = require('ui').border.style },
    layout = { width = { min = 32 }, spacing = 2 },
  },
}
