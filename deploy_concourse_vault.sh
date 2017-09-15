#!/bin/bash
#########################################################
#
#  Creates a Concourse deployment integrated with Vault.
#
#  Arguments:
#     1 - BOSH client
#     2 - BOSH client secret
#     3 - Director URL
#     4 - BOSH Certificate
#
#########################################################

set -e 
set -x 

export BOSH_ENVIRONMENT=bootstrap
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$1
export BOSH_DIRECTOR=$2
export BOSH_CERT=$3
export VAULT_IP=$4

# The vault deployment includes a self signed cert. 
# Consequently, we need to skip TLS verification. 
export VAULT_SKIP_VERIFY=true

# Set the BOSH environment.
bosh alias-env $BOSH_ENVIRONMENT -e $BOSH_DIRECTOR --ca-cert $3

# Vault needs to be deployed before Concourse due to the fact
# the Concourse deployment needs details about Vault.
vault/deploy_vault.sh $4 

# concourse/deploy_concourse.sh $6