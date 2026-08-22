-- LSP server configs, Mason installer wiring, and on-attach keymaps
-- https://github.com/neovim/nvim-lspconfig

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'mason-org/mason.nvim',
      opts = {
        registries = {
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
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    vim.api.nvim_create_autocmd('LspDetach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
      callback = function(event)
        vim.lsp.util.buf_clear_references(event.buf)
        vim.api.nvim_clear_autocmds { group = highlight_augroup, buffer = event.buf }
      end,
    })

    vim.lsp.config('*', {
      capabilities = require('blink.cmp').get_lsp_capabilities(),
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

    require('mason-tool-installer').setup {
      ensure_installed = require('tooling').mason,
      run_on_start = false,
    }

    require('mason-lspconfig').setup {
      automatic_enable = {
        exclude = {
          'jdtls',
        },
      },
    }
  end,
}
