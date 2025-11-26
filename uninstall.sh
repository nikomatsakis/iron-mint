#!/bin/bash
# Iron Mint Uninstaller
# Guides user through restoring from backups

set -e

echo "🌿 Iron Mint Uninstaller"
echo ""

BACKUP_BASE="$HOME/.dotfiles-backup-"

# Find all backup directories
backups=($(ls -d ${BACKUP_BASE}* 2>/dev/null | sort -r))

if [ ${#backups[@]} -eq 0 ]; then
    echo "No backup directories found."
    echo ""
    echo "To manually uninstall, remove Iron Mint lines from:"
    echo "  - ~/.bashrc or ~/.zshrc"
    echo "  - ~/.bash_profile or ~/.zprofile"
    echo "  - ~/.vimrc"
    echo "  - ~/.gitconfig"
    echo "  - ~/.gitignore"
    echo ""
    echo "And optionally remove:"
    echo "  - ~/dev/iron-mint (this repo)"
    echo "  - ~/.cargo (rustup)"
    echo "  - ~/.volta (volta)"
    exit 0
fi

echo "Found ${#backups[@]} backup(s):"
echo ""

for i in "${!backups[@]}"; do
    backup="${backups[$i]}"
    date_part=$(basename "$backup" | sed 's/\.dotfiles-backup-//')
    # Format: YYYYMMDD-HHMMSS -> YYYY-MM-DD HH:MM:SS
    formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2} ${date_part:9:2}:${date_part:11:2}:${date_part:13:2}"

    echo "  [$i] $formatted_date"

    # Show what's in the backup
    contents=$(ls -1 "$backup" 2>/dev/null | head -5)
    if [ -n "$contents" ]; then
        echo "$contents" | sed 's/^/      /'
        remaining=$(ls -1 "$backup" 2>/dev/null | wc -l)
        if [ "$remaining" -gt 5 ]; then
            echo "      ... and $((remaining - 5)) more"
        fi
    fi
    echo ""
done

echo "Which backup would you like to restore from? (0-$((${#backups[@]} - 1)), or 'q' to quit)"
read -r choice

if [ "$choice" = "q" ] || [ "$choice" = "Q" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#backups[@]}" ]; then
    echo "Invalid choice."
    exit 1
fi

selected_backup="${backups[$choice]}"
echo ""
echo "Restoring from: $selected_backup"
echo ""

# Restore each file
for file in "$selected_backup"/*; do
    [ -f "$file" ] || continue

    filename=$(basename "$file")

    # Check if this is a ".created" marker (file didn't exist before)
    if [[ "$filename" == *.created ]]; then
        original_file="${filename%.created}"
        target="$HOME/$original_file"
        if [ -f "$target" ]; then
            echo "🗑  Removing $original_file (was created by Iron Mint)"
            rm "$target"
        fi
    else
        target="$HOME/$filename"
        echo "📋 Restoring $filename"
        cp "$file" "$target"
    fi
done

echo ""
echo "✅ Restore complete!"
echo ""
echo "Optionally, you can also remove:"
echo "  - ~/dev/iron-mint     (this repo)"
echo "  - ~/.cargo            (rustup - Rust toolchain)"
echo "  - ~/.volta            (volta - Node.js manager)"
echo ""
echo "To remove rustup cleanly: rustup self uninstall"
echo "To remove volta: rm -rf ~/.volta"
echo ""
echo "🔄 Restart your shell to apply changes."
