# Create Concourse
Creates a BOSH deployed Concourse environment.

References:<br>
https://github.com/pivotalservices/concourse-pipeline-samples/tree/master/concourse-pipeline-patterns/vault-integration

## Github Authentication
To modify the concourse_stub.yml to use github authentication:

bosh interpolate concourse_stub.yml -o github-auth-patch.yml > concourse_stub_github.yml

This will generate a new yml file that can be used for the bosh deploy commmand
