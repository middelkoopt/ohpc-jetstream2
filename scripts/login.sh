#!/bin/bash

CLOUD_NAME=${1:-jetstream}
CLOUD_CONFIG=${2:-clouds.yaml}
CLOUD_AUTH=${3:-cloud/${CLOUD_NAME}.env}

echo "=== login.sh openstack ${CLOUD_NAME} ${CLOUD_CONFIG} ${CLOUD_AUTH}"

tee <<EOF | pass insert -m ${CLOUD_AUTH}
OS_NAME=${CLOUD_NAME}
OS_AUTH_URL=$(yq .clouds.openstack.auth.auth_url < ${CLOUD_CONFIG})
OS_AUTH_TYPE=v3applicationcredential
OS_APPLICATION_CREDENTIAL_ID=$(yq .clouds.openstack.auth.application_credential_id < ${CLOUD_CONFIG})
OS_APPLICATION_CREDENTIAL_SECRET=$(yq .clouds.openstack.auth.application_credential_secret < ${CLOUD_CONFIG})
EOF
