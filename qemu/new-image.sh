#!/bin/bash
set -e

: ${ARCH:=$(uname -m)}
: ${DIST:=rockylinux}
: ${VERSION:=9}
: ${DEST:=./images}

echo "=== download-image.sh ${DIST} ${VERSION} ${ARCH} ${DEST}"

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

## Download and overwrite head.qcow2
IMAGE_FILE="${DEST}/${IMAGE_URL##*/}"
if [ ! -r "${IMAGE_FILE}" ]; then
  install -vdp ${DEST}
  wget "${IMAGE_URL}" -P "${DEST}"
fi
cp -v "${IMAGE_FILE}" "head.qcow2"
