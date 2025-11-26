# Iron Mint

Personal development environment setup - shell scripts that configure your machine with sensible defaults.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

This will:
1. Clone Iron Mint to `~/dev/iron-mint/`
2. Install **rustup** (Rust toolchain)
3. Install **volta** (Node.js version manager)
4. Configure your shell (bash/zsh) with vi keybindings
5. Configure git with smart editor detection

Works on **macOS**, **Linux**, and **WSL**.

## What You Get

- **Vi keybindings** in your shell (`jk` to escape in zsh)
- **Bold hostname prompt**: `hostname. `
- **Rust** via rustup
- **Node.js** via volta (with automatic project version switching)
- **Smart git editor** - uses VS Code if in VS Code terminal, Zed if in Zed terminal, vim otherwise
- **Sensible git defaults** - rebase on pull, diff3 merge style, useful aliases

## Updating

```bash
cd ~/dev/iron-mint
git pull
./setup.sh
```

Or just re-run the curl command - it's idempotent.

## Uninstalling

```bash
~/dev/iron-mint/uninstall.sh
```

This shows you all available backups and lets you restore your original configuration.

## Structure

```
iron-mint/
├── install.sh          # curl entry point
├── setup.sh            # main setup script
├── uninstall.sh        # guided restore
├── scripts/
│   ├── install-rustup.sh
│   ├── install-volta.sh
│   ├── configure-shell.sh
│   └── configure-git.sh
├── config/
│   ├── multi-shrc      # shell config (vi mode, prompt, PATH)
│   ├── multi-profile   # login shell config
│   ├── gitconfig-dev   # git config for ~/dev/
│   ├── gitignore-global
│   └── vimrc
└── bin/
    └── git-editor      # smart editor picker
```

## Design Principles

1. **Simple shell scripts** - no complex tooling, easy to understand and modify
2. **Idempotent** - safe to run multiple times
3. **Preserves existing config** - appends to your dotfiles, doesn't replace them
4. **Comprehensive backups** - timestamped backups of everything modified
5. **Easy to undo** - guided restore from any backup point
