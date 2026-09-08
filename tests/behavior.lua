local fixture = vim.fn.tempname()
vim.fn.mkdir(fixture, 'p')
local function write(path, contents)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  vim.fn.writefile({ contents or '' }, path)
end
local buffers = {}
local function buffer(path)
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(bufnr, path)
  buffers[#buffers + 1] = bufnr
  return bufnr
end

local original_get_client, original_get_clients = vim.lsp.get_client_by_id, vim.lsp.get_clients
local jdtls = require 'jdtls'
local original_start = jdtls.start_or_attach
local ok, err = xpcall(function()
  local formatting = require 'formatting'
  local root = fixture .. '/web'
  vim.fn.mkdir(root .. '/.git', 'p')
  local source = buffer(root .. '/package/src/test.ts')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'Default web formatter changed')
  write(root .. '/node_modules/.bin/oxfmt', '#!/bin/sh')
  vim.fn.setfperm(root .. '/node_modules/.bin/oxfmt', 'rwxr-xr-x')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'Local installation incorrectly overrides formatting policy')
  write(root .. '/.oxfmtrc.json', '{}')
  assert(formatting.web_formatter(source)[1] == 'oxfmt', 'Explicit oxfmt config is ignored')
  vim.fn.delete(root .. '/.oxfmtrc.json')
  for _, name in ipairs(formatting.oxfmt_configs) do
    write(root .. '/' .. name, '{}')
    assert(formatting.web_formatter(source)[1] == 'oxfmt', 'oxfmt config is ignored: ' .. name)
    local project = require('conform.util').root_file(formatting.oxfmt_configs)(nil, { dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(source)) })
    assert(project and vim.uv.fs_realpath(project) == vim.uv.fs_realpath(root), 'oxfmt runs outside the project for ' .. name)
    vim.fn.delete(root .. '/' .. name)
  end
  write(root .. '/.oxfmtrc.json', '{}')
  write(root .. '/package/prettier.config.js', 'module.exports = {}')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'Nested Prettier config loses to ancestor oxfmt')
  write(root .. '/package/.oxfmtrc.json', '{}')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'Prettier should win same-directory conflicts')
  vim.b[source].web_formatter = 'oxfmt'
  assert(formatting.web_formatter(source)[1] == 'oxfmt', 'Buffer override is ignored')
  vim.b[source].web_formatter = nil
  vim.fn.delete(root .. '/package/prettier.config.js')
  vim.fn.delete(root .. '/package/.oxfmtrc.json')
  write(root .. '/package/package.json', '{"prettier":{"semi":false}}')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'package.json Prettier config is ignored')
  vim.fn.delete(root .. '/package/package.json')
  vim.fn.delete(root .. '/.oxfmtrc.json')
  write(fixture .. '/.oxfmtrc.json', '{}')
  assert(formatting.web_formatter(source)[1] == 'prettier', 'Search escaped the repository boundary')
  vim.g.disable_autoformat = true
  assert(not formatting.enabled(source), 'Global format disable is ignored')
  vim.g.disable_autoformat = false

  local first, second = buffer(fixture .. '/first.txt'), buffer(fixture .. '/second.txt')
  local clients = {
    {
      id = 91001,
      request = function()
        return true, 1
      end,
      supports_method = function()
        return true
      end,
    },
    {
      id = 91002,
      request = function()
        return true, 1
      end,
      supports_method = function()
        return true
      end,
    },
  }
  vim.lsp.get_client_by_id = function(id)
    return id == clients[1].id and clients[1] or clients[2]
  end
  vim.lsp.get_clients = function()
    return clients
  end
  local attach = vim.api.nvim_get_autocmds({ group = 'kickstart-lsp-attach' })[1].callback
  local detach = vim.api.nvim_get_autocmds({ group = 'kickstart-lsp-detach' })[1].callback
  for _, client in ipairs(clients) do
    attach { buf = first, data = { client_id = client.id } }
  end
  local function highlight_count()
    return #vim.api.nvim_get_autocmds { group = 'kickstart-lsp-highlight', buffer = first }
  end
  assert(highlight_count() == 4, 'Multiple clients duplicate highlight hooks')
  vim.api.nvim_set_current_buf(first)
  vim.lsp.inlay_hint.enable(false)
  vim.fn.maparg('<leader>th', 'n', false, true).callback()
  assert(vim.lsp.inlay_hint.is_enabled { bufnr = first })
  assert(not vim.lsp.inlay_hint.is_enabled { bufnr = second }, 'Inlay hint toggle affected another buffer')
  detach { buf = first, data = { client_id = clients[1].id } }
  assert(highlight_count() == 4, 'Detaching one client removed another client’s highlight hooks')
  clients = { clients[2] }
  detach { buf = first, data = { client_id = clients[1].id } }
  assert(highlight_count() == 0, 'Final detach leaked highlight hooks')
  vim.lsp.get_client_by_id, vim.lsp.get_clients = original_get_client, original_get_clients

  local calls = {}
  jdtls.start_or_attach = function(config)
    calls[vim.api.nvim_get_current_buf()] = config.root_dir
  end
  for _, name in ipairs { 'java-one', 'java-two' } do
    local project = fixture .. '/' .. name
    vim.fn.mkdir(project .. '/.git', 'p')
    local java_buffer = buffer(project .. '/Main.java')
    vim.api.nvim_set_current_buf(java_buffer)
    vim.bo[java_buffer].filetype = 'java'
    assert(calls[java_buffer] and vim.uv.fs_realpath(calls[java_buffer]) == vim.uv.fs_realpath(project), 'JDTLS did not configure the buffer’s project root')
    assert(next(vim.fn.maparg('<leader>jo', 'n', false, true)), 'Java buffer is missing its mappings')
  end

  -- Exercise the actual shell entrypoint; Lua errors must reach the process status.
  local failure_file = fixture .. '/failure.lua'
  write(failure_file, "error('intentional failure-status probe')")
  local failure = vim.system({ 'bash', './check.sh', failure_file }, { text = true }):wait(30000)
  assert(failure.code ~= 0 and failure.stderr:find('intentional failure-status probe', 1, true), 'Lua errors do not fail check.sh')
  write(failure_file, "vim.treesitter.query.parse('lua', '((audit_nonexistent_node) @error)')")
  failure = vim.system({ 'bash', './check.sh', failure_file }, { text = true }):wait(30000)
  assert(failure.code ~= 0 and failure.stderr:find('Invalid node', 1, true), 'Invalid queries do not fail check.sh')
  -- Runtime ftplugins use silent! for optional cleanup; that is not a failed task.
  write(failure_file, "vim.cmd 'silent! definitely_not_an_editor_command'")
  local ignored = vim.system({ 'bash', './check.sh', failure_file }, { text = true }):wait(30000)
  assert(ignored.code == 0, 'An explicitly ignored Vim error incorrectly fails check.sh')
end, debug.traceback)

jdtls.start_or_attach = original_start
vim.lsp.get_client_by_id, vim.lsp.get_clients = original_get_client, original_get_clients
vim.g.disable_autoformat = false
for _, bufnr in ipairs(buffers) do
  pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
end
vim.fn.delete(fixture, 'rf')
assert(ok, err)
