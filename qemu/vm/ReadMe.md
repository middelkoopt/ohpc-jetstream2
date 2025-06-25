# QEMU Cluster

## Build

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
