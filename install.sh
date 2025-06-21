#!/bin/bash
# One-liner installer for Iron Mint development environment
# Usage: curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash

set -e

echo "🚀 Installing Iron Mint Development Environment..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "📱 Detected OS: $OS"

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix with Determinate Systems installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "✅ Nix already installed"
    # Try to source nix environment
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        source ~/.nix-profile/etc/profile.d/nix.sh
    fi
fi

# Enable flakes (Determinate Systems installer enables this by default, but just in case)
echo "🔧 Ensuring Nix flakes are enabled..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Clone or update iron-mint
if [ -d ~/dev/iron-mint ]; then
    echo "🔄 Updating existing iron-mint..."
    cd ~/dev/iron-mint
    git pull
else
    echo "📁 Cloning iron-mint..."
    mkdir -p ~/dev
    git clone git@github.com:nikomatsakis/iron-mint.git ~/dev/iron-mint
fi

cd ~/dev/iron-mint

# Set up dotfiles
echo "🏠 Setting up dotfiles..."
nix build .#dotfiles
./result/bin/setup-dotfiles

echo ""
echo "✅ Iron Mint development environment installed successfully!"
echo ""
echo "🚀 To start Iron Mint, run:"
echo "   ~/dev/iron-mint/dev-env"
echo ""
echo "💡 Or add this alias to your shell config:"
echo "   alias iron='~/dev/iron-mint/dev-env'"
echo ""
echo "📚 See README.md for auto-start setup instructions"
