#!/bin/bash

echo "=== delete.sh"

. ./get-env.sh
. ./remove-knownhosts.sh

tofu -chdir=${OS_NAME} destroy -auto-approve -var-file=local.tfvars

if [ -x ${OS_NAME}/delete.sh ] ; then
    echo "--- run ${OS_NAME}/delete.sh"
    ( cd ${OS_NAME} && exec ./delete.sh )
fi
