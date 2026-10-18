-- Debug Adapter Protocol client with UI and polyglot adapters
-- https://github.com/mfussenegger/nvim-dap

local function python_path()
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

local function dotnet_program()
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

local function dap_action(method)
  return function()
    require('dap')[method]()
  end
end

return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      keys = {
        {
          '<leader>du',
          function()
            require('dapui').toggle()
          end,
          desc = 'DAP UI: toggle',
        },
        {
          '<leader>de',
          function()
            require('dapui').eval()
          end,
          desc = 'DAP UI: eval expression',
        },
      },
    },

    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'leoluz/nvim-dap-go',
    { 'theHamsta/nvim-dap-virtual-text', opts = { commented = true } },
  },
  keys = {
    { '<leader>dc', dap_action 'continue', desc = 'DAP: continue' },
    { '<leader>dr', dap_action 'restart', desc = 'DAP: restart' },
    { '<leader>dq', dap_action 'terminate', desc = 'DAP: quit' },

    { '<leader>db', dap_action 'toggle_breakpoint', desc = 'DAP: toggle breakpoint' },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'DAP: conditional breakpoint',
    },

    { '<leader>dn', dap_action 'step_over', desc = 'DAP: step over' },
    { '<leader>di', dap_action 'step_into', desc = 'DAP: step into' },
    { '<leader>do', dap_action 'step_out', desc = 'DAP: step out' },

    { '<leader>dk', dap_action 'up', desc = 'DAP: stack up' },
    { '<leader>dj', dap_action 'down', desc = 'DAP: stack down' },

    {
      '<leader>dh',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'DAP: hover',
      mode = { 'n', 'v' },
    },
    {
      '<leader>dp',
      function()
        require('dap.ui.widgets').preview()
      end,
      desc = 'DAP: preview',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    local netcoredbg_adapter = {
      type = 'executable',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }

    dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
    dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

    local mason = vim.fn.stdpath 'data' .. '/mason/packages'
    dap.adapters.python = {
      type = 'executable',
      command = mason .. '/debugpy/venv/bin/python',
      args = { '-m', 'debugpy.adapter' },
    }
    dap.configurations.python = {
      { type = 'python', request = 'launch', name = 'Launch current file', program = '${file}', pythonPath = python_path },
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

    dapui.setup {
      floating = { border = vim.o.winborder },
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'launch - netcoredbg',
        request = 'launch',
        program = dotnet_program,
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
