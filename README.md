# Iron Mint Quick Setup

## One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

## Start Iron Mint

```bash
~/dev/iron-mint/dev-env
```

## Make It Your Default Shell (Optional)

Add this to the end of your `~/.bashrc` or `~/.zshrc`:

```bash
# Auto-start Iron Mint development environment
if [[ -z "$IRON_MINT_ACTIVE" && -t 0 ]]; then
    export IRON_MINT_ACTIVE=1
    ~/dev/iron-mint/dev-env
fi
```

Or add a simple alias:

```bash
alias iron='~/dev/iron-mint/dev-env'
```

## That's It!

- **Everything lives in `~/dev/iron-mint/`** - no scattered config files
- **No PATH modifications** - just run the script directly
- **Type `exit`** to leave Iron Mint and return to normal shell
- **All your files and directories** work exactly the same
- **Tools available**: rust, cargo, mdbook, hugo, java, rg, fd, bat, eza, jq, fzf, tmux

---

*Iron Mint gives you a consistent development environment with modern tools, vim keybindings in zsh, and a clean pencil prompt: `✏️  `*
