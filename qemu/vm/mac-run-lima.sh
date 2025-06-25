#!/bin/bash
set -e

IMAGE_RAM=${1:-4}
IMAGE_CPUS=${2:-4}
IMAGE=ohpc-qemu
IMAGE_DISK="file:///$PWD//drive.qcow2"

echo "=== mac-run-linua.sh IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

echo "--- delete old lima vm"
limactl stop --yes ${IMAGE} || true
limactl delete --yes ${IMAGE} || true

echo "--- create lima vm"
limactl create --yes --plain \
    --name=${IMAGE} \
    --cpus=${IMAGE_CPUS} \
    --memory=${IMAGE_RAM} \
    --set ".images[0].location=\"${IMAGE_DISK}\"" \
    ./config-lima.yaml

echo "--- start lima vm"
limactl start --yes ${IMAGE}

echo "--- generate ssh key"
if [ ! -r ./id_rsa.pub ] ; then
    ssh-keygen -t rsa -b 2048 -N '' -C admin@${IMAGE} -f ./id_rsa
fi

echo "--- configure vm"
limactl shell ${IMAGE} << EOF
echo $(cat ./id_rsa.pub) >> .ssh/authorized_keys
EOF

echo "--- debug"
limactl shell ${IMAGE} sudo -i

echo "--- delete lima vm"
limactl stop --yes ${IMAGE}
limactl delete --yes ${IMAGE}
