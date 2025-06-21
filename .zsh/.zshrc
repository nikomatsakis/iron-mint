# Enable vim keybindings
bindkey -v

# Better history search with vim keys
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Quick escape to normal mode
bindkey -M viins 'jk' vi-cmd-mode

# Better vim mode cursor
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # Block cursor
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # Beam cursor
  fi
}
zle -N zle-keymap-select

# Initialize cursor
echo -ne '\e[5 q'

# Load aliases
alias ll='eza -la'
alias la='eza -a'
alias ls='eza'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Environment
export EDITOR=vim
export VISUAL=vim
export RUST_BACKTRACE=1

# Nice prompt with mode indicator
autoload -U promptinit && promptinit
function zle-line-init zle-keymap-select {
  VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
  RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$ZDOTDIR/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Completion
autoload -U compinit && compinit
