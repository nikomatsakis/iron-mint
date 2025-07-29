# Iron Mint Design Principles & Tool Management

**Context**: Iron Mint is Niko's personal development environment setup using Nix flakes, designed to provide a reproducible, comprehensive dev environment while respecting existing user configurations.

## Core Design Principles

1. **📁 Centralized Configuration**: Keep as much configuration as possible in the `~/dev/iron-mint/` directory
   - All custom configs live in `config/` subdirectory (vimrc, zshrc, gitconfig-dev, etc.)
   - Nix flake defines the complete environment declaratively
   - Users can inspect, modify, and understand the full setup in one location

2. **🏠 Preserve Existing Behavior**: Layer Iron Mint on top of user's existing setup, don't replace it
   - **Dotfiles**: Append source lines to existing `.vimrc`, `.zshrc`, `.gitconfig` rather than replacing them
   - **PATH**: Preserve existing PATH, add Iron Mint tools alongside user's tools
   - **Conditional Git Config**: Only apply Iron Mint git settings to `~/dev/` directory using `includeIf`
   - **Idempotent Setup**: Safe to run install multiple times without breaking existing configs

3. **🔄 Comprehensive Backup & Restore**: Always provide a way back to the original state
   - **Timestamped Backups**: Every dotfile change backed up to `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`
   - **Uninstall Script**: `--uninstall` flag provides guided restoration from backups  
   - **Backup Validation**: Track which files were created vs. modified by Iron Mint
   - **Non-destructive**: Never delete user data, only modify configuration files

## Implementation Patterns

**Dotfiles Strategy**: Layered configuration approach
- Existing user configs remain intact
- Iron Mint configs sourced conditionally from `~/dev/iron-mint/config/`
- Example: `.vimrc` gets `source ~/dev/iron-mint/config/vimrc` appended
- Allows users to override Iron Mint settings in their existing configs

**Nix Build Process**: 
- `nix build .#dotfiles` generates setup script dynamically
- Setup script embedded as heredoc in `flake.nix` for transparency
- Single source of truth for all installation logic

**Safety Mechanisms**:
- Check for existing configurations before modifying
- Idempotent operations (safe to run multiple times)
- Comprehensive backup system with guided restore process
- Clear separation between user configs and Iron Mint configs

---

# PATH & Tool Management Architecture

**Last Updated**: July 2025

## 🎯 Vision & Goals

Iron Mint implements a clean separation of tool management responsibilities:

- **Iron Mint (Nix)**: Core system utilities and development tools
- **Proto**: Project-specific toolchains based on config files (`.nvmrc`, `.python-version`, etc.)
- **Clean separation**: No redundant tools, proper priority order, CI-compatible

## 📊 Tool Priority Matrix

| Priority | Source | Tools | Purpose |
|----------|--------|-------|---------|
| 🥇 **Highest** | Proto shims | `node`, `python`, `rust` | Project-specific versions |
| 🥈 **Second** | Iron Mint (Nix) | `rg`, `pandoc`, `direnv`, `just`, `emacs`, `bat`, `fd`, `fzf`, etc. | Development utilities |
| 🥉 **Third** | Homebrew | ImageMagick deps, system libraries | System dependencies |
| 🏃 **Fallback** | macOS | `/usr/bin/git`, system tools | OS defaults |

## 🔧 PATH Construction Process

### Shell Loading Order (zsh)
1. **`.zshenv`** (always loaded) → Loads Cargo
2. **`.zprofile`** (login shells) → Loads Homebrew + **Iron Mint (Nix)**
3. **`.zshrc`** (interactive shells) → Loads **Proto activation**

### Final PATH Priority
```bash
# 1. Proto tools (project-specific) - HIGHEST PRIORITY
/Users/nikomat/.proto/activate-start
/Users/nikomat/.proto/shims
/Users/nikomat/.proto/tools/python/3.11.13/bin
/Users/nikomat/.proto/tools/node/20.19.4/bin
/Users/nikomat/.proto/bin

# 2. Iron Mint tools (Nix) - SECOND PRIORITY  
/Users/nikomat/.nix-profile/bin

# 3. Homebrew tools - THIRD PRIORITY
/opt/homebrew/bin
/opt/homebrew/sbin

# 4. System tools - FALLBACK
/usr/local/bin
/usr/bin
/bin
# ... etc
```

## 🛠 Configuration Files

### `.zprofile` - Login Shell Setup
```bash
# Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"

# Iron Mint (Nix) tools - higher priority than Homebrew
if [[ -d "$HOME/.nix-profile/bin" && ":$PATH:" != *":$HOME/.nix-profile/bin:"* ]]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi
```

### `~/dev/iron-mint/config/multi-shrc` - Interactive Shell Setup
```bash
# Proto activation - prepends to PATH for highest priority
if command -v proto >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(proto activate zsh)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(proto activate bash)"
  fi
fi
```

## 🧪 Verification Commands

### Check Tool Sources
```bash
# Should show Nix paths
which rg pandoc direnv just emacs

# Should show Proto shims  
which node python

# Test project-specific versions
cd project-with-nvmrc && node --version  # Project version
cd ~ && node --version                   # Global version
```

### Expected Output
```bash
rg      → /Users/nikomat/.nix-profile/bin/rg (Nix)
pandoc  → /Users/nikomat/.nix-profile/bin/pandoc (Nix)  
direnv  → /Users/nikomat/.nix-profile/bin/direnv (Nix)
just    → /Users/nikomat/.nix-profile/bin/just (Nix)
emacs   → /Users/nikomat/.nix-profile/bin/emacs (Nix)
node    → /Users/nikomat/.proto/shims/node (Proto)
python  → /Users/nikomat/.proto/shims/python (Proto)
```

## 🔄 Proto Project Integration

### How It Works
1. **Project declares needs**: `.nvmrc`, `.python-version`, etc.
2. **Proto detects context**: Reads config files in current directory
3. **Auto-installs versions**: `proto install` in project directory
4. **Shims route correctly**: Proto shims automatically use project-specific versions

### CI/CD Compatibility
```bash
# In any project directory
proto install  # Installs all tools specified in config files
node --version  # Uses project-specific version
```

### Example Workflow
```bash
# Create test project
mkdir test-project && cd test-project
echo "18.20.0" > .nvmrc
echo "3.10" > .python-version

# Install project tools
proto install

# Verify project-specific versions
node --version   # v18.20.0
python --version # Python 3.10.18

# Outside project uses global versions
cd ~ 
node --version   # v20.19.4 (global)
python --version # Python 3.11.13 (global)
```

## 🧹 Maintenance & Cleanup

### Adding New Tools to Iron Mint
1. Edit `~/dev/iron-mint/flake.nix`
2. Add tool to the `paths = with pkgs;` list
3. Rebuild: `cd ~/dev/iron-mint && nix build`
4. Upgrade: `nix profile upgrade iron-mint`

### Removing Redundant Homebrew Packages
```bash
# Check what Iron Mint provides
ls ~/.nix-profile/bin/ | grep -E "(rg|pandoc|direnv|just|emacs)"

# Remove from Homebrew if available in Nix
brew uninstall ripgrep pandoc direnv just emacs
```

### Troubleshooting PATH Issues
```bash
# Check PATH construction step by step
echo "=== After .zprofile ==="
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.nix-profile/bin:$PATH"
echo $PATH | tr ":" "\n" | head -5

echo "=== After proto activate ==="
eval "$(proto activate zsh)"
echo $PATH | tr ":" "\n" | head -10
```

## 🎉 Benefits Achieved

✅ **Clean separation of concerns** - Each tool source has a clear purpose  
✅ **Project-specific toolchains** - Automatic version switching based on project config  
✅ **CI/CD compatibility** - `proto install` works in any project  
✅ **No version conflicts** - Proper priority order prevents tool confusion  
✅ **Reproducible environments** - Nix ensures consistent tool versions  
✅ **Respectful of existing setup** - Layers on top without breaking user configs

**Recognition Signal**: When working on environment setup or configuration management projects, apply these principles to respect user agency while providing powerful defaults.

---

*Last updated: July 2025*