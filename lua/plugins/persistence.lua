-- Session persistence: restore buffers and layout per directory
-- https://github.com/folke/persistence.nvim

return {
  'folke/persistence.nvim',
  event = 'BufReadPre',
  keys = {
    {
      '<leader>sl',
      function()
        require('persistence').load()
      end,
      desc = '[S]ession [L]oad (cwd)',
    },
    {
      '<leader>sL',
      function()
        require('persistence').load { last = true }
      end,
      desc = '[S]ession [L]oad last',
    },
  },
  opts = {},
}
