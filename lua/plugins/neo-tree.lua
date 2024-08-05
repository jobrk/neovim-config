-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    {
      's1n7ax/nvim-window-picker',
      version = '2.*',
      config = function()
        require('window-picker').setup {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              buftype = { 'terminal', 'quickfix' },
            },
          },
        }
      end,
    },
  },
  cmd = 'Neotree',
  keys = {
    {
      '<leader>n',
      ':Neotree reveal<CR>',
      desc = 'NeoTree reveal',
      silent = true,
    },
  },
  opts = {
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.opt_local.number = true
          vim.opt_local.relativenumber = true
        end,
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
      window = {
        position = 'float',
        mappings = {
          ['<C-c>'] = 'close_window',
          ['l'] = 'open',
          ['L'] = 'open_vsplit',
          ['h'] = 'close_node',
          ['H'] = 'close_all_nodes',
        },
      },
    },
  },
}
