vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.textwidth = 100
vim.opt_local.smarttab = true
vim.opt_local.expandtab = true
vim.opt_local.smartindent = true

local jdtls = require('jdtls')
local root_markers = { 'gradlew', '.git' }
local home = os.getenv('HOME')
local root_dir = require('jdtls.setup').find_root(root_markers)
local workspace = home .. "/.workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local sdk_java_candidates = home .. "/.sdkman/candidates/java"
local mason_bin = home .. "/.local/share/nvim/mason/bin"
local config = {
  cmd = { mason_bin .. "/jdtls", '-data', workspace },
  root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-1.8",
            path = sdk_java_candidates .. "/8.0.282.hs-adpt/",
            default = true
          },
          {
            name = "JavaSE-17",
            path = sdk_java_candidates .. "/17.0.7-tem/"
          },
          {
            name = "JavaSE-19",
            path = sdk_java_candidates .. "/19.0.2-open/"
          },
        }
      }
    }
  },
  on_attach = function(client, bufnr)
    jdtls.setup.add_commands()
    local opts = { silent = true, buffer = bufnr }
    vim.keymap.set('n', "<space>o", jdtls.organize_imports, opts)
  end
}

jdtls.start_or_attach(config)
