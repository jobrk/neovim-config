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
    show_help = false,
    show_keys = false, -- The border title already shows the active prefix.
    win = {
      border = require('ui').border.style,
      padding = { 0, 1 },
      no_overlap = false, -- Keep the bottom panel intact when the cursor is low.
      height = { min = 1, max = math.huge }, -- Fit rows instead of clipping to 25.
    },
    -- A maximum matters: one long description must not force a single column.
    layout = { width = { min = 20, max = 28 }, spacing = 2 },
  },
}
