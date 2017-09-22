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

# Vault has a self-signed cert, so skip verification
export VAULT_SKIP_VERIFY=true

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$BOSH_ADMIN_PASSWORD
export BOSH_ENVIRONMENT="concourse-director"

echo "$BOSH_CA" > boshca.pem

bosh2 alias-env $BOSH_ENVIRONMENT -e $BOSH_DIRECTOR --ca-cert boshca.pem
   
cd create-concourse

./deploy_concourse.sh \
  172.28.98.52 \
  https://172.28.98.52 \
  https://172.28.98.51:8200 \
  $VAULT_ROOT_TOKEN \
  ./deployment_files

# Sometimes it takes a few tries until concourse is fully booted.
set +e 
fly -t concourse-test login -c https://172.28.98.52 -k -u admin -p admin
while [ $? -ne 0 ]; do fly -t concourse-test login -c https://172.28.98.52 -k -u admin -p admin; done
set -e 

fly -t concourse-test sync

# set the test pipeline and trigger it.

fly -t concourse-test set-pipeline -n -p test-concourse-vault-int -c ./ci/test-pipeline/pipeline.yml 
fly -t concourse-test unpause-pipeline -p test-concourse-vault-int
fly -t concourse-test trigger-job -j test-concourse-vault-int/test-concourse-vault -w 

# Use the exit status of the last fly command. If the job succeeded, the test was a success.
exit $?