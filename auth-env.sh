#!/bin/bash
## Source secure envrionment variables from pass
CLOUD_AUTH=${1:-jetstream}
echo "=== openstack auth-env.sh ${CLOUD_AUTH}"
source <(pass cloud/${CLOUD_AUTH}.env)
export OS_NAME OS_AUTH_URL OS_AUTH_TYPE OS_APPLICATION_CREDENTIAL_ID OS_APPLICATION_CREDENTIAL_SECRET OS_REGION_NAME
