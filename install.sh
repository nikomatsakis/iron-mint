#!/bin/bash
# Iron Mint Bootstrap Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash

set -e

REPO_URL="https://github.com/nikomatsakis/iron-mint.git"
INSTALL_DIR="$HOME/dev/iron-mint"

echo "🌿 Iron Mint Installer"
echo ""

# Create ~/dev if it doesn't exist
if [ ! -d "$HOME/dev" ]; then
    echo "📁 Creating ~/dev directory..."
    mkdir -p "$HOME/dev"
fi

# Clone or update the repository
if [ -d "$INSTALL_DIR" ]; then
    echo "📦 Iron Mint already installed, updating..."
    cd "$INSTALL_DIR"
    git pull --ff-only
else
    echo "📦 Cloning Iron Mint..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Run the setup script
echo ""
exec "$INSTALL_DIR/setup.sh"
