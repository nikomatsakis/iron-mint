#!/bin/bash
# Iron Mint installer wrapper
# Usage: curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
# Uninstall: iron-mint uninstall

set -e

# Check for uninstall option
if [[ "$1" == "--uninstall" ]]; then
    echo "🔄 The uninstall process has moved to the iron-mint command."
    echo ""
    
    if [ -f ~/dev/iron-mint/result/bin/iron-mint ]; then
        echo "🚀 Running: iron-mint uninstall"
        ~/dev/iron-mint/result/bin/iron-mint uninstall
    elif command -v iron-mint &> /dev/null; then
        echo "🚀 Running: iron-mint uninstall"
        iron-mint uninstall
    else
        echo "❌ iron-mint command not found."
        echo "   Try: nix shell github:nikomatsakis/iron-mint -c iron-mint uninstall"
    fi
    exit 0
fi

echo "🚀 Iron Mint Installer"
echo "📥 Downloading and running iron-mint install command..."
echo ""

# Try to use nix if available, otherwise download the script
if command -v nix &> /dev/null; then
    echo "✅ Nix found, using it to run iron-mint install"
    nix shell github:nikomatsakis/iron-mint -c iron-mint install
else
    echo "📦 Nix not found, will install it first"
    
    # Download the iron-mint script temporarily
    temp_script=$(mktemp)
    curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/scripts/iron-mint > "$temp_script"
    chmod +x "$temp_script"
    
    echo "🚀 Running iron-mint install"
    "$temp_script" install
    
    # Clean up
    rm -f "$temp_script"
fi

echo ""
echo "📚 For future management, use the 'iron-mint' command"
echo "   iron-mint help    - Show all commands"
echo "   iron-mint sync    - Update to latest"
echo "   iron-mint uninstall - Remove Iron Mint"
