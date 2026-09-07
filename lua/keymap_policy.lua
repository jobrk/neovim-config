local M = {}

M.mapping_timeout_ms = 300
M.hint_delay_ms = 200

M.groups = {
  { mode = 'n', keys = '<Leader>c', desc = '+[C]ode' },
  { mode = 'n', keys = '<Leader>d', desc = '+[D]ocument & [D]ebug' },
  { mode = 'n', keys = '<Leader>j', desc = '+[J]ava' },
  { mode = 'n', keys = '<Leader>r', desc = '+[R]ename' },
  { mode = 'n', keys = '<Leader>s', desc = '+[S]earch & [S]ession' },
  { mode = 'n', keys = '<Leader>w', desc = '+[W]orkspace' },
  { mode = 'n', keys = '<Leader>t', desc = '+[T]oggle & [T]ests' },
  { mode = { 'n', 'x' }, keys = '<Leader>h', desc = '+Git [H]unk' },
}

function M.which_key_groups()
  local groups = {}
  for _, group in ipairs(M.groups) do
    local modes = type(group.mode) == 'table' and group.mode or { group.mode }
    for _, mode in ipairs(modes) do
      groups[#groups + 1] = { group.keys, mode = mode, group = group.desc:gsub('^%+', '') }
    end
  end
  return groups
end

function M.which_key_spec()
  local spec = M.which_key_groups()
  -- Keep MiniAi descriptions aligned with the objects in plugins/mini.lua.
  local objects = {
    a = 'argument',
    b = 'bracket pair',
    c = 'class',
    f = 'function definition',
    q = 'quoted text',
    t = 'tag',
    u = 'function call',
    ['?'] = 'prompt for delimiters',
    ['"'] = 'double-quoted text',
    ["'"] = 'single-quoted text',
    ['`'] = 'backtick-quoted text',
    ['('] = 'parentheses (trim inner whitespace)',
    [')'] = 'parentheses',
    ['['] = 'square brackets (trim inner whitespace)',
    [']'] = 'square brackets',
    ['{'] = 'braces (trim inner whitespace)',
    ['}'] = 'braces',
    ['<'] = 'angle brackets (trim inner whitespace)',
    ['>'] = 'angle brackets',
  }
  for prefix, label in pairs { a = 'around', i = 'inside', an = 'around next', ['in'] = 'inside next', al = 'around previous', il = 'inside previous' } do
    spec[#spec + 1] = { prefix, mode = { 'o', 'x' }, group = label }
    for key, description in pairs(objects) do
      spec[#spec + 1] = { prefix .. key, mode = { 'o', 'x' }, desc = description }
    end
  end
  return spec
end

return M
