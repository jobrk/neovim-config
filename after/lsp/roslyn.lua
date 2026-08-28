---@type vim.lsp.Config
return {
  settings = {
    ['projects'] = {
      dotnet_enable_file_based_programs = false,
      dotnet_enable_file_based_programs_when_ambiguous = false,
    },
  },
}
