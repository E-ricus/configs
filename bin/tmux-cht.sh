#!/usr/bin/env bash
selected=`cat $XDG_CONFIG_HOME/tmux/cht-sh/cht-languages $XDG_CONFIG_HOME/tmux/cht-sh/cht-command | fzf`

read -p "Enter Query: " query

if grep -qs "$selected" $XDG_CONFIG_HOME/tmux/cht-sh/cht-languages; then
    query=`echo $query | tr ' ' '+'`
    tmux neww bash -c "curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
else
    tmux neww bash -c "curl cht.sh/$selected~$query & while [ : ]; do sleep 1; done"
fi

