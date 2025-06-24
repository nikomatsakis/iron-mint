# Iron Mint Quick Setup

## One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

This will:
1. Install Nix if needed
2. Clone Iron Mint to `~/dev/iron-mint/`
3. Add Iron Mint configuration to your `.zshrc`
4. Install all Iron Mint tools

## That's It!

Restart your shell and you'll have:
- **Vi keybindings** in zsh with `jk` to escape
- **Pencil prompt**: `✏️  `
- **All tools available** in your PATH

## Uninstall

To restore your original configuration:

```bash
~/dev/iron-mint/install.sh --uninstall
```

This will:
- Show you all available backups (created during installation)
- Let you choose which backup to restore
- Restore your original `.zshrc`, `.vimrc`, and `.gitconfig`

## Tools Available

- **Languages**: rustup, nodejs, python3
- **Modern CLI**: ripgrep (rg), fd, bat, eza, jq, fzf
- **Editors**: vim, neovim  
- **Build tools**: make, gcc
- **Other**: tmux, git, curl, wget, imagemagick, mdbook, hugo

## Features

- **Minimal setup** - just adds one line to your `.zshrc`
- **Everything in `~/dev/iron-mint/`** - no scattered config files
- **Safe installation** - backups created automatically, easy uninstall
- **Works with your existing setup** - doesn't replace your configuration

---

*Iron Mint gives you a consistent development environment with modern tools, vim keybindings in zsh, and a clean pencil prompt: `✏️  `*
