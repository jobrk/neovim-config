-- Exercise a real attached UI using Neovim's RPC client, without extra dependencies.
local child = vim.fn.jobstart({ vim.v.progpath, '--embed', '-i', 'NONE' }, {
  rpc = true,
  env = { NVIM = 'keyguide-test' }, -- Suppress Mini session saving on test exit.
})
assert(child > 0, 'Could not start the key guide test editor')
local watchdog = vim.uv.new_timer()
local child_pid = vim.fn.jobpid(child)
watchdog:start(30000, 0, function()
  vim.uv.kill(child_pid, 15)
end)
local function lua(code, ...)
  return vim.rpcrequest(child, 'nvim_exec_lua', code, { ... })
end
local function input(keys)
  vim.rpcrequest(child, 'nvim_input', keys)
end
local function wait_for(message, predicate, timeout)
  assert(vim.wait(timeout or 2000, predicate, 20), message)
end
local function popup()
  return lua [[
    local lines = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'wk' then
        vim.list_extend(lines, vim.api.nvim_buf_get_lines(buf, 0, -1, false))
      end
    end
    return table.concat(lines, '\n')
  ]]
end
local function expect_popup(keys, text)
  print('Key guide: ' .. keys .. ' -> ' .. text)
  input(keys)
  wait_for('Missing popup for ' .. keys .. ': ' .. text, function()
    return popup():find(text, 1, true) ~= nil
  end)
end
local function expect_compact(max_height)
  local layout = lua [[
    local windows, height, rows, columns = 0, 0, 0, 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'wk' then
        windows = windows + 1
        if vim.api.nvim_win_get_config(win).relative == 'editor' then
          height = vim.api.nvim_win_get_height(win)
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          rows = #lines
          for _, line in ipairs(lines) do
            local _, count = line:gsub('➜', '')
            columns = math.max(columns, count)
          end
        end
      end
    end
    return { windows = windows, height = height, rows = rows, columns = columns }
  ]]
  assert(layout.windows == 1, 'Key guide has an extra footer window')
  assert(layout.rows > 0 and layout.rows <= layout.height, 'Key guide requires scrolling: ' .. vim.inspect(layout))
  assert(layout.columns >= 2, 'Key guide is not using multiple columns')
  assert(layout.height <= max_height, 'Key guide uses too many rows: ' .. vim.inspect(layout))
end
local function reset()
  input '<Esc><Esc>'
  wait_for('Key guide did not close', function()
    return popup() == '' and lua 'return vim.fn.mode(1)' == 'n'
  end)
  -- WhichKey reattaches its triggers on the following event-loop tick.
  vim.wait(100)
end

local ok, err = xpcall(function()
  vim.rpcrequest(child, 'nvim_ui_attach', 120, 40, { rgb = true })
  wait_for('WhichKey did not initialize', function()
    return lua "return package.loaded['which-key.config'] and require('which-key.config').loaded == true"
  end, 5000)
  vim.wait(200)
  lua [[
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one two three' })
    vim.fn.setreg('a', 'WKREG')
    vim.api.nvim_buf_set_mark(0, 'a', 1, 0, {})
    vim.keymap.set('n', '<F8>', function() end, { buffer = true, desc = 'Local probe' })
    vim.keymap.set('n', '<F9>', function() end, { desc = 'Global probe' })
    -- Exercise the real LSP mapping and nowait policy; stub only the picker.
    require('telescope.builtin').lsp_references = function()
      vim.g.references_called = (vim.g.references_called or 0) + 1
    end
    local attach = vim.api.nvim_get_autocmds({ group = 'kickstart-lsp-attach' })[1].callback
    attach { buf = vim.api.nvim_get_current_buf(), data = { client_id = -1 } }
  ]]

  for _, case in ipairs {
    { ' ', 'Search' },
    { 'g', '[R]efer' }, -- Long descriptions are ellipsized in compact columns.
    { 'z', 'fold' },
    { '[', 'Previous' },
    { ']', 'Next' },
    { '<C-w>', 'Split window' },
    { '"', 'WKREG' },
    { "'", 'a' },
  } do
    expect_popup(case[1], case[2])
    reset()
  end

  lua "vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'helo' }); vim.api.nvim_win_set_cursor(0, {1, 0})"
  expect_popup('z=', 'hello')
  reset()

  -- Real viewport sizes catch clipping, excess height and single-column regressions.
  for _, size in ipairs { { 80, 24, 14 }, { 120, 40, 8 }, { 200, 50, 6 } } do
    vim.rpcrequest(child, 'nvim_ui_try_resize', size[1], size[2])
    lua [[vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn['repeat']({ 'one two three' }, 100))]]
    for _, position in ipairs { 'ggzt', 'Gzb' } do
      lua('vim.cmd.normal { ..., bang = true }', position)
      for _, keys in ipairs { ' ', 'g', 'z', ' s' } do
        expect_popup(keys, '➜')
        expect_compact(size[3])
        reset()
      end
    end
  end
  vim.rpcrequest(child, 'nvim_ui_try_resize', 120, 40)

  expect_popup(' ?', 'Local probe')
  assert(not popup():find('Global probe', 1, true), 'Buffer help includes global mappings')
  reset()

  -- Make an accidental timeout conspicuous without imposing tight CI timing.
  lua 'vim.o.timeoutlen = 3000'
  for _, paused in ipairs { false, true } do
    local before = lua 'return vim.g.references_called or 0'
    if paused then
      expect_popup('g', '[R]efer')
      input 'r'
    else
      input 'gr'
    end
    wait_for('gr waited for a longer mapping', function()
      return lua 'return vim.g.references_called or 0' == before + 1
    end, 750)
    reset()
  end
  lua 'vim.o.timeoutlen = require("keymap_policy").mapping_timeout_ms'

  -- MiniAi reads its own object key on fast input. Deferred hints appear
  -- when the operator has paused before a/i is pressed.
  for _, case in ipairs { { 'd', 'i', 'w' }, { 'y', 'a', 'w' } } do
    lua "vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one two three' }); vim.api.nvim_win_set_cursor(0, {1, 0})"
    input(case[1])
    vim.wait(400)
    assert(popup() == '', 'Bare operator unexpectedly opened the guide')
    expect_popup(case[2], 'function definition')
    assert(popup():find('function call', 1, true) and popup():find('quoted text', 1, true), 'MiniAi objects are missing')
    input(case[3])
    wait_for('Text object did not complete', function()
      return lua 'return vim.fn.mode(1)' == 'n'
    end)
    if case[1] == 'd' then
      assert(lua 'return vim.api.nvim_get_current_line()' == ' two three', 'diw changed its behaviour')
    else
      assert(lua [[return vim.fn.getreg('"')]] == 'one ', 'yaw changed its behaviour')
    end
    reset()
  end

  lua "vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'one two three' }); vim.api.nvim_win_set_cursor(0, {1, 0})"
  input 'diw'
  wait_for('Fast diw failed', function()
    return lua 'return vim.api.nvim_get_current_line()' == ' two three'
  end, 750)
  assert(popup() == '', 'A complete fast text object left a popup open')
  reset()

  input 'v'
  vim.wait(400)
  assert(popup() == '', 'Entering visual mode unexpectedly opened the guide')
  expect_popup(' ', '[P]aste')
  reset()
  input 'v'
  vim.wait(400)
  expect_popup('i', 'function definition')
  input 'w'
  wait_for('Visual text object did not select', function()
    return lua 'return vim.fn.mode()' == 'v' and popup() == ''
  end)
  reset()

  input 'i'
  wait_for('Insert key was intercepted', function()
    return lua 'return vim.fn.mode()' == 'i'
  end)
  expect_popup('<C-r>', 'WKREG')
  input 'a'
  wait_for('Register insertion failed', function()
    return lua('return vim.api.nvim_get_current_line()'):find('WKREG', 1, true) ~= nil
  end)
  reset()
  assert(lua 'return vim.v.errmsg' == '', 'The UI reported an error')
end, debug.traceback)

if not ok then
  pcall(function()
    print('UI at failure: ' .. popup())
    print('Input state: ' .. vim.inspect(lua 'return {mode=vim.fn.mode(1), error=vim.v.errmsg}'))
  end)
end
watchdog:stop()
watchdog:close()
vim.fn.jobstop(child)
vim.fn.jobwait({ child }, 1000)
assert(ok, err)
