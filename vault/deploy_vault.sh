#!/bin/bash

set -e 
set -x 

VAULT_FQDN=$1
GENERATED_DIR=./generated
DEPLOYMENT_NAME=vault_ssl
VAULT_RELEASE=https://bosh.io/d/github.com/cloudfoundry-community/vault-boshrelease
STEMCELL=https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent

VAULT_KEYS=$GENERATED_DIR/vault_keys

mkdir -p $GENERATED_DIR

bosh ur $VAULT_RELEASE
bosh us $STEMCELL
bosh -n -d concourse-vault deploy vault/vault_manifest_template.yml \
  --vars-store=$GENERATED_DIR/vars.yml \
  -v internal_ip=$VAULT_FQDN

export VAULT_ADDR="https://$VAULT_FQDN:8200"

# If vault has not been initialized, initial it.
# "-check" Don't actually initialize, just check if Vault is
# already initialized. A return code of 0 means Vault
# is initialized; a return code of 2 means Vault is not
# initialized; a return code of 1 means an error was
# encountered.

set +e
vault init -check -tls-skip-verify
VAULT_INITIALIZED=$?
set -e

if [[ $VAULT_INITIALIZED == 0 ]]; then
  echo "Vault already initialized"
  exit 0
elif [[ $VAULT_INITIALIZED == 2 ]]; then
  echo "Initializing vault"
  vault init -tls-skip-verify > $VAULT_KEYS

  # unseal vault. This requires unsealing with 3 keys.
  NUM_KEYS_READ=0
  while read KEY_LINE; do
    key=`echo $KEY_LINE | cut -d' ' -f4`
    vault unseal $key
    NUM_KEYS_READ=`expr $NUM_KEYS_READ + 1`
    if [[ NUM_KEYS_READ -eq 3 ]]; then
      break;
    fi
  done < $VAULT_KEYS

  ROOT_KEY=`grep "Root" $VAULT_KEYS | cut -d' ' -f4`
  vault auth $ROOT_KEY
else
  echo "Vault command error."
  exit $VAULT_INITIALIZED
fi