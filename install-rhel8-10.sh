#!/usr/bin/env bash

set -e

# Configuration
INSTALL_DIR="$HOME/tools"
FZF_VERSION="v0.68.0"
UV_VERSION="0.10.7"
PYTHON_VERSION="3.13"
NVIM_VERSION="nightly"
RUSTUP_VERSION="1.27.1"
CARGO_VERSION="stable"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --- Helper Functions ---

echo_info() {
    echo -e "${GREEN}==> $1${NC}"
}

echo_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

check_dependencies() {
    echo_info "Checking system dependencies..."
    
    local deps=(
        "stow" "git" "rg" "curl" "gcc" "make" "pkg-config" "bison" "xz" "unzip"
    )
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo_error "'$dep' not found. Please install it."
            exit 1
        else
            echo "✓ '$dep' found."
        fi
    done
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-dir)
                INSTALL_DIR="$2"
                shift 2
                ;;
            *)
                echo_error "Unknown argument: $1"
                exit 1
                ;;
        esac
    done
}

# --- Tool Installers ---

install_fzf() {
    FZF_FINAL_DIR="$INSTALL_DIR/fzf/$FZF_VERSION"
    if [ -d "$FZF_FINAL_DIR" ]; then
        echo_info "fzf is already installed."
        return 0
    fi

    echo_info "Cloning fzf $FZF_VERSION..."
    git clone --depth 1 --branch "$FZF_VERSION" https://github.com/junegunn/fzf.git "$FZF_FINAL_DIR"
    (cd "$FZF_FINAL_DIR" && ./install --bin)
}

install_nvim() {
    module purge
    module switch gcc/15.2.0
    
    NVIM_FINAL_DIR="$INSTALL_DIR/nvim/$NVIM_VERSION"
    
    if [ -d "$NVIM_FINAL_DIR" ]; then
        echo_info "Neovim $NVIM_VERSION is already installed."
        return 0
    fi

    echo_info "Building Neovim $NVIM_VERSION from source..."
    local tmp_dir=$(mktemp -d)
    
    # Clone the repository
    git clone --depth 1 --branch "$NVIM_VERSION" https://github.com/neovim/neovim.git "$tmp_dir/neovim"
    
    cd "$tmp_dir/neovim"
    
    # Build from source with custom install prefix
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$NVIM_FINAL_DIR"
    make install
    
    # Clean up
    cd -
    rm -rf "$tmp_dir"
    
    # Create XDG directories
    mkdir -p "$INSTALL_DIR/nvim/"{data,state,cache}
    
    echo_info "Neovim $NVIM_VERSION built and installed successfully."
}

install_rustup() {
    RUSTUP_FINAL_DIR="$INSTALL_DIR/rustup/$RUSTUP_VERSION"
    
    if [ -d "$RUSTUP_FINAL_DIR" ]; then
        echo_info "rustup $RUSTUP_VERSION is already installed."
        return 0
    fi

    echo_info "Installing rustup $RUSTUP_VERSION..."
    
    # Set rustup home to our custom directory
    export RUSTUP_HOME="$RUSTUP_FINAL_DIR"
    export CARGO_HOME="$INSTALL_DIR/cargo/$CARGO_VERSION"
    
    # Download and run rustup installer
    local tmp_dir=$(mktemp -d)
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$tmp_dir/rustup-init.sh"
    
    # Run installer with custom paths (non-interactive)
    sh "$tmp_dir/rustup-init.sh" -y --no-modify-path \
        --default-toolchain stable \
        --profile default
    
    rm -rf "$tmp_dir"
    
    echo_info "rustup installed successfully."
}

install_cargo() {
    CARGO_FINAL_DIR="$INSTALL_DIR/cargo/$CARGO_VERSION"
    
    # Cargo is installed alongside rustup, so we just verify it exists
    if [ -f "$CARGO_FINAL_DIR/bin/cargo" ]; then
        echo_info "cargo is already installed at $CARGO_FINAL_DIR"
        return 0
    fi
    
    # If rustup was installed but cargo isn't found, something went wrong
    if [ ! -f "$CARGO_FINAL_DIR/bin/cargo" ]; then
        echo_error "cargo not found. Ensure rustup installation completed successfully."
        exit 1
    fi
}

install_uv() {
    local arch=$(uname -m)
    local tarball="uv-$arch-unknown-linux-gnu.tar.gz"
    local url="https://github.com/astral-sh/uv/releases/download/$UV_VERSION/$tarball"

    echo_info "Downloading uv $UV_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1

    local version=$("$tmp_dir/extracted/uv" --version | awk '{print $2}')
    UV_FINAL_DIR="$INSTALL_DIR/uv/$version"

    if [ -d "$UV_FINAL_DIR" ]; then
        echo_info "uv $version is already installed."
        rm -rf "$tmp_dir"
        return 0
    fi

    mkdir -p "$(dirname "$UV_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$UV_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_uv_python() {
    local uv_bin="$UV_FINAL_DIR/uv"
    local uvx_bin="$UV_FINAL_DIR/uvx"
    export UV_CACHE_DIR="$UV_FINAL_DIR/cache"
    export UV_PYTHON_INSTALL_DIR="$UV_FINAL_DIR/python"
    mkdir -p "$UV_CACHE_DIR" "$UV_PYTHON_INSTALL_DIR"

    echo_info "Installing Python $PYTHON_VERSION..."
    "$uv_bin" python install "$PYTHON_VERSION"
    local uv_python_path=$("$uv_bin" python find "$PYTHON_VERSION")
    local python_root=$(dirname "$(dirname "$uv_python_path")")

    echo_info "Patching Python..."
    "$uvx_bin" --from "git+https://github.com/bluss/sysconfigpatcher" sysconfigpatcher "$python_root"
    PYTHON_FINAL_DIR=$(dirname "$uv_python_path")
}

# --- Main Flow ---

parse_args "$@"
mkdir -p "$INSTALL_DIR"
check_dependencies
install_fzf
install_rustup
install_cargo
install_nvim
install_uv
install_uv_python

# --- Generate Configs ---

BASH_CONFIG="bash/.bash_bootstrap_installs"
ZSH_CONFIG="zsh/.zsh_bootstrap_installs"

echo_info "Generating configuration files..."

gen_content() {
    echo "### nvim ###"
    echo "export XDG_DATA_HOME=\"$INSTALL_DIR/nvim/data\""
    echo "export XDG_STATE_HOME=\"$INSTALL_DIR/nvim/state\""
    echo "export XDG_CACHE_HOME=\"$INSTALL_DIR/nvim/cache\""
    echo "export PATH=\"$NVIM_FINAL_DIR/bin:\$PATH\""
    echo "### fzf ###"
    echo "export PATH=\"$FZF_FINAL_DIR/bin:\$PATH\""
    echo "### rustup ###"
    echo "export RUSTUP_HOME=\"$RUSTUP_FINAL_DIR\""
    echo "export PATH=\"$RUSTUP_FINAL_DIR/bin:\$PATH\""
    echo "### cargo ###"
    echo "export CARGO_HOME=\"$CARGO_FINAL_DIR\""
    echo "source \"$CARGO_FINAL_DIR/env\""
    echo "### uv ###"
    echo "export UV_CACHE_DIR=\"$UV_FINAL_DIR/cache\""
    echo "export UV_PYTHON_INSTALL_DIR=\"$UV_FINAL_DIR/python\""
    echo "export PATH=\"$UV_FINAL_DIR:\$PATH\""
    echo "### python ###"
    echo "export PATH=\"$PYTHON_FINAL_DIR:\$PATH\""
}

{ gen_content; echo "source \"$FZF_FINAL_DIR/shell/completion.bash\""; echo "source \"$FZF_FINAL_DIR/shell/key-bindings.bash\""; } > "$BASH_CONFIG"
{ gen_content; echo "source \"$FZF_FINAL_DIR/shell/completion.zsh\""; echo "source \"$FZF_FINAL_DIR/shell/key-bindings.zsh\""; } > "$ZSH_CONFIG"

echo_info "Installation complete."
echo_info ""
echo_info "To activate these tools, source the appropriate config file:"
echo_info "  Bash: source $BASH_CONFIG"
echo_info "  Zsh:  source $ZSH_CONFIG"
