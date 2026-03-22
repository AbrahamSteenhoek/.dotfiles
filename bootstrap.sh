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
# Neovim Nightly (requested: v0.12.0-dev-2459+g62135f5a57)
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
        "stow"
        "git"
        "rg"
        "curl"
        "gcc"
        "make"
        "pkg-config"
        "bison"
        "xz"
        #"ca-certificates"
        #"gnupg"
    )
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo_error "'$dep' not found. Please install it."
            exit 1
        else
            echo "✓ '$dep' found."
        fi
    done

    # Check for library headers (best effort)
    if ! pkg-config --exists libevent; then
        echo_error "'libevent' development files not found."
        exit 1
    else
        echo "✓ 'libevent' development files found."
    fi
    if ! pkg-config --exists ncurses; then
        echo_error "'ncurses' development files not found."
        exit 1
    else
        echo "✓ 'ncurses' development files found."
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

    echo_info "Downloading Node.js $NODE_VERSION to determine exact version..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download node from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    # Extract once to get the exact version folder name
    mkdir -p "$tmp_dir/extracted"
    tar -xJf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    # In some cases the version might differ slightly (unlikely for node, but good practice)
    local version=$("$tmp_dir/extracted/bin/node" --version)
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

install_docker() {
    local arch=$(uname -m)
    case $arch in
        x86_64) arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
        *) echo_error "Unsupported architecture: $arch"; exit 1 ;;
    esac
    local tarball="docker-$DOCKER_VERSION.tgz"
    local url="https://download.docker.com/linux/static/stable/$arch/$tarball"

    echo_info "Downloading Docker $DOCKER_VERSION..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download docker from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    # Static binaries don't have a simple --version that outputs just the string easily without a lot of noise or requiring the daemon for some info
    # But 'docker --version' should work.
    local version=$("$tmp_dir/extracted/docker" --version | awk '{print $3}' | sed 's/,//')
    DOCKER_FINAL_DIR="$INSTALL_DIR/docker/$version"

    if [ -d "$DOCKER_FINAL_DIR" ]; then
        echo_info "Docker $version is already installed at $DOCKER_FINAL_DIR."
        rm -rf "$tmp_dir"
        return 0
    fi

    echo_info "Installing Docker $version to $DOCKER_FINAL_DIR..."
    mkdir -p "$(dirname "$DOCKER_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$DOCKER_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_fzf() {
    FZF_FINAL_DIR="$INSTALL_DIR/fzf/$FZF_VERSION"
    if [ -d "$FZF_FINAL_DIR" ]; then
        echo_info "fzf $FZF_VERSION is already installed at $FZF_FINAL_DIR."
        return 0
    fi

    echo_info "Cloning fzf repository $FZF_VERSION..."
    local tmp_dir=$(mktemp -d)
    git clone --depth 1 --branch "$FZF_VERSION" https://github.com/junegunn/fzf.git "$tmp_dir/extracted"
    
    mkdir -p "$FZF_FINAL_DIR"
    mv "$tmp_dir/extracted"/* "$FZF_FINAL_DIR/"
    rm -rf "$tmp_dir"

    echo_info "Building fzf $FZF_VERSION..."
    (cd "$FZF_FINAL_DIR" && ./install --bin)
}

install_nvim() {
    local arch=$(uname -m)
    case $arch in
        x86_64) arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
    esac
    local tarball="nvim-linux-$arch.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/$tarball"

    echo_info "Downloading Neovim $NVIM_VERSION to determine exact version..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download neovim from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1
    
    local version=$("$tmp_dir/extracted/bin/nvim" --version | head -n 1 | awk '{print $2}')
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

    # Setup standard XDG paths within the tools dir for isolation
    mkdir -p "$INSTALL_DIR/nvim/data"
    mkdir -p "$INSTALL_DIR/nvim/state"
    mkdir -p "$INSTALL_DIR/nvim/cache"
}

install_uv() {
    local arch=$(uname -m)
    case $arch in
        x86_64) arch="x86_64" ;;
        aarch64) arch="aarch64" ;;
    esac
    local tarball="uv-$arch-unknown-linux-gnu.tar.gz"
    local url="https://github.com/astral-sh/uv/releases/download/$UV_VERSION/$tarball"

    echo_info "Downloading uv $UV_VERSION to determine exact version..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/$tarball"; then
        echo_error "Failed to download uv from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    mkdir -p "$tmp_dir/extracted"
    tar -xzf "$tmp_dir/$tarball" -C "$tmp_dir/extracted" --strip-components=1

    local version=$("$tmp_dir/extracted/uv" --version | awk '{print $2}')
    if [[ -z "$version" ]]; then
        echo_error "Could not determine uv version."
        rm -rf "$tmp_dir"
        exit 1
    fi

    UV_FINAL_DIR="$INSTALL_DIR/uv/$version"

    if [ -d "$UV_FINAL_DIR" ]; then
        echo_info "uv $version is already installed at $UV_FINAL_DIR."
        rm -rf "$tmp_dir"
        return 0
    fi

    echo_info "Installing uv $version to $UV_FINAL_DIR..."
    mkdir -p "$(dirname "$UV_FINAL_DIR")"
    mv "$tmp_dir/extracted" "$UV_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_sioyek() {
    SIOYEK_FINAL_DIR="$INSTALL_DIR/sioyek/$SIOYEK_VERSION"
    if [ -d "$SIOYEK_FINAL_DIR" ]; then
        echo_info "sioyek $SIOYEK_VERSION is already installed at $SIOYEK_FINAL_DIR."
        return 0
    fi

    # https://github.com/ahrm/sioyek/releases/download/v2.0.0/sioyek-release-linux.zip
    local url="https://github.com/ahrm/sioyek/releases/download/$SIOYEK_VERSION/sioyek-release-linux.zip"
    
    echo_info "Downloading sioyek $SIOYEK_VERSION..."
    local tmp_dir=$(mktemp -d)
    if ! curl -fSL "$url" -o "$tmp_dir/sioyek.zip"; then
        echo_error "Failed to download sioyek from $url"
        rm -rf "$tmp_dir"
        exit 1
    fi

    echo_info "Extracting sioyek zip..."
    unzip "$tmp_dir/sioyek.zip" -d "$tmp_dir/extracted"
    
    # The zip might contain the AppImage or the extracted contents.
    # User said: "It is an appimage so it requires you to first unzip, then --appimage-extract"
    local appimage=$(find "$tmp_dir/extracted" -name "*.AppImage" | head -n 1)
    if [ -z "$appimage" ]; then
        echo_error "Could not find AppImage in zip."
        rm -rf "$tmp_dir"
        exit 1
    fi
    chmod +x "$appimage"

    echo_info "Extracting AppImage (to get the binary)..."
    (cd "$tmp_dir" && "$appimage" --appimage-extract > /dev/null)

    echo_info "Installing sioyek to $SIOYEK_FINAL_DIR..."
    mkdir -p "$(dirname "$SIOYEK_FINAL_DIR")"
    mv "$tmp_dir/squashfs-root" "$SIOYEK_FINAL_DIR"
    rm -rf "$tmp_dir"
}

install_uv_python() {
    local uv_bin="$UV_FINAL_DIR/uv"
    local uvx_bin="$UV_FINAL_DIR/uvx"

    # Set UV_CACHE_DIR to be within the versioned uv directory
    export UV_CACHE_DIR="$UV_FINAL_DIR/cache"
    mkdir -p "$UV_CACHE_DIR"

    # Ensure uv installs python into our tools directory
    export UV_PYTHON_INSTALL_DIR="$UV_FINAL_DIR/python"
    mkdir -p "$UV_PYTHON_INSTALL_DIR"

    echo_info "Installing Python $PYTHON_VERSION using uv..."
    # Use uv to fetch the specific python version
    "$uv_bin" python install "$PYTHON_VERSION"

    # Get the actual path where uv installed python
    local uv_python_path=$("$uv_bin" python find "$PYTHON_VERSION")
    local python_root=$(dirname "$(dirname "$uv_python_path")")

    echo_info "Patching Python $PYTHON_VERSION sysconfig with sysconfigpatcher..."
    "$uvx_bin" --from "git+https://github.com/bluss/sysconfigpatcher" sysconfigpatcher "$python_root"

    # Set PYTHON_FINAL_DIR directly to the bin directory of the uv installation
    PYTHON_FINAL_DIR=$(dirname "$uv_python_path")

    echo_info "Python $PYTHON_VERSION is ready at $PYTHON_FINAL_DIR"
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
install_docker
install_fzf

install_nvim
install_uv
install_uv_python
install_sioyek

# --- Generate Configuration File ---

CONFIG_FILE="bash/.bash_bootstrap_installs"
echo_info "Generating configuration file: $CONFIG_FILE"

{
    echo "# Generated by bootstrap.sh on $(date)"
    echo "# Runtime Info: $(uname -a)"
    echo "# Run ID: $(cat /proc/sys/kernel/random/uuid 2>/dev/null || echo $RANDOM)"
    echo ""

    echo "### node ####################################################"
    echo "export NPM_CONFIG_CACHE=\"$INSTALL_DIR/node/npm-cache\""
    echo "export NPM_CONFIG_USERCONFIG=\"$INSTALL_DIR/node/npm-config/.npmrc\""
    echo "export PATH=\"$NODE_FINAL_DIR/bin:\$PATH\""

    echo "### docker ##################################################"
    echo "export PATH=\"$DOCKER_FINAL_DIR:\$PATH\""

    echo "### neovim ##################################################"
    echo "export XDG_DATA_HOME=\"$INSTALL_DIR/nvim/data\""
    echo "export XDG_STATE_HOME=\"$INSTALL_DIR/nvim/state\""
    echo "export XDG_CACHE_HOME=\"$INSTALL_DIR/nvim/cache\""
    echo "export PATH=\"$NVIM_FINAL_DIR/bin:\$PATH\""

    echo "### fzf (junegun) ###########################################"
    echo "export PATH=\"$FZF_FINAL_DIR/bin:\$PATH\""
    echo "source \"$FZF_FINAL_DIR/shell/completion.bash\""
    echo "source \"$FZF_FINAL_DIR/shell/key-bindings.bash\""

    echo "### uv ######################################################"
    echo "export UV_CACHE_DIR=\"$UV_FINAL_DIR/cache\""
    echo "export UV_PYTHON_INSTALL_DIR=\"$UV_FINAL_DIR/python\""
    echo "export PATH=\"$UV_FINAL_DIR:\$PATH\""

    echo "### python (uv managed) #####################################"
    echo "export PATH=\"$PYTHON_FINAL_DIR:\$PATH\""

    echo "### sioyek ##################################################"
    echo "export PATH=\"$SIOYEK_FINAL_DIR/usr/bin:\$PATH\""
} > "$CONFIG_FILE"

echo -e "\n${GREEN}Bootstrap complete!${NC}"
echo "Tools installed in: $INSTALL_DIR."
echo "Configuration saved to: $CONFIG_FILE"
echo "Make sure to source this file in your ~/.bashrc"
