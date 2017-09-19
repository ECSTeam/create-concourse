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
#       3 - Admin password
#
#############################################################

set -e 
set -x 

CONCOURSE_FQDN=$1
CONCOURSE_EXTERNAL_URL=$2
GENERATED_DIR=./generated
DEPLOYMENT_NAME=concourse_vault
CONCOURSE_RELEASE=https://bosh.io/d/github.com/concourse/concourse
GARDEN_RUNC_RELEASE=https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
STEMCELL=https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent

mkdir -p $GENERATED_DIR

bosh2 ur $CONCOURSE_RELEASE
bosh2 ur $GARDEN_RUNC_RELEASE
bosh2 us $STEMCELL
# Deploy concourse
bosh2 -n -d concourse deploy concourse_stub.yml \
  --vars-store=$GENERATED_DIR/vars.yml \
  -v internal_ip=$CONCOURSE_FQDN \
  -v external_url=$CONCOURSE_EXTERNAL_URL \
  -v concourse_admin_password=admin

