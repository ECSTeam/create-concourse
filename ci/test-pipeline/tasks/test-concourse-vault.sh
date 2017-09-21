#!/bin/bash

set -x
set -e 

echo "started $VAULT_RETRIEVED"

if [ "$VAULT_RETRIEVED" == "admin" ]; then
  # Successfully retrieved value from vault
  echo "Success"
  exit 0
fi

# Failed to retrieve expected value from vault.
echo "Failed"
exit 1