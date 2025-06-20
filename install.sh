#!/bin/bash
# One-liner installer for Niko's development environment
# Usage: curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash

set -e

echo "🚀 Installing Niko's Iron Mint Development Environment..."

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
    echo "📦 Installing Nix..."
    curl -L https://nixos.org/nix/install | sh
    source ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "✅ Nix already installed"
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# Enable flakes
echo "🔧 Enabling Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Clone the repo
if [ -d ~/.config/nix/personal-dev ]; then
    echo "🔄 Updating existing iron-mint config..."
    cd ~/.config/nix/personal-dev
    git pull
else
    echo "📁 Cloning iron-mint config..."
    git clone git@github.com:nikomatsakis/iron-mint.git ~/.config/nix/personal-dev
fi

cd ~/.config/nix/personal-dev

# Set up dotfiles
echo "🏠 Setting up dotfiles..."
nix build .#dotfiles
./result/bin/setup-dotfiles

# Install launcher scripts
echo "🔧 Installing launcher scripts..."
mkdir -p ~/.local/bin
cp scripts/dev-env ~/.local/bin/
cp scripts/setup-dev-machine ~/.local/bin/
chmod +x ~/.local/bin/dev-env ~/.local/bin/setup-dev-machine

# Add ~/.local/bin to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "🛤️  Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo ""
echo "✅ Iron Mint development environment installed successfully!"
echo ""
echo "🔄 Run 'source ~/.bashrc' or start a new shell to update your PATH"
echo "🚀 Then run 'dev-env' to enter your development environment"
echo ""
echo "📚 See README.md for usage instructions and customization options"
