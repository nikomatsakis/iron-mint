{
  description = "Niko's personal development environment";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }: 
  let
    # Support both Linux and macOS
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    
    # Personal development shell - your preferred environment
    devShells = forAllSystems (system: 
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          name = "niko-dev-env";
          
          buildInputs = with pkgs; [
            # Core utilities
            bash
            coreutils
            git
            curl
            wget
            
            # Editors
            vim
            neovim
            
            # Modern CLI tools
            ripgrep    # rg - better grep
            fd         # better find
            bat        # better cat
            eza        # better ls
            jq         # JSON processor
            fzf        # fuzzy finder
            tmux       # terminal multiplexer
            
            # Development languages and tools
            nodejs_20
            python3
            rustup     # Rust toolchain installer
            
            # Documentation and site generators
            mdbook         # Rust-based markdown book generator
            hugo           # Static site generator
            
            # Build tools
            gnumake
            gcc
            
            # Network tools
            openssh
            rsync
          ];
          
          shellHook = ''
            # Set preferred editor and shell
            export EDITOR=vim
            export VISUAL=vim
            export SHELL=${pkgs.zsh}/bin/zsh
            
            # Rust environment
            export RUST_BACKTRACE=1
            
            # Initialize rustup if not already done (quietly)
            if [ ! -d "$HOME/.rustup" ]; then
              echo "🦀 Initializing Rust toolchain..."
              rustup default stable >/dev/null 2>&1 || true
            fi
            
            # Create zsh config for vim keybindings
            export ZDOTDIR="$PWD/.zsh"
            mkdir -p "$ZDOTDIR"
            cat > "$ZDOTDIR/.zshrc" << 'EOF'
# Enable vim keybindings
bindkey -v

# Better history search with vim keys
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Quick escape to normal mode
bindkey -M viins 'jk' vi-cmd-mode

# Better vim mode cursor (silent)
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q' >/dev/tty 2>/dev/null  # Block cursor
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q' >/dev/tty 2>/dev/null  # Beam cursor
  fi
}
zle -N zle-keymap-select

# Initialize cursor (silent)
echo -ne '\e[5 q' >/dev/tty 2>/dev/null

# Environment
export EDITOR=vim
export VISUAL=vim
export RUST_BACKTRACE=1

# Simple pencil prompt
PROMPT='✏️  '

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$ZDOTDIR/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Completion (silent)
autoload -U compinit && compinit -d "$ZDOTDIR/.zcompdump"
EOF

            # Change to the original directory if IRON_MINT_ACTIVE contains a path
            if [ -n "$IRON_MINT_ACTIVE" ] && [ "$IRON_MINT_ACTIVE" != "1" ]; then
              cd "$IRON_MINT_ACTIVE"
            fi
            
            # Start zsh quietly
            exec ${pkgs.zsh}/bin/zsh
          '';
        };
      }
    );
    
    # Home configuration package (for dotfiles)
    packages = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        
        # Install your preferred dotfiles
        dotfiles = pkgs.stdenv.mkDerivation {
          name = "niko-dotfiles";
          buildCommand = ''
            mkdir -p $out/bin
            
            # Create a setup script for dotfiles
            cat > $out/bin/setup-dotfiles << 'EOF'
            #!/bin/bash
            set -e
            
            echo "🏠 Setting up Niko's dotfiles..."
            
            # Backup existing files
            backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "$backup_dir"
            
            # Add Iron Mint configuration to existing .vimrc
            if [ -f ~/.vimrc ]; then
                # Check if Iron Mint vim config is already sourced
                if ! grep -q "iron-mint/config/vimrc" ~/.vimrc; then
                    echo "📝 Adding Iron Mint configuration to existing .vimrc..."
                    # Backup the existing .vimrc before modifying
                    cp ~/.vimrc "$backup_dir/"
                    echo "" >> ~/.vimrc
                    echo '" Iron Mint vim configuration' >> ~/.vimrc
                    echo 'if filereadable(expand("~/dev/iron-mint/config/vimrc"))' >> ~/.vimrc
                    echo '    source ~/dev/iron-mint/config/vimrc' >> ~/.vimrc
                    echo 'endif' >> ~/.vimrc
                else
                    echo "✅ Iron Mint configuration already present in .vimrc"
                fi
            else
                echo "📝 Creating new .vimrc with Iron Mint configuration..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/.vimrc"
                cat > ~/.vimrc << 'VIMRC'
" Source Iron Mint vim configuration
if filereadable(expand("~/dev/iron-mint/config/vimrc"))
    source ~/dev/iron-mint/config/vimrc
endif
VIMRC
            fi
            
            # Add Iron Mint configuration to existing .zshrc
            iron_mint_source='# Iron Mint development environment'
            if [ -f ~/.zshrc ]; then
                # Check if Iron Mint config is already sourced
                if ! grep -q "iron-mint/config/zshrc" ~/.zshrc; then
                    echo "📝 Adding Iron Mint configuration to existing .zshrc..."
                    # Backup the existing .zshrc before modifying
                    cp ~/.zshrc "$backup_dir/"
                    echo "" >> ~/.zshrc
                    echo "$iron_mint_source" >> ~/.zshrc
                    echo 'if [ -f ~/dev/iron-mint/config/zshrc ]; then' >> ~/.zshrc
                    echo '    source ~/dev/iron-mint/config/zshrc' >> ~/.zshrc
                    echo 'fi' >> ~/.zshrc
                else
                    echo "✅ Iron Mint configuration already present in .zshrc"
                fi
            else
                echo "📝 Creating new .zshrc with Iron Mint configuration..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/.zshrc"
                cat > ~/.zshrc << 'ZSHRC'
# Basic Zsh Configuration
autoload -Uz compinit
compinit

# Iron Mint development environment
if [ -f ~/dev/iron-mint/config/zshrc ]; then
    source ~/dev/iron-mint/config/zshrc
fi
ZSHRC
            fi
            
            # Add Iron Mint configuration to existing .gitconfig
            if [ -f ~/.gitconfig ]; then
                # Check if Iron Mint git config is already included
                if ! grep -q "iron-mint/config/gitconfig-dev" ~/.gitconfig; then
                    echo "📝 Adding Iron Mint configuration to existing .gitconfig..."
                    # Backup the existing .gitconfig before modifying
                    cp ~/.gitconfig "$backup_dir/"
                    echo "" >> ~/.gitconfig
                    echo "# Iron Mint git configuration for ~/dev directory" >> ~/.gitconfig
                    echo "[includeIf \"gitdir:~/dev/\"]" >> ~/.gitconfig
                    echo "    path = ~/dev/iron-mint/config/gitconfig-dev" >> ~/.gitconfig
                else
                    echo "✅ Iron Mint configuration already present in .gitconfig"
                fi
            else
                echo "📝 Creating new .gitconfig with Iron Mint configuration..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/.gitconfig"
                cat > ~/.gitconfig << 'GITCONFIG'
# Iron Mint git configuration for ~/dev directory
[includeIf "gitdir:~/dev/"]
    path = ~/dev/iron-mint/config/gitconfig-dev
GITCONFIG
            fi
            
            echo "✅ Dotfiles setup complete!"
            echo "📁 Backups saved to: $backup_dir"
            echo "🔄 Run 'source ~/.bashrc' or start a new shell to apply changes"
EOF
            
            chmod +x $out/bin/setup-dotfiles
          '';
        };
      }
    );
  };
}
