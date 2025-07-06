#!/bin/bash
RECIPE=${1:-"recipe.sh"}
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
scp ./test-recipe-config.sh scp://$HEAD
scp $RECIPE scp://$HEAD/recipe.sh

echo "--- copy recipe"
ssh ssh://$HEAD "sudo OHPC_INPUT_LOCAL=./test-recipe-config.sh bash -x ./recipe.sh"

echo '--- done'
echo "ssh ssh://$HEAD"
