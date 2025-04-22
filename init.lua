-- [[ Setting options ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.tabstop = 2
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.hidden = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>', { desc = '[L]SP [R]estart' })

-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Temporary to get used to
vim.keymap.set('n', '<C-w><C-h>', '<cmd>echo "Use <C-h> to move!!"<CR>')
vim.keymap.set('n', '<C-w><C-l>', '<cmd>echo "Use <C-l> to move!!"<CR>')
vim.keymap.set('n', '<C-w><C-j>', '<cmd>echo "Use <C-j> to move!!"<CR>')
vim.keymap.set('n', '<C-w><C-k>', '<cmd>echo "Use <C-k> to move!!"<CR>')
vim.keymap.set('n', '<C-w>h', '<cmd>echo "Use <C-h> to move!!"<CR>')
vim.keymap.set('n', '<C-w>l', '<cmd>echo "Use <C-l> to move!!"<CR>')
vim.keymap.set('n', '<C-w>j', '<cmd>echo "Use <C-j> to move!!"<CR>')
vim.keymap.set('n', '<C-w>k', '<cmd>echo "Use <C-k> to move!!"<CR>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set('n', 'J', 'mzJ`z', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true })
vim.keymap.set('n', 'n', 'nzzzv', { silent = true })
vim.keymap.set('n', 'N', 'Nzzzv', { silent = true })

vim.keymap.set('x', '<leader>p', [["_dP]], { silent = true })

vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { silent = true })
vim.keymap.set('n', '<leader>Y', [["+Y]], { silent = true })

vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { silent = true })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({

  require 'plugins.vim_sleuth',
  require 'plugins.which_key',
  require 'plugins.telescope',
  require 'plugins.lazydev',
  require 'plugins.luvit_meta',
  require 'plugins.lsp_config',
  -- require 'plugins.typescript',
  require 'plugins.conform',
  require 'plugins.cmp',
  require 'plugins.catppuccin',
  require 'plugins.todo_comments',
  require 'plugins.lualine',
  require 'plugins.mini',
  require 'plugins.treesitter',
  require 'plugins.zen_mode',
  -- require 'plugins.debug',
  -- require 'plugins.indent_line',
  require 'plugins.lint',
  require 'plugins.autopairs',
  require 'plugins.neo-tree',
  require 'plugins.gitsigns',
  require 'plugins.tmux_navigator',
  require 'plugins.visual_multi',
}, {
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
})
