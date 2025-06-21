# Iron Mint Quick Setup

## One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/nikomatsakis/iron-mint/main/install.sh | bash
```

## Make It Your Default Shell

Add this to the end of your `~/.bashrc` or `~/.zshrc`:

```bash
# Auto-start Iron Mint development environment
if [[ -z "$IRON_MINT_ACTIVE" && -t 0 ]]; then
    export IRON_MINT_ACTIVE=1
    dev-env
fi
```

## That's It!

- **New terminals** will automatically start in Iron Mint
- **Type `exit`** to leave Iron Mint and return to normal shell
- **All your files and directories** work exactly the same
- **Tools available**: rust, cargo, mdbook, hugo, java, rg, fd, bat, eza, jq, fzf, tmux

---

*Iron Mint gives you a consistent development environment with modern tools, vim keybindings in zsh, and a clean pencil prompt: `✏️  `*
