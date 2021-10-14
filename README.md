# iskprinter/helm

The helm chart for all IskPrinter components

![Build Status](https://iskprinter.com/jenkins/buildStatus/icon?job=helm%2Fmain)

## How to use

Deploy using helm. Example parameters are below

helm upgrade --install "$RELEASE_NAME" ./helm \
    --kube-context "$KUBE_CONTEXT" \
    -n "$NAMESPACE" \
    --set "api.clientId=${API_CLIENT_ID}" \
    --set "api.clientSecret=${API_CLIENT_SECRET}" \
    --set "mongodb.url=mongodb+srv://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@${MONGODB_HOSTNAME}/?ssl=false"
    --set 'hostname=iskprinter.com' \
    [--dry-run]
