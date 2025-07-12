#!/bin/bash

: ${SESSION:=ohpc}

echo "--- attaching to tmux session '${SESSION}:0' if not already attached"
if [ "$(tmux list-clients -t ${SESSION})" == "" ] ; then
    exec tmux attach -t ${SESSION}:0
fi
