#!/bin/bash
set -e

RECIPE=${1:-"recipe.sh"}
OHPC=${2:-"ohpc4"}
. ./get-env.sh

echo "=== test-recipe-run.sh $RECIPE"
HEAD="$OHPC_USER@$OHPC_HEAD:$OHPC_PORT"

echo "--- wait for head $HEAD"
while ! ssh ssh://$HEAD hostname ; do echo . ; sleep .2 ; done

echo "--- setup head"
ssh ssh://$HEAD sudo bash <<- EOF
  dnf upgrade -y
  dnf install -y yum-utils initscripts-service ## AlmaLinux
  /usr/bin/needs-restarting -r || systemctl reboot
EOF

echo "--- wait for head $HEAD"
while ! ssh ssh://$HEAD hostname ; do echo . ; sleep .2 ; done

echo "--- copy recipe"
scp ./test-recipe-config-${OHPC}.sh scp://$HEAD
scp ./test-recipe-patch.sed scp://$HEAD
scp $RECIPE scp://$HEAD/recipe.sh

echo "--- patch recipe"
ssh ssh://$HEAD "sed -i -f ./test-recipe-patch.sed ./recipe.sh"

echo "--- run recipe"
ssh ssh://$HEAD "sudo OHPC_INPUT_LOCAL=./test-recipe-config-${OHPC}.sh bash -x -e ./recipe.sh"

echo '--- done'
echo "ssh ssh://$HEAD"
