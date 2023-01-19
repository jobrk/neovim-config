vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set("n", "J", "mzJ`z", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
vim.keymap.set("n", "n", "nzzzv", { silent = true })
vim.keymap.set("n", "N", "Nzzzv", { silent = true })

vim.keymap.set("x", "<leader>p", [["_dP]], { silent = true })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { silent = true })
vim.keymap.set("n", "<leader>Y", [["+Y]], { silent = true })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { silent = true })

vim.keymap.set("n", "<C-w>v", "<C-w>v<C-w><C-w>", { silent = true })

