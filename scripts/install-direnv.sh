#!/bin/bash
# Install direnv (directory-based environment management)
# Idempotent - safe to run multiple times

set -e

echo "📂 Direnv"

# Check if direnv is already installed
if command -v direnv &> /dev/null; then
    echo "   ✅ Already installed"
    echo "   📍 $(direnv --version)"
else
    echo "   📦 Installing direnv..."

    # Detect OS and install accordingly
    case "$(uname -s)" in
        Darwin*)
            # macOS - use Homebrew if available, otherwise curl
            if command -v brew &> /dev/null; then
                brew install direnv
            else
                # Fallback to binary install
                curl -sfL https://direnv.net/install.sh | bash
            fi
            ;;
        Linux*)
            # Linux - try package managers first, fall back to binary install
            installed=false
            if command -v apt-get &> /dev/null; then
                if sudo apt-get update && sudo apt-get install -y direnv 2>/dev/null; then
                    installed=true
                fi
            elif command -v dnf &> /dev/null; then
                if sudo dnf install -y direnv 2>/dev/null; then
                    installed=true
                fi
            elif command -v pacman &> /dev/null; then
                if sudo pacman -S --noconfirm direnv 2>/dev/null; then
                    installed=true
                fi
            fi

            if [ "$installed" = false ]; then
                echo "   ↳ package manager failed, downloading binary..."
                mkdir -p "$HOME/.local/bin"
                export bin_path="$HOME/.local/bin"
                curl -sfL https://direnv.net/install.sh | bash
            fi
            ;;
        *)
            echo "   ❌ Unsupported OS for automatic direnv installation"
            echo "   Please install direnv manually: https://direnv.net/docs/installation.html"
            exit 1
            ;;
    esac

    echo "   ✅ Installed successfully"
    echo "   📍 $(direnv --version)"
fi
