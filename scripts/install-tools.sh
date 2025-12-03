#!/bin/bash
# Install CLI tools from config/tools.json
# Bootstraps jq first, then uses it to parse the rest

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
    echo "   Please install tools manually"
    exit 0
fi

echo "📦 Using package manager: $PKG_MANAGER"

# Install a single package
install_package() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        brew)
            brew install "$pkg" 2>/dev/null || true
            ;;
        apt)
            sudo apt install -y "$pkg" 2>/dev/null || true
            ;;
        dnf)
            sudo dnf install -y "$pkg" 2>/dev/null || true
            ;;
    esac
}

# Bootstrap jq first if not installed
if ! command -v jq &> /dev/null; then
    echo "📥 Bootstrapping jq..."
    install_package "jq"

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
    pkg=$(jq -r ".tools[$i].$PKG_MANAGER" "$TOOLS_JSON")
    desc=$(jq -r ".tools[$i].description" "$TOOLS_JSON")

    # Skip if package name is null for this platform
    if [ "$pkg" = "null" ] || [ -z "$pkg" ]; then
        echo "⏭️  $name: not available for $PKG_MANAGER"
        continue
    fi

    # Check if already installed (by command name, not package name)
    if command -v "$name" &> /dev/null; then
        echo "✅ $name: already installed"
    else
        echo "📥 $name: installing ($desc)..."
        install_package "$pkg"

        if command -v "$name" &> /dev/null; then
            echo "✅ $name: installed"
        else
            echo "⚠️  $name: install attempted (may need shell restart)"
        fi
    fi
done

echo ""
echo "✅ Tool installation complete"
