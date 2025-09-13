#!/bin/bash

echo "=== reset.sh"

QMP='{ "execute": "qmp_capabilities", "arguments": { "enable": ["oob"] } }'

for I in *.sock ; do
  echo "--- reset ${I%%.sock}"
  echo '{"execute":"qmp_capabilities"}{"execute":"system_reset"}' | nc -U $I
done
