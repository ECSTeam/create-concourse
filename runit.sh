#!/bin/bash

bosh int ./creds.yml --path /director_ssl/ca > boshca.pem

./deploy_concourse_vault.sh \
  `bosh int ./creds.yml --path /admin_password` \
  172.28.98.50 \
  boshca.pem \
  172.28.98.51 