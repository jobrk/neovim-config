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

    -- Diagnostic and diff colors on the statusline bg (stock sections are monochrome)
    local function set_section_hl()
      local bg = vim.api.nvim_get_hl(0, { name = 'MiniStatuslineDevinfo', link = false }).bg
      for group, source in pairs {
        MiniStatuslineDiagError = 'DiagnosticError',
        MiniStatuslineDiagWarn = 'DiagnosticWarn',
        MiniStatuslineDiffAdd = 'GitSignsAdd',
        MiniStatuslineDiffChange = 'GitSignsChange',
        MiniStatuslineDiffDelete = 'GitSignsDelete',
      } do
        local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
        vim.api.nvim_set_hl(0, group, { fg = fg, bg = bg })
      end
    end
    set_section_hl()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('statusline-section-hl', { clear = true }),
      callback = set_section_hl,
    })

    local function section_diff()
      if statusline.is_truncated(75) then
        return ''
      end
      local status = vim.b.gitsigns_status_dict
      if not status then
        return ''
      end
      local parts = {}
      for _, d in ipairs { { 'added', 'Add', '+' }, { 'changed', 'Change', '~' }, { 'removed', 'Delete', '-' } } do
        local n = status[d[1]] or 0
        if n > 0 then
          parts[#parts + 1] = ('%%#MiniStatuslineDiff%s#%s%d'):format(d[2], d[3], n)
        end
      end
      return table.concat(parts, ' ')
    end

    local function section_diagnostics()
      if statusline.is_truncated(75) then
        return ''
      end
      local count = vim.diagnostic.count(0)
      local parts = {}
      for _, d in ipairs { { 'Error', 'E' }, { 'Warn', 'W' } } do
        local n = count[vim.diagnostic.severity[d[1]:upper()]] or 0
        if n > 0 then
          parts[#parts + 1] = ('%%#MiniStatuslineDiag%s#%s%d'):format(d[1], d[2], n)
        end
      end
      return table.concat(parts, ' ')
    end

    statusline.setup {
      content = {
        active = function()
          local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
          local git = statusline.section_git { trunc_width = 40 }
          local diff = section_diff()
          local diagnostics = section_diagnostics()
          local filename = statusline.section_filename { trunc_width = 140 }
          local recording = vim.fn.reg_recording() ~= '' and ('rec @' .. vim.fn.reg_recording()) or ''
          return statusline.combine_groups {
            { hl = mode_hl, strings = { mode, recording } },
            { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics } },
            '%<',
            { hl = 'MiniStatuslineFilename', strings = { filename } },
            '%=',
            { hl = 'MiniStatuslineFileinfo', strings = { vim.bo.filetype, '%l:%-2v', '%P' } },
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
