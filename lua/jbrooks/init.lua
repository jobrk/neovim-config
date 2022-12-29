require("jbrooks.set")
require("jbrooks.remap")

local autocmd = vim.api.nvim_create_autocmd

-- autocmd('BufWritePre', {
--   group = vim.api.nvim_create_augroup("jbrooks_fmt", {}),
--   pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
--   callback = vim.lsp.buf.format
-- })

autocmd("FileType", {
  callback = function()
    local bufnr = vim.fn.bufnr('%')
    vim.keymap.set("n", "<CR>", "<CR>:cclose<CR>", { buffer = bufnr })
  end,
  pattern = "qf",
})
