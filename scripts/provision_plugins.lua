require('lazy').restore { wait = true, show = false }

for name, plugin in pairs(require('lazy.core.config').plugins) do
  assert(vim.uv.fs_stat(plugin.dir), 'Missing plugin: ' .. name)
  for _, task in ipairs(plugin._.tasks or {}) do
    assert(not task:has_errors(), name .. ': ' .. task:output(vim.log.levels.ERROR))
  end
end
