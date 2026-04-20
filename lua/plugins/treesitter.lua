-- Parsers to install on plugin install/update (via :Lazy build)
local parsers = {
  'bash', 'c', 'css', 'diff', 'html', 'lua', 'luadoc',
  'javascript', 'json', 'typescript', 'tsx',
  'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  'jinja', 'groovy', 'python', 'yaml',
}

return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = function()
    require('nvim-treesitter').install(parsers):wait(300000)
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

        if not pcall(vim.treesitter.language.inspect, lang) then
          -- Parser missing: install async, then enable once ready
          pcall(function()
            require('nvim-treesitter').install { lang }
          end)
          local bufnr = ev.buf
          local timer = vim.uv.new_timer()
          local closed = false
          timer:start(500, 500, vim.schedule_wrap(function()
            if closed then
              return
            end
            if not vim.api.nvim_buf_is_valid(bufnr) then
              closed = true
              timer:stop()
              timer:close()
              return
            end
            if pcall(vim.treesitter.language.inspect, lang) then
              closed = true
              timer:stop()
              timer:close()
              enable_treesitter(bufnr)
            end
          end))
          return
        end

        enable_treesitter(ev.buf)
      end,
    })
  end,
}
