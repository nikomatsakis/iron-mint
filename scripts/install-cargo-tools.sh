#!/bin/bash
# Install Rust CLI tools via cargo-binstall

set -e

IRON_MINT_DIR="$HOME/dev/iron-mint"
CARGO_TOOLS_JSON="$IRON_MINT_DIR/config/cargo-tools.json"

echo "🦀 Installing Cargo tools..."

# Check if cargo is available
if ! command -v cargo &> /dev/null; then
    echo "⚠️  Cargo not found. Run 'iron-mint setup' to install Rust first."
    exit 0
fi

# Install cargo-binstall if not present
if ! command -v cargo-binstall &> /dev/null; then
    echo "📥 Installing cargo-binstall..."
    cargo install cargo-binstall
fi

# Install each tool from the list
for tool in $(jq -r '.[]' "$CARGO_TOOLS_JSON"); do
    if command -v "$tool" &> /dev/null; then
        echo "✅ $tool: already installed"
    else
        echo "📥 $tool: installing..."
        cargo binstall -y "$tool" || cargo install "$tool"
        echo "✅ $tool: installed"
    fi
done

echo ""
echo "✅ Cargo tool installation complete"
