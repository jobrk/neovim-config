local M = {}

function M.sync()
  local treesitter = require 'nvim-treesitter'
  local languages = require('tooling').treesitter
  local opts = { max_jobs = 1 }
  assert(treesitter.install(languages, opts):wait(900000), 'Tree-sitter parser installation failed')
  assert(treesitter.update(languages, opts):wait(900000), 'Tree-sitter parser update failed')
end

return M
