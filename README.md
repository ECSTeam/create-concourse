# Create Concourse
Creates a BOSH deployed Concourse environment.

## Requirements

bosh2 on PATH and already targeted to bosh director<br>
vault on PATH (if vault integration)

## Usage

### Parameters

1. Arguments:  
..* -i [ip addresss] Concourse Fully Qualified Domain Name / IP  
..* -u [url] External Concourse URL  
..* --iaas [iaas] iaas to use vsphere/aws/azure/google, default to vsphere - required to download stemcell  
..* --tsa-signing-key  
..* --host-private-key  
..* --host-public-key  
..* --worker-private-key  
..* --worker-public-key  


2. Optional Arguments:  
..* -d [directory] Directory to house the files related to a given deployment, will default to "deployment"  
..* -p [password] basic auth password, will default to "admin" if not specified  
..* -n [name] deployment name, will default to "concourse"  
..* --manifest [manifest] manifest file name, will default to concourse_stub.yml  

..* -v [vault integration] true/false defaults to false  
..* -a [address] Vault Address  
..* -r [token] Vault root token  

..* -g [github integration] true/false, defaults to false  
..* -c [client_id] github client id  
..* -s [client_secret] github client secret  
..* -o [org] github org  
..* -t [team] github team, will default to "all"  

..* --web-public-ip - optional, default value parsed from value of "-u" option  

### Basic Auth
Deploy concourse with basic authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts]
```
deployment-name defaults to "concourse"<br>
concourse-basic-auth-password defaults to "admin"<br>
directory-for-deployment-artifacts defaults to "deployment"

### Vault Integration
Deploy concourse with vault integration
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -v true -a vault-url -r vault-root-token
```
A new manifest will be created at [directory-for-deployment-artifacts]/concourse_stub_vault.yml

### Github Authentication Integration
Deploy concourse with github authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -g true -c github-client-id -s github-client-secret -o github-org [-t github-team]
```
A new manifest will be created at [directory-for-deployment-artifacts ]/concourse_stub_github.yml<br>

github-team defaults to "all"

### Vault and Github Integrations
Deploy concourse with vault and github authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -v true -a vault-url -r vault-root-token -g true -c github-client-id -s github-client-secret -o github-org [-t github-team]
```
A new manifest will be created at [directory-for-deployment-artifacts]/concourse_stub_vault.yml
### Example AWS deployment for concourse version 3.8.0
```
./deploy_concourse.sh -i concourse-ip -u concourse-url --iaas aws --manifest "concourse_stub-aws.yml" --tsa-signing-key deployment/keys/token_signing_key --host-private-key deployment/keys/host_key --host-public-key deployment/keys/host_key.pub --worker-private-key deployment/keys/worker_key --worker-public-key deployment/keys/worker_key.pub --web-public-ip public-ip
```
