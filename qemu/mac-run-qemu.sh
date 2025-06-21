#!/bin/bash

export IMAGE_RAM=${1:-4}
export IMAGE_CPUS=${2:-4}
export IMAGE=ohpc-qemu

echo "=== mac-run-linux.sh IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

qemu-system-aarch64 -accel hvf -machine virt -cpu host -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
    -bios /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nic socket,id=head,mcast=230.0.0.1:8001 \
    -nographic
