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
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# Key bindings
bindkey -e  # Emacs key bindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

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