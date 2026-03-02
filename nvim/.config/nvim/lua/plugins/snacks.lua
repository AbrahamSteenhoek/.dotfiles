-- Snacks.nvim configuration
require("snacks").setup({
    bigfile = { enabled = true }, -- handles opening large files efficiently
    dashboard = { enabled = true }, -- a customizable start screen
    explorer = { enabled = true }, -- a built-in file explorer
    indent = { enabled = true }, -- subtle indentation guides
    input = { enabled = true }, -- improved UI for text input
    picker = { -- powerful search and selection tool (telescope alternative)
        enabled = true,
        sources = {
            -- Configure grep to behave like your telescope setup
            grep = {
                hidden = true, -- show hidden files (dotfiles)
                exclude = { ".git" }, -- match telescope's !.git/ glob
            },
            -- Configure files to behave like your telescope setup
            files = {
                hidden = true,
                exclude = { ".git" },
            },
        },
    },
    notifier = { enabled = true }, -- sleek notification management
    quickfile = { enabled = true }, -- optimizes start time for opening single files
    scope = { enabled = true }, -- visual highlighting of the current code scope
    statuscolumn = { enabled = true }, -- improved gutter for signs and line numbers
    scroll = { enabled = false }, -- disabled smooth scrolling
    words = { enabled = false },  -- disabled search jump animation and word highlighting
})

-- Interactive Setup & Keymaps
local snacks = require("snacks")

-- 1. Explorer (File Tree)
-- This replaces netrw and provides a modern file tree interface
vim.keymap.set("n", "<leader>pv", function() snacks.explorer() end, { desc = "Project View (Explorer)" })

-- 2. Picker (Fuzzy Finder)
-- Powerful alternatives to standard telescope commands
vim.keymap.set("n", "<leader>ff", function() snacks.picker.files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function() snacks.picker.grep() end, { desc = "Live Grep (Search Text)" })
vim.keymap.set("n", "<leader>fb", function() snacks.picker.buffers() end, { desc = "Find Open Buffers" })
vim.keymap.set("n", "<leader>fh", function() snacks.picker.help() end, { desc = "Find Help Tags" })
vim.keymap.set("n", "<leader>fd", function() snacks.picker.diagnostics() end, { desc = "Search Diagnostics" })

-- RTL Specific Keymap (using snacks picker grep with custom filter)
vim.keymap.set("n", "<leader>fv", function()
    snacks.picker.grep({
        glob = { "*.v", "*.sv", "*.vh", "*.svh" },
        title = "Live Grep (Verilog/SystemVerilog)",
    })
end, { desc = "Live Grep in RTL Files" })

-- Alternative <leader>s prefix (for flexibility)
vim.keymap.set("n", "<leader>sf", function() snacks.picker.files() end, { desc = "Search Files" })
vim.keymap.set("n", "<leader>sg", function() snacks.picker.grep() end, { desc = "Search Grep" })
vim.keymap.set("n", "<leader>sb", function() snacks.picker.buffers() end, { desc = "Search Buffers" })
vim.keymap.set("n", "<leader>sh", function() snacks.picker.help() end, { desc = "Search Help" })
vim.keymap.set("n", "<leader>sd", function() snacks.picker.diagnostics() end, { desc = "Search Diagnostics" })

-- 3. Notifier (History)
-- View your notification history in a floating window
vim.keymap.set("n", "<leader>un", function() snacks.notifier.show_history() end, { desc = "Show Notification History" })

-- 4. Indent & Scope
-- These are mostly passive, but you can toggle them if needed
vim.keymap.set("n", "<leader>ui", function() snacks.indent.toggle() end, { desc = "Toggle Indent Guides" })
vim.keymap.set("n", "<leader>us", function() snacks.scope.toggle() end, { desc = "Toggle Scope Highlighting" })
