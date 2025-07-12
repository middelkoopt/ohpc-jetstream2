#!/bin/bash
set -e
: ${SESSION:=ohpc}

echo "=== delete.sh ${SESSION}"

echo "--- killing tmux session '${SESSION}'"
if tmux has-session -t ${SESSION} ; then
  tmux kill-session -t ${SESSION}
fi

echo "--- stopping vde_switch"
if [ -f ${SESSION}.pid ] ; then
  kill $(cat ${SESSION}.pid)
else
  echo "--- no vde_switch running"
fi
