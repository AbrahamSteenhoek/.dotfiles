# Gemini CLI Session History - March 1, 2026

## Neovim LSP Configuration (Native 0.12+)
- **Architecture**: Moved away from legacy `require('lspconfig').setup()` to modern `vim.lsp.config` and `vim.lsp.enable`.
- **Initialization**: Centralized in `lua/lsp/init.lua`, required by the top-level `init.lua`.
- **Languages**: 
  - Lua (`lua_ls`)
  - C/C++ (`clangd`)
  - SystemVerilog (`verible`)
  - Python (`pyright`)
  - CMake (`neocmake` with fixed `stdio` command)
  - Makefile (`autotools_ls`)
- **Features**:
  - **Formatting**: Manual formatting with `<leader>F` (`vim.lsp.buf.format({ async = true })`).
  - **Diagnostics**: Used `vim.diagnostic.jump` (0.11+) for `[d` and `]d`. Floating window on `<leader>e`.
  - **Highlights**: Customized `DiagnosticWarn` to Orange with `undercurl`.

## Snacks.nvim Setup
- **Organization**: Configuration moved to `lua/plugins/snacks.lua`.
- **Animations**: Disabled `scroll` and `words` modules to remove all jump/scroll animations.
- **Picker**: Synced with Telescope settings (`hidden = true`, `exclude = { ".git" }`).
- **Explorer**: Replaced `netrw` with `snacks.explorer` on `<leader>pv`.

## Bootstrap Script (`~/.dotfiles/bootstrap.sh`)
- **UV**: Added auto-install for `uv` (v0.10.7) into `$INSTALL_DIR/uv/`.
- **Python**: Added `install_python` function using `uv` to manage Python 3.13.
- **Sysconfigpatch**: Added `sysconfigpatcher` step to fix hardcoded paths in `uv`-managed Python builds.
- **UV Cache & Python Fix**: Localized `UV_CACHE_DIR` to the versioned `uv/` directory (`uv/<ver>/cache/`) and redirected `uv` Python installations to `uv/<ver>/python/` using `UV_PYTHON_INSTALL_DIR`.
- **Simplified Python PATH**: Pointed the Python `PATH` directly to the `uv`-managed `bin/` directory, removing the unnecessary symlink layer. This ensures `which python` shows exactly where the binary originated.
- **Self-Contained**: The entire `uv` environment and its managed Pythons are now fully self-contained within the versioned tools directory.
- **Reliability**: Updated `bootstrap.sh` to export these new paths at the end of the script.

## Style Decisions
- **Icons**: Decided to skip `nvim-web-devicons` for a cleaner, text-only, high-performance setup.
- **Modularity**: Prioritized a single `lsp/init.lua` for simplicity while keeping plugin configs separate.
