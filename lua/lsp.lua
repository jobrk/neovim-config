local M = {}

function M.capabilities()
  return require('blink.cmp').get_lsp_capabilities()
end

return M
