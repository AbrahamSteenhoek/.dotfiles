#!/usr/bin/env bash

set -e

# Configuration
INSTALL_DIR="$HOME/tools"
NODE_VERSION="v25.7.0"
FZF_VERSION="v0.68.0"
# Neovim Nightly (requested: v0.12.0-dev-2459+g62135f5a57)
NVIM_VERSION="nightly" 

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# --- Helper Functions ---

echo_info() { echo -e "${GREEN}==>${NC} $1"; }
echo_error() { echo -e "${RED}Error:${NC} $1"; }

check_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo_error "'$1' is not installed or not in PATH."
        return 1
    fi
    echo -e "${GREEN}✓${NC} '$1' found."
}

check_lib() {
    if ! pkg-config --exists "$1" >/dev/null 2>&1; then
        echo_error "Development library '$1' not found (checked via pkg-config)."
        return 1
    fi
    echo -e "${GREEN}✓${NC} '$1' development files found."
}

# --- Initialization ---

usage() {
    echo "Usage: $0 [--install-dir <path>]"
    echo "  --install-dir <path>  Directory to install tools (default: $HOME/tools)"
    echo "                        If specified, the directory must already exist."
    exit 1
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-dir)
                INSTALL_DIR="$2"
                if [ ! -d "$INSTALL_DIR" ]; then
                    echo_error "Directory '$INSTALL_DIR' does not exist."
                    exit 1
                fi
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# --- Dependency Checks ---

check_dependencies() {
    echo_info "Checking system dependencies..."
    local errors=0
    check_cmd "stow" || errors=$((errors + 1))
    check_cmd "git" || errors=$((errors + 1))
    check_cmd "rg" || errors=$((errors + 1))
    check_cmd "curl" || errors=$((errors + 1))
    check_cmd "gcc" || errors=$((errors + 1))
    check_cmd "make" || errors=$((errors + 1))
    check_cmd "pkg-config" || errors=$((errors + 1))
    check_cmd "bison" || errors=$((errors + 1))

    if command -v pkg-config >/dev/null 2>&1; then
        check_lib "libevent" || errors=$((errors + 1))
        check_lib "ncurses" || errors=$((errors + 1))
    fi

    if [ "$errors" -ne 0 ]; then
        echo_error "Bootstrap failed: $errors dependencies are missing."
        exit 1
    fi
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
    
    echo_info "Downloading Node.js $NODE_VERSION to determine exact version..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download Node.js from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    mkdir -p "$tmp_dir/extracted"
    tar -xJf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    local version=$("$tmp_dir/extracted/bin/node" --version)
    if [[ -z "$version" ]]; then
        echo_error "Could not determine Node.js version."
        rm -rf "$tmp_dir"
        exit 1
    fi

    NODE_FINAL_DIR="$INSTALL_DIR/node/$version"

    if [ -d "$NODE_FINAL_DIR" ]; then
        echo_info "Node.js $version is already installed at $NODE_FINAL_DIR."
        rm -rf "$tmp_dir"
        return 0
    fi

    echo_info "Installing Node.js $version to $NODE_FINAL_DIR..."
    mkdir -p "$(dirname "$NODE_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$NODE_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_fzf() {
    local tmp_dir=$(mktemp -d)
    echo_info "Cloning fzf repository $FZF_VERSION..."
    git clone --depth 1 --branch "$FZF_VERSION" https://github.com/junegunn/fzf.git "$tmp_dir/extracted"
    
    local version=""
    if [[ -f "$tmp_dir/extracted/bin/fzf" ]]; then
        version=$("$tmp_dir/extracted/bin/fzf" --version | awk '{print $1}')
    fi

    if [[ -z "$version" ]]; then
        # If binary doesn't exist yet, we'll use the version tag
        version="$FZF_VERSION"
    fi
    # Ensure version starts with 'v' if it's just a number, for consistency
    [[ $version =~ ^[0-9] ]] && version="v$version"

    FZF_FINAL_DIR="$INSTALL_DIR/fzf/$version"

    if [ -d "$FZF_FINAL_DIR" ]; then
        echo_info "fzf $version is already installed at $FZF_FINAL_DIR."
        rm -rf "$tmp_dir"
        return 0
    fi

    echo_info "Installing fzf $version to $FZF_FINAL_DIR..."
    mkdir -p "$(dirname "$FZF_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$FZF_FINAL_DIR"
    rm -rf "$tmp_dir"
    
    echo_info "Running fzf install script..."
    "$FZF_FINAL_DIR/install" --all --no-update-rc
}

install_nvim() {
    local arch=$(uname -m)
    case $arch in
        x86_64) arch="x86_64" ;;
        aarch64) arch="arm64" ;;
    esac
    local tarball="nvim-linux-$arch.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$tarball"
    
    echo_info "Downloading Neovim $NVIM_VERSION to determine exact version..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download Neovim from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    local version=$("$tmp_dir/extracted/bin/nvim" --version | head -n 1 | awk '{print $2}')
    if [[ -z "$version" ]]; then
        echo_error "Could not determine Neovim version."
        rm -rf "$tmp_dir"
        exit 1
    fi

    NVIM_FINAL_DIR="$INSTALL_DIR/nvim/$version"
    
    if [ -d "$NVIM_FINAL_DIR" ]; then
        echo_info "Neovim $version is already installed at $NVIM_FINAL_DIR."
        rm -rf "$tmp_dir"
        return 0
    fi

    echo_info "Installing Neovim $version to $NVIM_FINAL_DIR..."
    mkdir -p "$(dirname "$NVIM_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$NVIM_FINAL_DIR"
    rm -rf "$tmp_dir"
}

# --- Main Flow ---

parse_args "$@"

# Ensure default INSTALL_DIR exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo_info "Creating default install directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

check_dependencies

install_node
install_fzf
install_nvim

echo -e "\n${GREEN}Bootstrap complete!${NC}"
echo "Tools installed in: $INSTALL_DIR. To use these tools, add them to your PATH (e.g., in ~/.bashrc)"
echo "### node ####################################################"
echo "export PATH=\"$NODE_FINAL_DIR/bin:\$PATH\""

echo "### neovim ##################################################"
echo "export PATH=\"$NVIM_FINAL_DIR/bin:\$PATH\""

echo "### fzf (junegun) ###########################################"
echo "export PATH=\"$FZF_FINAL_DIR/bin:\$PATH\""
echo "source \"$FZF_FINAL_DIR/shell/completion.bash\""
echo "source \"$FZF_FINAL_DIR/shell/key-bindings.bash\""
