#!/bin/bash
#############################################################
#
#  Creates a bosh2 Concourse deployment.
#  Assumes that following environment variables are set
#       export BOSH_CLIENT=admin
#       export BOSH_CLIENT_SECRET=`bosh2 int creds.yml --path /admin_password`
#       export BOSH_ENVIRONMENT=bootstrap
#  Optional integrations with github for authentciation and vault.
#  This script expects the bosh2 director to be targeted.
#
#   Arguments:
#       -i <ip addresss> Concourse Fully Qualified Domain Name / IP
#       -u <url> External Concourse URL
#       --iaas <iaas> iaas to use vsphere/aws/azure/google, default to vsphere - required to download stemcell
#       --tsa-signing-key - tsa signing key
#       --host-private-key - host private key
#       --host-public-key - host public key
#       --worker-private-key - worker private key
#       --worker-public-key - worker public key

#
#   Optional Arguments:
#       -d <directory> Directory to house the files related to a given deployment, will default to "deployment"
#       -p <password> basic auth password, will default to "admin" if not specified
#       -n <name> deployment name, will default to "concourse"
#       --manifest <manifest> manifest file name, will default to concourse_stub.yml
#
#
#       -v <vault integration> true/false defaults to false
#       -a <address> Vault Address
#       -r <token> Vault root token
#
#       -g <github integration> true/false, defaults to false
#       -c <client_id> github client id
#       -s <client_secret> github client secret
#       -o <org> github org
#       -t <team> github team, will default to "all"
#
#       --web-public-ip - optional, default value parsed from value of "-u" option
#############################################################

set -e

function usage() {
cat <<EOF
USAGE:
   deploy_concourse.sh -i <ip addresss/fqdn> -u <concourse url> [-d <deployment directory>] \
[-n <deployment name>] [-p <concourse admin password>] [-v <vault integration true/false> \
-a <vault address> -r <vault root token] [-g <github integration true/false> \
-c <github client id> -s <github client secret> -o <github org> [-t <github team>]] \
 --iaas <iaas> --tsa-signing-key <tsa-signing-key-file> --manifest <manifest-file> \
 --host-private-key <host-private-key-file> --host-public-key <host-public-key-file> \
 --worker-private-key <worker-private-key-file> --worker-public-key <worker-public-key-file> \
 --web-public-ip <--web-public-ip>

EOF
}

CONCOURSE_FQDN=""
CONCOURSE_EXTERNAL_URL=""
CONCOURSE_PASSWORD="admin"

# directory where files related to this deployment will go.
DEPLOYMENT_DIR="deployment"

#vault integration
VAULT_INTEGRATION=false
VAULT_ADDR=""
VAULT_ROOT_TOKEN=""

#github integariton
GITHUB_INTEGRATION=false
GITHUB_CLIENT_ID=""
GITHUB_CLIENT_SECRET=""
GITHUB_ORG=""
GITHUB_TEAM="all" #default to all

MANIFEST="concourse_stub.yml"
DEPLOYMENT_NAME="concourse"
IAAS=vsphere

# Parse the command argument list
# while getopts "h:i:u:d:v:a:r:g:c:s:o:t:n:p:" opt; do
#     case "$opt" in
#     h|\?)
#         usage
#         exit 0
#         ;;
#     i)
#         CONCOURSE_FQDN=$OPTARG
#         ;;
#     u)
#         CONCOURSE_EXTERNAL_URL=$OPTARG
#         ;;
#     d)
#         DEPLOYMENT_DIR=$OPTARG
#         ;;
#     p)
#         CONCOURSE_PASSWORD=$OPTARG
#         ;;
#     n)
#         DEPLOYMENT_NAME=$OPTARG
#         ;;
#     v)
#         if [ $OPTARG = true ] || [ $OPTARG = false ]; then
#           VAULT_INTEGRATION=$OPTARG
#         else
#           echo "Unknown value for -v: $OPTARG.  Options are true/false"
#           exit 1
#         fi
#         ;;
#     a)
#         VAULT_ADDR=$OPTARG
#         ;;
#     r)
#         VAULT_ROOT_TOKEN=$OPTARG
#         ;;
#     g)
#         if [ $OPTARG = true ] || [ $OPTARG = false ]; then
#           GITHUB_INTEGRATION=$OPTARG
#         else
#           echo "Unknown value for -v: $OPTARG.  Options are true/false"
#           exit 1
#         fi
#         ;;
#     c)
#         GITHUB_CLIENT_ID=$OPTARG
#         ;;
#     s)
#         GITHUB_CLIENT_SECRET=$OPTARG
#         ;;
#     o)
#         GITHUB_ORG=$OPTARG
#         ;;
#     t)
#         GITHUB_TEAM=$OPTARG
#         ;;
#     *)
#         echo "Unknown argument - $opt"
#         #usage
#         #exit 1
#         ;;
#     esac
# done

n=0;
for arg in $*; do
   (( n++ ))
   m=$(( n+1 ))
   if [[ $arg == "-h" ]]; then
      usage
      exit 0
   elif [[ $arg == "-i" ]]; then
      CONCOURSE_FQDN=${!m}
   elif [[ $arg == "-u" ]]; then
      CONCOURSE_EXTERNAL_URL=${!m}
   elif [[ $arg == "-d" ]]; then
      DEPLOYMENT_DIR=${!m}
   elif [[ $arg == "-p" ]]; then
      CONCOURSE_PASSWORD=${!m}
   elif [[ $arg == "-n" ]]; then
      DEPLOYMENT_NAME=${!m}
   elif [[ $arg == "-v" ]]; then
      if [ ${!m} = true ] || [ ${!m} = false ]; then
         VAULT_INTEGRATION=${!m}
      else
         echo "Unknown value for -v: ${!m}.  Options are true/false"
         exit 1
      fi
   elif [[ $arg == "-a" ]]; then
      VAULT_ADDR=${!m}
   elif [[ $arg == "-r" ]]; then
      VAULT_ROOT_TOKEN=${!m}
   elif [[ $arg == "-g" ]]; then
      if [ ${!m} = true ] || [ ${!m} = false ]; then
         GITHUB_INTEGRATION=${!m}
      else
         echo "Unknown value for -v: ${!m}.  Options are true/false"
         exit 1
      fi
   elif [[ $arg == "-c" ]]; then
      GITHUB_CLIENT_ID=${!m}
   elif [[ $arg == "-s" ]]; then
      GITHUB_CLIENT_SECRET=${!m}
   elif [[ $arg == "-o" ]]; then
      GITHUB_ORG=${!m}
   elif [[ $arg == "-t" ]]; then
      GITHUB_TEAM=${!m}
   elif [[ $arg == "--tsa-signing-key" ]]; then
      TSA_SIGNING_KEY=${!m}
   elif [[ $arg == "--iaas" ]]; then
      IAAS=${!m}
   elif [[ $arg == "--manifest" ]]; then
      MANIFEST=${!m}
   elif [[ $arg == "--host-private-key" ]]; then
      HOST_PRIVATE_KEY=${!m}
   elif [[ $arg == "--host-public-key" ]]; then
      HOST_PUBLIC_KEY=${!m}
   elif [[ $arg == "--worker-private-key" ]]; then
      WORKER_PRIVATE_KEY=${!m}
   elif [[ $arg == "--worker-public-key" ]]; then
      WORKER_PUBLIC_KEY=${!m}
   elif [[ $arg == "--web-public-ip" ]]; then
      WEB_PUBLIC_IP=${!m}
   fi
done
# if web-public-ip is not provided, parse it from "-u"
if [ ! -z $WEB_PUBLIC_IP ]; then
   # set WEB_PUBLIC_IP - to assign public ips to public clouds (aws)
   arr=(${CONCOURSE_EXTERNAL_URL//\/\// }) # split with "\\" as delimiter
   arr1=(${arr[1]//:/ }) # split with ":" as delimiter
   WEB_PUBLIC_IP=${arr1[0]}
fi


CONCOURSE_RELEASE=https://bosh.io/d/github.com/concourse/concourse
GARDEN_RUNC_RELEASE=https://bosh.io/d/github.com/cloudfoundry/garden-runc-release
POSTGRES_RELEASE=http://bosh.io/d/github.com/cloudfoundry/postgres-release
if [ $IAAS == "vsphere" ]; then
   STEMCELL=https://bosh.io/d/stemcells/bosh-vsphere-esxi-ubuntu-trusty-go_agent
elif [ $IAAS == "aws" ]; then
   STEMCELL=https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent
elif [ $IAAS == "azure" ]; then
   STEMCELL=https://bosh.io/d/stemcells/bosh-azure-hyperv-ubuntu-trusty-go_agent
elif [ $IAAS == "azure" ]; then
   STEMCELL=https://bosh.io/d/stemcells/bosh-google-kvm-ubuntu-trusty-go_agent
fi
mkdir -p $DEPLOYMENT_DIR
# Upload the releases and stemcell needed for the deployment.
echo $STEMCELL
bosh2 ur $CONCOURSE_RELEASE
bosh2 ur $POSTGRES_RELEASE
bosh2 ur $GARDEN_RUNC_RELEASE
bosh2 us $STEMCELL
DEPLOY_ARGS=""

# Configure Vault
if [ $VAULT_INTEGRATION = true ]; then
  echo "Setting up intergation with vault at $VAULT_ADDR"
  export VAULT_ADDR=$VAULT_ADDR
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

  bosh2 interpolate $MANIFEST -o operations/vault-patch.yml > $DEPLOYMENT_DIR/concourse_stub_vault.yml
  MANIFEST=$DEPLOYMENT_DIR/concourse_stub_vault.yml

  DEPLOY_ARGS="$DEPLOY_ARGS -v vault-url=$VAULT_ADDR -v vault-token=$VAULT_ROOT_TOKEN"
fi

#Configure github authentication
if [ $GITHUB_INTEGRATION = true ]; then
  echo "Setting up authentication with github org $GITHUB_ORG and team $GITHUB_TEAM"

  bosh2 interpolate $MANIFEST -o operations/github-auth-patch.yml > $DEPLOYMENT_DIR/concourse_stub_github.yml
  DEPLOY_ARGS="$DEPLOY_ARGS -v github_organization=$GITHUB_ORG -v github_team=$GITHUB_TEAM \
              -v github_client_id=$GITHUB_CLIENT_ID -v github_client_secret=$GITHUB_CLIENT_SECRET"
  MANIFEST="$DEPLOYMENT_DIR/concourse_stub_github.yml"
else
  echo "Using basic authentication"

  DEPLOY_ARGS="$DEPLOY_ARGS -v concourse_admin_password=$CONCOURSE_PASSWORD"
fi
echo "manifest = $MANIFEST"
# Deploy concourse
bosh2 -n -d $DEPLOYMENT_NAME deploy $MANIFEST --vars-store=$DEPLOYMENT_DIR/vars.yml \
      -v deployment_name=$DEPLOYMENT_NAME -v internal_ip=$CONCOURSE_FQDN \
      -v external_url=$CONCOURSE_EXTERNAL_URL $DEPLOY_ARGS --var-file token_signing_key=$TSA_SIGNING_KEY \
      --var-file host_private_key=$HOST_PRIVATE_KEY \
      --var-file host_public_key=$HOST_PUBLIC_KEY \
      --var-file worker_private_key=$WORKER_PRIVATE_KEY \
      --var-file worker_public_key=$WORKER_PUBLIC_KEY \
      -v web_public_ip=$WEB_PUBLIC_IP
