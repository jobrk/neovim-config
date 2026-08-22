-- Debug Adapter Protocol client with UI, virtual text, and Go/.NET adapters
-- https://github.com/mfussenegger/nvim-dap

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
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

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

    { 'theHamsta/nvim-dap-virtual-text', opts = { commented = true } },
  },
  keys = {
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'DAP: continue',
    },
    {
      '<leader>dr',
      function()
        require('dap').restart()
      end,
      desc = 'DAP: restart',
    },
    {
      '<leader>dq',
      function()
        require('dap').terminate()
      end,
      desc = 'DAP: quit',
    },

    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'DAP: toggle breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'DAP: conditional breakpoint',
    },

    {
      '<leader>dn',
      function()
        require('dap').step_over()
      end,
      desc = 'DAP: step over',
    },
    {
      '<leader>di',
      function()
        require('dap').step_into()
      end,
      desc = 'DAP: step into',
    },
    {
      '<leader>do',
      function()
        require('dap').step_out()
      end,
      desc = 'DAP: step out',
    },

    {
      '<leader>dk',
      function()
        require('dap').up()
      end,
      desc = 'DAP: stack up',
    },
    {
      '<leader>dj',
      function()
        require('dap').down()
      end,
      desc = 'DAP: stack down',
    },

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

    require('mason-nvim-dap').setup {
      handlers = {},
      ensure_installed = require('tooling').mason_dap,
    }

    dapui.setup {
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
        program = function()
          -- Default to the newest bin/Debug/net*/ dir so the prompt survives .NET version bumps
          local dirs = vim.fn.glob(vim.fn.getcwd() .. '/bin/Debug/net*/', true, true)
          local default = dirs[#dirs] or (vim.fn.getcwd() .. '/bin/Debug/')
          return vim.fn.input('Path to dll: ', default, 'file')
        end,
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
