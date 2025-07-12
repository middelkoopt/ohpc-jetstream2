#!/bin/bash
set -e

n=${1:-1}
ram=${2:-5}
cpus=${3:-1}
: ${SESSION:=ohpc}

echo "### create.sh ${SESSION} nodes: n=${n} ram=${ram} cpus=${cpus}"

echo '--- remove old ssh key'
ssh-keygen -R "[localhost]:8022"

./generate-seed.sh
./run-image.sh head 2 2

for (( i=1 ; i<=n ; i++ )) ; do
  ./run-image.sh c$i $ram $cpus
done
