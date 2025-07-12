#!/bin/bash

echo "=== snapshot.sh"

IMAGE=$(openstack server show head --format=json | jq -r .image)
IMAGE_NAME=${IMAGE%% \(*}

# Remove "Snapshot" or "Base" from the end of the title
IMAGE_BASE=${IMAGE_NAME%%-Snapshot}
IMAGE_BASE=${IMAGE_BASE%%-Base}

# Extract the UUID part (everything between the parentheses)
IMAGE_UUID=${IMAGE#*\(}
IMAGE_UUID=${IMAGE_UUID%\)*}

echo "--- IMAGE: $IMAGE_BASE IMAGE_UUID: $IMAGE_UUID"
. ./get-env.sh

echo "--- wait for head $OHPC_HEAD"
while ! ssh $OHPC_USER@$OHPC_HEAD hostname ; do echo -n . ; sleep .2 ; done
echo done

echo "--- update"
ssh $OHPC_USER@$OHPC_HEAD sudo dnf update -y
ssh $OHPC_USER@$OHPC_HEAD sudo systemctl poweroff

echo "--- stop vm"
openstack server stop head
while [ "$(openstack server show head -f value -c status)" != "SHUTOFF" ]; do
  echo -n .
done
echo done

echo "--- create snapshot"
openstack server image create --name ${IMAGE_BASE}-Snapshot head

if [[ ${IMAGE_NAME} == "${IMAGE_BASE}-Snapshot" ]] ; then
  echo "--- deleting old image"
  openstack server delete head --wait
  openstack image delete ${IMAGE_UUID}
fi
