#!/bin/bash
#########################################################
#
#  Test the script that creates a Concourse BOSH deployment
#  functions as expected.
#
#########################################################

# Exit if a command fails.
set -e 

# Print commands executed.
set -x

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$BOSH_ADMIN_PASSWORD
export BOSH_ENVIRONMENT="concourse-director"

echo "$BOSH_CA" > boshca.pem

bosh2 alias-env $BOSH_ENVIRONMENT -e $BOSH_DIRECTOR --ca-cert boshca.pem
   
cd create-concourse

./deploy_concourse.sh 172.28.98.52 https://172.28.98.52 admin

sleep 3
fly -t concourse-test login -c https://172.28.98.52 -k -u admin -p admin