-- Seamless <C-hjkl> navigation between vim splits and tmux panes
-- https://github.com/christoomey/vim-tmux-navigator

return {
  'christoomey/vim-tmux-navigator',
  cmd = {
    'TmuxNavigateLeft',
    'TmuxNavigateDown',
    'TmuxNavigateUp',
    'TmuxNavigateRight',
    'TmuxNavigatePrevious',
  },
  keys = {
    { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>', desc = 'Navigate left (vim/tmux)' },
    { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>', desc = 'Navigate down (vim/tmux)' },
    { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>', desc = 'Navigate up (vim/tmux)' },
    { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>', desc = 'Navigate right (vim/tmux)' },
    { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>', desc = 'Navigate previous (vim/tmux)' },
  },
}
