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
echo "🔄 To use in this session, run:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "   dev-env"
echo ""
echo "🚀 Or start a new terminal and run 'dev-env'"
echo ""
echo "📚 See README.md for auto-start setup instructions"
