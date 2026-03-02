-- Neovim 0.12+ Modern LSP Configuration

-- 1. Global settings for all LSP servers
vim.lsp.config('*', {
  -- Native completion (0.12+)
  completion = {
    enable = true,
    autotrigger = true,
  },
  -- Native inlay hints (0.12+)
  inlay_hint = {
    enable = true,
  },
  -- Global on_attach for shared keymaps
  on_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

    -- Diagnostic Keymaps
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    -- Formatting Keymap (Manual, easily undo-able)
    vim.keymap.set('n', '<leader>F', function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

-- Customize warning highlights
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "Orange" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = "Orange" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "Orange" })

-- 2. Language-specific configurations and enablement

-- Lua
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable('lua_ls')

-- SystemVerilog
vim.lsp.enable('verible')

-- C/C++
vim.lsp.enable('clangd')

-- CMake
vim.lsp.config('neocmake', {
  cmd = { 'neocmakelsp', 'stdio' },
})
vim.lsp.enable('neocmake')

-- Python
vim.lsp.enable('pyright')

-- Makefile (Autotools)
vim.lsp.enable('autotools_ls')
