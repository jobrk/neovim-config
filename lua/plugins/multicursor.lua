-- Multiple cursors: <C-n> adds a cursor at the next match of the word/selection
-- https://github.com/jake-stewart/multicursor.nvim

return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  keys = {
    {
      '<C-n>',
      function()
        require('multicursor-nvim').matchAddCursor(1)
      end,
      mode = { 'n', 'x' },
      desc = 'Add cursor at next match',
    },
  },
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()

    -- Only active while multiple cursors exist (vim-visual-multi style)
    mc.addKeymapLayer(function(layerSet)
      layerSet({ 'n', 'x' }, 'q', function()
        mc.matchSkipCursor(1)
      end, { desc = 'Skip match, add cursor at next' })
      layerSet({ 'n', 'x' }, 'Q', mc.deleteCursor, { desc = 'Delete main cursor' })
      layerSet({ 'n', 'x' }, '<Left>', mc.prevCursor, { desc = 'Previous cursor' })
      layerSet({ 'n', 'x' }, '<Right>', mc.nextCursor, { desc = 'Next cursor' })
      layerSet('n', '<Esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)
  end,
}
