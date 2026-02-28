----------------------------------------------------------------
--  Base Neovim Settings
----------------------------------------------------------------

vim.opt.termguicolors = true -- full terminal color support
vim.cmd.colorscheme("habamax")

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.wrap = false -- do not wrap lines
vim.opt.scrolloff = 8 -- # lines padded vertically from cursor
vim.opt.sidescrolloff = 8 -- # lines padded horizontally from cursor

vim.opt.tabstop = 4 -- tabwidth
vim.opt.softtabstop = 4 -- soft tab stop not tabs on tab/backspace
vim.opt.shiftwidth = 4 -- indent width
vim.opt.expandtab = true -- spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line

-- Configure the specific characters to use
vim.opt.list = true -- Enable the display of listchars
vim.opt.listchars = {
    --eol = '↵',    -- End-of-line character
    tab = '>·',   -- Tab character (requires 2 or 3 characters)
    trail = '·',    -- the floating middle dot for trailing spaces
    lead = '·',    -- spaces padding code
    nbsp = '␣',   -- Non-breaking space character
    extends = '»', -- Character shown in the last column when a line continues past the edge
    precedes = '«', -- Character shown in the first column when a line continues from the left
}

vim.opt.ignorecase = true -- case-insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string
vim.opt.hlsearch = true -- highlight search match
vim.opt.incsearch = true -- move cursor to match as you type

vim.opt.signcolumn = "yes" -- always show a sign column
vim.opt.colorcolumn = "100" -- show a col at 100 position chars
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- single line cmdline
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- do not show mode, instead display in statusline
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 10 -- floating window transparency
vim.opt.conceallevel = 0 -- do not hide markup
vim.opt.concealcursor = "" -- do not cursor in markup
vim.opt.lazyredraw = true -- do not redraw during macros
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.nvim/undodir")
if
    vim.fn.isdirectory(undodir) == 0 -- create undodir if doesn't exist
then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undofile = true
vim.opt.undodir = undodir

vim.opt.backup = false -- no backup files
vim.opt.writebackup = false -- don't write to backup files
vim.opt.swapfile = false -- no swap files
vim.opt.updatetime = 50 -- faster completion
vim.opt.timeoutlen = 300 -- timeout duration
vim.opt.ttimeoutlen = 0 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if file is updated outside of neovim
vim.opt.autowrite = true -- don't auto-save

vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- error bells are annoying
vim.opt.backspace = "indent,eol,start" -- better backspace behavior
vim.opt.autochdir = false -- keep original dir as cwd for all working files
vim.opt.iskeyword:append("-") -- include - in neovim "words"
vim.opt.path:append("**") -- include sudirs in search
vim.opt.selection = "inclusive" -- include last char in selection
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications
vim.opt.encoding = "utf-8" -- char encoding

-- folding requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory


----------------------------------------------------------------
--  Keymaps (remaps)
----------------------------------------------------------------
vim.g.mapleader = ","
vim.g.localleader = ","

-- better movement around wrapped text
vim.keymap.set("n", "j", function()
    return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)"})
vim.keymap.set("n", "k", function()
    return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)"})

vim.keymap.set("n", "<leader> ", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("x", "<leader>p", '\"_dP', { desc = "Paste without yanking" })
vim.keymap.set({"n", "v"}, "<leader>x", '\"_d', { desc = "Delete without yanking" })

vim.keymap.set("n", "<leader>y", "\"+y") -- copy from neovim into + (clipboard) buffer
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "previous buffer" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "keep cursor in middle when half-page jumping" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "keep cursor in middle when half-page jumping" })
--vim.keymap.set("n", "n", "nzzzv", { desc = "Keep cursor in middle when advancing to next search" })
--vim.keymap.set("n", "N", "Nzzzv", { desc = "Keep cursor in middle when reversing to previous search" })

vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Decrease window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect in visual mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect in visual mode" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and key cursor at same position" })
vim.keymap.set("n", "Wq", "wq", { desc = "excuse my fat fingering when save-quitting" })
vim.keymap.set("n", "Q", "<Nop>", { desc = "I'm afraid of Ex mode" })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw filetree" })


----------------------------------------------------------------
--  AutoCmds
----------------------------------------------------------------
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augropu,
    callback = function()
        vim.hl.on_yank()
    end,
})

-- return to last cursor position when opening file
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Restore last cursor position when opening file",
    callback = function()
        if vim.o.diff then
            return -- don't do this for diff mode
        end
        local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- store the {line, col}
        local last_line = vim.api.nvim_buf_line_count(0)
        local row = last_pos[1]
        if row < 1 or row > last_line then
            return
        end
        pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
    end,
})

-- Fix fat-fingered write/quit commands
vim.api.nvim_create_user_command('Wq', 'wq', { desc = "excuse my fat-fingering when typing :wq" })
vim.api.nvim_create_user_command('WQ', 'wq', { desc = "excuse my fat-fingering when typing :wq" })

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
    end,
})

----------------------------------------------------------------
--  Statusline
----------------------------------------------------------------

-- Get file type
local function file_type()
    local ft = vim.bo.filetype
    local icons = {
        lua = "\u{e620} ", -- nf-dev-lua
        python = "\u{e73c} ", -- nf-dev-python
        javascript = "\u{e74e} ", -- nf-dev-javascript
        typescript = "\u{e628} ", -- nf-dev-typescript
        javascriptreact = "\u{e7ba} ",
        typescriptreact = "\u{e7ba} ",
        html = "\u{e736} ", -- nf-dev-html5
        css = "\u{e749} ", -- nf-dev-css3
        scss = "\u{e749} ",
        json = "\u{e60b} ", -- nf-dev-json
        markdown = "\u{e73e} ", -- nf-dev-markdown
        vim = "\u{e62b} ", -- nf-dev-vim
        sh = "\u{f489} ", -- nf-oct-terminal
        bash = "\u{f489} ",
        zsh = "\u{f489} ",
        rust = "\u{e7a8} ", -- nf-dev-rust
        go = "\u{e724} ", -- nf-dev-go
        c = "\u{e61e} ", -- nf-dev-c
        cpp = "\u{e61d} ", -- nf-dev-cplusplus
        java = "\u{e738} ", -- nf-dev-java
        php = "\u{e73d} ", -- nf-dev-php
        ruby = "\u{e739} ", -- nf-dev-ruby
        swift = "\u{e755} ", -- nf-dev-swift
        kotlin = "\u{e634} ",
        dart = "\u{e798} ",
        elixir = "\u{e62d} ",
        haskell = "\u{e777} ",
        sql = "\u{e706} ",
        yaml = "\u{f481} ",
        toml = "\u{e615} ",
        xml = "\u{f05c} ",
        dockerfile = "\u{f308} ", -- nf-linux-docker
        gitcommit = "\u{f418} ", -- nf-oct-git_commit
        gitconfig = "\u{f1d3} ", -- nf-fa-git
        vue = "\u{fd42} ", -- nf-md-vuejs
        svelte = "\u{e697} ",
        astro = "\u{e628} ",
    }

    if ft == "" then
        return " \u{f15b} " -- nf-fa-file_o
    end

    return ((icons[ft] or " \u{f15b} ") .. ft)
end

-- Get file size
local function file_size()
    local size = vim.fn.getfsize(vim.fn.expand("%"))
    if size < 0 then
        return ""
    end
    local size_str
    if size < 1024 then
        size_str = size .. "B"
    elseif size < 1024 * 1024 then
        size_str = string.format("%.1fK", size / 1024)
    else
        size_str = string.format("%.1fM", size / 1024 / 1024)
    end
    return size_str .. " " -- nf-fa-file_o
end

-- Generate Mode indicator string
local function mode_icon()
    local mode = vim.fn.mode()
    local modes = {
        n       = "  NORMAL",
        i       = "  INSERT",
        v       = "  VISUAL",
        V       = "  V-LINE",
        ["\22"] = " V-BLOCK",
        c       = " COMMAND",
        s       = "  SELECT",
        S       = "  S-LINE",
        ["\19"] = " S-BLOCK",
        R       = " REPLACE",
        r       = " REPLACE",
        ["!"]   = "   SHELL",
        t       = "TERMINAL",
    }
    return modes[mode] or (" \u{f059} " .. mode)
end

_G.mode_icon = mode_icon
_G.file_type = file_type
_G.file_size = file_size

vim.cmd([[
    highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        callback = function()
            vim.opt_local.statusline = table.concat({
                " %#StatusLineBold# ", -- stuff in this part of the statusline is bold
                "%{v:lua.mode_icon()}",
                "%#StatusLine#",
                " | %f, %{v:lua.file_size()} %h%m%r", -- filename, filesize
                --"%{v:lua.git_branch()}",
                "%=", -- Right-align everything after this
                " l:%l | c:%c  %P ", -- nf-fa-clock_o for line/col
            })
        end,
    })
    vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        callback = function()
            vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %=  %l:%c   %P "
        end,
    })
end

setup_dynamic_statusline()
