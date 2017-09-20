#!/bin/bash
#################################################
# Deletes the concourse deployment.
#################################################

set -x
set -e

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$BOSH_ADMIN_PASSWORD
export BOSH_ENVIRONMENT="concourse-director"

echo "$BOSH_CA" > boshca.pem

bosh2 alias-env $BOSH_ENVIRONMENT -e $BOSH_DIRECTOR --ca-cert boshca.pem

bosh2 -n delete-deployment -d concourse