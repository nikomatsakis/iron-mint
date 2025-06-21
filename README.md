# Niko's Personal Development Environment

A Nix-based, cross-platform development environment that provides consistent tooling across Linux and macOS.

## Features

- **Modern CLI Tools**: ripgrep, fd, bat, eza, jq, fzf, tmux
- **Development Languages**: Node.js 20, Python 3, Rust
- **Editors**: vim, neovim with sensible configurations
- **Cross-Platform**: Works on Linux (x86_64, aarch64) and macOS (Intel, Apple Silicon)
- **Reproducible**: Same environment everywhere using Nix

## Quick Start

### New Machine Setup

```bash
# Install Nix with Determinate Systems installer (recommended)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Clone this repo
git clone git@github.com:nikomatsakis/iron-mint.git ~/.config/nix/personal-dev
cd ~/.config/nix/personal-dev

# Enable Nix flakes (usually enabled by default with Determinate Systems installer)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Set up dotfiles
nix build .#dotfiles
./result/bin/setup-dotfiles

# Create launcher script
mkdir -p ~/.local/bin
cp scripts/dev-env ~/.local/bin/
chmod +x ~/.local/bin/dev-env

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Daily Usage

```bash
# Enter development environment
dev-env

# Inside the environment, you have access to:
rg "search term"    # Better grep
fd "filename"       # Better find  
bat file.txt        # Better cat with syntax highlighting
eza -la             # Better ls with colors
jq '.' data.json    # JSON processor
fzf                 # Fuzzy finder
tmux                # Terminal multiplexer
```

## Customization

### Adding New Tools

Edit `flake.nix` and add packages to the `buildInputs` list:

```nix
buildInputs = with pkgs; [
  # ... existing tools ...
  htop              # System monitor
  docker            # Container runtime
  awscli2           # AWS CLI
];
```

### Modifying Aliases

Edit the `shellHook` section in `flake.nix`:

```nix
shellHook = ''
  # Add your custom aliases here
  alias myalias='some command'
'';
```

### Updating Environment

After making changes:

```bash
# Test your changes
dev-env

# Commit and push changes
git add .
git commit -m "Add new tools"
git push
```

## Structure

```
.
├── flake.nix          # Main Nix configuration
├── flake.lock         # Locked dependency versions
├── scripts/           # Helper scripts
│   ├── dev-env        # Environment launcher
│   └── setup-machine  # New machine setup
└── README.md          # This file
```

## Sync Across Machines

This repo keeps your development environment in sync across all machines:

1. **Make changes** on any machine by editing `flake.nix`
2. **Commit and push** your changes
3. **Pull and rebuild** on other machines:
   ```bash
   cd ~/.config/nix/personal-dev
   git pull
   dev-env  # Automatically rebuilds with new changes
   ```

## Troubleshooting

### Nix not found
```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### Flakes not enabled
```bash
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

### Environment not updating
```bash
# Force rebuild
cd ~/.config/nix/personal-dev
nix flake update
dev-env
```

---

*Last updated: June 2025*
