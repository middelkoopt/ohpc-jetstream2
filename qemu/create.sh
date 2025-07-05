#!/bin/bash
set -e

n=${1:-1}
: ${SESSION:=ohpc}

echo "=== create.sh n=${n}"

echo '--- remove old ssh key'
ssh-keygen -R "[localhost]:8022"

./run-image.sh head 1 1

for (( i=1 ; i<=n ; i++ )) ; do
  ./run-image.sh c$i 3 1
done

echo "--- attaching to tmux session '${SESSION}:0' if not already attached"
if [ "$(tmux list-clients -t ${SESSION})" == "" ] ; then
    exec tmux attach -t ${SESSION}:0
fi
