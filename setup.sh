#!/bin/bash
# Iron Mint Setup Script
# Can be run directly or via install.sh
# Idempotent - safe to run multiple times

set -e

IRON_MINT_DIR="$HOME/dev/iron-mint"
SCRIPTS_DIR="$IRON_MINT_DIR/scripts"

echo "🌿 Iron Mint Setup"
echo ""

# Ensure we're in the right place
if [ ! -d "$IRON_MINT_DIR" ]; then
    echo "❌ Iron Mint not found at $IRON_MINT_DIR"
    echo "   Run the installer: curl -fsSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash"
    exit 1
fi

# Create backup directory for this run
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
export IRON_MINT_BACKUP_DIR="$BACKUP_DIR"

echo "📁 Backups will be saved to: $BACKUP_DIR"
echo ""

# Detect OS
case "$(uname -s)" in
    Linux*)  OS="linux" ;;
    Darwin*) OS="macos" ;;
    CYGWIN*|MINGW*|MSYS*) OS="windows" ;;
    *)       OS="unknown" ;;
esac

# Detect if running in WSL
if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
    OS="wsl"
fi

export IRON_MINT_OS="$OS"
echo "🖥  Detected OS: $OS"

# Detect shell
CURRENT_SHELL=$(basename "$SHELL")
export IRON_MINT_SHELL="$CURRENT_SHELL"
echo "🐚 Detected shell: $CURRENT_SHELL"
echo ""

# Run component scripts
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/install-tools.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/install-rustup.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/install-volta.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/install-direnv.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/configure-shell.sh"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"$SCRIPTS_DIR/configure-git.sh"

# Check if backup directory is empty (nothing was backed up)
if [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    rmdir "$BACKUP_DIR"
    echo ""
    echo "✅ Iron Mint setup complete! (no backups needed - all configs were fresh)"
else
    echo ""
    echo "✅ Iron Mint setup complete!"
    echo "📁 Backups saved to: $BACKUP_DIR"
fi

echo ""
echo "🔄 Restart your shell or run:"
if [ "$CURRENT_SHELL" = "zsh" ]; then
    echo "   source ~/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
    echo "   source ~/.bashrc"
fi
