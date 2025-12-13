#!/bin/bash
set -e

echo "+++ installing remote bash kernel"
. ./.venv/bin/activate

## Get username and host for head node
OHPC_DNS=$(tofu output -raw ohpc_dns)
OHPC_USER=$(tofu output -raw ohpc_user)

## (Re)create a ssh key for connecting to the head node as root (without passphrase!)
rm -vfc ~/.ssh/id_ohpc
ssh-keygen -t rsa -b 4096 -N '' -C "OpenHPC Head Node Key"  -f ~/.ssh/id_ohpc
ssh ${OHPC_USER}@${OHPC_DNS} sudo tee -a /root/.ssh/authorized_keys < ~/.ssh/id_ohpc.pub

## Install bash_kernel on remote
ssh -i ~/.ssh/id_ohpc root@${OHPC_DNS} pip install --root-user-action=ignore bash_kernel

## Setup remote_kernel
rm -rf $(jupyter kernelspec list --json | jq -r '.kernelspecs["remote_root-ohpc-head"].resource_dir')
export JUPYTER_DATA_DIR=$(jupyter --paths --json |jq -r '.data[0]')
python3 -m remote_kernel install --name remote_root@ohpc-head --target root@${OHPC_DNS} -i ~/.ssh/id_ohpc --kernel 'python3 -m bash_kernel'

## show kernels
jupyter kernelspec list
