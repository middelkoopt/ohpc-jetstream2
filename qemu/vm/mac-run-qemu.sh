#!/bin/bash

IMAGE_RAM=${1:-4}
IMAGE_CPUS=${2:-4}

echo "=== mac-run-qemu.sh IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

qemu-system-aarch64 -accel hvf -machine virt -cpu host -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
    -bios /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
