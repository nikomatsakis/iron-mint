#!/bin/bash
# Configure git with Iron Mint settings
# Idempotent - safe to run multiple times

set -e

echo "📦 Git Configuration"

IRON_MINT_DIR="$HOME/dev/iron-mint"
BACKUP_DIR="${IRON_MINT_BACKUP_DIR:-$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"

# Helper function to backup a file
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        echo "   📋 Backed up $(basename "$file")"
    fi
}

# Configure global gitconfig
echo "   📝 Configuring .gitconfig..."

if [ -f "$HOME/.gitconfig" ]; then
    # Check if Iron Mint config is already included
    if ! grep -q "iron-mint/config/gitconfig-dev" "$HOME/.gitconfig"; then
        backup_file "$HOME/.gitconfig"
        echo "" >> "$HOME/.gitconfig"
        echo "# Iron Mint git configuration for ~/dev directory" >> "$HOME/.gitconfig"
        echo '[includeIf "gitdir:~/dev/"]' >> "$HOME/.gitconfig"
        echo "    path = ~/dev/iron-mint/config/gitconfig-dev" >> "$HOME/.gitconfig"
        echo "   ✅ Added Iron Mint config to .gitconfig"
    else
        echo "   ✅ .gitconfig already configured"
    fi
else
    # Create new .gitconfig
    cat > "$HOME/.gitconfig" << 'EOF'
# Iron Mint git configuration for ~/dev directory
[includeIf "gitdir:~/dev/"]
    path = ~/dev/iron-mint/config/gitconfig-dev
EOF
    mkdir -p "$BACKUP_DIR"
    touch "$BACKUP_DIR/.gitconfig.created"
    echo "   ✅ Created .gitconfig"
fi

# Configure global gitignore
echo "   📝 Configuring global gitignore..."

START_MARKER="# >>> iron-mint >>>"
END_MARKER="# <<< iron-mint <<<"

if [ -f "$HOME/.gitignore" ]; then
    # Remove existing Iron Mint section if present
    if grep -q "$START_MARKER" "$HOME/.gitignore"; then
        backup_file "$HOME/.gitignore"
        sed "/$START_MARKER/,/$END_MARKER/d" "$HOME/.gitignore" > "$HOME/.gitignore.tmp"
        mv "$HOME/.gitignore.tmp" "$HOME/.gitignore"
        echo "   🔄 Removed old Iron Mint patterns"
    fi
else
    # Create empty file
    touch "$HOME/.gitignore"
    mkdir -p "$BACKUP_DIR"
    touch "$BACKUP_DIR/.gitignore.created"
fi

# Append fresh Iron Mint patterns in marked block
{
    echo ""
    echo "$START_MARKER"
    cat "$IRON_MINT_DIR/config/gitignore-global"
    echo "$END_MARKER"
} >> "$HOME/.gitignore"
echo "   ✅ Added Iron Mint patterns to .gitignore"

# Set global excludesfile
git config --global core.excludesfile ~/.gitignore
echo "   ✅ Set global excludesfile"

echo "   ✅ Git editor configured (vi)"
