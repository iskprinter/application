# iskprinter/helm

The helm chart for all IskPrinter components

![Build Status](https://iskprinter.com/jenkins/buildStatus/icon?job=helm%2Fmain)

## How to use

Install/upgrade the helm chart using the `deploy.sh` script.
```
./deploy.sh \
    --client-id=<client-id> \
    --client-secret=<client-secret> \
    --host=<host> \
    --mongo-initdb-root-password=<mongo-initdb-root-password> \
    [--kube-context=<kube-context>] \
    [--dry-run]
```
Example values for local deployment:
* `--client-id='some-client-id'`
* `--client-secret='some-client-secret'`
* `--host='localhost'`
* `--mongo-initdb-root-password='some-password'`
* `--kube-context='docker-desktop'`

Example values for production deployment can be found in the `Jenkinsfile` in this repo.
