-- Collection of small independent modules (using: ai textobjects, surround,
-- pairs, icons, statusline)
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

    -- Icons, also serving telescope/neo-tree via the devicons API
    require('mini.icons').setup()
    MiniIcons.mock_nvim_web_devicons()

    -- Statusline: mode+recording | git, diff, diagnostics | file ... filetype | location
    local statusline = require 'mini.statusline'
    statusline.setup {
      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
          local git = statusline.section_git { trunc_width = 40 }
          local diff = statusline.section_diff { trunc_width = 75 }
          local diagnostics = statusline.section_diagnostics { trunc_width = 75 }
          local filename = statusline.section_filename { trunc_width = 140 }
          local location = statusline.section_location { trunc_width = 75 }
          local recording = vim.fn.reg_recording() ~= '' and ('rec @' .. vim.fn.reg_recording()) or ''
          return statusline.combine_groups {
            { hl = mode_hl, strings = { mode, recording } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { vim.bo.filetype } },
            { hl = mode_hl, strings = { location } },
          }
        end,
      },
    }
    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      group = vim.api.nvim_create_augroup('statusline-recording', { clear = true }),
      command = 'redrawstatus',
    })
  end,
}
