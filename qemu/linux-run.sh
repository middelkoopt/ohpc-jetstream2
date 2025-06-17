#!/bin/bash

echo "=== linux-run.sh"
declare -A efi_bios=(["x86_64"]="/usr/share/ovmf/OVMF.fd" ["aarch64"]="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd")
qemu-system-$HOSTTYPE -accel kvm -machine virt -cpu host -m 2G \
    -bios ${efi_bios[$HOSTTYPE]} \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
