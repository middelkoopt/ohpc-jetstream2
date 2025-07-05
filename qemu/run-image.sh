#!/bin/bash

export IMAGE_NAME=${1:-head}
export IMAGE_RAM=${2:-1}
export IMAGE_CPUS=${3:-1}
: ${SESSION:=ohpc}

echo "=== run-image.sh ${SESSION} IMAGE_NAME=${IMAGE_NAME} IMAGE_RAM=${IMAGE_RAM} IMAGE_CPUS=${IMAGE_CPUS}"

## Set ARCH
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

## Set OS
: ${OS:=$(uname -s)}
case "$OS" in
    Linux)
        case "$ARCH" in
            aarch64)
                QEMU_EFI="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
                ;;
            x86_64)
                QEMU_EFI="/usr/share/qemu/OVMF.fd"
                ;;
        esac
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

## Create a new tmux session if it doesn't exist
if ! tmux has-session -t ${SESSION} ; then
    echo "--- create new tmux session ${SESSION}"
    tmux new-session -s ${SESSION} -d
    tmux set-option -g remain-on-exit failed 
    tmux set-option -g remain-on-exit-format ""
fi

if [ $IMAGE_NAME = "head" ] ; then
    echo "--- start ${IMAGE_NAME} on ${SESSION}:0"
    : ${RUN:=exec tmux new-window -k -t ${SESSION}:0 -n ${IMAGE_NAME}}
    $RUN $QEMU $QEMU_ACCEL -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
        -bios $QEMU_EFI \
        -drive if=virtio,file=${IMAGE_NAME}.qcow2,format=qcow2 \
        -drive if=virtio,file=seed.img,format=raw,media=cdrom \
        -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
        -device virtio-net-pci,netdev=net1,mac=52:54:00:05:00:08 \
        -netdev dgram,id=net1,remote.type=inet,remote.host=224.0.0.1,remote.port=8001 \
        -nographic
else
    ## Create a new backing disk (overwrites existing disk)
    echo "--- create new disk image ${IMAGE_NAME}.qcow2"
    qemu-img create -f qcow2 ${IMAGE_NAME}.qcow2 10G

    ## Start QEMU
    echo "--- start ${IMAGE_NAME} on ${SESSION}:${IMAGE_ID}"
    printf -v IMAGE_ID "%02x" ${IMAGE_NAME//[^0-9]}
    : ${RUN:=exec tmux new-window -k -t ${SESSION}:${IMAGE_ID} -n ${IMAGE_NAME}}

    $RUN $QEMU $QEMU_ACCEL -m ${IMAGE_RAM}G -smp ${IMAGE_CPUS} \
        -bios $QEMU_EFI \
        -drive if=virtio,file=${IMAGE_NAME}.qcow2,format=qcow2 \
        -device virtio-net-pci,netdev=net0,mac=52:54:00:05:01:${IMAGE_ID} \
        -netdev dgram,id=net0,remote.type=inet,remote.host=224.0.0.1,remote.port=8001 \
        -boot order=n \
        -nographic
fi
