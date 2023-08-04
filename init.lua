vim.g.python2_host_prog = 'python2'
vim.g.python3_host_prog = 'python3'

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.local/share/nvim/plugged')
Plug 'godlygeek/tabular'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rake'
Plug 'tpope/vim-rails'
Plug 'vimwiki/vimwiki'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-abolish'
Plug('iamcco/markdown-preview.nvim', { ['do'] = vim.fn['mkdp#util#install'] })
Plug('williamboman/mason.nvim', { ['do'] = vim.fn[':MasonUpdate'] })
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'mfussenegger/nvim-jdtls'
Plug 'mhartington/formatter.nvim'
Plug 'jose-elias-alvarez/typescript.nvim'
Plug 'mfussenegger/nvim-lint'
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'dpayne/CodeGPT.nvim'
Plug 'github/copilot.vim'
vim.call('plug#end')

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    "clangd",
    "cucumber_language_server",
    "dockerls",
    "docker_compose_language_service",
    "gopls",
    "gradle_ls",
    "graphql",
    "groovyls",
    "html",
    "jsonls",
    "jdtls",
    "tsserver",
    "marksman",
    "pylsp",
    "solargraph",
    "rust_analyzer",
    "sqls",
    "tailwindcss",
    "lemminx",
    "yamlls"
  }
}

require("typescript").setup({})

local lspconfig = require("lspconfig")

lspconfig.solargraph.setup {
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true
    }
  }
}

-- lspconfig.jdtls.setup {}
lspconfig.gradle_ls.setup {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

local home = os.getenv('HOME')
require("formatter").setup {
  logging = true,
  log_level = vim.log.levels.WARN,
  filetype = {
    java = {
      function()
        return {
          exe = home .. "/.local/share/nvim/mason/bin/google-java-format",
          args = {  vim.api.nvim_buf_get_name(0) },
          stdin = true,
        }
      end
    },
    ruby = {
      require("formatter.filetypes.ruby").rubocop()
    },
    go = {
      require("formatter.filetypes.go").gofmt()
    },
    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

local format_autogroup = vim.api.nvim_create_augroup('FormatAutogroup', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = '*',
  group = format_autogroup,
  command = 'FormatWrite',
})

vim.keymap.set('n', '<space>f', ':Format<CR>', { silent = true })
vim.keymap.set('n', '<space>F', ':FormatWrite<CR>', { silent = true })

require("codegpt.config")

-- Better display for messages
vim.opt.cmdheight = 2

-- You will have bad experience for diagnostic messages when it's default 4000.
vim.opt.updatetime = 300

-- don't give |ins-completion-menu| messages.
vim.opt.shortmess:append({ I = true })

-- allow backspacing over everything in insert mode
vim.opt.backspace = { indent, eol, start }

vim.opt.history = 50  -- keep 50 lines of command line history

vim.cmd [[
  highlight ExtraWhitespace ctermbg=Red guibg=Red
  match ExtraWhitespace /\s\+$\| \+\ze\t/
]]

vim.g.mapleader = ','

vim.keymap.set('n', '<Leader>a=', ':Tabularize /=<CR>')
vim.keymap.set('v', '<Leader>a=', ':Tabularize /=<CR>')
vim.keymap.set('n', '<Leader>a:', ':Tabularize /:\zs<CR>')
vim.keymap.set('v', '<Leader>a:', ':Tabularize /:\zs<CR>')
vim.keymap.set('n', '<Leader>a,', ':Tabularize /,\zs<CR>')
vim.keymap.set('v', '<Leader>a,', ':Tabularize /,\zs<CR>')

function _G.alignMdTable()
  local pattern = '^%s*|%s.*%s|%s*$'
  local lineNumber = vim.fn.line('.')
  local currentColumn = vim.fn.col('.')
  local previousLine = vim.fn.getline(lineNumber - 1)
  local currentLine = vim.fn.getline('.')
  local nextLine = vim.fn.getline(lineNumber + 1)

  if vim.fn.exists(':Tabularize') and currentLine:match('^%s*|') and (previousLine:match(pattern) or nextLine:match(pattern)) then
    local column = #currentLine:sub(1, currentColumn):gsub('[^|]', '')
    local position = #vim.fn.matchstr(currentLine:sub(1, currentColumn), ".*|\\s*\\zs.*")
    vim.cmd('Tabularize/|/l1') -- `l` means left aligned and `1` means one space of cell padding
    vim.cmd('normal! 0')
    vim.fn.search(('[^|]*|'):rep(column) .. ('\\s\\{-\\}'):rep(position), 'ce', lineNumber)
  end
end

vim.keymap.set('i', '<silent> <Bar>', '<Bar><Esc>:call v:lua.alignMdTable()<CR>a', { expr = true, noremap = true })
