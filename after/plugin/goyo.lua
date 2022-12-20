vim.keymap.set("n", "<leader>g", ":Goyo<cr>")

vim.g.goyo_linenr = 1
vim.g.goyo_height = "100%"
vim.g.goyo_width = 100

-- function! s:goyo_enter()
--   lua require('lualine').hide()
-- endfunction

-- function! s:goyo_leave()
--   lua require('lualine').hide({unhide=true})
--   Catppuccin frappe
-- endfunction
--
-- autocmd! User GoyoEnter nested call <SID>goyo_enter()
-- autocmd! User GoyoLeave nested call <SID>goyo_leave()
