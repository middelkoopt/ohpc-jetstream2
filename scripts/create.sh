#!/bin/bash
set -e

echo "=== create.sh ${OS_NAME}"

if [[ -z "${OS_NAME}" ]] ; then
    echo "error: must set OS_NAME"
    exit 1
fi

tofu -chdir=${OS_NAME} apply -auto-approve -var-file=local.tfvars

. ./get-env.sh
. ./remove-knownhosts.sh

echo "=== create.sh ${OHPC_IP4} ${OHPC_IP6} ${OHPC_DNS}"

if [ -x ${OS_NAME}/create.sh ] ; then
    echo "--- run ${OS_NAME}/create.sh"
    ( cd ${OS_NAME} && exec ./create.sh )
fi
