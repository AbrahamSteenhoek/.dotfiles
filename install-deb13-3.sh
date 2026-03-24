#!/usr/bin/env bash

set -e

# Configuration
INSTALL_DIR="$HOME/tools"
NODE_VERSION="v25.7.0"
DOCKER_VERSION="27.3.1"
FZF_VERSION="v0.68.0"
UV_VERSION="0.10.7"
SIOYEK_VERSION="v2.0.0"
PYTHON_VERSION="3.13"
NVIM_VERSION="nightly" 

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

    if ! pkg-config --exists libevent; then
        echo_error "'libevent' development files not found."
        exit 1
    fi
    if ! pkg-config --exists ncurses; then
        echo_error "'ncurses' development files not found."
        exit 1
    fi
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
    case $arch in
        x86_64) arch="x64" ;;
        aarch64) arch="arm64" ;;
    esac
    local tarball="node-$NODE_VERSION-linux-$arch.tar.xz"
    local url="https://nodejs.org/dist/$NODE_VERSION/$tarball"

    echo_info "Downloading Node.js $NODE_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xJf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    local version=$("$tmp_dir/extracted/bin/node" --version)
    NODE_FINAL_DIR="$INSTALL_DIR/node/$version"

    if [ -d "$NODE_FINAL_DIR" ]; then
        echo_info "Node.js $version is already installed."
        rm -rf "$tmp_dir"
        return 0
    fi

    mkdir -p "$(dirname "$NODE_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$NODE_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_docker() {
    local arch=$(uname -m)
    local tarball="docker-$DOCKER_VERSION.tgz"
    local url="https://download.docker.com/linux/static/stable/$arch/$tarball"

    echo_info "Downloading Docker $DOCKER_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    DOCKER_FINAL_DIR="$INSTALL_DIR/docker/$DOCKER_VERSION"
    if [ -d "$DOCKER_FINAL_DIR" ]; then
        echo_info "Docker is already installed."
        rm -rf "$tmp_dir"
        return 0
    fi

    mkdir -p "$(dirname "$DOCKER_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$DOCKER_FINAL_DIR"
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
    local tarball="nvim-linux-$arch.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$tarball"

    echo_info "Downloading Neovim $NVIM_VERSION..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/$tarball"
    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    local version=$("$tmp_dir/extracted/bin/nvim" --version | head -n 1 | awk '{print $2}')
    NVIM_FINAL_DIR="$INSTALL_DIR/nvim/$version"

    if [ -d "$NVIM_FINAL_DIR" ]; then
        echo_info "Neovim $version is already installed."
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

install_sioyek() {
    SIOYEK_FINAL_DIR="$INSTALL_DIR/sioyek/$SIOYEK_VERSION"
    if [ -d "$SIOYEK_FINAL_DIR" ]; then
        echo_info "sioyek is already installed."
        return 0
    fi

    local url="https://github.com/ahrm/sioyek/releases/download/$SIOYEK_VERSION/sioyek-release-linux.zip"
    echo_info "Downloading sioyek..."
    local tmp_dir=$(mktemp -d)
    curl -fSL "$url" -o "$tmp_dir/sioyek.zip"
    unzip "$tmp_dir/sioyek.zip" -d "$tmp_dir/extracted"
    local appimage=$(find "$tmp_dir/extracted" -name "*.AppImage" | head -n 1)
    chmod +x "$appimage"
    (cd "$tmp_dir" && "$appimage" --appimage-extract > /dev/null)
    mkdir -p "$(dirname "$SIOYEK_FINAL_DIR")"
    mv "$tmp_dir/squashfs-root" "$SIOYEK_FINAL_DIR"
    rm -rf "$tmp_dir"
}

# --- Main Flow ---

parse_args "$@"
mkdir -p "$INSTALL_DIR"
check_dependencies
install_node
install_docker
install_fzf
install_nvim
install_uv
install_uv_python
install_sioyek

# --- Generate Configs ---

BASH_CONFIG="bash/.bash_bootstrap_installs"
ZSH_CONFIG="zsh/.zsh_bootstrap_installs"

echo_info "Generating configuration files..."

gen_content() {
    echo "### node ###"
    echo "export NPM_CONFIG_CACHE=\"$INSTALL_DIR/node/npm-cache\""
    echo "export NPM_CONFIG_USERCONFIG=\"$INSTALL_DIR/node/npm-config/.npmrc\""
    echo "export PATH=\"$NODE_FINAL_DIR/bin:\$PATH\""
    echo "### docker ###"
    echo "export PATH=\"$DOCKER_FINAL_DIR:\$PATH\""
    echo "### nvim ###"
    echo "export XDG_DATA_HOME=\"$INSTALL_DIR/nvim/data\""
    echo "export XDG_STATE_HOME=\"$INSTALL_DIR/nvim/state\""
    echo "export XDG_CACHE_HOME=\"$INSTALL_DIR/nvim/cache\""
    echo "export PATH=\"$NVIM_FINAL_DIR/bin:\$PATH\""
    echo "### fzf ###"
    echo "export PATH=\"$FZF_FINAL_DIR/bin:\$PATH\""
    echo "### uv ###"
    echo "export UV_CACHE_DIR=\"$UV_FINAL_DIR/cache\""
    echo "export UV_PYTHON_INSTALL_DIR=\"$UV_FINAL_DIR/python\""
    echo "export PATH=\"$UV_FINAL_DIR:\$PATH\""
    echo "### python ###"
    echo "export PATH=\"$PYTHON_FINAL_DIR:\$PATH\""
    echo "### sioyek ###"
    echo "export PATH=\"$SIOYEK_FINAL_DIR/usr/bin:\$PATH\""
}

{ gen_content; echo "source \"$FZF_FINAL_DIR/shell/completion.bash\""; echo "source \"$FZF_FINAL_DIR/shell/key-bindings.bash\""; } > "$BASH_CONFIG"
{ gen_content; echo "source \"$FZF_FINAL_DIR/shell/completion.zsh\""; echo "source \"$FZF_FINAL_DIR/shell/key-bindings.zsh\""; } > "$ZSH_CONFIG"

echo_info "Installation complete."
