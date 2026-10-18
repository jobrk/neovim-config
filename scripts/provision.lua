local function provision()
  local ok, err = xpcall(function()
    assert(vim.v.errmsg == '', vim.v.errmsg)

    local stage = vim.env.NVIM_PROVISION_STAGE
    if stage == 'plugins' then
      print '==> Restoring plugins'
      require('lazy').restore { wait = true, show = false }
      for name, plugin in pairs(require('lazy.core.config').plugins) do
        assert(vim.uv.fs_stat(plugin.dir), 'Missing plugin: ' .. name)
        for _, task in ipairs(plugin._.tasks or {}) do
          assert(not task:has_errors(), name .. ': ' .. task:output(vim.log.levels.ERROR))
        end
      end
    elseif stage == 'parsers' then
      print '==> Aligning parsers'
      require('parsers').sync()
    elseif stage == 'tools' then
      print '==> Installing tools'
      vim.cmd 'MasonToolsInstallSync'
      local registry = require 'mason-registry'
      local tooling = require 'tooling'
      for _, name in ipairs(tooling.mason) do
        assert(registry.get_package(name):is_installed(), 'Tool installation failed: ' .. name)
      end
      assert(registry.get_package('netcoredbg'):get_installed_version() == tooling.netcoredbg_version, 'netcoredbg version/architecture migration failed')
    else
      error('Unknown provisioning stage: ' .. tostring(stage))
    end
  end, debug.traceback)

  if not ok then
    io.stderr:write(tostring(err) .. '\n')
    vim.cmd 'cquit 1'
  end
  vim.cmd 'qa!'
end

-- Let startup and VimEnter plugins finish before changing installed tooling.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(provision)
  end,
})
