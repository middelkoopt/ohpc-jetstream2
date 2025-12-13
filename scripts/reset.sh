#!/bin/bash

echo "=== reset.sh"
if [ -x $OS_NAME/reset.sh ] ; then
  ( cd $OS_NAME && ./reset.sh )
fi
