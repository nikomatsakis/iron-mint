#!/bin/bash
# Install rustup (Rust toolchain manager)
# Idempotent - safe to run multiple times

set -e

echo "🦀 Rustup"

# Check if rustup is already installed
if command -v rustup &> /dev/null; then
    echo "   ✅ Already installed"
    echo "   📍 $(rustup --version)"

    # Update if already installed
    echo "   🔄 Updating..."
    rustup update stable
    echo "   ✅ Updated to latest stable"
else
    echo "   📦 Installing rustup..."

    # Use rustup's official installer with default options
    # -y: assume yes to all prompts
    # --default-toolchain stable: install stable by default
    # --profile default: standard installation
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default

    # Source cargo env for this session
    source "$HOME/.cargo/env"

    echo "   ✅ Installed successfully"
    echo "   📍 $(rustup --version)"
fi

# Ensure PATH includes cargo bin (will be properly configured by shell setup)
if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi
