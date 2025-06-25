#!/bin/bash

IMAGE_RAM=${1:-4}
: ${DATA:=/data}

echo "=== run-head.sh IMAGE_RAM=${IMAGE_RAM}"

declare -A efi_bios=(
    ["x86_64"]="/usr/share/ovmf/OVMF.fd"
    ["aarch64"]="/usr/share/edk2/aarch64/QEMU_EFI.fd"
)
declare -A machine_type=(
    ["x86_64"]="q35"
    ["aarch64"]="virt"
)

/usr/libexec/qemu-kvm -accel kvm -machine ${machine_type[$HOSTTYPE]} -cpu host -m ${IMAGE_RAM}G \
    -bios ${efi_bios[$HOSTTYPE]} \
    -drive if=virtio,file=${DATA}/head.qcow2,format=qcow2 \
    -drive if=virtio,file=${DATA}/seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
