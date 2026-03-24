#!/usr/bin/env zsh

set -e

# Configuration
INSTALL_DIR="$HOME/tools"
NODE_VERSION="v25.7.0"
FZF_VERSION="v0.68.0"
UV_VERSION="0.10.7"
SIOYEK_VERSION="v2.0.0"
PYTHON_VERSION="3.13"
NVIM_VERSION="nightly" 

# Colors
RED='%F{red}'
GREEN='%F{green}'
NC='%f'

echo_info() { print -P "${GREEN}==> $1${NC}"; }
echo_error() { print -P "${RED}ERROR: $1${NC}" >&2; }

# --- Helper Functions ---

check_dependencies() {
    echo_info "Checking system dependencies (Homebrew)..."
    if ! command -v brew &> /dev/null; then
        echo_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        [[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew update
    brew install git stow ripgrep curl unzip
    # Casks for GUI apps
    brew install --cask alacritty
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

install_node() {
    local arch=$(uname -m)
    [[ $arch == "x86_64" ]] && arch="x64" || arch="arm64"
    local tarball="node-$NODE_VERSION-darwin-$arch.tar.gz"
    local url="https://nodejs.org/dist/$NODE_VERSION/$tarball"

    echo_info "Downloading Node.js $NODE_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    NODE_FINAL_DIR="$INSTALL_DIR/node/$NODE_VERSION"
    if [ -d "$NODE_FINAL_DIR" ]; then
        echo_info "Node.js is already installed."
        rm -rf "$tmp_dir"
        return 0
    fi

    mkdir -p "$(dirname "$NODE_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$NODE_FINAL_DIR"
    rm -rf "$tmp_dir"
}

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
    local arch=$(uname -m)
    local tarball="nvim-macos-$arch.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$tarball"

    echo_info "Downloading Neovim $NVIM_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    NVIM_FINAL_DIR="$INSTALL_DIR/nvim/$NVIM_VERSION"
    if [ -d "$NVIM_FINAL_DIR" ]; then
        echo_info "Neovim is already installed."
        rm -rf "$tmp_dir"
        return 0
    fi

    mkdir -p "$(dirname "$NVIM_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$NVIM_FINAL_DIR"
    rm -rf "$tmp_dir"
    mkdir -p "$INSTALL_DIR/nvim/"{data,state,cache}
}

install_uv() {
    local arch=$(uname -m)
    [[ $arch == "arm64" ]] && arch="aarch64"
    local tarball="uv-$arch-apple-darwin.tar.gz"
    local url="https://github.com/astral-sh/uv/releases/download/$UV_VERSION/$tarball"

    echo_info "Downloading uv $UV_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1

    UV_FINAL_DIR="$INSTALL_DIR/uv/$UV_VERSION"
    if [ -d "$UV_FINAL_DIR" ]; then
        echo_info "uv is already installed."
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

install_sioyek() {
    # On macOS, we'll just use the Homebrew Cask version as there is no static AppImage equivalent
    echo_info "Installing Sioyek via Homebrew..."
    brew install --cask sioyek
}

# --- Main Flow ---

parse_args "$@"
mkdir -p "$INSTALL_DIR"
check_dependencies
install_node
install_fzf
install_nvim
install_uv
install_uv_python
install_sioyek

# --- Generate Config ---

ZSH_CONFIG="zsh/.zsh_bootstrap_installs"
echo_info "Generating configuration file: $ZSH_CONFIG"

{
    echo "# macOS Tool configuration (Version Pinned)"
    [[ $(uname -m) == "arm64" ]] && echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' || echo 'eval "$(/usr/local/bin/brew shellenv)"'
    
    echo "### node ###"
    echo "export PATH=\"$NODE_FINAL_DIR/bin:\$PATH\""
    echo "### nvim ###"
    echo "export XDG_DATA_HOME=\"$INSTALL_DIR/nvim/data\""
    echo "export XDG_STATE_HOME=\"$INSTALL_DIR/nvim/state\""
    echo "export XDG_CACHE_HOME=\"$INSTALL_DIR/nvim/cache\""
    echo "export PATH=\"$NVIM_FINAL_DIR/bin:\$PATH\""
    echo "### fzf ###"
    echo "export PATH=\"$FZF_FINAL_DIR/bin:\$PATH\""
    echo "source \"$FZF_FINAL_DIR/shell/completion.zsh\""
    echo "source \"$FZF_FINAL_DIR/shell/key-bindings.zsh\""
    echo "### uv ###"
    echo "export UV_CACHE_DIR=\"$UV_FINAL_DIR/cache\""
    echo "export UV_PYTHON_INSTALL_DIR=\"$UV_FINAL_DIR/python\""
    echo "export PATH=\"$UV_FINAL_DIR:\$PATH\""
    echo "### python ###"
    echo "export PATH=\"$PYTHON_FINAL_DIR:\$PATH\""
    
} > "$ZSH_CONFIG"

echo_info "Installation complete."
