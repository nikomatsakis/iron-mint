# Iron Mint Design Principles

**Context**: Iron Mint is Niko's personal development environment setup using simple shell scripts, designed to provide sensible defaults while respecting existing user configurations.

## Core Design Principles

1. **📁 Centralized Configuration**: Keep configuration in `~/dev/iron-mint/`
   - Custom configs live in `config/` subdirectory (vimrc, multi-shrc, gitconfig-dev, etc.)
   - Helper scripts in `bin/`
   - Setup scripts in `scripts/`
   - Users can inspect, modify, and understand the full setup in one location

2. **🏠 Preserve Existing Behavior**: Layer Iron Mint on top of user's existing setup
   - **Dotfiles**: Append source lines to existing `.vimrc`, `.zshrc`, `.bashrc`, `.gitconfig` rather than replacing them
   - **PATH**: Preserve existing PATH, add Iron Mint tools alongside user's tools
   - **Conditional Git Config**: Only apply Iron Mint git settings to `~/dev/` directory using `includeIf`
   - **Idempotent Setup**: Safe to run setup multiple times without breaking existing configs

3. **🔄 Comprehensive Backup & Restore**: Always provide a way back
   - **Timestamped Backups**: Every dotfile change backed up to `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`
   - **Uninstall Script**: `uninstall.sh` provides guided restoration from backups
   - **Non-destructive**: Never delete user data, only modify configuration files

## What Iron Mint Provides

Iron Mint focuses on **configuration**, not tool installation:

- **Vi keybindings** in your shell (`jk` to escape in zsh)
- **Bold hostname prompt**: `hostname. `
- **Vi as the Git editor**
- **Sensible git defaults** - rebase on pull, diff3 merge style, useful aliases
- **Direnv integration** - directory-based environment management

## Tool Installation

Iron Mint installs tools in two categories:

### CLI Tools (via package manager)
Defined in `config/tools.json` and installed by `scripts/install-tools.sh`:

| Tool | Description |
|------|-------------|
| **jq** | JSON processor (bootstrapped first) |
| **gh** | GitHub CLI |
| **ripgrep** | Fast grep alternative (rg) |
| **fd** | Fast find alternative |
| **bat** | Cat with syntax highlighting |
| **fzf** | Fuzzy finder |
| **Hugo** | Static site generator |

The script auto-detects brew/apt/dnf and uses the correct package name for each platform.

To add a new tool, edit `config/tools.json`:
```json
{
  "name": "tool-name",
  "description": "What it does",
  "brew": "brew-package-name",
  "apt": "apt-package-name",
  "dnf": "dnf-package-name"
}
```

### Language Toolchains (custom installers)

| Tool | Purpose | Installed By |
|------|---------|--------------|
| **rustup** | Rust toolchain management | `scripts/install-rustup.sh` |
| **volta** | Node.js version management | `scripts/install-volta.sh` |
| **direnv** | Directory-based environments | `scripts/install-direnv.sh` |

## Directory Structure

```
iron-mint/
├── install.sh          # curl entry point
├── setup.sh            # main setup script (runs all scripts/)
├── uninstall.sh        # guided restore from backups
├── scripts/
│   ├── install-tools.sh    # CLI tools from tools.json
│   ├── install-rustup.sh
│   ├── install-volta.sh
│   ├── install-direnv.sh
│   ├── configure-shell.sh
│   └── configure-git.sh
├── config/
│   ├── tools.json      # CLI tools to install (cross-platform)
│   ├── multi-shrc      # shell config (vi mode, prompt, PATH)
│   ├── multi-profile   # login shell config
│   ├── gitconfig-dev   # git config for ~/dev/
│   ├── gitignore-global
│   └── vimrc
└── bin/                # command helpers
```

## Shell Configuration

`config/multi-shrc` is sourced by your shell RC file and provides:

1. **Vi mode** with visual cursor feedback (block in normal, beam in insert)
2. **Quick escape**: `jk` exits insert mode in zsh
3. **History navigation**: `j`/`k` in normal mode searches history
4. **Bold hostname prompt**
5. **PATH additions** for Cargo, Volta, and Iron Mint bin/

Works with both zsh and bash by detecting shell type at runtime.

## Git Configuration

`config/gitconfig-dev` is conditionally included for repos under `~/dev/`:

- Vi as the Git editor
- Rebase on pull (`pull.rebase = true`)
- Better merge conflict style (`merge.conflictstyle = diff3`)
- Useful aliases

## Updating

```bash
cd ~/dev/iron-mint
git pull
./setup.sh
```

Or re-run the curl installer - it's idempotent.

---

*Last updated: December 2025*
