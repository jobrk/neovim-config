local builtin = require("telescope.builtin")

vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-l>", builtin.live_grep, {})

require('telescope').setup { defaults = { file_ignore_patterns = { "node_modules", ".git" } } }
