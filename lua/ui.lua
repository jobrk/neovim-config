local M = {}

M.border = {
  style = 'single',
  horizontal = '─',
  vertical = '│',
  top_left = '┌',
  top_right = '┐',
  bottom_right = '┘',
  bottom_left = '└',
  tee_left = '├',
  tee_right = '┤',
}

function M.telescope_borderchars()
  local b = M.border
  return {
    b.horizontal,
    b.vertical,
    b.horizontal,
    b.vertical,
    b.top_left,
    b.top_right,
    b.bottom_right,
    b.bottom_left,
  }
end

function M.telescope_dropdown_borderchars()
  local b = M.border
  return {
    prompt = { b.horizontal, b.vertical, ' ', b.vertical, b.top_left, b.top_right, b.vertical, b.vertical },
    results = { b.horizontal, b.vertical, b.horizontal, b.vertical, b.tee_left, b.tee_right, b.bottom_right, b.bottom_left },
    preview = M.telescope_borderchars(),
  }
end

function M.noice_views(names)
  local views = {}
  for _, name in ipairs(names) do
    views[name] = { border = { style = M.border.style } }
  end
  return views
end

return M
