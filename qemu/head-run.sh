#!/bin/bash

export IMAGE_NAME=${1:-head}
export IMAGE_RAM=${2:-2}
export IMAGE_CPUS=${3:-1}
: ${TMUX:=tmux new-session -s ${IMAGE_NAME} -n ${IMAGE_NAME} }

echo "=== head-run.sh IMAGE_NAME=${IMAGE_NAME} IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

: ${ARCH:=$(uname -m)}
case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        QEMU="qemu-system-x86_64 -machine q35 -cpu host"
        ;;
    aarch64|arm64)
        ARCH="aarch64"
        QEMU="qemu-system-aarch64 -machine virt -cpu host"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

: ${OS:=$(uname -s)}
case "$OS" in
    Linux)
        QEMU_EFI="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
        QEMU_ACCEL="-accel kvm"
        ;;
    Darwin)
        QEMU_EFI="/opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd"
        QEMU_ACCEL="-accel hvf"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# /opt/homebrew/Cellar/qemu/*/share/qemu/edk2-aarch64-code.fd

$TMUX $QEMU $QEMU_ACCEL -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
    -bios $QEMU_EFI \
    -drive if=virtio,file=${IMAGE_NAME}.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -device virtio-net-pci,netdev=net1,mac=52:54:00:ff:00:01 \
    -netdev dgram,id=net1,remote.type=inet,remote.host=224.0.0.1,remote.port=8001 \
    -nographic
