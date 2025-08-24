{
  description = "Personal development environment with modern CLI tools and proto for project version management";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  
  outputs = { self, nixpkgs }: 
  let
    # Support both Linux and macOS
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    
    # Package set containing all Iron Mint tools
    packages = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.buildEnv {
          name = "iron-mint-tools";
          paths = with pkgs; [
            # Iron Mint maintenance script
            (pkgs.writeScriptBin "iron-mint" ''
              #!/bin/bash
              # Iron Mint wrapper script that uses the correct directory
              
              # Always use the user's Iron Mint directory, not the Nix store location
              IRON_MINT_DIR="$HOME/dev/iron-mint"
              
              # Check if the Iron Mint directory exists
              if [ ! -d "$IRON_MINT_DIR" ]; then
                  echo "❌ Error: Iron Mint directory not found at $IRON_MINT_DIR"
                  echo "   Please ensure Iron Mint is properly installed."
                  exit 1
              fi
              
              # Execute the actual iron-mint script from the user's directory
              exec "$IRON_MINT_DIR/scripts/iron-mint" "$@"
            '')
            # Core utilities
            bash
            zsh
            coreutils
            git
            git-filter-repo  # Advanced git history rewriting tool
            curl
            wget
            libiconv
            
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
            github-cli # gh - GitHub CLI tool
            direnv     # directory-based environment management
            just       # command runner (better make)
            emacs      # text editor
            
            # Version management
            proto          # Multi-language version manager
            
            # Documentation and site generators  
            pandoc
            
            # Network tools
            openssh
            rsync
            
            # Image processing
            imagemagick
            
            # Container tools
            podman
          ];
        };
        
        # Install your preferred dotfiles
        dotfiles = pkgs.stdenv.mkDerivation {
          name = "niko-dotfiles";
          buildCommand = ''
            mkdir -p $out/bin
            
            # Create a setup script for dotfiles
            cat > $out/bin/setup-dotfiles << 'EOF'
            #!/bin/bash
            set -e
            
            echo "🏠 Setting up Iron Mint..."
            
            # Detect current shell
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
            
            # Configure shell-specific RC file
            if [[ "$current_shell" == "zsh" ]]; then
                rc_file="$HOME/.zshrc"
                shell_name="zsh"
                default_config='# Basic Zsh Configuration
autoload -Uz compinit
compinit

# Iron Mint development environment
source ~/dev/iron-mint/config/multi-shrc'
            elif [[ "$current_shell" == "bash" ]]; then
                rc_file="$HOME/.bashrc"
                shell_name="bash"
                default_config='# Basic Bash Configuration

# Iron Mint development environment
source ~/dev/iron-mint/config/multi-shrc'
            else
                # Fallback to zsh config for unknown shells
                rc_file="$HOME/.zshrc"
                shell_name="zsh"
                default_config='# Basic Zsh Configuration
autoload -Uz compinit
compinit

# Iron Mint development environment
source ~/dev/iron-mint/config/multi-shrc'
            fi
            
            # Add Iron Mint configuration to existing RC file
            if [ -f "$rc_file" ]; then
                # Check if Iron Mint config is already sourced
                if ! grep -q "iron-mint/config/multi-shrc" "$rc_file"; then
                    echo "📝 Adding Iron Mint configuration to existing .$shell_name rc..."
                    # Backup the existing RC file before modifying
                    cp "$rc_file" "$backup_dir/"
                    echo "" >> "$rc_file"
                    echo "# Iron Mint development environment" >> "$rc_file"
                    echo 'source ~/dev/iron-mint/config/multi-shrc' >> "$rc_file"
                else
                    echo "✅ Iron Mint configuration already present in .$shell_name rc"
                fi
            else
                echo "📝 Creating new .$shell_name rc with Iron Mint configuration..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/$(basename "$rc_file")"
                echo "$default_config" > "$rc_file"
            fi
            
            # Configure shell-specific profile file for login shells
            if [[ "$current_shell" == "zsh" ]]; then
                profile_file="$HOME/.zprofile"
                profile_name="zprofile"
                default_profile_config='# Iron Mint development environment (login shell)
source ~/dev/iron-mint/config/multi-profile'
            elif [[ "$current_shell" == "bash" ]]; then
                profile_file="$HOME/.bash_profile"
                profile_name="bash_profile"
                default_profile_config='# Iron Mint development environment (login shell)
source ~/dev/iron-mint/config/multi-profile'
            else
                # Fallback to zsh profile for unknown shells
                profile_file="$HOME/.zprofile"
                profile_name="zprofile"
                default_profile_config='# Iron Mint development environment (login shell)
source ~/dev/iron-mint/config/multi-profile'
            fi
            
            # Add Iron Mint configuration to existing profile file
            if [ -f "$profile_file" ]; then
                # Check if Iron Mint profile config is already sourced
                if ! grep -q "iron-mint/config/multi-profile" "$profile_file"; then
                    echo "📝 Adding Iron Mint configuration to existing .$profile_name..."
                    # Backup the existing profile file before modifying
                    cp "$profile_file" "$backup_dir/"
                    echo "" >> "$profile_file"
                    echo "# Iron Mint development environment (login shell)" >> "$profile_file"
                    echo 'source ~/dev/iron-mint/config/multi-profile' >> "$profile_file"
                else
                    echo "✅ Iron Mint configuration already present in .$profile_name"
                fi
            else
                echo "📝 Creating new .$profile_name with Iron Mint configuration..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/$(basename "$profile_file")"
                echo "$default_profile_config" > "$profile_file"
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
            
            # Setup global gitignore by appending Iron Mint patterns to ~/.gitignore
            if [ -f ~/.gitignore ]; then
                # Check if Iron Mint patterns are already added
                if ! grep -q "# Iron Mint global gitignore patterns" ~/.gitignore; then
                    echo "📝 Adding Iron Mint gitignore patterns to existing ~/.gitignore..."
                    # Backup the existing .gitignore before modifying
                    cp ~/.gitignore "$backup_dir/"
                    echo "" >> ~/.gitignore
                    echo "# Iron Mint global gitignore patterns" >> ~/.gitignore
                    cat ~/dev/iron-mint/config/gitignore-global | grep -v "^#" | grep -v "^$" >> ~/.gitignore
                else
                    echo "✅ Iron Mint gitignore patterns already present in ~/.gitignore"
                fi
            else
                echo "📝 Creating ~/.gitignore with Iron Mint patterns..."
                # Mark that this file was created by Iron Mint
                touch "$backup_dir/.gitignore"
                echo "# Iron Mint global gitignore patterns" > ~/.gitignore
                cat ~/dev/iron-mint/config/gitignore-global | grep -v "^#" | grep -v "^$" >> ~/.gitignore
            fi
            
            # Set git to use ~/.gitignore as the global excludesfile
            git config --global core.excludesfile ~/.gitignore
            echo "✅ Global gitignore configured"
            
            # Setup proto configuration symlink
            if [ -f ~/.prototools ]; then
                # Check if it's already our symlink
                if [ -L ~/.prototools ] && [ "$(readlink ~/.prototools)" = "~/dev/iron-mint/config/prototools" ]; then
                    echo "✅ Iron Mint proto configuration already linked"
                else
                    echo "📝 Backing up existing .prototools and creating Iron Mint symlink..."
                    cp ~/.prototools "$backup_dir/"
                    rm ~/.prototools
                    ln -s ~/dev/iron-mint/config/prototools ~/.prototools
                fi
            else
                echo "📝 Creating Iron Mint proto configuration symlink..."
                # Mark that this file was created by Iron Mint (no existing file)
                touch "$backup_dir/.prototools"
                ln -s ~/dev/iron-mint/config/prototools ~/.prototools
            fi
            
            # Install Iron Mint packages to user profile
            echo "📦 Installing Iron Mint packages..."
            if nix profile install ~/dev/iron-mint#default; then
                echo "✅ Iron Mint packages installed successfully!"
            else
                echo "❌ Failed to install Iron Mint packages. You can try manually:"
                echo "   nix profile install ~/dev/iron-mint#default"
            fi
            
            echo "✅ Iron Mint setup complete!"
            echo "📁 Backups saved to: $backup_dir"
            echo ""
            echo "🔄 Restart your shell or run: source ~/.zshrc"
EOF
            
            chmod +x $out/bin/setup-dotfiles
          '';
        };
      }
    );
  };
}
