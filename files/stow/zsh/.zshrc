# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Basic options
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# Completion
autoload -Uz compinit && compinit
zmodload zsh/complist  # Load complist module for menuselect keymap
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# Key bindings - Vi mode
bindkey -v  # Vi key bindings
export KEYTIMEOUT=1  # Reduce delay when switching modes

# Better vi mode search
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Keep some useful emacs bindings in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^Y' yank

# History search with arrow keys (works in both modes)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey -M vicmd '^[[A' history-search-backward
bindkey -M vicmd '^[[B' history-search-forward

# Edit line in vim with v in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Load aliases
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Path additions
export PATH="$HOME/.local/bin:$PATH"

# Mise (runtime manager) activation
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
  
  # Set GOROOT based on mise's Go installation
  if mise which go &>/dev/null 2>&1; then
    export GOROOT="$(mise where go)"
    export PATH="$GOROOT/bin:$PATH"
  fi
fi

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Zoxide (better cd)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# FZF integration
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# Load custom functions
if [[ -d "$HOME/.config/zsh/functions" ]]; then
  for func in $HOME/.config/zsh/functions/*; do
    source "$func"
  done
fi

# Load local configuration if it exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"