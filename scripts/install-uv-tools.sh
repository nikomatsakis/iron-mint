#!/bin/bash
# Install Python CLI tools via uv tool install

set -e

IRON_MINT_DIR="$HOME/dev/iron-mint"
UV_TOOLS_JSON="$IRON_MINT_DIR/config/uv-tools.json"

echo "🐍 Installing Python tools via uv..."

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "📥 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v uv &> /dev/null; then
    echo "⚠️  uv not found after install attempt. Skipping Python tools."
    exit 0
fi

# Install each tool from the list
for tool in $(jq -r '.[]' "$UV_TOOLS_JSON"); do
    if uv tool list 2>/dev/null | grep -q "^$tool "; then
        echo "✅ $tool: already installed"
    else
        echo "📥 $tool: installing..."
        uv tool install "$tool"
        echo "✅ $tool: installed"
    fi
done

echo ""
echo "✅ Python tool installation complete"
