#!/usr/local/bin/bash

# vim: set syntax=sh:

#shopt -s globstar

source ~/.git-prompt.sh

function include() {
  [[ -f "${1}" ]] && . "${1}" > /dev/null 2>&1
}

export TERM=xterm-256color
[[ ! -z ${TMUX+x} ]] && export TERM=screen-256color

readonly  __ps1_reset=$(tput sgr0)
readonly  __ps1_red=$(tput bold; tput setaf 196)
readonly  __ps1_grey=$(tput setaf 240)
readonly  __ps1_yellow=$(tput bold; tput setaf 3)
readonly  __ps1_lightgreen=$(tput setaf 34)
readonly  __ps1_blue=$(tput bold; tput setaf 6)

function __ps1_failed_exit () {
    local rc="${?}";
    if (( "${rc}" != 0 )); then
        echo "[${rc}]";
    fi
}

GIT_PS1_SHOWDIRTYSTATE=true

PS1=''
PS1+='\[${__ps1_red}\]$(__ps1_failed_exit)'
PS1+='\[${__ps1_yellow}\] ''\[${__ps1_lightgreen}\]$ '
PS1+='\[${__ps1_blue}\]$(__git_ps1 "[%s]")'
PS1+='\[${__ps1_grey}\]\w'
PS1+='\[${__ps1_reset}\] '


# add this configuration to ~/.bashrc
shopt -s histappend
export HSTR_CONFIG=hicolor,regexp-matching,verbose-kill
export HISTCONTROL=ignoreboth
export HISTFILESIZE=10000
export HISTSIZE="${HISTFILESIZE}"

function __hh_sync_history() {
  history -a
  # consider history -n instead of these
  history -c
  history -r
}
precmd_functions+=(__hh_sync_history)


set -o vi
export EDITOR=vim



# completions
include /etc/bash_completion.d/g4d

export P4DIFF=colordiff

# rebound in inputrc
#stty werase undef


export PATH=$HOME/.local/bin:$PATH

# aliases

[[ -f $HOME/.aliases ]] && source $HOME/.aliases
[[ -f $HOME/.amzn_aliases ]] && source $HOME/.amzn_aliases

# amzn builder tools
export PATH=$PATH:$HOME/.toolbox/bin

# golang
export GOPATH=$(go env GOPATH)
export PATH=$PATH:$(go env GOPATH)/bin

# java
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$PATH:$JAVA_HOME/bin

# python
export PYTHON_HOME=/Users/whitfiec/Library/Python/3.8
export PATH=$PATH:$PYTHON_HOME/bin

# ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# node
export NODE_HOME=/usr/local/opt/node@12
export PATH=$PATH:$NODE_HOME/bin
