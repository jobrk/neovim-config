-- Collection of small independent modules (using: ai textobjects, surround,
-- pairs, icons, statusline, hipatterns, sessions, clue)
-- https://github.com/echasnovski/mini.nvim

return {
  'echasnovski/mini.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    --  - vaf  - [V]isually select [A]round [F]unction definition
    --  - dic  - [D]elete [I]nside [C]lass
    --  - ciu  - [C]hange [I]nside function call ([U]sage)
    local ai = require 'mini.ai'
    ai.setup {
      n_lines = 500,
      custom_textobjects = {
        f = ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' },
        c = ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' },
        u = ai.gen_spec.function_call(),
      },
    }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    -- Auto-insert matching brackets, quotes, and parens
    require('mini.pairs').setup()

    -- Highlight TODO, FIXME, HACK, NOTE in comments
    local hipatterns = require 'mini.hipatterns'
    local function comment_word(word, group)
      return {
        pattern = function(buf_id)
          return vim.bo[buf_id].commentstring ~= '' and '%f[%w]()' .. word .. '()%f[%W]' or nil
        end,
        group = group,
      }
    end
    local comment_highlighters = {}
    for _, word in ipairs { 'FIXME', 'HACK', 'TODO', 'NOTE' } do
      local name = word:lower()
      local title = name:sub(1, 1):upper() .. name:sub(2)
      comment_highlighters[name] = comment_word(word, 'MiniHipatterns' .. title)
    end
    hipatterns.setup {
      highlighters = comment_highlighters,
    }

    -- Session persistence per directory
    local sessions = require 'mini.sessions'
    local function cwd_session_name()
      return (vim.fn.getcwd():gsub('[/\\:]', '%%'))
    end
    sessions.setup { autoread = false, autowrite = true }
    vim.api.nvim_create_autocmd('VimLeavePre', {
      group = vim.api.nvim_create_augroup('session-autowrite', { clear = true }),
      callback = function()
        if #vim.api.nvim_list_uis() > 0 and vim.env.NVIM == nil then
          sessions.write(cwd_session_name(), { force = true })
        end
      end,
    })
    vim.keymap.set('n', '<leader>sl', function()
      sessions.read(cwd_session_name())
    end, { desc = '[S]ession [L]oad (cwd)' })
    vim.keymap.set('n', '<leader>sL', function()
      sessions.read(sessions.get_latest())
    end, { desc = '[S]ession [L]oad last' })

    -- Popup showing pending keybinds as a responsive bottom grid
    require('mini_clue').setup()

    -- Icons, also serving telescope/neo-tree via the devicons API
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()

    -- Statusline: mode+recording | git, diff, diagnostics | file ... filetype | location
    require('statusline').setup()
  end,
}
