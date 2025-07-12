#!/bin/bash
set -e

n=${1:-1}
ram=${2:-3}
: ${SESSION:=ohpc}

echo "### create.sh n=${n}"

echo '--- remove old ssh key'
ssh-keygen -R "[localhost]:8022"

./generate-seed.sh

./run-image.sh head 2 2

for (( i=1 ; i<=n ; i++ )) ; do
  ./run-image.sh c$i $ram 1
done
