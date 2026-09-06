# Iron Mint

Personal development environment setup - shell scripts that configure your machine with sensible defaults.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

This will:
1. Clone Iron Mint to `~/dev/iron-mint/`
2. Install CLI tools (gh, ripgrep, fd, bat, fzf, jq, Hugo)
3. Install **rustup** (Rust toolchain)
4. Install **volta** (Node.js version manager)
5. Configure your shell (bash/zsh) with vi keybindings
6. Configure tmux with vi-style copy-mode and prompt keys
7. Configure git to use `vi`

Works on **macOS**, **Linux**, and **WSL**.

## What You Get

- **Vi keybindings** in your shell (`jk` to escape in zsh)
- **Persistent Bash history** shared across sessions, with a long on-disk history
- **Vi keybindings** in tmux copy mode and prompts
- **Bold hostname prompt**: `hostname. `
- **Rust** via rustup
- **Node.js** via volta (with automatic project version switching)
- **Hugo** for static site generation
- **Vi as the Git editor**
- **Sensible git defaults** - rebase on pull, diff3 merge style, useful aliases
- **`git worktrees` helper** - lists every worktree for the current repo with recent activity and HEAD commit

## Updating

```bash
cd ~/dev/iron-mint
git pull
iron-mint setup
```

`iron-mint setup` is safe to run at any time: it installs any missing tools and reapplies the managed configuration without duplicating entries. To only refresh configuration, use `iron-mint sync`.

You can also re-run the curl command; it is idempotent.

## Git Worktree Orientation

Once Iron Mint is on your `PATH`, you can run this inside any git worktree:

```bash
git worktrees
```

It prints every worktree for that repository, sorted by recent activity, along with the branch and current HEAD commit. The "last used" column is a best-effort timestamp derived from git metadata plus mtimes of currently dirty files.

## Uninstalling

```bash
~/dev/iron-mint/uninstall.sh
```

This shows you all available backups and lets you restore your original configuration.

**Note:** Uninstall restores your shell/git configuration but does not remove installed CLI tools (gh, ripgrep, etc.) - those are generally useful to keep around.

## Structure

```
iron-mint/
├── install.sh          # curl entry point
├── setup.sh            # main setup script
├── uninstall.sh        # guided restore
├── scripts/
│   ├── install-tools.sh    # CLI tools from tools.json
│   ├── install-rustup.sh
│   ├── install-volta.sh
│   ├── configure-shell.sh
│   ├── configure-tmux.sh
│   └── configure-git.sh
├── config/
│   ├── tools.json      # CLI tools to install (cross-platform)
│   ├── multi-shrc      # shell config (vi mode, prompt, PATH)
│   ├── multi-profile   # login shell config
│   ├── tmux.conf        # tmux config (vi keys)
│   ├── gitconfig-dev   # git config for ~/dev/
│   ├── gitignore-global
│   └── vimrc
└── bin/
    ├── git-editor      # smart editor picker
    └── git-worktrees   # recent worktree overview
```

## Design Principles

1. **Simple shell scripts** - no complex tooling, easy to understand and modify
2. **Idempotent** - safe to run multiple times
3. **Preserves existing config** - appends to your dotfiles, doesn't replace them
4. **Comprehensive backups** - timestamped backups of everything modified
5. **Easy to undo** - guided restore from any backup point
