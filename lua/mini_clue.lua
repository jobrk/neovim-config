local M = {}

M.max_rows = 6
M.min_cell_width = 24

local packed_buffers = {}

local function fit_cell(text, width)
  local text_width = vim.fn.strdisplaywidth(text)
  if text_width <= width then
    return text .. string.rep(' ', width - text_width), #text
  end

  local char_count = vim.fn.strchars(text)
  while char_count > 0 do
    local prefix = vim.fn.strcharpart(text, 0, char_count)
    local visible = prefix .. '…'
    local visible_width = vim.fn.strdisplaywidth(visible)
    if visible_width <= width then
      return visible .. string.rep(' ', width - visible_width), #visible
    end
    char_count = char_count - 1
  end

  return string.rep(' ', width), 0
end

function M.layout(lines, available_width)
  local gap = '  '
  available_width = math.max(available_width, 1)

  local max_columns = math.max(1, math.floor((available_width + #gap) / (M.min_cell_width + #gap)))
  local columns = math.min(max_columns, math.max(1, math.ceil(#lines / M.max_rows)))
  local rows = math.max(1, math.ceil(#lines / columns))
  local cell_width = math.max(1, math.floor((available_width - #gap * (columns - 1)) / columns))

  local grid = {}
  local placements = {}
  for row = 1, rows do
    grid[row] = ''
  end
  for index, line in ipairs(lines) do
    local row = (index - 1) % rows + 1
    local column = math.floor((index - 1) / rows)
    local cell, visible_bytes = fit_cell(line, cell_width)
    local offset = column * (cell_width + #gap)
    grid[row] = grid[row] .. (column == 0 and '' or gap) .. cell
    placements[index] = { row = row - 1, col = offset, visible_bytes = visible_bytes }
  end

  return {
    lines = grid,
    placements = placements,
    columns = columns,
    rows = rows,
    width = available_width,
  }
end

local function read_highlights(buf_id, lines)
  local namespace = vim.api.nvim_get_namespaces().MiniClueHighlight
  local highlights = {}
  if not namespace then
    return namespace, highlights
  end

  for _, extmark in ipairs(vim.api.nvim_buf_get_extmarks(buf_id, namespace, 0, -1, { details = true })) do
    local source_row = extmark[2] + 1
    local details = extmark[4]
    highlights[source_row] = highlights[source_row] or {}
    highlights[source_row][#highlights[source_row] + 1] = {
      start_col = extmark[3],
      end_col = details.end_row == extmark[2] and details.end_col or #lines[source_row],
      group = details.hl_group,
    }
  end
  return namespace, highlights
end

local function write_highlights(buf_id, namespace, highlights, layout)
  if not namespace then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf_id, namespace, 0, -1)
  for source_row, row_highlights in pairs(highlights) do
    local placement = layout.placements[source_row]
    for _, highlight in ipairs(row_highlights) do
      local start_col = math.min(highlight.start_col, placement.visible_bytes)
      local end_col = math.min(highlight.end_col, placement.visible_bytes)
      if start_col < end_col then
        vim.api.nvim_buf_set_extmark(buf_id, namespace, placement.row, placement.col + start_col, {
          end_row = placement.row,
          end_col = placement.col + end_col,
          hl_group = highlight.group,
        })
      end
    end
  end
end

function M.window_config(buf_id)
  local current_tick = vim.api.nvim_buf_get_changedtick(buf_id)
  local packed = packed_buffers[buf_id]
  if packed and packed.tick == current_tick and packed.columns == vim.o.columns then
    return packed.config
  end

  local source_lines
  local namespace
  local highlights
  if packed and packed.tick == current_tick then
    source_lines = packed.source_lines
    namespace = packed.namespace
    highlights = packed.highlights
  else
    source_lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
    namespace, highlights = read_highlights(buf_id, source_lines)
  end

  local layout = M.layout(source_lines, vim.o.columns - 4)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, layout.lines)
  write_highlights(buf_id, namespace, highlights, layout)

  local config = {
    anchor = 'SW',
    row = 'auto',
    col = 'auto',
    width = layout.width,
    height = layout.rows,
  }
  packed_buffers[buf_id] = {
    tick = vim.api.nvim_buf_get_changedtick(buf_id),
    columns = vim.o.columns,
    config = config,
    source_lines = source_lines,
    namespace = namespace,
    highlights = highlights,
  }
  return config
end

function M.setup()
  local clue = require 'mini.clue'
  local keymap_policy = require 'keymap_policy'

  clue.setup {
    -- Keep clue's custom key-query process away from native and LSP prefixes.
    -- In particular, `gr` is also a prefix for Neovim's `gra`, `gri`, etc.;
    -- intercepting `g` makes clue wait for those instead of opening references.
    triggers = {
      { mode = 'n', keys = '<Leader>' },
      { mode = 'x', keys = '<Leader>' },
    },
    clues = keymap_policy.clues(),
    window = {
      delay = keymap_policy.clue_delay_ms,
      config = M.window_config,
    },
  }
end

return M
