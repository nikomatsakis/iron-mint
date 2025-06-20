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
            
            # Set preferred editor
            export EDITOR=vim
            export VISUAL=vim
            
            # Rust environment
            export RUST_BACKTRACE=1
            
            echo "✨ Environment ready! Type 'exit' to leave this shell."
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
            
            # Backup and create .bashrc additions
            [ -f ~/.bashrc ] && cp ~/.bashrc "$backup_dir/"
            cat >> ~/.bashrc << 'BASHRC'
            
            # Niko's Bash Configuration
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
            export HISTSIZE=10000
            export HISTFILESIZE=20000
            export HISTCONTROL=ignoredups:erasedups
            
            # Prompt
            export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
            BASHRC
            
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
