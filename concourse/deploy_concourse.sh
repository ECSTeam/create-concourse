#!/bin/bash

set -e 
set -x 

CONCOURSE_FQDN=REPLACE_ME
GENERATED_DIR=./generated
DEPLOYMENT_NAME=concourse_ssl
CONCOURSE_RELEASE=https://bosh.io/d/github.com/concourse/concourse
GARDEN_RUNC_RELEASE=https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
STEMCELL=https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent

mkdir -p $GENERATED_DIR

bosh-v2 interpolate ./generate_certs.yml -v internal_ip=$CONCOURSE_FQDN --vars-store $GENERATED_DIR/concourse_certs.yml

cat $GENERATED_DIR/concourse_certs.yml | yaml2json | jq -r ".$DEPLOYMENT_NAME.certificate" > $GENERATED_DIR/$DEPLOYMENT_NAME.crt
cat $GENERATED_DIR/concourse_certs.yml | yaml2json | jq -r ".$DEPLOYMENT_NAME.private_key" > $GENERATED_DIR/$DEPLOYMENT_NAME.pem

CONCOURSE_SSL_CERT=`sed 's/^/        /' $GENERATED_DIR/$DEPLOYMENT_NAME.crt`
CONCOURSE_SSL_KEY=`sed 's/^/        /' $GENERATED_DIR/$DEPLOYMENT_NAME.pem`

cat <<EOF > $GENERATED_DIR/concourse_certs_stub.yml
instance_groups:
- name: web
  jobs:
  - name: atc
    properties:
      tls_key: |
${CONCOURSE_SSL_KEY}
      tls_cert: |
${CONCOURSE_SSL_CERT}
EOF

spiff merge ./concourse_stub.yml $GENERATED_DIR/concourse_certs_stub.yml > $GENERATED_DIR/concourse.yml

bosh deployment $GENERATED_DIR/concourse.yml
bosh upload release $CONCOURSE_RELEASE
bosh upload release $GARDEN_RUNC_RELEASE
bosh upload stemcell $STEMCELL
bosh -n deploy

rm $GENERATED_DIR/$DEPLOYMENT_NAME.*
