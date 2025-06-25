#!/bin/bash
set -e

IMAGE=ohpc-qemu
SIZE=5G
NBD=/dev/nbd0

echo "=== build.sh ${IMAGE} ${NBD}"

echo "--- setup nbd"
sudo modprobe nbd

echo "--- cleanup failed builds"
sudo umount -v ${NBD}p1 || /bin/true
sudo umount -v ${NBD}p2 || /bin/true
sudo qemu-nbd --disconnect ${NBD}

echo "--- build container"
podman build --progress=plain -t ${IMAGE} ./container $*

echo "--- create disk"
qemu-img create -f qcow2 drive.qcow2 ${SIZE}

echo "--- nbd mount disk"
sudo qemu-nbd --connect=${NBD} --format=qcow2 --discard=unmap --detect-zeroes=unmap drive.qcow2

echo "--- create partitions"
sudo sfdisk ${NBD} << EOF
label: gpt
: start=8192 size=+200MiB type=uefi name=EFI
: type=linux name=root
EOF
sudo fdisk -l ${NBD}

echo "--- format partitions"
sudo mkdosfs -F 32 -n EFI ${NBD}p1
sudo mke2fs -T ext4 -L root ${NBD}p2

echo "--- mount"
sudo install -vdp /mnt/${IMAGE}
sudo mount -v ${NBD}p2 /mnt/${IMAGE}
sudo install -vdp /mnt/${IMAGE}/boot/efi
sudo mount -v ${NBD}p1 /mnt/${IMAGE}/boot/efi

echo "--- extract container"
ID=$(podman create ${IMAGE})
echo ${ID}
podman container export ${ID} | sudo tar -xpf - -C /mnt/${IMAGE}
podman container rm ${ID}

echo "--- debug"
#( cd /mnt/${IMAGE} && /usr/bin/bash --rcfile <(echo "PS1='(debug) $ '") -i )
#sudo chroot /mnt/${IMAGE} /bin/bash -i

echo "--- umount"
sudo umount -v /mnt/${IMAGE}/boot/efi
sudo umount -v /mnt/${IMAGE}
sudo qemu-nbd --disconnect ${NBD}

