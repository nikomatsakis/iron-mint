# Iron Mint Quick Setup

## Installation

**Option 1: One-line install (recommended)**
```bash
curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

**Option 2: Using the iron-mint command**
```bash
# First get the iron-mint script (if you have Nix already)
nix shell github:nikomatsakis/iron-mint -c iron-mint install
```

This will:
1. Install Nix if needed
2. Clone Iron Mint to `~/dev/iron-mint/`
3. Add Iron Mint configuration to your shell RC file
4. Install all Iron Mint tools

## That's It!

Restart your shell and you'll have:
- **Vi keybindings** with `jk` to escape (zsh and bash)
- **Pencil prompt**: `✏️  `
- **All tools available** in your PATH
- **The `iron-mint` command** for easy management

## Uninstall

To restore your original configuration:

```bash
iron-mint uninstall
```

This will:
- Show you all available backups (created during installation)
- Let you choose which backup to restore
- Restore your original shell RC, vim, and git configuration
- Remove Iron Mint packages from your profile

## Tools Available

- **Languages**: rustup, nodejs, python3
- **Modern CLI**: ripgrep (rg), fd, bat, eza, jq, fzf
- **Editors**: vim, neovim  
- **Build tools**: make, gcc
- **Other**: tmux, git, curl, wget, imagemagick, mdbook, hugo

## Package Management

Iron Mint includes the `iron-mint` command for easy package management:

```bash
# Add packages locally (just for you)
iron-mint add docker
iron-mint add kubectl

# Remove packages
iron-mint remove docker

# See what's installed
iron-mint list

# Update to latest Iron Mint packages
iron-mint update

# Pull latest changes and update everything
iron-mint sync

# Add packages to Iron Mint itself (for everyone)
iron-mint edit
```

### Workflows

**Adding packages locally:**
```bash
iron-mint add <package-name>
```
This installs packages just for you using `nix profile install`.

**Adding packages to Iron Mint:**
```bash
iron-mint edit
# Add the package to the list in flake.nix
iron-mint sync
```
This makes packages available to all Iron Mint users.

**Staying up to date:**
```bash
iron-mint sync
```
Pulls the latest Iron Mint changes and updates your packages.

## Features

- **Minimal setup** - just adds one line to your shell RC file
- **Everything in `~/dev/iron-mint/`** - no scattered config files
- **Safe installation** - backups created automatically, easy uninstall
- **Works with your existing setup** - doesn't replace your configuration
- **Simple package management** - no need to learn Nix commands

---

*Iron Mint gives you a consistent development environment with modern tools, vim keybindings in zsh, and a clean pencil prompt: `✏️  `*
