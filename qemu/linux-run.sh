#!/bin/bash

IMAGE_RAM=${1:-2G}
echo "=== linux-run.sh IMAGE_RAM=${IMAGE_RAM}"

declare -A efi_bios=(
    ["x86_64"]="/usr/share/ovmf/OVMF.fd"
    ["aarch64"]="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
)
declare -A machine_type=(
    ["x86_64"]="q35"
    ["aarch64"]="virt"
)

qemu-system-$HOSTTYPE -accel kvm -machine ${machine_type[$HOSTTYPE]} -cpu host -m ${IMAGE_RAM} \
    -bios ${efi_bios[$HOSTTYPE]} \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
