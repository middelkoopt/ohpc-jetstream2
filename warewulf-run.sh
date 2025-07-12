#!/bin/bash
set -e

echo "=== warewulf-run.sh"
. ./get-env.sh
export OS_NAME

echo "--- wait for head $OHPC_HEAD"
while ! ssh ssh://$OHPC_USER@$OHPC_HEAD:$OHPC_PORT hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/system-el.yaml
ansible-playbook -v playbooks/warewulf-head-el9.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/image-el9.yaml
ansible-playbook -v playbooks/nodes.yaml

echo ssh://$OHPC_USER@$OHPC_HEAD:$OHPC_PORT
echo '--- done'
