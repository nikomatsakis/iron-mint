#!/bin/bash
# One-liner installer for Iron Mint development environment
# Usage: curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
# Uninstall: ~/dev/iron-mint/install.sh --uninstall

set -e

# Check for uninstall option
if [[ "$1" == "--uninstall" ]]; then
    echo "🗑️  Iron Mint Uninstaller"
    echo ""
    
    # List available backups
    backup_dirs=($(ls -1d ~/.dotfiles-backup-* 2>/dev/null | sort -r))
    
    if [ ${#backup_dirs[@]} -eq 0 ]; then
        echo "❌ No backup directories found."
        echo "   Cannot restore original configuration."
        exit 1
    fi
    
    echo "📋 Available backups:"
    echo ""
    for i in "${!backup_dirs[@]}"; do
        dir="${backup_dirs[$i]}"
        timestamp=$(basename "$dir" | sed 's/.*-backup-//')
        date_formatted=$(date -d "${timestamp:0:8} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" 2>/dev/null || echo "$timestamp")
        echo "  $((i+1)). $date_formatted"
        
        # Show what's in this backup
        if [ -f "$dir/.zshrc" ]; then echo "      - .zshrc"; fi
        if [ -f "$dir/.vimrc" ]; then echo "      - .vimrc"; fi
        if [ -f "$dir/.gitconfig" ]; then echo "      - .gitconfig"; fi
        echo ""
    done
    
    echo -n "Select backup to restore (1-${#backup_dirs[@]}) or 'q' to quit: "
    read -r choice
    
    if [[ "$choice" == "q" ]]; then
        echo "👋 Uninstall cancelled."
        exit 0
    fi
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#backup_dirs[@]}" ]; then
        echo "❌ Invalid choice."
        exit 1
    fi
    
    selected_backup="${backup_dirs[$((choice-1))]}"
    echo ""
    echo "🔄 Restoring from: $selected_backup"
    
    # Restore files
    for file in .zshrc .vimrc .gitconfig; do
        if [ -f "$selected_backup/$file" ]; then
            if [ -s "$selected_backup/$file" ]; then
                echo "   ✅ Restoring $file"
                cp "$selected_backup/$file" ~/"$file"
            else
                echo "   🗑️  Removing $file (was created by Iron Mint)"
                rm -f ~/"$file"
            fi
        fi
    done
    
    echo ""
    echo "✅ Configuration restored!"
    echo "💡 Note: This only restored your dotfiles. Iron Mint is still in ~/dev/iron-mint"
    echo "   To fully remove Iron Mint, you can:"
    echo "   - Remove the directory: rm -rf ~/dev/iron-mint"
    echo "   - Uninstall Nix if desired (see Nix documentation)"
    exit 0
fi

echo "🚀 Installing Iron Mint Development Environment..."

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

# Check shell
current_shell=$(basename "$SHELL")
echo "🐚 Detected shell: $current_shell"

if [[ "$current_shell" != "zsh" && "$current_shell" != "bash" ]]; then
    echo "⚠️  Warning: Iron Mint is designed for zsh or bash"
    echo "   Your current shell is: $SHELL"
    echo "   Iron Mint may not work correctly with other shells."
    read -p "   Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 1
    fi
fi

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

# Clone or update iron-mint
if [ -d ~/dev/iron-mint ]; then
    echo "🔄 Updating existing iron-mint..."
    echo "💡 Tip: To uninstall, run: ~/dev/iron-mint/install.sh --uninstall"
    echo ""
    cd ~/dev/iron-mint
    git pull
else
    echo "📁 Cloning iron-mint..."
    mkdir -p ~/dev
    git clone git@github.com:nikomatsakis/iron-mint.git ~/dev/iron-mint
fi

cd ~/dev/iron-mint

# Set up dotfiles  
echo "🏠 Setting up dotfiles..."
nix build .#dotfiles
bash ./result/bin/setup-dotfiles

# Install Iron Mint tools
echo ""
echo "📦 Installing Iron Mint tools..."
nix profile install .

echo ""
echo "✅ Iron Mint development environment installed successfully!"
echo ""
echo "💡 To activate in current session:"
echo "   source ~/.zshrc"
echo ""
echo "🚀 New terminal sessions will automatically have Iron Mint configuration"
echo ""
echo "📚 See README.md for more information"
