#!/bin/bash
set -e

VERSION=${1:-el10}

echo "=== warewulf-run.sh ${VERSION}"
. ./get-env.sh
export OS_NAME

echo "--- wait for head $OHPC_HEAD"
while ! ssh ssh://$OHPC_USER@$OHPC_HEAD:$OHPC_PORT hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/system-el.yaml
ansible-playbook -v playbooks/warewulf-head-${VERSION}.yaml
ansible-playbook -v playbooks/image-${VERSION}.yaml
ansible-playbook -v playbooks/nodes.yaml

echo ssh://$OHPC_USER@$OHPC_HEAD:$OHPC_PORT
echo '--- done'
