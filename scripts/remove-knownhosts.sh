#!/bin/bash

echo "--- remove-knownhosts.sh ${OS_NAME}"

if [[ "$(tofu -chdir=${OS_NAME} show -json)" == '{"format_version":"1.0"}' ]] ; then
  echo "--- no know hosts to remove"
else
  if [[ -n "${OHPC_IP4}" ]] ; then
    ssh-keygen -R $OHPC_IP4
  fi

  if [[ -n "${OHPC_IP6}" ]] ; then
    ssh-keygen -R $OHPC_IP6
  fi

  if [[ -n "${OHPC_DNS}" ]] ; then
    ssh-keygen -R $OHPC_DNS
  fi

  if [[ -n "${OHPC_HEAD}" ]] ; then
    ssh-keygen -R $OHPC_HEAD
  fi
fi
