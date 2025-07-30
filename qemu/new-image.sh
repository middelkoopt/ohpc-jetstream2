#!/bin/bash
set -e

DIST=${1:-rockylinux}
VERSION=${2:-10}
: ${ARCH:=$(uname -m)}
: ${DEST:=./images}
: ${IMAGE_NAME:=head}
: ${IMAGE_SIZE:=40G}

echo "=== new-image.sh ${DIST} ${VERSION} ${ARCH} ${DEST} ${IMAGE_NAME} ${IMAGE_SIZE}"

case "$ARCH" in
    x86_64|amd64)
        ARCH="x86_64"
        ;;
    aarch64|arm64)
        ARCH="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

case "$DIST" in
    rockylinux|rocky)
        IMAGE_URL="https://dl.rockylinux.org/pub/rocky/${VERSION}/images/${ARCH}/Rocky-${VERSION}-GenericCloud-Base.latest.${ARCH}.qcow2"
        ;;
    almalinux|alma)
        IMAGE_URL="https://repo.almalinux.org/almalinux/${VERSION}/cloud/${ARCH}/images/AlmaLinux-${VERSION}-GenericCloud-latest.${ARCH}.qcow2"
        ;;
    *)
        echo "Unsupported DIST: $DIST"
        exit 1
        ;;
esac

IMAGE_FILE="${DEST}/${IMAGE_URL##*/}"
echo "--- Download ${IMAGE_FILE} to ${DEST} if needed"
if [ ! -r "${IMAGE_FILE}" ]; then
  install -vdp ${DEST}
  wget "${IMAGE_URL}" -P "${DEST}"
fi

echo "--- Remove ${IMAGE_NAME}.qcow2"
rm -fv ${IMAGE_NAME}.qcow2

echo "--- Copy ${IMAGE_FILE} to ${IMAGE_NAME}.qcow2"
cp -v "${IMAGE_FILE}" "${IMAGE_NAME}.qcow2"

echo "--- Resize to ${IMAGE_SIZE}"
qemu-img resize "${IMAGE_NAME}.qcow2" ${IMAGE_SIZE}

