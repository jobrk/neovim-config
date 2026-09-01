local M = {}

local detail_width = 75

local function set_section_highlights()
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

local function section_diff(statusline)
  if statusline.is_truncated(detail_width) then
    return ''
  end
  local status = vim.b.gitsigns_status_dict
  if not status then
    return ''
  end

  local parts = {}
  for _, diff in ipairs { { 'added', 'Add', '+' }, { 'changed', 'Change', '~' }, { 'removed', 'Delete', '-' } } do
    local count = status[diff[1]] or 0
    if count > 0 then
      parts[#parts + 1] = ('%%#MiniStatuslineDiff%s#%s%d'):format(diff[2], diff[3], count)
    end
  end
  return table.concat(parts, ' ')
end

local function section_diagnostics(statusline)
  if statusline.is_truncated(detail_width) then
    return ''
  end

  local count = vim.diagnostic.count(0)
  local parts = {}
  for _, diagnostic in ipairs { { 'Error', 'E' }, { 'Warn', 'W' } } do
    local severity_count = count[vim.diagnostic.severity[diagnostic[1]:upper()]] or 0
    if severity_count > 0 then
      parts[#parts + 1] = ('%%#MiniStatuslineDiag%s#%s%d'):format(diagnostic[1], diagnostic[2], severity_count)
    end
  end
  return table.concat(parts, ' ')
end

function M.setup()
  local statusline = require 'mini.statusline'

  set_section_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('statusline-section-hl', { clear = true }),
    callback = set_section_highlights,
  })

  statusline.setup {
    content = {
      active = function()
        local mode, mode_hl = statusline.section_mode { trunc_width = 120 }
        local git = statusline.section_git { trunc_width = 40 }
        local diff = section_diff(statusline)
        local diagnostics = section_diagnostics(statusline)
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
end

return M
