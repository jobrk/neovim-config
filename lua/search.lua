local M = {}

M.excluded_dirs = {
  '.git',
  '.worktrees',
  '.claude/worktrees',
}

function M.rg_exclude_globs()
  return vim.tbl_map(function(dir)
    return '--glob=!**/' .. dir .. '/*'
  end, M.excluded_dirs)
end

function M.telescope_ignore_patterns()
  return vim.tbl_map(function(dir)
    return vim.pesc(dir) .. '/'
  end, M.excluded_dirs)
end

return M
