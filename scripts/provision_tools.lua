vim.cmd 'MasonToolsInstallSync'
local registry = require 'mason-registry'
for _, name in ipairs(require('tooling').mason) do
  assert(registry.get_package(name):is_installed(), 'Tool installation failed: ' .. name)
end
assert(registry.get_package('netcoredbg'):get_installed_version() == require('tooling').netcoredbg_version, 'netcoredbg version/architecture migration failed')
