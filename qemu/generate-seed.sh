#!/bin/bash

: ${IMAGE:=head}

echo "=== generate-seed.sh ${IMAGE}"

echo "--- generate key"
if [ ! -r ./id_rsa.pub ] ; then
    ssh-keygen -t rsa -b 2048 -N '' -C admin@${IMAGE} -f ./id_rsa
fi

echo "--- make cloud-init"
install -vdp ./cloud-init
echo "local-hostname: ${IMAGE}" > ./cloud-init/meta-data
cat > ./cloud-init/user-data << EOF
#cloud-config
users:
  - name: admin
    plain_text_passwd: "admin"
    lock_passwd: false
    groups: sudo
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - $(cat ./id_rsa.pub)
EOF
cat > ./cloud-init/network-config << EOF
#cloud-config
network:
  version: 2
  ethernets:
    eth0:
      match:
        macaddress: "52:54:00:00:02:0f"
      dhcp4: true
      dhcp6: true
    eth1:
      match:
        macaddress: "52:54:00:05:00:08"
      addresses:
        - 10.5.0.8/16
        - fd00:5::8/64
EOF
mkisofs -output ./seed.img -volid cidata -rational-rock -joliet -input-charset utf-8 ./cloud-init
