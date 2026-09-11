-- LSP server configs, Mason installer wiring, and on-attach keymaps
-- https://github.com/neovim/nvim-lspconfig

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'mason-org/mason.nvim',
      opts = {
        registries = {
          'lua:mason_registry',
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      },
    },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },
  config = function()
    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = true })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, opts)
          opts = vim.tbl_extend('force', { buffer = event.buf, desc = 'LSP: ' .. desc }, opts or {})
          vim.keymap.set('n', keys, func, opts)
        end

        -- Search exclusions belong to the file and grep pickers. The server already
        -- scopes its results to the project, and applying the exclusions here would
        -- discard every result whose path sits under a worktree directory.
        local lsp_picker = function(name)
          return function()
            require('telescope.builtin')[name] { file_ignore_patterns = {} }
          end
        end

        map('gd', lsp_picker 'lsp_definitions', '[G]oto [D]efinition')
        map('gr', lsp_picker 'lsp_references', '[G]oto [R]eferences', { nowait = true })
        map('gI', lsp_picker 'lsp_implementations', '[G]oto [I]mplementation')
        map('<leader>D', lsp_picker 'lsp_type_definitions', 'Type [D]efinition')

        map('<leader>ds', lsp_picker 'lsp_document_symbols', '[D]ocument [S]ymbols')
        map('<leader>ws', lsp_picker 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')

        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          -- One set per buffer, even when several clients provide highlights.
          vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event.buf }
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            local filter = { bufnr = event.buf }
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event)
        vim.lsp.util.buf_clear_references(event.buf)
        local remaining = vim.tbl_filter(function(client)
          return client.id ~= event.data.client_id
        end, vim.lsp.get_clients { bufnr = event.buf, method = vim.lsp.protocol.Methods.textDocument_documentHighlight })
        if #remaining == 0 then
          vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event.buf }
        end
      end,
    })

    vim.lsp.config('*', {
      capabilities = require('lsp').capabilities(),
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    })

    local tooling = require 'tooling'
    require('mason-tool-installer').setup {
      ensure_installed = vim.tbl_map(function(name)
        return name == 'netcoredbg' and { name, version = tooling.netcoredbg_version } or name
      end, tooling.mason),
      run_on_start = false,
      integrations = { ['mason-nvim-dap'] = false },
    }

    require('mason-lspconfig').setup {
      -- Installation is separate from activation. JDTLS, Roslyn and
      -- Rustaceanvim own their specialised language-server lifecycles.
      automatic_enable = require('tooling').lsp,
    }
  end,
}
