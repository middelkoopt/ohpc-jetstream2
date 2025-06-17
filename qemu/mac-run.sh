#!/bin/bash

echo "=== mac-run.sh"
qemu-system-aarch64 -accel hvf -machine virt -cpu host -m 2G \
    -bios /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
