local M = {}

M.mapping_timeout_ms = 300
M.clue_delay_ms = 200

M.groups = {
  { mode = 'n', keys = '<Leader>c', desc = '+[C]ode' },
  { mode = 'n', keys = '<Leader>d', desc = '+[D]ocument & [D]ebug' },
  { mode = 'n', keys = '<Leader>r', desc = '+[R]ename' },
  { mode = 'n', keys = '<Leader>s', desc = '+[S]earch & [S]ession' },
  { mode = 'n', keys = '<Leader>w', desc = '+[W]orkspace' },
  { mode = 'n', keys = '<Leader>t', desc = '+[T]oggle & [T]ests' },
  { mode = { 'n', 'x' }, keys = '<Leader>h', desc = '+Git [H]unk' },
}

function M.clues()
  local clues = {}
  for _, group in ipairs(M.groups) do
    local modes = type(group.mode) == 'table' and group.mode or { group.mode }
    for _, mode in ipairs(modes) do
      clues[#clues + 1] = { mode = mode, keys = group.keys, desc = group.desc }
    end
  end
  return clues
end

return M
