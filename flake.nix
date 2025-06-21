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
            echo "🚀 Welcome to Niko's development environment!"
            echo "📦 Available tools: rg, fd, bat, eza, jq, fzf, tmux, node, python3, rust"
            
            # Set up aliases
            alias ll='eza -la'
            alias la='eza -a'
            alias ls='eza'
            alias cat='bat'
            alias find='fd'
            alias grep='rg'
            
            # Git aliases
            alias gs='git status'
            alias ga='git add'
            alias gc='git commit'
            alias gp='git push'
            alias gl='git log --oneline'
            
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

# Better vim mode cursor
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # Block cursor
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # Beam cursor
  fi
}
zle -N zle-keymap-select

# Initialize cursor
echo -ne '\e[5 q'

# Load aliases
alias ll='eza -la'
alias la='eza -a'
alias ls='eza'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Environment
export EDITOR=vim
export VISUAL=vim
export RUST_BACKTRACE=1

# Nice prompt with mode indicator
autoload -U promptinit && promptinit
function zle-line-init zle-keymap-select {
  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
  RPS1="''${''${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$ZDOTDIR/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Completion
autoload -U compinit && compinit
EOF

            echo "✨ Environment ready! Starting zsh with vim keybindings..."
            echo "💡 Use 'jk' to quickly escape to normal mode, 'k/j' for history search"
            
            # Start zsh
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
            
            # Better vim mode cursor
            function zle-keymap-select {
              if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
                echo -ne '\e[1 q'  # Block cursor
              elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $1 = 'beam' ]]; then
                echo -ne '\e[5 q'  # Beam cursor
              fi
            }
            zle -N zle-keymap-select
            
            # Initialize cursor
            echo -ne '\e[5 q'
            
            # Environment
            export EDITOR=vim
            export VISUAL=vim
            export RUST_BACKTRACE=1
            
            # Modern CLI aliases (when tools are available)
            command -v eza >/dev/null && alias ls='eza' && alias ll='eza -la' && alias la='eza -a'
            command -v bat >/dev/null && alias cat='bat'
            command -v rg >/dev/null && alias grep='rg'
            command -v fd >/dev/null && alias find='fd'
            
            # Git aliases
            alias gs='git status'
            alias ga='git add'
            alias gc='git commit'
            alias gp='git push'
            alias gl='git log --oneline'
            alias gd='git diff'
            
            # Useful aliases
            alias ..='cd ..'
            alias ...='cd ../..'
            alias l='ls -CF'
            
            # History settings
            HISTSIZE=10000
            SAVEHIST=10000
            HISTFILE=~/.zsh_history
            setopt HIST_IGNORE_DUPS
            setopt HIST_IGNORE_SPACE
            setopt SHARE_HISTORY
            setopt APPEND_HISTORY
            setopt INC_APPEND_HISTORY
            
            # Completion
            autoload -U compinit && compinit
            
            # Prompt with vim mode indicator
            autoload -U promptinit && promptinit
            function zle-line-init zle-keymap-select {
              VIM_PROMPT="%{$fg_bold[yellow]%} [NORMAL]%{$reset_color%}"
              RPS1="''${''${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
              zle reset-prompt
            }
            zle -N zle-line-init
            zle -N zle-keymap-select
            
            PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '
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
