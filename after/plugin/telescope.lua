local builtin = require("telescope.builtin")

vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-l>", builtin.live_grep, {})
vim.keymap.set("n", "<leader><space>", builtin.buffers, {})
-- Seems broken for now
-- vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, {})

pcall(require('telescope').load_extension, 'fzf')
require('telescope').setup { defaults = { file_ignore_patterns = { "node_modules", ".git" } } }
