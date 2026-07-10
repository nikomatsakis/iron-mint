#!/bin/bash
# Configure tmux with Iron Mint settings without replacing existing config.
# Idempotent - safe to run multiple times.

set -e

echo "🖥  Tmux Configuration"

TMUX_CONF="$HOME/.tmux.conf"
BACKUP_DIR="${IRON_MINT_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
MARKER="iron-mint/config/tmux.conf"

backup_file() {
    if [ -f "$TMUX_CONF" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$TMUX_CONF" "$BACKUP_DIR/"
        echo "   📋 Backed up .tmux.conf"
    fi
}

if [ -f "$TMUX_CONF" ]; then
    if grep -Fq "$MARKER" "$TMUX_CONF"; then
        echo "   ✅ .tmux.conf already configured"
    else
        backup_file
        {
            echo ""
            echo "# Iron Mint tmux configuration"
            echo "source-file ~/dev/iron-mint/config/tmux.conf"
        } >> "$TMUX_CONF"
        echo "   ✅ Added Iron Mint config to .tmux.conf"
    fi
else
    cat > "$TMUX_CONF" << 'EOF'
# Iron Mint tmux configuration
source-file ~/dev/iron-mint/config/tmux.conf
EOF
    mkdir -p "$BACKUP_DIR"
    touch "$BACKUP_DIR/.tmux.conf.created"
    echo "   ✅ Created .tmux.conf"
fi
