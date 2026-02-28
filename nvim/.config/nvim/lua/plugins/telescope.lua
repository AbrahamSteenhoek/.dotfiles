-- lua/config/telescope.lua

local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
    defaults = {
        prompt_prefix = "🔍 ",
        selection_caret = "❯ ",
        path_display = { "truncate" },
        
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
        },
    },
    pickers = {
        find_files = {
            hidden = true, 
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
    },
})

-- Safely load the fast C-sorter
pcall(telescope.load_extension, 'fzf')

-- Keymaps
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep (Search text)' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find open buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help tags' })

-- RTL Specific Keymap
vim.keymap.set('n', '<leader>fv', function()
    builtin.live_grep({
        glob_pattern = { "*.v", "*.sv", "*.vh", "*.svh" },
        prompt_title = "Live Grep (Verilog/SystemVerilog)",
    })
end, { desc = 'Live grep in RTL files' })
