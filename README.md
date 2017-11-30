# Create Concourse
Creates a BOSH deployed Concourse environment.

## Requirements

bosh2 on PATH and already targeted to bosh director
vault on PATH (if vault integration)

## Usage

### Basic Auth
Deploy concourse with basic authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts]
```
deployment-name defaults to "concourse"
concourse-basic-auth-password defaults to "admin"
directory-for-deployment-artifacts defaults to "deployment"

### Vault Integration
Deploy concourse with vault integration
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -v true -a vault-url -r vault-root-token
```
A new manifest stub will be created at [directory-for-deployment-artifacts]/concourse_stub_vault.yml

### Github Authentication Integration
Deploy concourse with github authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -g true -c github-client-id -s github-client-secret -o github-org [-t github-team]
```
A new manifest stub will be created at [directory-for-deployment-artifacts ]/concourse_stub_github.yml

github-team defaults to "all"

### Vault and Github Integrations
Deploy concourse with vault and github authentication
```
./deploy_concourse.sh -i concourse-ip -u concourse-url [-n deployment-name] [-p concourse-basic-auth-password] [-d directory-for-deployment-artifacts] -v true -a vault-url -r vault-root-token -g true -c github-client-id -s github-client-secret -o github-org [-t github-team]
```
A new manifest stub will be created at [directory-for-deployment-artifacts]/concourse_stub_vault.yml
