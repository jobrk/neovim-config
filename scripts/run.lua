-- Run a headless task with a real process failure on startup or Lua errors.
local function run()
  local ok, err = xpcall(function()
    assert(vim.v.errmsg == '', vim.v.errmsg)
    dofile(assert(vim.env.NVIM_TASK, 'NVIM_TASK must name a Lua task'))
  end, debug.traceback)

  if not ok then
    io.stderr:write(tostring(err) .. '\n')
    vim.cmd 'cquit 1'
  else
    vim.cmd 'qa!'
  end
end

if vim.v.vim_did_enter == 1 then
  vim.schedule(run)
else
  vim.api.nvim_create_autocmd('VimEnter', {
    once = true,
    callback = function()
      vim.schedule(run)
    end,
  })
end
