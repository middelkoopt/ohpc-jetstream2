#!/bin/bash

export IMAGE_NAME=${1:-c1}
export IMAGE_RAM=${2:-2}
export IMAGE_CPUS=${3:-1}

echo "=== head-run.sh IMAGE_NAME=${IMAGE_NAME} IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

## Configure based on architecture
: ${ARCH:=$(uname -m)}
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        QEMU="qemu-system-x86_64 -accel kvm -cpu host"
        ;;
    aarch64|arm64)
        ARCH="aarch64"
        QEMU="qemu-system-aarch64 -accel hvf -machine virt -cpu host"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

## Create a new tmux session if it doesn't exist
if ! tmux has-session -t nodes ; then
    echo "--- create new tmux session"
    tmux new-session -s nodes -d
    tmux set-option -t nodes -g remain-on-exit failed 
    tmux set-option -t nodes -g remain-on-exit-format ""
fi
: ${TMUX:=tmux new-window -t nodes -n ${IMAGE_NAME}}

## Create a new backing disk (overwrites existing disk)
echo "--- create new disk image ${IMAGE_NAME}.qcow2"
qemu-img create -f qcow2 ${IMAGE_NAME}.qcow2 10G

## Start QEMU
echo "--- start ${IMAGE_NAME}"
$TMUX $QEMU -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
    -bios ./QEMU_EFI.fd \
    -drive if=virtio,file=${IMAGE_NAME}.qcow2,format=qcow2 \
    -device virtio-net-pci,netdev=net0,mac=52:54:00:05:01:${IMAGE_NAME} \
    -netdev dgram,id=net0,remote.type=inet,remote.host=224.0.0.1,remote.port=8001 \
    -boot order=n \
    -nographic

echo '--- attaching to tmux session if not already attached'
if [ "$(tmux list-clients -t nodes)" == "" ] ; then
    tmux attach -t nodes
fi
