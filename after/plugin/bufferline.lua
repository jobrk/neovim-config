require("catppuccin").setup({
  flavour = "macchiato",
})

require('bufferline').setup {
  highlights = require("catppuccin.groups.integrations.bufferline").get()
}
