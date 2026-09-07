local M = {}

function M.python()
  if vim.env.VIRTUAL_ENV then
    local executable = vim.env.VIRTUAL_ENV .. '/bin/python'
    if vim.fn.executable(executable) == 1 then
      return executable
    end
  end
  local directory = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  while directory and directory ~= '' do
    for _, name in ipairs { '.venv', 'venv' } do
      local executable = directory .. '/' .. name .. '/bin/python'
      if vim.fn.executable(executable) == 1 then
        return executable
      end
    end
    if vim.uv.fs_stat(directory .. '/.git') then
      break
    end
    local parent = vim.fs.dirname(directory)
    if parent == directory then
      break
    end
    directory = parent
  end
  return vim.fn.exepath 'python3'
end

function M.dotnet_program()
  local project = vim.fs.find(function(name)
    return name:match '%.csproj$' ~= nil
  end, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1]
  local directory = project and vim.fs.dirname(project) or vim.fn.getcwd()
  local outputs = vim.fn.glob(directory .. '/bin/Debug/net*/*.runtimeconfig.json', true, true)
  table.sort(outputs, function(a, b)
    return vim.fn.getftime(a) > vim.fn.getftime(b)
  end)
  local default = outputs[1] and outputs[1]:gsub('%.runtimeconfig%.json$', '.dll') or directory .. '/bin/Debug/'
  return vim.fn.input('Path to DLL (build the project first): ', default, 'file')
end

function M.setup()
  local dap = require 'dap'
  local mason = vim.fn.stdpath 'data' .. '/mason/packages'
  dap.adapters.python = {
    type = 'executable',
    command = mason .. '/debugpy/venv/bin/python',
    args = { '-m', 'debugpy.adapter' },
  }
  dap.configurations.python = {
    { type = 'python', request = 'launch', name = 'Launch current file', program = '${file}', pythonPath = M.python },
  }

  dap.adapters['pwa-node'] = {
    type = 'server',
    host = '127.0.0.1',
    port = '${port}',
    executable = { command = 'js-debug-adapter', args = { '${port}', '127.0.0.1' } },
  }
  for _, ft in ipairs { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } do
    dap.configurations[ft] = {
      { type = 'pwa-node', request = 'launch', name = 'Launch current file', program = '${file}', cwd = '${workspaceFolder}', sourceMaps = true },
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to Node',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
      },
    }
  end

  dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = { command = 'codelldb', args = { '--port', '${port}' } },
  }
end

return M
