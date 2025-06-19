#!/bin/bash
set -e

: ${ARCH:=$(uname -m)}
: ${DIST:=rockylinux}
: ${VERSION:=9}
: ${DEST:=/data}

echo "=== download-head.sh ${DIST} ${VERSION} ${ARCH} ${DEST}"

declare -A DISTRO_URLS=(
    [rockylinux]="https://dl.rockylinux.org/pub/rocky/${VERSION}/images/${ARCH}/Rocky-${VERSION}-GenericCloud-Base.latest.${ARCH}.qcow2"
    [almalinux]="https://repo.almalinux.org/almalinux/${VERSION}/cloud/${ARCH}/images/AlmaLinux-${VERSION}-GenericCloud-latest.${ARCH}.qcow2"
)

wget -c "${DISTRO_URLS[$DIST]}" -P "${DEST}"
cp -v "${DISTRO_URLS[$DIST]##*/}" "drive.qcow2"
