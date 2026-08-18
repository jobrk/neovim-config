-- [[ Options ]]
vim.g.mapleader = ' ' -- Space as leader key
vim.g.maplocalleader = ' ' -- Space as local leader too
vim.g.have_nerd_font = true -- Terminal font has icons
vim.g.loaded_netrw = 1 -- Disable netrw (neo-tree instead)
vim.g.loaded_netrwPlugin = 1 -- Disable netrw plugin part

vim.opt.number = true -- Absolute number on current line
vim.opt.relativenumber = true -- Relative numbers elsewhere
vim.opt.signcolumn = 'yes' -- Always show sign column (no shifting)
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 10 -- Keep 10 lines around cursor
vim.opt.smoothscroll = true -- <C-d> over wrapped/folded lines scrolls by screen line
vim.opt.wrap = false -- No line wrapping
vim.opt.showmode = false -- Mode already shown by statusline
vim.opt.winborder = 'single' -- Border for all floating windows
vim.opt.shortmess:append 'I' -- No intro screen on start

vim.opt.mouse = 'a' -- Mouse in all modes
vim.opt.confirm = true -- Prompt instead of failing :q with changes
vim.opt.tabstop = 2 -- Tab renders as 2 spaces
vim.opt.updatetime = 250 -- Faster CursorHold / swap writes
vim.opt.timeoutlen = 300 -- Wait 300ms for mapped sequences
vim.opt.spelllang = 'en_us' -- Spell language (spell off by default)
vim.opt.jumpoptions = 'stack' -- <C-o>/<C-i> behave like a browser history stack
vim.opt.virtualedit = 'block' -- visual-block past end-of-line (rectangles that make sense)
vim.opt.diffopt:append 'linematch:60' -- dramatically better intra-hunk diff alignment

vim.opt.ignorecase = true -- Case-insensitive search...
vim.opt.smartcase = true -- ...unless query has capitals
vim.opt.inccommand = 'split' -- Live preview of :substitute

vim.opt.splitright = true -- Vertical splits open right
vim.opt.splitbelow = true -- Horizontal splits open below

vim.opt.swapfile = false -- No swap files
vim.opt.backup = false -- No backup files
vim.opt.writebackup = false -- No backup before overwriting
vim.opt.undofile = true -- Persistent undo across sessions

vim.opt.foldmethod = 'expr' -- Folds from expression...
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- ...computed by treesitter
vim.opt.foldtext = '' -- Keep syntax highlight on folded line
vim.opt.foldlevel = 99 -- Open files fully unfolded

vim.diagnostic.config { virtual_text = { current_line = true } } -- Inline diagnostics on cursor line only
vim.lsp.log.set_level(vim.log.levels.WARN) -- Keep lsp.log small

-- [[ Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror float' })
vim.keymap.set('n', '[e', function()
  vim.diagnostic.jump { count = -1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Previous error' })
vim.keymap.set('n', ']e', function()
  vim.diagnostic.jump { count = 1, severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Next error' })
vim.keymap.set('n', '<leader>cr', '<cmd>LspRestart<CR>', { desc = '[C]ode LSP [R]estart' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down', silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up', silent = true })
vim.keymap.set('n', 'J', 'mzJ`z', { desc = 'Join line below (keep cursor)', silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centered)', silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centered)', silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next match (centered)', silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous match (centered)', silent = true })

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = '[P]aste without yanking selection', silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = '[Y]ank to system clipboard', silent = true })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = '[Y]ank line to system clipboard', silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>x', [["_d]], { desc = 'Delete without yanking', silent = true })

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Restore cursor to last position when reopening a file',
  group = vim.api.nvim_create_augroup('restore-cursor', { clear = true }),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Equalize splits when the terminal is resized',
  group = vim.api.nvim_create_augroup('resize-splits', { clear = true }),
  command = 'wincmd =',
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Plugins ]]
require('lazy').setup {
  spec = { { import = 'plugins' } },
  rocks = { enabled = false },
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
}
