-- Treesitter parsers for highlighting and indentation, auto-installed per filetype
-- https://github.com/nvim-treesitter/nvim-treesitter

return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
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
          return
        end

        if not vim.tbl_contains(require('nvim-treesitter').get_available(), lang) then
          return
        end

        -- Parser missing: install async, then enable once ready
        local ok, task = pcall(require('nvim-treesitter').install, { lang })
        if not ok or not task then
          return
        end
        task:await(function(err, installed)
          if not err and installed then
            vim.schedule(function()
              enable_treesitter(ev.buf)
            end)
          end
        end)
      end,
    })
  end,
}
