-- Treesitter parsers for highlighting and indentation
-- https://github.com/nvim-treesitter/nvim-treesitter

local parsers = require('tooling').treesitter

return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = function()
    require('nvim-treesitter').install(parsers, { max_jobs = 1 }):wait(300000)
  end,
  config = function()
    local function enable_treesitter(bufnr)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      pcall(vim.treesitter.start, bufnr)
      local ft = vim.bo[bufnr].filetype
      if ft ~= 'ruby' then
        vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
      callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
          return
        end

        if pcall(vim.treesitter.language.inspect, lang) then
          enable_treesitter(ev.buf)
        end
      end,
    })
  end,
}
