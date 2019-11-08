#!/bin/bash

setopt autocd

export PATH=$PATH/bin:$PATH

# amzn stuff
source /apollo/env/envImprovement/var/zshrc

export BRAZIL_WORKSPACE_DEFAULT_LAYOUT=short

for f in SDETools envImprovement AmazonAwsCli OdinTools; do
    if [[ -d /apollo/env/$f ]]; then
        export PATH=$PATH:/apollo/env/$f/bin
    fi
done

if [ -f ~/.zshrc-dev-dsk-post ]; then
    source ~/.zshrc-dev-dsk-post
fi

# zsh promopt

PROMPT='%(?.%B%F{green}$.%F{red}[%?])%f %B%F{240}%1~%f%b  '


# enable color support of ls

if [ -x /usr/bin/dircolors ]; then                                                                                                                                                                                                                                                           
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# builder tools exports

TOOLBOX=$HOME/.toolbox/bin

# path export

export PATH=$TOOLBOX:$PATH

# aliases

[[ -f $HOME/.aliases ]] && source $HOME/.aliases
[[ -f $HOME/.amzn_aliases ]] && source $HOME/.amzn_aliases
