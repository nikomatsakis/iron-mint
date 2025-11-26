#!/bin/bash
# Configure shell (bash/zsh) with Iron Mint settings
# Idempotent - safe to run multiple times

set -e

echo "🐚 Shell Configuration"

IRON_MINT_DIR="$HOME/dev/iron-mint"
BACKUP_DIR="${IRON_MINT_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
CURRENT_SHELL="${IRON_MINT_SHELL:-$(basename "$SHELL")}"

# Helper function to backup a file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        echo "   📋 Backed up $(basename "$file")"
    fi
}

# Helper function to add source line if not present
add_source_line() {
    local file="$1"
    local source_path="$2"
    local marker="$3"

    if [ -f "$file" ]; then
        if ! grep -q "$marker" "$file"; then
            backup_file "$file"
            echo "" >> "$file"
            echo "# Iron Mint configuration" >> "$file"
            echo "source $source_path" >> "$file"
            return 0  # Added
        fi
        return 1  # Already present
    else
        # Create new file
        echo "# Iron Mint configuration" > "$file"
        echo "source $source_path" >> "$file"
        # Mark that we created this file (empty backup = created by us)
        mkdir -p "$BACKUP_DIR"
        touch "$BACKUP_DIR/$(basename "$file").created"
        return 0  # Created
    fi
}

# Configure vim
echo "   📝 Configuring vim..."
if [ -f "$HOME/.vimrc" ]; then
    if ! grep -q "iron-mint/config/vimrc" "$HOME/.vimrc"; then
        backup_file "$HOME/.vimrc"
        echo "" >> "$HOME/.vimrc"
        echo '" Iron Mint vim configuration' >> "$HOME/.vimrc"
        echo 'if filereadable(expand("~/dev/iron-mint/config/vimrc"))' >> "$HOME/.vimrc"
        echo '    source ~/dev/iron-mint/config/vimrc' >> "$HOME/.vimrc"
        echo 'endif' >> "$HOME/.vimrc"
        echo "   ✅ Added Iron Mint config to .vimrc"
    else
        echo "   ✅ .vimrc already configured"
    fi
else
    cat > "$HOME/.vimrc" << 'EOF'
" Iron Mint vim configuration
if filereadable(expand("~/dev/iron-mint/config/vimrc"))
    source ~/dev/iron-mint/config/vimrc
endif
EOF
    mkdir -p "$BACKUP_DIR"
    touch "$BACKUP_DIR/.vimrc.created"
    echo "   ✅ Created .vimrc"
fi

# Configure shell RC file
if [ "$CURRENT_SHELL" = "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
    PROFILE_FILE="$HOME/.zprofile"
else
    RC_FILE="$HOME/.bashrc"
    PROFILE_FILE="$HOME/.bash_profile"
fi

echo "   📝 Configuring $CURRENT_SHELL..."

# Add source to RC file
if add_source_line "$RC_FILE" "~/dev/iron-mint/config/multi-shrc" "iron-mint/config/multi-shrc"; then
    echo "   ✅ Added Iron Mint config to $(basename "$RC_FILE")"
else
    echo "   ✅ $(basename "$RC_FILE") already configured"
fi

# Add source to profile file (for login shells)
if add_source_line "$PROFILE_FILE" "~/dev/iron-mint/config/multi-profile" "iron-mint/config/multi-profile"; then
    echo "   ✅ Added Iron Mint config to $(basename "$PROFILE_FILE")"
else
    echo "   ✅ $(basename "$PROFILE_FILE") already configured"
fi
