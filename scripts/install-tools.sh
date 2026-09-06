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
        aarch64|arm64) arch="arm64" ;;
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
                aarch64|arm64) fzf_arch="arm64" ;;
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
        gohugoio/hugo)
            local release_json
            local version
            local platform
            local package_format
            local asset_name
            local asset_url
            local checksums_url
            local expected_checksum
            local actual_checksum

            case "$(uname -s)" in
                Linux)
                    platform="linux-${arch}"
                    package_format="tar.gz"
                    ;;
                Darwin)
                    platform="darwin-universal"
                    package_format="pkg"
                    ;;
                *)      return 1 ;;
            esac

            if ! release_json=$(curl -sfL "https://api.github.com/repos/${repo}/releases/latest"); then
                return 1
            fi

            version=$(printf '%s' "$release_json" | jq -r '.tag_name | ltrimstr("v")')
            if [ -z "$version" ] || [ "$version" = "null" ]; then
                return 1
            fi

            asset_name="hugo_${version}_${platform}.${package_format}"
            asset_url=$(printf '%s' "$release_json" | jq -r --arg name "$asset_name" \
                '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
            checksums_url=$(printf '%s' "$release_json" | jq -r --arg name "hugo_${version}_checksums.txt" \
                '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)

            if [ -z "$asset_url" ] || [ -z "$checksums_url" ]; then
                return 1
            fi

            local tmp
            tmp=$(mktemp -d)
            if ! curl -sfL "$asset_url" -o "$tmp/$asset_name" || \
               ! curl -sfL "$checksums_url" -o "$tmp/checksums.txt"; then
                rm -rf "$tmp"
                return 1
            fi

            expected_checksum=$(awk -v asset="$asset_name" '$2 == asset { print $1 }' "$tmp/checksums.txt")
            if [ -z "$expected_checksum" ]; then
                rm -rf "$tmp"
                return 1
            fi

            if command -v sha256sum &> /dev/null; then
                actual_checksum=$(sha256sum "$tmp/$asset_name" | awk '{ print $1 }')
            elif command -v shasum &> /dev/null; then
                actual_checksum=$(shasum -a 256 "$tmp/$asset_name" | awk '{ print $1 }')
            else
                rm -rf "$tmp"
                return 1
            fi

            if [ "$actual_checksum" != "$expected_checksum" ]; then
                echo "   ↳ checksum verification failed"
                rm -rf "$tmp"
                return 1
            fi

            case "$package_format" in
                tar.gz)
                    if tar xzf "$tmp/$asset_name" -C "$tmp" hugo 2>/dev/null; then
                        cp "$tmp/hugo" "$install_dir/hugo"
                        chmod +x "$install_dir/hugo"
                        rm -rf "$tmp"
                        return 0
                    fi
                    ;;
                pkg)
                    local expanded_dir="$tmp/expanded"
                    local hugo_path
                    if command -v pkgutil &> /dev/null && \
                       pkgutil --expand-full "$tmp/$asset_name" "$expanded_dir" 2>/dev/null; then
                        hugo_path=$(find "$expanded_dir" -type f -path '*/usr/local/bin/hugo' -print -quit)
                        if [ -n "$hugo_path" ]; then
                            cp "$hugo_path" "$install_dir/hugo"
                            chmod +x "$install_dir/hugo"
                            rm -rf "$tmp"
                            return 0
                        fi
                    fi
                    ;;
            esac
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
