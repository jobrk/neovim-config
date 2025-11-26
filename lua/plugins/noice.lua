return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = { enabled = true },
    messages = { enabled = true },
    popupmenu = { enabled = false },
    notify = { enabled = false },
    lsp = {
      progress = { enabled = false },
      hover = { enabled = false },
      signature = { enabled = false },
      message = { enabled = false },
    },
    health = { checker = false },
    presets = {
      bottom_search = false,
      command_palette = false,
      long_message_to_split = false,
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
  dependencies = {
      "MunifTanjim/nui.nvim",
  }
}
