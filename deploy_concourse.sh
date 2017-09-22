#!/bin/bash
#############################################################
#
#  Creates a BOSH Concourse deployment integrated with Vault.
#  This script expects the bosh director to be targeted.
#  A "generated" directory is created under the current
#  directory to house the creds generated during deployment.
#
#   Arguments:
#       1 - Concourse Fully Qualified Domain Name / IP
#       2 - External Concourse URL
#       3 - Vault Address
#       4 - Vault root token
#       5 - Directory to house the files related to a given deployment.
#
#############################################################

set -e 
set -x 

CONCOURSE_FQDN=$1
CONCOURSE_EXTERNAL_URL=$2

# this is used by the vault cli to point at the correct vault.
export VAULT_ADDR=$3
VAULT_ROOT_TOKEN=$4

# directory where files related to this deployment will go.
DEPLOYMENT_DIR=$5

DEPLOYMENT_NAME=concourse_vault
CONCOURSE_RELEASE=https://bosh.io/d/github.com/concourse/concourse
GARDEN_RUNC_RELEASE=https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
STEMCELL=https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent

mkdir -p $DEPLOYMENT_DIR

# Configure Vault
vault auth $VAULT_ROOT_TOKEN

# turn off failing if command fails. /concourse may already be mounted. Not a big
# deal if it is, we just need to make sure it exists. This command fails if it is
# already mounted.
set +e
vault mount -path=/concourse -description="Secrets for concourse pipelines" generic
set -e

vault policy-write policy-concourse policy.hcl
TOKEN_CREATE_JSON=`vault token-create --policy=policy-concourse -period="600h" -format=json`
CLIENT_TOKEN=`echo $TOKEN_CREATE_JSON | jq -r .auth.client_token`

# Upload the releases and stemcell needed for the deployment.
bosh2 ur $CONCOURSE_RELEASE
bosh2 ur $GARDEN_RUNC_RELEASE
bosh2 us $STEMCELL

# Deploy concourse
bosh2 -n -d concourse deploy concourse_stub.yml \
  --vars-store=$DEPLOYMENT_DIR/vars.yml \
  -v internal_ip=$CONCOURSE_FQDN \
  -v external_url=$CONCOURSE_EXTERNAL_URL \
  -v concourse_admin_password=admin \
  -v vault-url=$VAULT_ADDR \
  -v vault-token=$CLIENT_TOKEN

