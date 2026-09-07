-- Supported column layout; only leader mappings enter the key guide.
return {
  'folke/which-key.nvim',
  version = '^3',
  event = 'VeryLazy',
  opts = {
    preset = 'classic',
    delay = require('keymap_policy').hint_delay_ms,
    triggers = { { '<leader>', mode = 'nx' } },
    spec = require('keymap_policy').which_key_groups(),
    win = { border = require('ui').border.style },
    layout = { width = { min = 24 }, spacing = 2 },
  },
}
