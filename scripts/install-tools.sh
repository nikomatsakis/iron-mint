#!/bin/bash
# Install CLI tools from config/tools.json
# Bootstraps jq first, then uses it to parse the rest
#
# Install methods tried in order:
#   1. System package manager (brew/apt/dnf)
#   2. cargo install (for Rust tools)
#   3. GitHub release binary download

set -e

IRON_MINT_DIR="$HOME/dev/iron-mint"
TOOLS_JSON="$IRON_MINT_DIR/config/tools.json"

echo "🔧 Installing CLI tools..."

# Detect package manager
detect_package_manager() {
    if command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    else
        echo "unknown"
    fi
}

PKG_MANAGER=$(detect_package_manager)

if [ "$PKG_MANAGER" = "unknown" ]; then
    echo "⚠️  No supported package manager found (brew, apt, dnf)"
    echo "   Will try cargo/GitHub installs where possible"
fi

if [ "$PKG_MANAGER" != "unknown" ]; then
    echo "📦 Using package manager: $PKG_MANAGER"
fi

# Install via system package manager
install_via_pkg_manager() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        brew)
            brew install "$pkg" 2>/dev/null
            ;;
        apt)
            sudo apt install -y "$pkg" 2>/dev/null
            ;;
        dnf)
            sudo dnf install -y "$pkg" 2>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Install via cargo
install_via_cargo() {
    local crate="$1"
    if ! command -v cargo &> /dev/null; then
        return 1
    fi
    cargo install "$crate"
}

# Install via GitHub release binary
install_via_github() {
    local repo="$1"
    local bin_name="$2"
    local arch
    local os

    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)       return 1 ;;
    esac

    case "$(uname -s)" in
        Linux)  os="linux" ;;
        Darwin) os="macOS" ;;
        *)      return 1 ;;
    esac

    local install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"

    case "$repo" in
        cli/cli)
            local version
            version=$(curl -sI "https://github.com/cli/cli/releases/latest" | grep -i "^location:" | sed 's|.*/v||' | tr -d '\r\n')
            if [ -z "$version" ]; then return 1; fi
            local url="https://github.com/cli/cli/releases/download/v${version}/gh_${version}_${os}_${arch}.tar.gz"
            local tmp
            tmp=$(mktemp -d)
            if curl -sfL "$url" | tar xz -C "$tmp" 2>/dev/null; then
                cp "$tmp"/gh_*/bin/gh "$install_dir/gh"
                chmod +x "$install_dir/gh"
                rm -rf "$tmp"
                return 0
            fi
            rm -rf "$tmp"
            return 1
            ;;
        junegunn/fzf)
            local version
            version=$(curl -sI "https://github.com/junegunn/fzf/releases/latest" | grep -i "^location:" | sed 's|.*/v||' | tr -d '\r\n')
            if [ -z "$version" ]; then return 1; fi
            local fzf_arch
            case "$(uname -m)" in
                x86_64)  fzf_arch="amd64" ;;
                aarch64) fzf_arch="arm64" ;;
            esac
            local url="https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-${os}_${fzf_arch}.tar.gz"
            local tmp
            tmp=$(mktemp -d)
            if curl -sfL "$url" | tar xz -C "$tmp" 2>/dev/null; then
                cp "$tmp/fzf" "$install_dir/fzf"
                chmod +x "$install_dir/fzf"
                rm -rf "$tmp"
                return 0
            fi
            rm -rf "$tmp"
            return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Bootstrap jq first if not installed
if ! command -v jq &> /dev/null; then
    echo "📥 Bootstrapping jq..."
    install_via_pkg_manager "jq" || true

    if ! command -v jq &> /dev/null; then
        echo "❌ Failed to install jq. Cannot proceed with tool installation."
        exit 1
    fi
fi

# Now use jq to parse tools.json and install each tool
echo ""
tool_count=$(jq '.tools | length' "$TOOLS_JSON")

for i in $(seq 0 $((tool_count - 1))); do
    name=$(jq -r ".tools[$i].name" "$TOOLS_JSON")
    pkg=$(jq -r ".tools[$i].$PKG_MANAGER // empty" "$TOOLS_JSON")
    cargo_crate=$(jq -r ".tools[$i].cargo // empty" "$TOOLS_JSON")
    github_repo=$(jq -r ".tools[$i].github // empty" "$TOOLS_JSON")
    desc=$(jq -r ".tools[$i].description // empty" "$TOOLS_JSON")
    bin_name=$(jq -r ".tools[$i].bin_name // empty" "$TOOLS_JSON")

    # The command to check might differ from the tool name (e.g. ripgrep -> rg)
    check_cmd="${bin_name:-$name}"

    # Skip if no install method available
    if [ -z "$pkg" ] && [ -z "$cargo_crate" ] && [ -z "$github_repo" ]; then
        echo "⏭️  $name: no install method for this platform"
        continue
    fi

    # Check if already installed
    if command -v "$check_cmd" &> /dev/null; then
        echo "✅ $name: already installed"
        continue
    fi

    echo "📥 $name: installing ($desc)..."

    installed=false

    # Try package manager first
    if [ -n "$pkg" ] && install_via_pkg_manager "$pkg"; then
        if command -v "$check_cmd" &> /dev/null; then
            installed=true
        fi
    fi

    # Try cargo
    if [ "$installed" = false ] && [ -n "$cargo_crate" ]; then
        echo "   ↳ trying cargo install..."
        if install_via_cargo "$cargo_crate"; then
            if command -v "$check_cmd" &> /dev/null; then
                installed=true
            fi
        fi
    fi

    # Try GitHub release
    if [ "$installed" = false ] && [ -n "$github_repo" ]; then
        echo "   ↳ trying GitHub release..."
        if install_via_github "$github_repo" "$check_cmd"; then
            if command -v "$check_cmd" &> /dev/null; then
                installed=true
            fi
        fi
    fi

    if [ "$installed" = true ]; then
        echo "✅ $name: installed"
    else
        echo "⚠️  $name: could not install (try manually)"
    fi
done

echo ""
echo "✅ Tool installation complete"
