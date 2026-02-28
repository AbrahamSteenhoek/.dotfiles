-- lua/plugins/treesitter.lua

-- 1. Register any filetype exceptions here
-- The syntax is: vim.treesitter.language.register('parser_name', 'filetype')
vim.treesitter.language.register('bash', 'sh')
vim.treesitter.language.register('systemverilog', 'sv')
vim.treesitter.language.register('systemverilog', 'svh')
vim.treesitter.language.register('systemverilog', 'v')
vim.treesitter.language.register('systemverilog', 'vh')

-- Example: If Neovim ever misidentifies your SystemVerilog header files 
-- as generic Verilog or cpp, you can force the mapping like this:
-- vim.treesitter.language.register('systemverilog', 'svh')

-- 2. Enable Native Neovim Highlighting
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        -- Tries to start treesitter natively. If the parser isn't installed yet,
        -- pcall silently catches the error and falls back to standard regex highlighting.
        pcall(vim.treesitter.start, args.buf)
    end
})
