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
            (pkgs.writeScriptBin "iron-mint" (builtins.readFile ./scripts/iron-mint))
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
            
            # Version management
            proto          # Multi-language version manager
            
            # Documentation and site generators  
            pandoc
            
            # Network tools
            openssh
            rsync
            
            # Image processing
            imagemagick
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
