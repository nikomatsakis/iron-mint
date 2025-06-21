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
            zsh
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
            
            # Development tools
            nodejs_20
            python3
            rustc
            cargo
            
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
            
            # Backup and create .vimrc
            [ -f ~/.vimrc ] && cp ~/.vimrc "$backup_dir/"
            cat > ~/.vimrc << 'VIMRC'
            " Niko's Vim Configuration
            set number
            set relativenumber
            set tabstop=2
            set shiftwidth=2
            set expandtab
            set autoindent
            set smartindent
            syntax on
            set hlsearch
            set incsearch
            set ignorecase
            set smartcase
            
            " Modern vim improvements
            set wildmenu
            set wildmode=list:longest
            set backspace=indent,eol,start
            
            " Color scheme
            colorscheme desert
            VIMRC
            
            # Backup and create .zshrc
            [ -f ~/.zshrc ] && cp ~/.zshrc "$backup_dir/"
            cat > ~/.zshrc << 'ZSHRC'
            # Niko's Zsh Configuration
            
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
            
            # History settings
            HISTSIZE=10000
            SAVEHIST=10000
            HISTFILE=~/.zsh_history
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_SPACE
            setopt SHARE_HISTORY
            setopt APPEND_HISTORY
            setopt INC_APPEND_HISTORY
            
            # Completion (silent)
            autoload -U compinit && compinit -d ~/.zcompdump
            
            # Simple pencil prompt
            PROMPT='✏️  '
            ZSHRC
            
            # Create .gitconfig if it doesn't exist
            if [ ! -f ~/.gitconfig ]; then
                echo "📝 Creating basic .gitconfig (you'll want to customize this)"
                cat > ~/.gitconfig << 'GITCONFIG'
            [user]
                name = Your Name
                email = your.email@example.com
            
            [core]
                editor = vim
                autocrlf = input
            
            [init]
                defaultBranch = main
            
            [pull]
                rebase = false
            
            [alias]
                st = status
                co = checkout
                br = branch
                ci = commit
                unstage = reset HEAD --
                last = log -1 HEAD
                visual = !gitk
            GITCONFIG
                echo "⚠️  Remember to update ~/.gitconfig with your actual name and email!"
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
