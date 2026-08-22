-- Eclipse JDT language server extensions for Java
-- https://github.com/mfussenegger/nvim-jdtls

return {
  'mfussenegger/nvim-jdtls',
  ft = { 'java' },
  dependencies = {
    'mfussenegger/nvim-dap',
    'saghen/blink.cmp',
  },
  config = function()
    local jdtls = require 'jdtls'
    local data_dir = vim.fn.stdpath 'data'
    local jdtls_command = data_dir .. '/mason/bin/jdtls'
    if vim.fn.executable(jdtls_command) == 0 then
      vim.notify('jdtls is not installed; run :MasonToolsInstallSync', vim.log.levels.WARN)
      return
    end

    local root_dir = vim.fs.root(0, { 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', 'build.gradle.kts', '.git' }) or vim.fn.getcwd()
    local project_name = vim.fs.basename(root_dir)
    local workspace_id = project_name .. '-' .. vim.fn.sha256(root_dir):sub(1, 12)
    local workspace_dir = vim.fn.stdpath 'cache' .. '/jdtls/' .. workspace_id

    local mason_packages = data_dir .. '/mason/packages'
    local bundles = vim.fn.glob(mason_packages .. '/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
    local excluded_test_jars = {
      ['com.microsoft.java.test.runner-jar-with-dependencies.jar'] = true,
      ['jacocoagent.jar'] = true,
    }
    for _, jar in ipairs(vim.fn.glob(mason_packages .. '/java-test/extension/server/*.jar', true, true)) do
      if not excluded_test_jars[vim.fs.basename(jar)] then
        table.insert(bundles, jar)
      end
    end

    local map = function(keys, action, description)
      vim.keymap.set('n', keys, action, { buffer = true, desc = description })
    end
    map('<leader>jo', jdtls.organize_imports, 'Java: organize imports')
    map('<leader>jt', jdtls.test_nearest_method, 'Java: test nearest method')
    map('<leader>jT', jdtls.test_class, 'Java: test class')

    jdtls.start_or_attach {
      cmd = { jdtls_command, '-data', workspace_dir },
      root_dir = root_dir,
      capabilities = require('blink.cmp').get_lsp_capabilities(),
      init_options = { bundles = bundles },
      on_attach = function()
        jdtls.setup_dap { hotcodereplace = 'auto' }
        require('jdtls.dap').setup_dap_main_class_configs()
      end,
    }
  end,
}
