require("nvim-tree").setup({
  view = {
    mappings = {
      list = {
        { key = "<C-t>", action = "" },
      }
    }
  }
})

local api = require("nvim-tree.api")
local view = require("nvim-tree.view")

vim.keymap.set("n", "<leader>n", function()
  -- Hack used to ensure the tree view stays open
  api.tree.close()
  api.tree.toggle(true)
end)
vim.keymap.set("n", "<C-t>", function()
  api.tree.toggle()
end)

