-- Treesitter parsers for highlighting and indentation, installed on first launch
-- https://github.com/nvim-treesitter/nvim-treesitter

-- Install the complete language set while lazy.nvim bootstraps this plugin.
local parsers = {
  'bash',
  'c',
  'c_sharp',
  'css',
  'diff',
  'dockerfile',
  'gitignore',
  'git_rebase',
  'go',
  'graphql',
  'groovy',
  'html',
  'ini',
  'javascript',
  'jinja',
  'jinja_inline',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'powershell',
  'proto',
  'puppet',
  'python',
  'query',
  'rust',
  'sql',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
  'zsh',
}

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
