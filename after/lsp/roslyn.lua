-- Extends roslyn.nvim's lsp/roslyn.lua (merged by runtimepath order).
---@type vim.lsp.Config
return {
  settings = {
    ['projects'] = {
      -- A .cs outside any loaded project (scratch buffers, files opened
      -- before the solution finishes loading) otherwise becomes a
      -- file-based program in a synthetic misc csproj and reports
      -- phantom errors against the real project's types.
      dotnet_enable_file_based_programs = false,
      dotnet_enable_file_based_programs_when_ambiguous = false,
    },
  },
}
