# Enable vim keybindings
bindkey -v

# Better history search with vim keys
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Quick escape to normal mode
bindkey -M viins 'jk' vi-cmd-mode

# Better vim mode cursor (silent)
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q' >/dev/tty 2>/dev/null  # Block cursor
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q' >/dev/tty 2>/dev/null  # Beam cursor
  fi
}
zle -N zle-keymap-select

# Initialize cursor (silent)
echo -ne '\e[5 q' >/dev/tty 2>/dev/null

# Environment
export EDITOR=vim
export VISUAL=vim
export RUST_BACKTRACE=1

# Simple pencil prompt
PROMPT='✏️  '

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$ZDOTDIR/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Completion (silent)
autoload -U compinit && compinit -d "$ZDOTDIR/.zcompdump"
