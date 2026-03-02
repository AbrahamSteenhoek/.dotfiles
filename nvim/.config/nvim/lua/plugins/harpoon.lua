local harpoon = require('harpoon')
harpoon:setup({})

-- Harpoon Keymaps
vim.keymap.set("n", "<leader>m", function() harpoon:list():add() end, { desc = "Mark file with Harpoon" })
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle Harpoon Quick Menu" })

-- Jumping to Nth file
vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Harpoon jump to 1" })
vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Harpoon jump to 2" })
vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Harpoon jump to 3" })
vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Harpoon jump to 4" })

-- Navigation
vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Harpoon previous" })
vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Harpoon next" })

-- Clear Registry
vim.keymap.set("n", "<leader>hC", function() harpoon:list():clear() end, { desc = "Clear Harpoon list" })
