-- Fuzzy finder for files, grep, buffers, LSP symbols, and more
-- https://github.com/nvim-telescope/telescope.nvim

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    local vimgrep_arguments = vim.deepcopy(require('telescope.config').values.vimgrep_arguments)
    vimgrep_arguments[#vimgrep_arguments + 1] = '--hidden'
    local ignore_patterns = {}
    for _, directory in ipairs { '.git', '.worktrees', '.claude/worktrees' } do
      vimgrep_arguments[#vimgrep_arguments + 1] = '--glob=!**/' .. directory .. '/*'
      ignore_patterns[#ignore_patterns + 1] = vim.pesc(directory) .. '/'
    end
    -- Telescope draws borders through Plenary and cannot inherit winborder.
    local borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' }

    require('telescope').setup {
      defaults = {
        file_ignore_patterns = ignore_patterns,
        vimgrep_arguments = vimgrep_arguments,
        borderchars = borderchars,
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown {
            borderchars = {
              prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
              results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
              preview = borderchars,
            },
          },
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<C-p>', function()
      builtin.find_files { previewer = false, hidden = true }
    end, { desc = 'Search Files' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>l', builtin.live_grep, { desc = 'Search by [L]iveGrep' })
    vim.keymap.set('n', '<leader>sd', function()
      builtin.diagnostics { previewer = false }
    end, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', function()
      builtin.buffers { sort_mru = true, ignore_current_buffer = true }
    end, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
