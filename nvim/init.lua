--init.lua
vim.g.mapleader = ' '

-- 1. Настройки базового интерфейса
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.wrap = false

-- 2. Установка менеджера плагинов (Lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Список плагинов
require("lazy").setup({
  -- Цветовая схема VS
  {
    'Mofiqul/vscode.nvim',
    config = function()
      vim.cmd.colorscheme 'vscode'
    end
  },

  -- Treesitter (улучшенная подсветка)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {'c', 'cpp', 'python', 'lua', 'cmake'},
        highlight = {enable = true},
        indent = {enable = true}
      })
    end
  },

  -- LSP и автодополнение
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'L3MON4D3/LuaSnip'},

  -- Файловый менеджер
  {'nvim-tree/nvim-tree.lua'},

  -- Статусная строка
  {'nvim-lualine/lualine.nvim'},

  -- Отладка (DAP)
  {'mfussenegger/nvim-dap'},
  {'rcarriga/nvim-dap-ui'},

  -- Telescope (поиск)
  {'nvim-telescope/telescope.nvim', dependencies = {'nvim-lua/plenary.nvim'}},

  { 'nvim-neotest/nvim-nio' },
})

-- 4. Настройка LSP для C/C++
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {'clangd'},
  handlers = {
    function(server_name)
      lspconfig[server_name].setup {
        capabilities = capabilities,
      }
    end,
  }
})

-- 5. Настройка автодополнения
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  })
})

-- 6. Настройка файлового менеджера
require('nvim-tree').setup()

-- 7. Настройка статусной строки
require('lualine').setup({
  options = {theme = 'vscode'}
})

-- 8. Настройка отладки (DAP)
local dap = require('dap')
local dapui = require('dapui')

dapui.setup()
dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Конфигурация для C/C++ (требуется установленный lldb)
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode',
  name = 'lldb'
}

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}

-- 9. Горячие клавиши
vim.keymap.set('n', '<ctrl>f', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
vim.keymap.set('n', '<F5>', ':lua require"dap".continue()<CR>')
vim.keymap.set('n', '<F9>', ':lua require"dap".toggle_breakpoint()<CR>')
vim.keymap.set('n', '<F10>', ':lua require"dap".step_over()<CR>')
vim.keymap.set('n', '<F11>', ':lua require"dap".step_into()<CR>')
