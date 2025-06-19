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
  - name: root
    plain_text_passwd: ""
    lock_passwd: false
  - name: admin
    groups: sudo
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    ssh_authorized_keys:
      - $(cat ./id_rsa.pub)
EOF
mkisofs -output ./seed.img -volid cidata -rational-rock -joliet -input-charset utf-8 ./cloud-init
