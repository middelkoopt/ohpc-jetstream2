# QEMU Cluster

## Dependencies

Debian
```bash
sudo apt-get install --yes qemu-system ansible mkisofs
ansible-galaxy collection install community.general
```

## Standalone VM

Debian/Ubuntu
```bash
apt-get install --yes podman qemu-utils qemu-system-x86 qemu-system-arm ovmf dosfstools mkisofs 
```

Rocky/Alma
```bash
dnf install -y podman qemu-kvm edk2-aarch64
```

build
```bash
IMAGE=ohpc-qemu ./container/data/generate-seed.sh
./build.sh
```
