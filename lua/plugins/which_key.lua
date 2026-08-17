-- Popup showing pending keybinds as you type
-- https://github.com/folke/which-key.nvim

return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    require('which-key').setup()

    -- Document existing key chains
    require('which-key').add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument & [D]ebug' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch & [S]ession' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle & [T]ests' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    }
  end,
}
