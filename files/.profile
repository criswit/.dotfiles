#!/bin/bash

# vim: set syntax=sh:

#shopt -s globstar

function include() {
  [[ -f "${1}" ]] && . "${1}" > /dev/null 2>&1
}

export TERM=xterm-256color
[[ ! -z ${TMUX+x} ]] && export TERM=screen-256color

readonly  __ps1_reset=$(tput sgr0)
readonly  __ps1_red=$(tput bold; tput setaf 196)
readonly  __ps1_yellow=$(tput setaf 11)$USER
readonly  __ps1_grey=$(tput setaf 240)
#readonly  __ps1_yellow=$(tput bold; tput setaf 3)
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

# golang
#GOVERSION="1.12.4"
#export GIMME_ENV="$HOME/.gimme/envs/go${GOVERSION}.env"
#include "${GIMME_ENV}"
#export GOROOT="${HOME}/.gimme/versions/go${GOVERSION}.linux.amd64"
#export GOPATH="${HOME}/go"

export PATH=$PATH/bin:$PATH

set -o vi
export EDITOR=vim

export GOPATH="${HOME}/go"
export PATH=$GOPATH/bin:$PATH


#export KUBE_ROOT=$GOPATH/src/k8s.io/kubernetes

#export PATH=$HOME/google-cloud-sdk/bin:$PATH

# completions
include /etc/bash_completion.d/g4d
include "$HOME/.bazel/bin/bazel-complete.bash"

if [[ -d "${HOME}/bin/" ]]; then
  export PATH="$HOME/bin:/Users/whitfiec/Library/Python/3.7/bin:$PATH"
fi

export P4DIFF=colordiff

# rebound in inputrc
#stty werase undef

export PATH=$HOME/.local/bin:$PATH

# aliases

[[ -f $HOME/.aliases ]] && source $HOME/.aliases
[[ -f $HOME/.amzn_aliases ]] && source $HOME/.amzn_aliases
