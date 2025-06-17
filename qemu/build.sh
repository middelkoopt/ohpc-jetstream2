#!/bin/bash
set -e

IMAGE=ohpc-qemu
SIZE=5G
NBD=/dev/nbd0

echo "=== build.sh ${IMAGE} ${NBD}"

echo "--- cleanup failed builds"
sudo umount -v ${NBD}p1 || /bin/true
sudo umount -v ${NBD}p2 || /bin/true
sudo qemu-nbd --disconnect ${NBD}

echo "--- build container"
podman build --progress=plain -t ${IMAGE} ./image $*

echo "--- create disk"
qemu-img create -f qcow2 drive.qcow2 ${SIZE}

echo "--- nbd mount disk"
sudo modprobe nbd
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

echo "--- generate key"
if [ ! -r id_rsa.pub ] ; then
    ssh-keygen -t rsa -b 2048 -N '' -C admin@${IMAGE} -f id_rsa
fi

echo "--- make cloud-init"
install -vdp ./cloud-init
echo "local-hostname: ${IMAGE}" > ./cloud-init/meta-data
cat > ./cloud-init/user-data << EOF
#cloud-config
users:
  - name: root
    plain_text_passwd: ""
    lock_passwd: false
  - name: admin
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - $(cat id_rsa.pub)
EOF
genisoimage -output seed.img -volid cidata -rational-rock -joliet -input-charset utf-8 cloud-init

echo "--- run qemu"
declare -A efi_bios=(["x86_64"]="/usr/share/ovmf/OVMF.fd" ["aarch64"]="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd")
qemu-system-$HOSTTYPE -accel kvm -machine virt -cpu host -m 2G \
    -bios ${efi_bios[$HOSTTYPE]} \
    -drive if=virtio,file=drive.qcow2,format=qcow2 \
    -drive if=virtio,file=seed.img,format=raw,media=cdrom \
    -nic user,model=virtio-net-pci,hostfwd=tcp::8022-:22 \
    -nographic
