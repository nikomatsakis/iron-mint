#!/bin/bash
# Install Volta (Node.js version manager)
# Idempotent - safe to run multiple times

set -e

echo "⚡ Volta"

VOLTA_HOME="$HOME/.volta"

# Check if volta is already installed
if command -v volta &> /dev/null; then
    echo "   ✅ Already installed"
    echo "   📍 $(volta --version)"
else
    echo "   📦 Installing volta..."

    # Use volta's official installer
    curl https://get.volta.sh | bash -s -- --skip-setup

    # Add to PATH for this session
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    echo "   ✅ Installed successfully"
    echo "   📍 $(volta --version)"
fi

# Install default Node.js LTS if not present
if [ -d "$VOLTA_HOME" ]; then
    # Check if any node version is installed
    if ! volta list node 2>/dev/null | grep -q "node@"; then
        echo "   📦 Installing Node.js LTS..."
        volta install node@lts
        echo "   ✅ Node.js LTS installed"
    else
        echo "   ✅ Node.js already configured"
    fi
fi
